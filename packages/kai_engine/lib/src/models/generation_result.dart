import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kai_engine/src/models/core_message.dart';

part 'generation_result.freezed.dart';

@freezed
sealed class GenerationResult with _$GenerationResult {
  const GenerationResult._();

  const factory GenerationResult({
    /// The original request message
    required CoreMessage requestMessage,

    /// Generate messages result per request, not including previous context and user messages
    required IList<CoreMessage> generatedMessage,

    Map<String, dynamic>? extensions,
  }) = _GenerationResult;

  /// The message which suppose to display
  CoreMessage get displayMessage {
    // Return the last message from the messages list as default implementation
    if (generatedMessage.isEmpty) {
      throw StateError('Cannot get displayMessage from empty messages list');
    }

    /// We expect AI message back, not function call etc
    return generatedMessage.lastWhere((e) => e.type == CoreMessageType.ai);
  }
}
