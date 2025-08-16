import 'package:freezed_annotation/freezed_annotation.dart';

import 'kai_exception.dart';

part 'generation_state.freezed.dart';

/// Provide rich detail what it being load
@freezed
sealed class LoadingPhase with _$LoadingPhase {
  const LoadingPhase._();

  const factory LoadingPhase.initial() = _DefaultLoadingPhase;
  const factory LoadingPhase.processingQuery([String? stageName]) = _ProcessingQueryPhase;
  const factory LoadingPhase.buildContext([String? stageName]) = _BuildingContextPhase;
  const factory LoadingPhase.buildingResponse([String? stageName]) = _BuildingResponsePhase;
  const factory LoadingPhase.generatingResponse([
    String? stageName,
    String? message,
  ]) = _GeneratingResponsePhase;
}

@freezed
class GenerationState<T> with _$GenerationState<T> {
  const GenerationState._();

  const factory GenerationState.initial() = GenerationInitialState;

  const factory GenerationState.loading([@Default(LoadingPhase.initial()) LoadingPhase phase]) =
      GenerationLoadingState;

  /// Represents a streaming text update during generation.
  const factory GenerationState.streamingText(String text) = GenerationStreamingTextState;

  const factory GenerationState.functionCalling(String names) = GenerationFunctionCallingState;

  /// Represents the completion of generation with the final message.
  const factory GenerationState.complete(T result) = GenerationCompleteState;

  const factory GenerationState.error(KaiException exception) = GenerationErrorState;

  bool get isGenerating =>
      this is GenerationLoadingState ||
      this is GenerationStreamingTextState ||
      this is GenerationFunctionCallingState;
}
