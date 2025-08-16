import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_session.freezed.dart';

@freezed
sealed class ConversationSession with _$ConversationSession {
  const factory ConversationSession({
    required String id,
    DateTime? createdAt,
    @Default({}) Map<String, dynamic> metadata,
  }) = _ConversationSession;

  factory ConversationSession.withCurrentTime({
    required String id,
    String? userId,
    Map<String, dynamic>? metadata,
  }) {
    return ConversationSession(
      id: id,
      createdAt: DateTime.now(),
      metadata: metadata ?? const {},
    );
  }
}
