import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kai_engine/kai_engine.dart';
import 'package:kai_engine_firebase_ai/kai_engine_firebase_ai.dart';
import 'package:synchronized/synchronized.dart';

part 'generation_service.freezed.dart';

@freezed
sealed class GenerativeConfig with _$GenerativeConfig {
  const GenerativeConfig._();

  const factory GenerativeConfig({
    required String model,
    List<SafetySetting>? safetySettings,
    GenerationConfig? generationConfig,
    List<FirebaseAiToolSchema>? toolSchemas,
    ToolConfig? toolConfig,
    String? systemPrompt,
  }) = _GenerativeConfig;
}

class FirebaseAiGenerationService implements GenerationServiceBase {
  final GenerativeMessageAdapterBase<Content> _messageAdapter;
  final GenerativeConfig _config;
  final FirebaseAI _firebaseAi;
  final _generationLock = Lock();
  GenerativeModel? _model;

  FirebaseAiGenerationService({
    required FirebaseAI firebaseAi,
    required GenerativeConfig config,
    GenerativeMessageAdapterBase<Content> messageAdapter = const FirebaseAiContentAdapter(),
  }) : _firebaseAi = firebaseAi,
       _messageAdapter = messageAdapter,
       _config = config;

  GenerativeModel _effectiveGenerativeModel(IList<CoreMessage> messages) {
    final firstSystemMessage = messages.firstWhereOrNull((m) => m.type == CoreMessageType.system);
    final effectiveSystemPrompt = firstSystemMessage?.content ?? _config.systemPrompt;

    if (_model == null ||
        (firstSystemMessage != null && firstSystemMessage.content != _config.systemPrompt) ||
        (firstSystemMessage == null && _config.systemPrompt != null)) {
      _model = _firebaseAi.generativeModel(
        model: _config.model,
        safetySettings: _config.safetySettings,
        generationConfig: _config.generationConfig,
        toolConfig: _config.toolConfig,
        tools: _config.toolSchemas?.toFirebaseAiTools(),
        systemInstruction: effectiveSystemPrompt != null
            ? Content.system(effectiveSystemPrompt)
            : null,
      );
    }

    return _model!;
  }

  IList<CoreMessage> _filterSystemMessages(IList<CoreMessage> messages) {
    bool foundFirstSystem = false;
    return messages.where((message) {
      if (message.type == CoreMessageType.system) {
        if (!foundFirstSystem) {
          foundFirstSystem = true;
          return false; // Skip the first system message
        }
        return true; // Keep subsequent system messages
      }
      return true; // Keep all non-system messages
    }).toIList();
  }

  @override
  Future<int> countToken(IList<CoreMessage> prompts) async {
    try {
      final filteredPrompts = _filterSystemMessages(prompts);
      final content = filteredPrompts.map(_messageAdapter.fromCoreMessage).toList();
      final response = await _effectiveGenerativeModel(prompts).countTokens(content);
      return response.totalTokens;
    } catch (e) {
      throw Exception('Failed to count tokens: $e');
    }
  }

  @override
  Future<String> invoke(IList<CoreMessage> prompts) async {
    return await _generationLock.synchronized(() async {
      try {
        final filteredPrompts = _filterSystemMessages(prompts);
        final content = filteredPrompts.map(_messageAdapter.fromCoreMessage).toList();
        final response = await _effectiveGenerativeModel(prompts).generateContent(content);

        if (response.text case final text?) {
          return text;
        }

        throw Exception('No text response generated');
      } catch (e) {
        throw Exception('Invocation failed: $e');
      }
    });
  }

  /// Aggregates streaming content chunks into a single Content object
  Content _aggregateContent(List<Content> contents) {
    if (contents.isEmpty) {
      throw ArgumentError('Cannot aggregate empty content list');
    }

    final role = contents.first.role ?? 'model';
    final parts = <Part>[];
    final textBuffer = StringBuffer();

    void flushTextBuffer() {
      if (textBuffer.isNotEmpty) {
        parts.add(TextPart(textBuffer.toString()));
        textBuffer.clear();
      }
    }

    for (final content in contents) {
      for (final part in content.parts) {
        if (part case TextPart(:final text)) {
          textBuffer.write(text);
        } else {
          flushTextBuffer();
          parts.add(part);
        }
      }
    }

    flushTextBuffer();
    return Content(role, parts);
  }

  @override
  Stream<GenerationState<GenerationResult>> stream(
    IList<CoreMessage> prompts, {
    CancelToken? cancelToken,
    List<ToolSchema> tools = const [],
    Map<String, dynamic>? config,
  }) async* {
    yield const GenerationState.loading();

    try {
      yield* await _generationLock.synchronized(() async {
        return _generateStream(prompts, cancelToken: cancelToken, tools: tools, config: config);
      });
    } catch (e, stackTrace) {
      yield GenerationState.error(KaiException.exception(e.toString(), stackTrace));
    }
  }

