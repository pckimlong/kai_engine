import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'context_builder.dart';
import 'inspector/kai_phase.dart';
import 'inspector/models/timeline_types.dart';
import 'inspector/phase_types.dart';
import 'models/core_message.dart';
import 'models/query_context.dart';

part 'prompt_engine.freezed.dart';

/// Abstract base class that defines how to generate contextual prompts for AI interactions.
///
/// This engine orchestrates the creation of a complete conversation context by combining
/// system prompts, historical context, and user input according to a defined template structure.
/// It supports both parallel and sequential context building strategies to optimize performance
/// while maintaining logical ordering where required.
abstract base class ContextEngine
    extends KaiPhase<ContextEngineInput, ContextEngineOutput> {
  /// Defines the template structure for building prompts.
  ///
  /// This list specifies what components should be included in the final prompt and in what order.
  /// It must contain exactly one [PromptTemplate.input] element.
  List<PromptTemplate> get promptBuilder;

  @override
  Future<ContextEngineOutput> execute(ContextEngineInput input) async {
    final result = await generate(
      source: input.conversationMessages,
      inputQuery: input.inputQuery,
    );
    return ContextEngineOutput(prompts: result.prompts);
  }

  /// Generates a complete contextual prompt ready for AI consumption.
  ///
  /// This method orchestrates the complete prompt building process:
  /// 1. Identifies and processes the user input
  /// 2. Separates prompt builders into parallel and sequential groups
  /// 3. Executes parallel builders concurrently for performance
  /// 4. Executes sequential builders in order, with each aware of previous context
  /// 5. Combines all results maintaining the original template order
  /// 6. Appends the user message at the end
  ///
  /// Parameters:
  /// - [source]: The source messages to build context from, typically the existing chat history
  /// - [inputQuery]: The current user query with additional context
  /// - [onStageStart]: Optional callback to notify when each processing stage begins
  /// - [providedUserMessage]: The user input message, if provided it will use that, otherwise it generate new one with new id
  ///
  /// Returns:
  /// - A record containing the user message and the complete contextual prompt
  Future<({CoreMessage userMessage, IList<CoreMessage> prompts})> generate({
    /// Source messages to build context from, usually this is the message available in chat context
    required IList<CoreMessage> source,
    required QueryContext inputQuery,
    void Function(String name)? onStageStart,
    CoreMessage? providedUserMessage,
  }) async {
    // Extract messageId for debug tracking
    final userMessage =
        providedUserMessage ??
        CoreMessage.user(content: inputQuery.originalQuery);
    final messageId = userMessage.messageId;

    // Use inspector logging instead of debug methods
    await withStep(
      'context-engine-processing',
      operation: (step) async {
        addLog(
          'Processing prompt templates',
          metadata: {
            'prompt-templates': promptBuilder.length,
            'source-messages': source.length,
          },
        );
      },
    );

    assert(
      promptBuilder.whereType<InputPromptTemplate>().length == 1,
      "Must define exactly one input prompt.",
    );

    // Create indexed pairs to preserve original order
    final indexedBuilders = promptBuilder
        .asMap()
        .entries
        .map((entry) => (index: entry.key, builder: entry.value))
        .toList();

    // Separate by type while keeping index
    final parallelItems = indexedBuilders
        .where((item) => item.builder is _BuildParallelPromptTemplate)
        .toList();

    final sequentialItems = indexedBuilders
        .where((item) => item.builder is _BuildSequentialPromptTemplate)
        .toList();

    // Use inspector logging
    await withStep(
      'builder-distribution',
      operation: (step) async {
        addLog(
          'Builder distribution',
          metadata: {
            'parallel-builders': parallelItems.length,
            'sequential-builders': sequentialItems.length,
          },
        );
      },
    );

    // Process both concurrently
    final parallelFuture = _buildParallelWithIndex(
      parallelItems,
      source,
      inputQuery,
      onStageStart,
      messageId,
    );
    final sequentialFuture = _buildSequentialWithIndex(
      sequentialItems,
      source,
      inputQuery,
      onStageStart,
      messageId,
    );

    final results = await Future.wait([parallelFuture, sequentialFuture]);
    final parallelResults = results[0];
    final sequentialResults = results[1];

    // Merge results back in original order
    final allResults = <int, List<CoreMessage>>{};

    // Add parallel results
    for (final item in parallelResults) {
      allResults[item.index] = item.result;
    }

    // Add sequential results
    for (final item in sequentialResults) {
      allResults[item.index] = item.result;
    }

    // Rebuild in original order, including system templates
    final finalContexts = <CoreMessage>[];
    for (int i = 0; i < promptBuilder.length; i++) {
      if (allResults.containsKey(i)) {
        // Add results from parallel/sequential builders
        finalContexts.addAll(allResults[i]!);
      } else {
        // Handle system templates and other non-builder templates
        final template = promptBuilder[i];
        if (template is _SystemPromptTemplate) {
          // Convert system template to a CoreMessage
          finalContexts.add(CoreMessage.system(template.text));
        }
        // Other template types (like input) are not added to the context
      }
    }

    /// Clean up context by removing duplicates and adding the user message
    finalContexts
      ..removeWhere((e) => e.messageId == userMessage.messageId)
      ..removeDuplicates(by: (e) => e.messageId);

    final input = promptBuilder.whereType<InputPromptTemplate>().first;
    final overriddenMessage =
        await input.revision?.call(inputQuery, finalContexts.toIList()) ??
        inputQuery.originalQuery;
    final finalUserMessage = userMessage.copyWith(content: overriddenMessage);

    // Use inspector logging for final results
    await withStep(
      'final-results',
      operation: (step) async {
        addLog(
          'Final context results',
          metadata: {
            'final-context-messages': finalContexts.length,
            'total-prompt-messages': finalContexts.length + 1,
          },
        );
      },
    );

    return (
      userMessage: finalUserMessage,
      prompts: IList([...finalContexts, finalUserMessage]),
    );
  }

  /// Builds parallel context items while preserving their original indices.
  ///
  /// This method executes all parallel context builders concurrently to optimize performance,
  /// as these builders don't depend on each other's results.
  ///
  /// Parameters:
  /// - [items]: The parallel prompt template items with their original indices
  /// - [inputQuery]: The current user query with additional context
  /// - [onStageStart]: Optional callback to notify when each processing stage begins
  ///
  /// Returns:
  /// - A list of results with their original indices for proper reordering
  Future<List<({int index, List<CoreMessage> result})>> _buildParallelWithIndex(
    List<({int index, PromptTemplate builder})> items,
    IList<CoreMessage> source,
    QueryContext inputQuery,
    void Function(String name)? onStageStart,
    String messageId,
  ) async {
    return await Future.wait(
      items.map((item) async {
        final parallelBuilder = item.builder as _BuildParallelPromptTemplate;
        final builder = parallelBuilder.builder;
        final builderName = 'parallel-${builder.runtimeType}';

        return await withStep(
          builderName,
          operation: (step) async {
            onStageStart?.call('${builder.runtimeType}');

            try {
              final result = await builder.build(inputQuery, source);

              addLog('Built ${result.length} messages');
              return (index: item.index, result: result);
            } catch (e) {
              addLog(
                'Failed to build: $e',
                severity: TimelineLogSeverity.error,
              );
              rethrow;
            }
          },
        );
      }),
    );
  }

  /// Builds sequential context items while preserving their original indices.
  ///
  /// This method executes sequential context builders one after another, with each
  /// builder having access to the context built by previous builders. This ensures
  /// proper logical ordering when context dependencies exist.
  ///
  /// Parameters:
  /// - [items]: The sequential prompt template items with their original indices
  /// - [source]: The source messages to build context from
  /// - [inputQuery]: The current user query with additional context
  /// - [onStageStart]: Optional callback to notify when each processing stage begins
  ///
  /// Returns:
  /// - A list of results with their original indices for proper reordering
  Future<List<({int index, List<CoreMessage> result})>>
  _buildSequentialWithIndex(
    List<({int index, PromptTemplate builder})> items,
    IList<CoreMessage> source,
    QueryContext inputQuery,
    void Function(String name)? onStageStart,
    String messageId,
  ) async {
    final results = <({int index, List<CoreMessage> result})>[];
    List<CoreMessage> currentContext = source.unlock;

    for (final item in items) {
      final sequentialBuilder = item.builder as _BuildSequentialPromptTemplate;
      final builder = sequentialBuilder.builder;
      final builderName = 'sequential-${builder.runtimeType}';

      final context = await withStep(
        builderName,
        operation: (step) async {
          onStageStart?.call('${builder.runtimeType}');

          try {
            final context = await builder.build(inputQuery, currentContext);

            addLog(
              'Built ${context.length} messages from context size ${currentContext.length}',
            );
            return context;
          } catch (e) {
            addLog('Failed to build: $e', severity: TimelineLogSeverity.error);
            rethrow;
          }
        },
      );

      currentContext = context;
      results.add((index: item.index, result: context));
    }

    return results;
  }
}

