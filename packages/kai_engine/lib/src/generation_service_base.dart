import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kai_engine/src/models/core_message.dart';
import 'package:kai_engine/src/tool_schema.dart';

import 'models/cancel_token.dart';
import 'models/generation_result.dart';
import 'models/generation_state.dart';

part 'generation_service_base.freezed.dart';

@freezed
sealed class ToolingConfig with _$ToolingConfig {
  const ToolingConfig._();

  const factory ToolingConfig.auto() = _ToolingConfigAuto;
  const factory ToolingConfig.any(Set<String> allowedFunctionNames) =
      _ToolingConfigAny;
  const factory ToolingConfig.none() = _ToolingConfigNone;
}

/// Base class for generation services - clean, standalone, no inspection dependencies
abstract interface class GenerationServiceBase {
  /// Process messages and return a stream of generation states.
  /// Response the generated state of IList[CoreMessage]
  /// In some case like tool calling the response might involve multiple messages steps
  /// This means we need to handle the response and save it accordingly
  Stream<GenerationState<GenerationResult>> stream(
    IList<CoreMessage> prompts, {
    CancelToken? cancelToken,
    List<ToolSchema> tools = const [],
    ToolingConfig? toolingConfig,
    Map<String, dynamic>? config,
  });

  /// Count tokens for the given prompts
  Future<int> countToken(IList<CoreMessage> prompts);

  /// Generate a simple response for the given prompts
  Future<String> invoke(IList<CoreMessage> prompts);

  /// Invoke the service with tools, must provide tools it will handle tool execution
  Future<String> tooling({
    required IList<CoreMessage> prompts,
    required List<ToolSchema> tools,
    required ToolingConfig toolingConfig,
  });
}