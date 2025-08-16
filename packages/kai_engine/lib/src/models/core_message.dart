import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'core_message.freezed.dart';
part 'core_message.g.dart';

final _uuid = Uuid();

enum CoreMessageType { system, user, ai, function, unknown }

/// Message Model suppose to use within internal logic only
@freezed
sealed class CoreMessage with _$CoreMessage {
  const CoreMessage._();

  factory CoreMessage.user({String? messageId, required String content}) {
    return CoreMessage(
      messageId: messageId ?? _uuid.v4(),
      type: CoreMessageType.user,
      content: content,
    );
  }

  factory CoreMessage.ai({String? messageId, required String content}) {
    return CoreMessage(
      messageId: messageId ?? _uuid.v4(),
      type: CoreMessageType.ai,
      content: content,
    );
  }

  /// Creates a system message. Note that system message never persist to database
  factory CoreMessage.system(String prompt) {
    return CoreMessage(messageId: _uuid.v4(), type: CoreMessageType.system, content: prompt);
  }

  /// Creates a new CoreMessage with the given parameters and automatically generates a messageId.
  factory CoreMessage.create({
    required String content,
    required CoreMessageType type,
    required Map<String, dynamic> extensions,
  }) {
    return CoreMessage(messageId: _uuid.v4(), type: type, content: content, extensions: extensions);
  }

  const factory CoreMessage({
    required String messageId,
    required CoreMessageType type,
    required String content,
    @Default(<String, dynamic>{}) Map<String, dynamic> extensions,
  }) = _CoreMessage;

  bool get isDisplayable => type == CoreMessageType.user || type == CoreMessageType.ai;

  // This allow for simple use case where adapter is not require, user can directly use [CoreMessage] as main model
  factory CoreMessage.fromJson(Map<String, dynamic> json) => _$CoreMessageFromJson(json);

  CoreMessage copyWithExtensions(Map<String, dynamic> updated) {
    final newExtensions = Map<String, dynamic>.from(extensions);
    for (final entry in updated.entries) {
      if (entry.value == null) {
        newExtensions.remove(entry.key);
      } else {
        newExtensions[entry.key] = entry.value;
      }
    }
    return copyWith(extensions: newExtensions);
  }
}