/// A simple context engine implementation for basic chat interactions.
///
/// This engine provides a straightforward prompt structure consisting of:
/// 1. A fixed system prompt defining the AI's personality
/// 2. Sequential historical context building
/// 3. The user's input message
///
/// This implementation is suitable for most basic conversational AI scenarios.
final class SimpleContextEngine extends ContextEngine {
  @override
  List<PromptTemplate> get promptBuilder => [
    PromptTemplate.system("You're kai, a useful friendly personal assistant."),
    PromptTemplate.buildSequential(HistoryContext()),
    PromptTemplate.input(),
  ];
}

@freezed
sealed class PromptTemplate with _$PromptTemplate {
  const PromptTemplate._();

  /// Creates a system prompt template with fixed text content.
  ///
  /// System prompts define the AI's role, personality, and general behavior guidelines.
  /// For more dynamic system prompts that incorporate user context, consider using
  /// [PromptTemplate.buildParallel] or [PromptTemplate.buildSequential] instead.
  ///
  /// Parameters:
  /// - [text]: The fixed text content for the system prompt
  const factory PromptTemplate.system(String text) = _SystemPromptTemplate;

  /// Creates a prompt template that builds context through parallel execution.
  ///
  /// Parallel builders can be executed concurrently since they don't depend on each other's results.
  /// This approach optimizes performance for independent context elements like:
  /// - User profile information
  /// - Current date/time
  /// - System status information
  ///
  /// Parameters:
  /// - [builder]: The context builder that will generate the prompt content
  const factory PromptTemplate.buildParallel(ParallelContextBuilder builder) =
      _BuildParallelPromptTemplate;

