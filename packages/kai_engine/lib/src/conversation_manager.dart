import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:rxdart/rxdart.dart';

import 'message_adapter_base.dart';
import 'message_repository_base.dart';
import 'models/conversation_session.dart';
import 'models/core_message.dart';

/// ConversationManager - Manages conversation state and persistence
///
/// Handles saving and retrieving messages for a conversation session.
class ConversationManager<T> {
  final ConversationSession session;
  final MessageRepositoryBase<T> _repository;
  final MessageAdapterBase<T> _messageAdapter;
  IList<CoreMessage> _messages = IList(const []);
  final BehaviorSubject<IList<CoreMessage>> _messagesController =
      BehaviorSubject<IList<CoreMessage>>();
  final BehaviorSubject<bool> _loadingController = BehaviorSubject<bool>.seeded(
    false,
  );

  ConversationManager._({
    required this.session,
    required MessageRepositoryBase<T> repository,
    required MessageAdapterBase<T> messageAdapter,
  }) : _repository = repository,
       _messageAdapter = messageAdapter;

  /// Factory constructor with async initialization
  static Future<ConversationManager<T>> create<T>({
    required ConversationSession session,
    required MessageRepositoryBase<T> repository,
    required MessageAdapterBase<T> messageAdapter,
  }) async {
    final manager = ConversationManager._(
      session: session,
      repository: repository,
      messageAdapter: messageAdapter,
    );
    await manager._loadMessages();
    return manager;
  }

  /// Loads messages from the repository
  Future<void> _loadMessages() async {
    _loadingController.add(true);
    try {
      final loadedMessages = await _repository.getMessages(session);
      _messages = IList(loadedMessages.map(_messageAdapter.toCoreMessage));
      _messagesController.add(_messages);
    } finally {
      _loadingController.add(false);
    }
  }

  /// Adds a message to the conversation
  Future<IList<CoreMessage>> addMessages(IList<CoreMessage> messages) async {
    // Ensure system messages are ignored
    final persistentMessages = messages
        .where((m) => m.isMessageSavable)
        .toList();

    // Store original state for rollback
    final originalMessages = _messages;

    try {
      // Optimistic update: Add to local state first for instant UI feedback
      _messages = _messages.addAll(persistentMessages);
      _messagesController.add(_messages);

      // Save to repository
      final result = await _repository
          .saveMessages(
            session: session,
            messages: persistentMessages.map(
              (e) => _messageAdapter.fromCoreMessage(e, session: session),
            ),
          )
          .then((e) => e.map(_messageAdapter.toCoreMessage));

      _messages = _messages
          .removeWhere(
            (e) => persistentMessages.any((m) => m.messageId == e.messageId),
          )
          .addAll(result);
      _messagesController.add(_messages);
      return result.toIList();
    } catch (error) {
      // Rollback optimistic update on failure
      _messages = originalMessages;
      _messagesController.add(_messages);
      rethrow;
    }
  }

  Future<void> updateMessages(IList<CoreMessage> messages) async {
    final persistentMessages = messages
        .where((m) => m.isMessageSavable)
        .toList();

    // Store original state for rollback
    final originalMessages = _messages;

    try {
      // Create a map for efficient lookups
      final messageMap = {for (var m in persistentMessages) m.messageId: m};

      // Optimistic update: Update local state first for instant UI feedback
      _messages = _messages.map((message) {
        return messageMap[message.messageId] ?? message;
      }).toIList();
      _messagesController.add(_messages);

      // Update repository
      final result = await _repository
          .updateMessages(
            persistentMessages.map(
              (e) => _messageAdapter.fromCoreMessage(e, session: session),
            ),
          )
          .then((e) => e.map(_messageAdapter.toCoreMessage));

      // Create a map for the repository results
      final resultMap = {for (var m in result) m.messageId: m};

      // Replace optimistic updates with actual repository results
      _messages = _messages.map((message) {
        return resultMap[message.messageId] ?? message;
      }).toIList();
      _messagesController.add(_messages);
    } catch (error) {
      // Rollback optimistic update on failure
      _messages = originalMessages;
      _messagesController.add(_messages);
      rethrow;
    }
  }

  /// Gets the current list of messages
  Future<IList<CoreMessage>> getMessages() async => _messages;

  /// Removes messages from the conversation
  Future<void> removeMessages(IList<CoreMessage> messages) async {
    // Store original state for rollback
    final originalMessages = _messages;

    try {
      // Optimistic update: Remove from local state first for instant UI feedback
      _messages = _messages.removeAll(messages);
      _messagesController.add(_messages);

      // Remove from repository
      await _repository.removeMessages(
        messages.map(
          (e) => _messageAdapter.fromCoreMessage(e, session: session),
        ),
      );
    } catch (error) {
      // Rollback optimistic update on failure
      _messages = originalMessages;
      _messagesController.add(_messages);
      rethrow;
    }
  }

  /// Stream of messages
  Stream<IList<CoreMessage>> get messagesStream => _messagesController.stream;

  /// Stream indicating if the manager is loading
  Stream<bool> get isLoadingStream => _loadingController.stream;

  /// Disposes of the controller resources
  Future<void> dispose() async {
    await _messagesController.close();
    await _loadingController.close();
  }
}

/// Prebuilt for in memory management of conversation messages
final class InMemoryConversationManager
    extends ConversationManager<CoreMessage> {
  InMemoryConversationManager({required super.session})
    : super._(
        repository: InMemoryMessageRepository(),
        messageAdapter: CoreMessageAdapter(),
      );
}
