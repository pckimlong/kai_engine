import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'generation_service_base.dart';
import 'models/cancel_token.dart';
import 'models/core_message.dart';
import 'models/generation_result.dart';
import 'models/generation_state.dart';
import 'pipeline/kai_phase.dart';
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
final class AIGenerationPhase extends KaiPhase<AIGenerationInput, GenerationResult> {
  final GenerationServiceBase _generationService;

  AIGenerationPhase(this._generationService);

  @override
  Future<GenerationResult> execute(AIGenerationInput input) async {
    GenerationResult? finalResult;

    final responseStream = _generationService.stream(
      input.prompts,
      cancelToken: input.cancelToken,
      tools: input.tools,
      config: input.config,
    );

    await for (final state in responseStream) {
      if (state case GenerationState<GenerationResult> result) {
        input.onStateUpdate(result);
        if (result case GenerationCompleteState complete) {
          finalResult = complete.result;
        }
      }
    }

    if (finalResult == null) {
      throw Exception('Generation stream completed without emitting a final result');
    }

    return finalResult;
  }
}
