import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:kai_engine/src/post_response_engine.dart';
import 'package:kai_engine/src/tool_schema.dart';
import 'package:rxdart/rxdart.dart';

import 'conversation_manager.dart';
import 'debug/debug_system.dart';
import 'generation_service_base.dart';
import 'kai_logger.dart';
import 'models/cancel_token.dart';
import 'models/core_message.dart';
import 'models/generation_result.dart';
import 'models/generation_state.dart';
import 'models/kai_exception.dart';
import 'prompt_engine.dart';
import 'query_engine.dart';

typedef GenerationExecuteConfig = ({List<ToolSchema> tools, Map<String, dynamic>? config});

/// Base orchestrator for chat interactions
/// override to add more configuration
/// [TEntity] is the type of the message object which can use to translate to the backend
abstract base class ChatControllerBase<TEntity> with DebugTrackingMixin {
  final QueryEngine _queryEngine;
  final ConversationManager<TEntity> _conversationManager;
  final GenerationServiceBase _generationService;
  final PostResponseEngine _postResponseEngine;
  final CancelToken _cancelToken;
  final KaiLogger _logger;

  ChatControllerBase({
    required ConversationManager<TEntity> conversationManager,
    required GenerationServiceBase generationService,
    required QueryEngine queryEngine,
    required PostResponseEngine postResponseEngine,
    KaiLogger? logger,
  }) : _queryEngine = queryEngine,
       _conversationManager = conversationManager,
       _generationService = generationService,
       _postResponseEngine = postResponseEngine,
       _cancelToken = CancelToken(),
       _logger = logger ?? const NoOpKaiLogger();

  /// Handle generation state updates
  final _generationStateController = BehaviorSubject<GenerationState<GenerationResult>>.seeded(
    GenerationState.initial(),
  );

  ContextEngine build();

  /// Provide custom generative config in addition to default configuration of generative service base on the prompt which will send to server
  GenerationExecuteConfig generativeConfigs(IList<CoreMessage> prompts) {
    return (tools: [], config: null);
  }

  /// Submit user input for processing and generation
  /// [revertInputOnError] indicates whether to revert user input if error occurs, by default it is false
  /// which means the user input will be retained even if an error occurs
  Future<GenerationState<CoreMessage>> submit(
    String input, {
    bool revertInputOnError = false,
  }) async {
    var userMessage = CoreMessage.user(content: input);
    debugStartMessage(userMessage.messageId, input);

    try {
      await _logger.logInfo('Chat submission started', data: {'input': input});
      _setState(GenerationState.loading());

      // Add user message to conversation, no await
      unawaited(
        _conversationManager.addMessages([userMessage].lock).then((inserted) async {
          userMessage = inserted.first;
        }),
      );

      // Optimize query
      _setLoadingPhase(LoadingPhase.processingQuery());
      debugStartPhase(userMessage.messageId, 'query-processing');
      final inputQuery = await _queryEngine.process(
        input,
        session: _conversationManager.session,
        onStageStart: (name) {
          _setLoadingPhase(LoadingPhase.processingQuery(name));
        },
      );
      debugEndPhase(userMessage.messageId, 'query-processing');
      debugQueryProcessed(userMessage.messageId, inputQuery);

      // Build context/history with input ready
      _setLoadingPhase(LoadingPhase.buildContext());
      debugStartPhase(userMessage.messageId, 'context-building');
      final contextResult = await build().generate(
        source: await _conversationManager.getMessages(),
        inputQuery: inputQuery,
        // the original user message will get override but not effect database
        providedUserMessage: userMessage,
        onStageStart: (name) {
          _setLoadingPhase(LoadingPhase.buildContext(name));
        },
      );
      debugEndPhase(userMessage.messageId, 'context-building');
      debugContextBuilt(
        userMessage.messageId,
        await _conversationManager.getMessages(),
        contextResult.prompts,
      );

      // Generate response
      final configs = generativeConfigs(contextResult.prompts);
      debugGenerationConfigured(
        userMessage.messageId,
        DebugGenerationConfig(
          availableTools: configs.tools.map((t) => t.name).toList(),
          config: configs.config ?? {},
        ),
      );

      _setLoadingPhase(LoadingPhase.generatingResponse());
      debugStartPhase(userMessage.messageId, 'ai-generation');
      final responseStream = _generationService.stream(
        contextResult.prompts,
        cancelToken: _cancelToken,
        tools: configs.tools,
        config: configs.config,
      );

      GenerationState<GenerationResult>? finalState;
      await for (final state in responseStream) {
        if (state is! GenerationStreamingTextState<GenerationResult>) {
          // If it not a generation streaming, log it to better see what behind
          _logger.logInfo('Generation state updated: $state');
        }

        // Track streaming chunks for debug
        if (state is GenerationStreamingTextState<GenerationResult>) {
          debugStreamingChunk(userMessage.messageId, state.text);
        }

        // Handle error states from the stream
        if (state is GenerationErrorState<GenerationResult>) {
          debugEndPhase(userMessage.messageId, 'ai-generation');
          debugMessageFailed(userMessage.messageId, state.exception, 'ai-generation');

          // Emit error state through the controller
          _generationStateController.add(state);

          // Handle revertInputOnError for stream errors
          if (revertInputOnError) {
            await _conversationManager.removeMessages([userMessage].lock);
          }

          await _logger.logError('Generation stream error', error: state.exception);
          return _mapGenerationState(state);
        }

        if (state is GenerationCompleteState<GenerationResult>) {
          debugEndPhase(userMessage.messageId, 'ai-generation');

          // Save AI responses, added messages might get modified again by post-processing
          // we need to add the message before process background to make sure process background
          // included the new responses
          await _conversationManager.addMessages(state.result.generatedMessage);

          // Process background task on generated response, eg summarize, generate embedding
          // without blocking process
          // added messages might get modified again by post-processing
          debugStartPhase(userMessage.messageId, 'post-response-processing');
          _postResponseEngine
              .process(
                input: inputQuery,
                result: state.result,
                conversationManager: _conversationManager,
              )
              .then((_) {
                debugEndPhase(userMessage.messageId, 'post-response-processing');
              })
              .catchError((error, stackTrace) {
                debugMessageFailed(userMessage.messageId, Exception(error.toString()), 'post-response-processing');
                _logger.logError(
                  'Post response processing failed',
                  error: error,
                  stackTrace: stackTrace,
                );
              });

          // Validate generatedMessage contains only newly generated content
          assert(
            state.result.generatedMessage.isNotEmpty,
            'generatedMessage should not be empty - this indicates a bug in the generation service',
          );
          assert(
            state.result.generatedMessage.every(
              (msg) => msg.type == CoreMessageType.ai || msg.type == CoreMessageType.function,
            ),
            'generatedMessage should only contain AI responses and function calls/responses, '
            'not system prompts or user messages. Found: ${state.result.generatedMessage.map((m) => m.type).toList()}',
          );

          // Complete debug session
          debugMessageCompleted(userMessage.messageId, state.result.generatedMessage);
        }

        // Emit state through the controller
        finalState = state;
        _generationStateController.add(state);
      }

      if (finalState == null) {
        throw KaiException.exception('Response stream completed without emitting a final state');
      }

      final result = _mapGenerationState(finalState);
      await _logger.logInfo('Chat submission completed successfully');
      return result;
    } catch (error, stackTrace) {
      debugMessageFailed(userMessage.messageId, Exception(error.toString()), 'unknown');
      await _logger.logError('Chat submission failed', error: error, stackTrace: stackTrace);

      if (revertInputOnError) {
        // If userMessage is set, it means we successfully processed the input and persisted it
        await _conversationManager.removeMessages([userMessage].lock);
      }

      final errorState = GenerationState<GenerationResult>.error(
        KaiException.exception(error.toString(), stackTrace),
      );
      _generationStateController.add(errorState);
      return _mapGenerationState(errorState);
    }
  }

  Future<void> cancel() async {
    _cancelToken.cancel();
    _setState(GenerationState.error(KaiException.cancelled()));
  }

  Stream<IList<CoreMessage>> get messagesStream => _conversationManager.messagesStream;

  Stream<GenerationState<CoreMessage>> get generationStateStream =>
      _generationStateController.stream.map(_mapGenerationState);

  /// Extends [ChatControllerBase] must call dispose to close streams otherwise memory leaks may occur
  void dispose() {
    _generationStateController.close();
    _cancelToken.cancel();
  }

  GenerationState<CoreMessage> _mapGenerationState(GenerationState<GenerationResult> state) {
    return state.map(
      loading: (l) => GenerationState.loading(l.phase),
      initial: (value) => GenerationState.initial(),
      streamingText: (text) => GenerationState.streamingText(text.text),
      complete: (c) {
        return GenerationState.complete(c.result.displayMessage);
      },
      error: (e) => GenerationState.error(e.exception),
      functionCalling: (f) => GenerationState.functionCalling(f.names),
    );
  }

  void _setState(GenerationState<GenerationResult> state) => _generationStateController.add(state);
  void _setLoadingPhase(LoadingPhase phase) => _setState(GenerationState.loading(phase));
}
