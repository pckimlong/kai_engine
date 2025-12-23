import 'dart:async';

import 'models/conversation_session.dart';
import 'models/core_message.dart';

/// Abstract interface for a message repository.
///
/// Defines the contract for storing and retrieving conversation messages.
abstract interface class MessageRepositoryBase<T> {
  Future<Iterable<T>> getMessages(ConversationSession session);

  Future<Iterable<T>> saveMessages({
    required ConversationSession session,
    required Iterable<T> messages,
  });

  Future<Iterable<T>> updateMessages(Iterable<T> messages);

  Future<void> removeMessages(Iterable<T> messages);
}

/// Abstract interface for a core message repository. No adapter required.
abstract interface class CoreMessageRepositoryBase
    extends MessageRepositoryBase<CoreMessage> {}

/// Prebuilt repository for memory persistence.
final class InMemoryMessageRepository implements CoreMessageRepositoryBase {
  InMemoryMessageRepository({Iterable<CoreMessage>? initialMessages})
    : _messages = initialMessages?.toList() ?? [];

  final List<CoreMessage> _messages;

  @override
  Future<Iterable<CoreMessage>> getMessages(ConversationSession session) {
    return Future.value(_messages);
  }

  @override
  Future<void> removeMessages(Iterable<CoreMessage> messages) async {
    _messages.removeWhere(
      (message) => messages.map((e) => e.messageId).contains(message.messageId),
    );
  }

  @override
  Future<Iterable<CoreMessage>> saveMessages({
    required ConversationSession session,
    required Iterable<CoreMessage> messages,
  }) {
    _messages.addAll(messages);
    return Future.value(messages);
  }

  @override
  Future<Iterable<CoreMessage>> updateMessages(Iterable<CoreMessage> messages) {
    for (var message in messages) {
      var index = _messages.indexWhere((m) => m.messageId == message.messageId);
      if (index != -1) {
        _messages[index] = message;
      }
    }
    return Future.value(messages);
  }
}
