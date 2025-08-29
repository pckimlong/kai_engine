import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kai_engine/src/models/core_message.dart';

part 'generation_result.freezed.dart';

@freezed
sealed class GenerationResult with _$GenerationResult {
  const GenerationResult._();

  const factory GenerationResult({
    /// The original request message
    required IList<CoreMessage> requestMessages,

    /// Generate messages result per request, not including previous context and user messages
    required IList<CoreMessage> generatedMessages,

    /// The usage information for the generation, this is optional
    required GenerationUsage? usage,

    Map<String, dynamic>? extensions,

    String? responseText,
  }) = _GenerationResult;

  String get text => responseText ?? displayMessage.content;

  /// The message which suppose to display
  CoreMessage get displayMessage {
    // Return the last message from the messages list as default implementation
    if (generatedMessages.isEmpty) {
      throw StateError('Cannot get displayMessage from empty messages list');
    }

    /// We expect AI message back, not function call etc
    return generatedMessages.lastWhere((e) => e.type == CoreMessageType.ai);
  }
}

@freezed
sealed class GenerationUsage with _$GenerationUsage {
  const GenerationUsage._();

  const factory GenerationUsage({
    required int? inputToken,
    required int? outputToken,
    required int? apiCallCount,
    Map<String, dynamic>? extensions,
  }) = _GenerationUsage;

  int? get tokenCount {
    if (inputToken != null && outputToken != null) {
      return inputToken! + outputToken!;
    }
    return null;
  }
}