  /// Creates a prompt template that builds context through sequential execution.
  ///
  /// Sequential builders are executed in order, with each builder having access to the context
  /// built by previous builders. This approach is necessary when context elements have dependencies:
  /// - Building conversation history where each message may reference previous ones
  /// - Creating context that requires multiple dependent processing steps
  ///
  /// Even when mixed with parallel builders, sequential builders maintain their logical order
  /// in the final prompt according to the template sequence.
  ///
  /// Parameters:
  /// - [builder]: The context builder that will generate the prompt content
  const factory PromptTemplate.buildSequential(
    SequentialContextBuilder builder,
  ) = _BuildSequentialPromptTemplate;

  /// Creates an input prompt template for the user's message.
  ///
  /// This template must be included exactly once at the end of the prompt template list.
  /// By default, it uses the raw user input, but you can provide a custom function to
  /// modify or enhance the input before it's added to the prompt.
  ///
  /// The requirement to explicitly include this template (rather than auto-injecting it)
  /// ensures developers have full visibility into how their prompts are constructed.
  ///
  /// Parameters:
  /// - [revision]: Optional function to override the raw user input before inclusion. This helpful for inject custom instruction to user input
  /// - [input]: The user's raw input message
  /// - [messages]: The final list of messages in the conversation context after processing other templates include system prompts
  const factory PromptTemplate.input([
    FutureOr<String> Function(
      QueryContext input,
      IList<CoreMessage> finalizedMessages,
    )?
    revision,
  ]) = InputPromptTemplate;
}