  Stream<GenerationState<GenerationResult>> _generateStream(
    IList<CoreMessage> prompts, {
    CancelToken? cancelToken,
    List<ToolSchema> tools = const [],
    Map<String, dynamic>? config,
  }) async* {
    final filteredPrompts = _filterSystemMessages(prompts);
    var conversationHistory = filteredPrompts.map(_messageAdapter.fromCoreMessage).toList();

    // Track the starting point to know what's newly generated
    final initialHistoryLength = conversationHistory.length;

    var totalInputTokens = 0;
    var totalOutputTokens = 0;
    var apiCallCount = 0;

    while (true) {
      if (cancelToken?.isCancelled == true) {
        yield GenerationState.error(KaiException.cancelled());
        return;
      }

      apiCallCount++;
      final model = _effectiveGenerativeModel(prompts);
      final stream = model.generateContentStream(
        conversationHistory,
        tools: _effectiveTools(tools).toFirebaseAiTools(),
        generationConfig: config?['generationConfig'],
        toolConfig: config?['toolConfig'],
      );

      final accumulatedText = StringBuffer();
      final contentParts = <Content>[];
      GenerateContentResponse? lastResponse;

      await for (final chunk in stream) {
        // Check for cancellation during streaming
        if (cancelToken?.isCancelled == true) {
          yield const GenerationState.error(KaiException.cancelled());
          return;
        }

        lastResponse = chunk;

        // Accumulate text for progressive updates
        if (chunk.text != null && chunk.text!.isNotEmpty) {
          accumulatedText.write(chunk.text);
          yield GenerationState.streamingText(accumulatedText.toString());
        }

        // Collect content for final result
        if (chunk.candidates case [final candidate, ...]) {
          contentParts.add(candidate.content);
        }
      }

      // Handle empty response
      if (contentParts.isEmpty || lastResponse == null) {
        yield const GenerationState.error(KaiException.noResponse());
        return;
      }

      final usage = lastResponse.usageMetadata;
      if (usage != null) {
        totalInputTokens += usage.promptTokenCount ?? 0;
        totalOutputTokens += usage.candidatesTokenCount ?? 0;
      }

      // Aggregate final content
      final modelContent = _aggregateContent(contentParts);
      final functionCalls = modelContent.parts.whereType<FunctionCall>().toList();
      conversationHistory.add(modelContent);

      if (functionCalls.isEmpty) {
        // Extract only the newly generated content (everything after initial history)
        final newlyGeneratedContent = conversationHistory.skip(initialHistoryLength).toList();

        yield GenerationState.complete(
          GenerationResult(
            requestMessage: prompts.last,
            generatedMessage: newlyGeneratedContent.mapIndexed((index, content) {
              // Add generation usage only to the last message
              final isLastMessage = index == newlyGeneratedContent.length - 1;
              return _messageAdapter
                  .toCoreMessage(content)
                  .copyWithGenerationUsage(
                    !isLastMessage
                        ? null
                        : GenerationUsage(
                            inputToken: totalInputTokens,
                            outputToken: totalOutputTokens,
                            apiCallCount: apiCallCount,
                          ),
                  );
            }).toIList(),
            extensions: {
              'prompt_feedback': {
                'block_reason': lastResponse.promptFeedback?.blockReason?.toJson(),
                'block_reason_message': lastResponse.promptFeedback?.blockReasonMessage,
                'other_feedback': lastResponse.promptFeedback?.safetyRatings.map((e) {
                  return e.toString();
                }).toList(),
              },
            },
          ),
        );
        return;
      } else {
        // Function calls detected - yield intermediate state
        yield GenerationState.functionCalling(functionCalls.toString());
        final functionResponses = await _effectiveTools(tools).executes(functionCalls);
        conversationHistory.add(Content.functionResponses(functionResponses));

        // Continue the loop for AI's next response
        continue;
      }
    }
  }

  /// Returns a map of tool name to schema, merging provided and config tools, removing duplicates by name.
  List<FirebaseAiToolSchema> _effectiveTools(List<ToolSchema> tools) {
    final firebaseTools = tools.whereType<FirebaseAiToolSchema>().toList();
    final merged = <FirebaseAiToolSchema>[
      ...firebaseTools,
      if (_config.toolSchemas != null) ..._config.toolSchemas!,
    ];
    return merged..removeDuplicates(by: (item) => item.name);
  }
}
