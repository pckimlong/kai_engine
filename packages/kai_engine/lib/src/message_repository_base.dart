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
abstract interface class CoreMessageRepositoryBase extends MessageRepositoryBase<CoreMessage> {}

/// Prebuilt repository for memory persistence.
/// Messages are automatically sorted by timestamp on initialization.
final class InMemoryMessageRepository implements CoreMessageRepositoryBase {
  InMemoryMessageRepository({Iterable<CoreMessage>? initialMessages})
    : _messages = (initialMessages?.toList() ?? [])
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

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

/// Prebuilt repository for callback-based persistence.
///
/// Simplified API with only 2 required callbacks:
/// - [onInitial]: Load initial messages from persistence
/// - [onPut]: Persist insert or update operations (upsert)
/// - [onRemove]: Optional callback for persisting deletions
///
/// Note: Callbacks are for persistence only. The repository maintains
/// its own internal state for immediate read operations. Messages are
/// automatically sorted by timestamp on initial load.
final class CoreMessageRepository implements CoreMessageRepositoryBase {
  final Future<Iterable<CoreMessage>> Function(ConversationSession session) onInitial;
  final Future<void> Function(ConversationSession session, Iterable<CoreMessage> messages) onPut;
  final Future<void> Function(Iterable<CoreMessage> messages)? onRemove;

  final List<CoreMessage> _messages = [];
  ConversationSession? _cachedSession;
  bool _isInitialized = false;

  CoreMessageRepository({required this.onInitial, required this.onPut, this.onRemove});

  @override
  Future<Iterable<CoreMessage>> getMessages(ConversationSession session) async {
    if (!_isInitialized || _cachedSession != session) {
      _cachedSession = session;
      final loaded = await onInitial(session);
      _messages.clear();
      _messages.addAll(loaded);
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      _isInitialized = true;
    }
    return _messages;
  }

  @override
  Future<Iterable<CoreMessage>> saveMessages({
    required ConversationSession session,
    required Iterable<CoreMessage> messages,
  }) async {
    if (_cachedSession != null && _cachedSession != session) {
      _cachedSession = session;
      _messages.clear();
    } else {
      _cachedSession = session;
    }
    _isInitialized = true;
    _messages.addAll(messages);
    await onPut(session, messages);
    return messages;
  }

  @override
  Future<Iterable<CoreMessage>> updateMessages(Iterable<CoreMessage> messages) async {
    if (_cachedSession == null) {
      throw StateError('Session not initialized. Call getMessages or saveMessages first.');
    }
    for (var message in messages) {
      final index = _messages.indexWhere((m) => m.messageId == message.messageId);
      if (index != -1) {
        _messages[index] = message;
      }
    }
    await onPut(_cachedSession!, messages);
    return messages;
  }

  @override
  Future<void> removeMessages(Iterable<CoreMessage> messages) async {
    _messages.removeWhere(
      (message) => messages.map((e) => e.messageId).contains(message.messageId),
    );
    await onRemove?.call(messages);
  }
}
