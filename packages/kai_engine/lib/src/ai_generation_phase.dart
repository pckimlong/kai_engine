import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'generation_service_base.dart';
import 'inspector/kai_phase.dart';
import 'inspector/models/timeline_types.dart';
import 'models/cancel_token.dart';
import 'models/core_message.dart';
import 'models/generation_result.dart';
import 'models/generation_state.dart';
import 'tool_schema.dart';

/// Input for the AI generation phase
class AIGenerationInput {
  final IList<CoreMessage> prompts;
  final CancelToken cancelToken;
  final List<ToolSchema> tools;
  final Map<String, dynamic>? config;
  final void Function(GenerationState<GenerationResult>) onStateUpdate;

  const AIGenerationInput({
    required this.prompts,
    required this.cancelToken,
    required this.tools,
    required this.config,
    required this.onStateUpdate,
  });
}

/// Dedicated phase for AI generation with streaming support
class AIGenerationPhase extends KaiPhase<AIGenerationInput, GenerationResult> {
  final GenerationServiceBase _generationService;

  AIGenerationPhase(this._generationService);

  @override
  Future<GenerationResult> execute(AIGenerationInput input) async {
    addLog('Starting AI generation with ${input.prompts.length} prompts');

    GenerationResult? finalResult;
    int streamEventCount = 0;
    int totalTokens = 0;

    await withStep(
      'Stream AI Response',
      description: 'Processing streaming response from AI service',
      metadata: {
        'prompt_count': input.prompts.length,
        'tool_count': input.tools.length,
        'has_cancel_token': input.cancelToken != null,
      },
      operation: (step) async {
        final stopwatch = Stopwatch()..start();

        try {
          // Get the streaming response from the clean service
          final responseStream = _generationService.stream(
            input.prompts,
            cancelToken: input.cancelToken,
            tools: input.tools,
            config: input.config,
          );

          await for (final state in responseStream) {
            if (state case GenerationState<GenerationResult> result) {
              streamEventCount++;

              // Update the UI with streaming state
              input.onStateUpdate(result);

              // Track and log key milestones
              if (result case GenerationStreamingTextState text) {
                addLog('Streaming text chunk: ${text.text.length} characters');
              } else if (result case GenerationCompleteState complete) {
                finalResult = complete.result;
                totalTokens = complete.result.usage?.tokenCount ?? 0;

                addLog('Generation completed successfully');
                if (totalTokens > 0) {
                  addLog('Token usage: $totalTokens tokens');
                  updateAggregates(tokenUsage: totalTokens);
                }
              } else if (result case GenerationFunctionCallingState functionCall) {
                addLog('Function calling: ${functionCall.names}');
              }
            }
          }

          stopwatch.stop();
          addLog(
            'Streaming completed: $streamEventCount events in ${stopwatch.elapsedMilliseconds}ms',
            metadata: {
              'stream_events': streamEventCount,
              'duration_ms': stopwatch.elapsedMilliseconds,
              'tokens_used': totalTokens,
            },
          );

          return finalResult;
        } catch (error) {
          stopwatch.stop();
          addLog(
            'Streaming failed after ${stopwatch.elapsedMilliseconds}ms: $error',
            severity: TimelineLogSeverity.error,
          );
          rethrow;
        }
      },
    );

    if (finalResult == null) {
      throw Exception('Generation stream completed without emitting a final result');
    }

    addLog('AI generation completed successfully');
    return finalResult!;
  }
}
