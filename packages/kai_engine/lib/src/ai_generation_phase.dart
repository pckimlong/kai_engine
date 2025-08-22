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
        'has_cancel_token': true,
      },
      operation: (step) async {
        final stopwatch = Stopwatch()..start();

        // Initialize streaming metrics
        final streamingMetrics = {
          'chunks_received': 0,
          'total_characters': 0,
          'first_chunk_time': null,
          'function_calls': <String>[],
        };

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

              // Track and log key milestones with detailed metrics
              if (result case GenerationStreamingTextState text) {
                streamingMetrics['chunks_received'] = 
                    (streamingMetrics['chunks_received'] as int) + 1;
                streamingMetrics['total_characters'] = 
                    (streamingMetrics['total_characters'] as int) + text.text.length;
                
                // Record first chunk timing
                if (streamingMetrics['first_chunk_time'] == null) {
                  streamingMetrics['first_chunk_time'] = stopwatch.elapsedMilliseconds;
                  addLog('First chunk received', metadata: {
                    'time_to_first_chunk_ms': stopwatch.elapsedMilliseconds,
                    'chunk_size': text.text.length,
                  });
                }
                
                addLog('Streaming text chunk: ${text.text.length} characters', 
                  metadata: {
                    'chunk_size': text.text.length,
                    'cumulative_chunks': streamingMetrics['chunks_received'],
                    'cumulative_characters': streamingMetrics['total_characters'],
                  });
              } else if (result case GenerationCompleteState complete) {
                finalResult = complete.result;
                totalTokens = complete.result.usage?.tokenCount ?? 0;
                
                // Comprehensive token usage logging
                final usage = complete.result.usage;
                final tokenMetadata = {
                  'total_tokens': totalTokens,
                  'input_tokens': usage?.inputToken,
                  'output_tokens': usage?.outputToken,
                  'api_call_count': usage?.apiCallCount,
                  'tokens_per_ms': totalTokens > 0 && stopwatch.elapsedMilliseconds > 0 
                      ? (totalTokens / stopwatch.elapsedMilliseconds).toStringAsFixed(3)
                      : null,
                };
                
                // Add streaming performance metrics
                tokenMetadata.addAll(streamingMetrics);
                
                addLog('Generation completed successfully', metadata: tokenMetadata);
                
                if (totalTokens > 0) {
                  addLog('Token usage: $totalTokens tokens (${usage?.inputToken ?? 0} in, ${usage?.outputToken ?? 0} out)');
                  updateAggregates(tokenUsage: totalTokens);
                }
              } else if (result case GenerationFunctionCallingState functionCall) {
                (streamingMetrics['function_calls'] as List<String>).add(functionCall.names);
                addLog('Function calling: ${functionCall.names}', metadata: {
                  'function_names': functionCall.names,
                  'total_functions_called': streamingMetrics['function_calls'],
                });
              }
            }
          }

          stopwatch.stop();
          
          // Final comprehensive metrics
          final finalMetrics = {
            'stream_events': streamEventCount,
            'duration_ms': stopwatch.elapsedMilliseconds,
            'tokens_used': totalTokens,
            'average_chunk_size': (streamingMetrics['chunks_received'] as int) > 0 
                ? ((streamingMetrics['total_characters'] as int) / 
                   (streamingMetrics['chunks_received'] as int)).round()
                : 0,
            'tokens_per_second': totalTokens > 0 && stopwatch.elapsedMilliseconds > 0
                ? ((totalTokens * 1000) / stopwatch.elapsedMilliseconds).toStringAsFixed(2)
                : '0',
            'time_to_first_chunk_ms': streamingMetrics['first_chunk_time'],
            'function_calls_made': streamingMetrics['function_calls'],
          };
          
          addLog(
            'Streaming completed: $streamEventCount events in ${stopwatch.elapsedMilliseconds}ms',
            metadata: finalMetrics,
          );

          return finalResult;
        } catch (error) {
          stopwatch.stop();
          addLog(
            'Streaming failed after ${stopwatch.elapsedMilliseconds}ms: $error',
            severity: TimelineLogSeverity.error,
            metadata: {
              'duration_ms': stopwatch.elapsedMilliseconds,
              'events_processed': streamEventCount,
              'error_type': error.runtimeType.toString(),
              ...streamingMetrics,
            },
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
