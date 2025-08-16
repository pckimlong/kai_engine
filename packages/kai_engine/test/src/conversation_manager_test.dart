import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_engine/src/conversation_manager.dart';
import 'package:kai_engine/src/message_adapter_base.dart';
import 'package:kai_engine/src/message_repository_base.dart';
import 'package:kai_engine/src/models/conversation_session.dart';
import 'package:kai_engine/src/models/core_message.dart';
import 'package:mocktail/mocktail.dart';

class MockMessageRepository extends Mock implements MessageRepositoryBase<TestMessage> {}

class MockMessageAdapter extends Mock implements MessageAdapterBase<TestMessage> {}

class TestMessage {
  final String messageId;
  final String content;
  final String type;

  TestMessage({required this.messageId, required this.content, required this.type});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestMessage &&
          runtimeType == other.runtimeType &&
          messageId == other.messageId &&
          content == other.content &&
          type == other.type;

  @override
  int get hashCode => messageId.hashCode ^ content.hashCode ^ type.hashCode;
}

void main() {
  group('ConversationManager', () {
    late MockMessageRepository mockRepository;
    late MockMessageAdapter mockAdapter;
    late ConversationSession session;

    setUp(() {
      mockRepository = MockMessageRepository();
      mockAdapter = MockMessageAdapter();
      session = ConversationSession.withCurrentTime(id: 'test-session');

      registerFallbackValue(session);
      registerFallbackValue(<TestMessage>[]);
      registerFallbackValue(CoreMessage.user(content: 'test'));
      registerFallbackValue(TestMessage(messageId: 'test', content: 'test', type: 'user'));
    });

    group('create', () {
      test('should create instance and load initial messages', () async {
        final testMessages = [
          TestMessage(messageId: '1', content: 'Hello', type: 'user'),
          TestMessage(messageId: '2', content: 'Hi there', type: 'ai'),
        ];
        final coreMessages = [
          CoreMessage.user(messageId: '1', content: 'Hello'),
          CoreMessage.ai(messageId: '2', content: 'Hi there'),
        ];

        when(() => mockRepository.getMessages(any())).thenAnswer((_) async => testMessages);
        when(() => mockAdapter.toCoreMessage(testMessages[0])).thenReturn(coreMessages[0]);
        when(() => mockAdapter.toCoreMessage(testMessages[1])).thenReturn(coreMessages[1]);

        final manager = await ConversationManager.create(
          session: session,
          repository: mockRepository,
          messageAdapter: mockAdapter,
        );

        expect(await manager.getMessages(), equals(IList(coreMessages)));
        verify(() => mockRepository.getMessages(session)).called(1);
      });

      test('should handle empty repository on creation', () async {
        when(() => mockRepository.getMessages(any())).thenAnswer((_) async => <TestMessage>[]);

        final manager = await ConversationManager.create(
          session: session,
          repository: mockRepository,
          messageAdapter: mockAdapter,
        );

        expect(await manager.getMessages(), equals(IList<CoreMessage>(const [])));
      });
    });

    group('addMessages', () {
      late ConversationManager<TestMessage> manager;

      setUp(() async {
        when(() => mockRepository.getMessages(any())).thenAnswer((_) async => <TestMessage>[]);
        manager = await ConversationManager.create(
          session: session,
          repository: mockRepository,
          messageAdapter: mockAdapter,
        );
      });

      test('should add non-system messages and save to repository', () async {
        final userMessage = CoreMessage.user(messageId: '1', content: 'Hello');
        final aiMessage = CoreMessage.ai(messageId: '2', content: 'Hi there');
        final systemMessage = CoreMessage.system('System prompt');

        final testUserMessage = TestMessage(messageId: '1', content: 'Hello', type: 'user');
        final testAiMessage = TestMessage(messageId: '2', content: 'Hi there', type: 'ai');

        when(
          () => mockAdapter.fromCoreMessage(userMessage, session: session),
        ).thenReturn(testUserMessage);
        when(
          () => mockAdapter.fromCoreMessage(aiMessage, session: session),
        ).thenReturn(testAiMessage);
        when(() => mockAdapter.toCoreMessage(testUserMessage)).thenReturn(userMessage);
        when(() => mockAdapter.toCoreMessage(testAiMessage)).thenReturn(aiMessage);

        when(
          () => mockRepository.saveMessages(
            session: any(named: 'session'),
            messages: any(named: 'messages'),
          ),
        ).thenAnswer((_) async => [testUserMessage, testAiMessage]);

        await manager.addMessages(IList([userMessage, aiMessage, systemMessage]));

        final messages = await manager.getMessages();
        expect(messages.length, equals(2));
        expect(messages.any((m) => m.type == CoreMessageType.system), isFalse);

        verify(
          () => mockRepository.saveMessages(
            session: session,
            messages: any(named: 'messages'),
          ),
        ).called(1);
      });

      test('should provide optimistic updates - instant UI feedback', () async {
        final userMessage = CoreMessage.user(messageId: 'temp-1', content: 'Hello');
        final testMessage = TestMessage(messageId: 'temp-1', content: 'Hello', type: 'user');

        when(
          () => mockAdapter.fromCoreMessage(userMessage, session: session),
        ).thenReturn(testMessage);
        when(() => mockAdapter.toCoreMessage(testMessage)).thenReturn(userMessage);

        final completer = Completer<List<TestMessage>>();
        when(
          () => mockRepository.saveMessages(
            session: any(named: 'session'),
            messages: any(named: 'messages'),
          ),
        ).thenAnswer((_) => completer.future);

        final streamData = <IList<CoreMessage>>[];
        final subscription = manager.messagesStream.listen(streamData.add);

        // Start the operation (should immediately show optimistic update)
        final addFuture = manager.addMessages(IList([userMessage]));

        await Future.delayed(Duration.zero);

        // Should have optimistic update in stream
        expect(streamData.length, greaterThanOrEqualTo(1));
        expect(streamData.last.length, equals(1));
        expect(streamData.last.first.content, equals('Hello'));

        // Complete the repository operation
        completer.complete([testMessage]);
        await addFuture;

        await subscription.cancel();
      });

      test('should rollback optimistic updates on repository failure', () async {
        final userMessage = CoreMessage.user(messageId: 'temp-1', content: 'Hello');
        final testMessage = TestMessage(messageId: 'temp-1', content: 'Hello', type: 'user');

        when(
          () => mockAdapter.fromCoreMessage(userMessage, session: session),
        ).thenReturn(testMessage);
        when(() => mockAdapter.toCoreMessage(testMessage)).thenReturn(userMessage);

        when(
          () => mockRepository.saveMessages(
            session: any(named: 'session'),
            messages: any(named: 'messages'),
          ),
        ).thenThrow(Exception('Repository error'));

        final streamData = <IList<CoreMessage>>[];
        final subscription = manager.messagesStream.listen(streamData.add);

        // Should throw and rollback
        expect(
          () => manager.addMessages(IList([userMessage])),
          throwsA(isA<Exception>()),
        );

        await Future.delayed(Duration.zero);

        // Should be back to empty state
        final messages = await manager.getMessages();
        expect(messages.length, equals(0));

        await subscription.cancel();
      });

      test('should update messages with repository results', () async {
        final initialMessage = CoreMessage.user(messageId: 'temp-1', content: 'Hello');
        final updatedMessage = CoreMessage.user(messageId: '1', content: 'Hello');

        final testInitialMessage = TestMessage(messageId: 'temp-1', content: 'Hello', type: 'user');
        final testUpdatedMessage = TestMessage(messageId: '1', content: 'Hello', type: 'user');

        when(
          () => mockAdapter.fromCoreMessage(initialMessage, session: session),
        ).thenReturn(testInitialMessage);
        when(() => mockAdapter.toCoreMessage(testInitialMessage)).thenReturn(initialMessage);
        when(() => mockAdapter.toCoreMessage(testUpdatedMessage)).thenReturn(updatedMessage);

        when(
          () => mockRepository.saveMessages(
            session: any(named: 'session'),
            messages: any(named: 'messages'),
          ),
        ).thenAnswer((_) async => [testUpdatedMessage]);

        await manager.addMessages(IList([initialMessage]));

        final messages = await manager.getMessages();
        expect(messages.length, equals(1));
        expect(messages.first.messageId, equals('1'));
      });

      test('should emit messages through stream', () async {
        final userMessage = CoreMessage.user(messageId: '1', content: 'Hello');
        final testMessage = TestMessage(messageId: '1', content: 'Hello', type: 'user');

        when(
          () => mockAdapter.fromCoreMessage(userMessage, session: session),
        ).thenReturn(testMessage);
        when(() => mockAdapter.toCoreMessage(testMessage)).thenReturn(userMessage);
        when(
          () => mockRepository.saveMessages(
            session: any(named: 'session'),
            messages: any(named: 'messages'),
          ),
        ).thenAnswer((_) async => [testMessage]);

        final streamData = <IList<CoreMessage>>[];
        final subscription = manager.messagesStream.listen(streamData.add);

        await manager.addMessages(IList([userMessage]));

        await Future.delayed(Duration.zero);
        expect(streamData.length, greaterThanOrEqualTo(1));
        expect(streamData.last.length, equals(1));

        await subscription.cancel();
      });
    });

    group('updateMessages', () {
      late ConversationManager<TestMessage> manager;

      setUp(() async {
        final existingMessage = CoreMessage.user(messageId: '1', content: 'Original');
        final testMessage = TestMessage(messageId: '1', content: 'Original', type: 'user');

        when(() => mockRepository.getMessages(any())).thenAnswer((_) async => [testMessage]);
        when(() => mockAdapter.toCoreMessage(testMessage)).thenReturn(existingMessage);

        manager = await ConversationManager.create(
          session: session,
          repository: mockRepository,
          messageAdapter: mockAdapter,
        );
      });

      test('should update existing messages', () async {
        final updatedMessage = CoreMessage.user(messageId: '1', content: 'Updated');
        final testUpdatedMessage = TestMessage(messageId: '1', content: 'Updated', type: 'user');

        when(
          () => mockAdapter.fromCoreMessage(updatedMessage, session: session),
        ).thenReturn(testUpdatedMessage);
        when(() => mockAdapter.toCoreMessage(testUpdatedMessage)).thenReturn(updatedMessage);
        when(
          () => mockRepository.updateMessages(any()),
        ).thenAnswer((_) async => [testUpdatedMessage]);

        await manager.updateMessages(IList([updatedMessage]));

        final messages = await manager.getMessages();
        expect(messages.length, equals(1));
        expect(messages.first.content, equals('Updated'));

        verify(() => mockRepository.updateMessages(any())).called(1);
      });

      test('should provide optimistic updates for message updates', () async {
        final updatedMessage = CoreMessage.user(messageId: '1', content: 'Updated');
        final testUpdatedMessage = TestMessage(messageId: '1', content: 'Updated', type: 'user');

        when(
          () => mockAdapter.fromCoreMessage(updatedMessage, session: session),
        ).thenReturn(testUpdatedMessage);
        when(() => mockAdapter.toCoreMessage(testUpdatedMessage)).thenReturn(updatedMessage);

        final completer = Completer<List<TestMessage>>();
        when(() => mockRepository.updateMessages(any())).thenAnswer((_) => completer.future);

        final streamData = <IList<CoreMessage>>[];
        final subscription = manager.messagesStream.listen(streamData.add);

        // Start the update operation
        final updateFuture = manager.updateMessages(IList([updatedMessage]));

        await Future.delayed(Duration.zero);

        // Should show optimistic update
        expect(streamData.last.first.content, equals('Updated'));

        // Complete the repository operation
        completer.complete([testUpdatedMessage]);
        await updateFuture;

        await subscription.cancel();
      });

      test('should rollback optimistic updates on update failure', () async {
        final updatedMessage = CoreMessage.user(messageId: '1', content: 'Updated');
        final testUpdatedMessage = TestMessage(messageId: '1', content: 'Updated', type: 'user');

        when(
          () => mockAdapter.fromCoreMessage(updatedMessage, session: session),
        ).thenReturn(testUpdatedMessage);
        when(() => mockAdapter.toCoreMessage(testUpdatedMessage)).thenReturn(updatedMessage);

        when(() => mockRepository.updateMessages(any())).thenThrow(Exception('Update failed'));

        // Should throw and rollback to original state
        expect(
          () => manager.updateMessages(IList([updatedMessage])),
          throwsA(isA<Exception>()),
        );

        await Future.delayed(Duration.zero);

        // Should be back to original content
        final messages = await manager.getMessages();
        expect(messages.first.content, equals('Original'));
      });

      test('should ignore system messages in updates', () async {
        final systemMessage = CoreMessage.system('System prompt');

        when(() => mockRepository.updateMessages(any())).thenAnswer((_) async => <TestMessage>[]);

        await manager.updateMessages(IList([systemMessage]));

        verifyNever(() => mockAdapter.fromCoreMessage(systemMessage, session: session));
        verify(() => mockRepository.updateMessages(any())).called(1);
      });
    });

    group('removeMessages', () {
      late ConversationManager<TestMessage> manager;

      setUp(() async {
        final existingMessages = [
          CoreMessage.user(messageId: '1', content: 'Message 1'),
          CoreMessage.user(messageId: '2', content: 'Message 2'),
        ];
        final testMessages = [
          TestMessage(messageId: '1', content: 'Message 1', type: 'user'),
          TestMessage(messageId: '2', content: 'Message 2', type: 'user'),
        ];

        when(() => mockRepository.getMessages(any())).thenAnswer((_) async => testMessages);
        when(() => mockAdapter.toCoreMessage(testMessages[0])).thenReturn(existingMessages[0]);
        when(() => mockAdapter.toCoreMessage(testMessages[1])).thenReturn(existingMessages[1]);

        manager = await ConversationManager.create(
          session: session,
          repository: mockRepository,
          messageAdapter: mockAdapter,
        );
      });

      test('should remove messages from local state and repository', () async {
        final messageToRemove = CoreMessage.user(messageId: '1', content: 'Message 1');
        final testMessageToRemove = TestMessage(messageId: '1', content: 'Message 1', type: 'user');

        when(
          () => mockAdapter.fromCoreMessage(messageToRemove, session: session),
        ).thenReturn(testMessageToRemove);
        when(() => mockRepository.removeMessages(any())).thenAnswer((_) async {});

        await manager.removeMessages(IList([messageToRemove]));

        final messages = await manager.getMessages();
        expect(messages.length, equals(1));
        expect(messages.first.messageId, equals('2'));

        verify(() => mockRepository.removeMessages(any())).called(1);
      });

      test('should provide optimistic updates for message removal', () async {
        final messageToRemove = CoreMessage.user(messageId: '1', content: 'Message 1');
        final testMessageToRemove = TestMessage(messageId: '1', content: 'Message 1', type: 'user');

        when(
          () => mockAdapter.fromCoreMessage(messageToRemove, session: session),
        ).thenReturn(testMessageToRemove);

        final completer = Completer<void>();
        when(() => mockRepository.removeMessages(any())).thenAnswer((_) => completer.future);

        final streamData = <IList<CoreMessage>>[];
        final subscription = manager.messagesStream.listen(streamData.add);

        // Start the remove operation
        final removeFuture = manager.removeMessages(IList([messageToRemove]));

        await Future.delayed(Duration.zero);

        // Should show optimistic removal (only 1 message left)
        expect(streamData.last.length, equals(1));
        expect(streamData.last.first.messageId, equals('2'));

        // Complete the repository operation
        completer.complete();
        await removeFuture;

        await subscription.cancel();
      });

      test('should rollback optimistic updates on removal failure', () async {
        final messageToRemove = CoreMessage.user(messageId: '1', content: 'Message 1');
        final testMessageToRemove = TestMessage(messageId: '1', content: 'Message 1', type: 'user');

        when(
          () => mockAdapter.fromCoreMessage(messageToRemove, session: session),
        ).thenReturn(testMessageToRemove);
        when(() => mockRepository.removeMessages(any())).thenThrow(Exception('Remove failed'));

        // Should throw and rollback to original state
        expect(
          () => manager.removeMessages(IList([messageToRemove])),
          throwsA(isA<Exception>()),
        );

        await Future.delayed(Duration.zero);

        // Should still have both messages
        final messages = await manager.getMessages();
        expect(messages.length, equals(2));
      });
    });

    group('streams', () {
      late ConversationManager<TestMessage> manager;

      setUp(() async {
        when(() => mockRepository.getMessages(any())).thenAnswer((_) async => <TestMessage>[]);
        manager = await ConversationManager.create(
          session: session,
          repository: mockRepository,
          messageAdapter: mockAdapter,
        );
      });

      test('should provide loading state stream', () async {
        final loadingStates = <bool>[];
        final subscription = manager.isLoadingStream.listen(loadingStates.add);

        await Future.delayed(Duration.zero);
        expect(loadingStates.isNotEmpty, isTrue);
        expect(loadingStates.last, isFalse);

        await subscription.cancel();
      });

      test('should indicate loading during message loading', () async {
        final completer = Completer<List<TestMessage>>();
        when(() => mockRepository.getMessages(any())).thenAnswer((_) => completer.future);

        final loadingStates = <bool>[];

        final managerFuture = ConversationManager.create(
          session: session,
          repository: mockRepository,
          messageAdapter: mockAdapter,
        );

        await Future.delayed(const Duration(milliseconds: 10));

        completer.complete(<TestMessage>[]);
        final manager = await managerFuture;

        final subscription = manager.isLoadingStream.listen(loadingStates.add);
        await Future.delayed(Duration.zero);

        expect(loadingStates.last, isFalse);

        await subscription.cancel();
      });
    });

    group('dispose', () {
      test('should dispose without errors', () async {
        when(() => mockRepository.getMessages(any())).thenAnswer((_) async => <TestMessage>[]);

        final manager = await ConversationManager.create(
          session: session,
          repository: mockRepository,
          messageAdapter: mockAdapter,
        );

        expect(() => manager.dispose(), returnsNormally);
      });
    });

    group('placeholder functionality', () {
      late ConversationManager<TestMessage> manager;

      setUp(() async {
        when(() => mockRepository.getMessages(any())).thenAnswer((_) async => <TestMessage>[]);
        manager = await ConversationManager.create(
          session: session,
          repository: mockRepository,
          messageAdapter: mockAdapter,
        );
      });

      test('addPlaceholderUserMessage should add message immediately', () async {
        final placeholder = manager.addPlaceholderUserMessage('Hello');

        final messages = await manager.getMessages();
        expect(messages.length, equals(1));
        expect(messages.first.content, equals('Hello'));
        expect(messages.first.messageId, equals(placeholder.messageId));
      });

      test('replacePlaceholderMessage should replace and persist', () async {
        final placeholder = manager.addPlaceholderUserMessage('Hello');
        final actualMessage = CoreMessage.user(messageId: '1', content: 'Hello');
        final testMessage = TestMessage(messageId: '1', content: 'Hello', type: 'user');

        when(
          () => mockAdapter.fromCoreMessage(actualMessage, session: session),
        ).thenReturn(testMessage);
        when(() => mockAdapter.toCoreMessage(testMessage)).thenReturn(actualMessage);
        when(
          () => mockRepository.saveMessages(
            session: any(named: 'session'),
            messages: any(named: 'messages'),
          ),
        ).thenAnswer((_) async => [testMessage]);

        await manager.replacePlaceholderMessage(placeholder, actualMessage);

        final messages = await manager.getMessages();
        expect(messages.length, equals(1));
        expect(messages.first.messageId, equals('1')); // Should have repository ID
        expect(messages.first.content, equals('Hello'));

        verify(
          () => mockRepository.saveMessages(
            session: session,
            messages: any(named: 'messages'),
          ),
        ).called(1);
      });

      test('replacePlaceholderMessage should provide optimistic updates', () async {
        final placeholder = manager.addPlaceholderUserMessage('Hello');
        final actualMessage = CoreMessage.user(messageId: '1', content: 'Hello');
        final testMessage = TestMessage(messageId: '1', content: 'Hello', type: 'user');

        when(
          () => mockAdapter.fromCoreMessage(actualMessage, session: session),
        ).thenReturn(testMessage);
        when(() => mockAdapter.toCoreMessage(testMessage)).thenReturn(actualMessage);

        final completer = Completer<List<TestMessage>>();
        when(
          () => mockRepository.saveMessages(
            session: any(named: 'session'),
            messages: any(named: 'messages'),
          ),
        ).thenAnswer((_) => completer.future);

        final streamData = <IList<CoreMessage>>[];
        final subscription = manager.messagesStream.listen(streamData.add);

        // Start the replacement operation
        final replaceFuture = manager.replacePlaceholderMessage(placeholder, actualMessage);

        await Future.delayed(Duration.zero);

        // Should show optimistic replacement
        expect(streamData.last.length, equals(1));
        expect(streamData.last.first.content, equals('Hello'));

        // Complete the repository operation
        completer.complete([testMessage]);
        await replaceFuture;

        await subscription.cancel();
      });

      test('replacePlaceholderMessage should rollback on failure', () async {
        final placeholder = manager.addPlaceholderUserMessage('Hello');
        final actualMessage = CoreMessage.user(messageId: '1', content: 'Hello');
        final testMessage = TestMessage(messageId: '1', content: 'Hello', type: 'user');

        when(
          () => mockAdapter.fromCoreMessage(actualMessage, session: session),
        ).thenReturn(testMessage);
        when(() => mockAdapter.toCoreMessage(testMessage)).thenReturn(actualMessage);
        when(
          () => mockRepository.saveMessages(
            session: any(named: 'session'),
            messages: any(named: 'messages'),
          ),
        ).thenThrow(Exception('Save failed'));

        // Should throw and rollback to original placeholder state
        expect(
          () => manager.replacePlaceholderMessage(placeholder, actualMessage),
          throwsA(isA<Exception>()),
        );

        await Future.delayed(Duration.zero);

        // Should still have placeholder
        final messages = await manager.getMessages();
        expect(messages.length, equals(1));
        expect(messages.first.messageId, equals(placeholder.messageId));
      });
    });
  });
}
