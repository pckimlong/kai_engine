import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'generation_service_base.dart';
import 'inspector/kai_phase.dart';
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

    // Get the streaming response
    final responseStream = _generationService.stream(
      input.prompts,
      cancelToken: input.cancelToken,
      tools: input.tools,
      config: input.config,
    );

    GenerationResult? finalResult;

    await withStep(
      'Stream AI Response',
      description: 'Processing streaming response from AI service',
      operation: (step) async {
        await for (final state in responseStream) {
          if (state case GenerationState<GenerationResult> result) {
            // Update the UI with streaming state
            input.onStateUpdate(result);

            // Log key milestones
            if (result case GenerationCompleteState complete) {
              finalResult = complete.result;
              addLog('Generation completed successfully');
            } else if (result
                case GenerationFunctionCallingState functionCall) {
              addLog('Function calling: ${functionCall.names}');
            }
          }
        }
        return finalResult;
      },
    );

    if (finalResult == null) {
      throw Exception(
        'Generation stream completed without emitting a final result',
      );
    }

    addLog('AI generation completed successfully');
    return finalResult!;
  }
}
