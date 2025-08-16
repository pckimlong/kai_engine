import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kai_engine/kai_engine.dart';

part 'message_extensions.freezed.dart';
part 'message_extensions.g.dart';

@freezed
sealed class GenerationUsage with _$GenerationUsage {
  const GenerationUsage._();

  const factory GenerationUsage({
    required int? inputToken,
    required int? outputToken,
    required int? apiCallCount,
  }) = _GenerationUsage;

  factory GenerationUsage.fromJson(Map<String, dynamic> json) => _$GenerationUsageFromJson(json);
}

extension CoreMessageFirebaseExtension on CoreMessage {
  GenerationUsage? get generationUsage {
    final usage = extensions['generationUsage'];
    if (usage is Map<String, dynamic>) {
      return GenerationUsage.fromJson(usage);
    }
    return null;
  }

  CoreMessage copyWithGenerationUsage(GenerationUsage? usage) {
    if (usage == null) {
      return copyWithExtensions({
        'generationUsage': null,
      });
    } else {
      return copyWithExtensions({
        'generationUsage': usage.toJson(),
      });
    }
  }
}
