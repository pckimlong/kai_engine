import 'package:freezed_annotation/freezed_annotation.dart';

import '../../kai_engine.dart';

part 'generation_execute_config.freezed.dart';

@freezed
sealed class GenerationExecuteConfig with _$GenerationExecuteConfig {
  const GenerationExecuteConfig._();

  const factory GenerationExecuteConfig({
    @Default([]) List<ToolSchema> tools,
    ToolingConfig? toolingConfig,
    Map<String, dynamic>? config,
  }) = _GenerationExecuteConfig;

  factory GenerationExecuteConfig.none() => const GenerationExecuteConfig();
}
