import 'package:kai_engine/src/message_repository_base.dart';
import 'package:kai_engine/src/models/conversation_session.dart';
import 'package:kai_engine/src/models/core_message.dart';
import 'package:test/test.dart';

void main() {
  group('InMemoryMessageRepository', () {
    test('should sort messages by timestamp on initialization', () async {
      final now = DateTime.now();
      final msg1 = CoreMessage.user(messageId: '1', content: 'First');
      final msg2 = CoreMessage.ai(messageId: '2', content: 'Second');
      final msg3 = CoreMessage.user(messageId: '3', content: 'Third');

      // Create messages with different timestamps
      final messages = [
        msg3.copyWith(timestamp: now.add(Duration(minutes: 2))),
        msg1.copyWith(timestamp: now),
        msg2.copyWith(timestamp: now.add(Duration(minutes: 1))),
      ];

      final repo = InMemoryMessageRepository(initialMessages: messages);
      final session = ConversationSession.withCurrentTime(id: 'test');
      final result = await repo.getMessages(session);

      // Should be sorted by timestamp
      expect(result.first.messageId, equals('1'));
      expect(result.elementAt(1).messageId, equals('2'));
      expect(result.last.messageId, equals('3'));
    });
  });

  group('CoreMessageRepository', () {
    late ConversationSession session;
    late CoreMessage testMessage1;
    late CoreMessage testMessage2;

    setUp(() {
      session = ConversationSession.withCurrentTime(id: 'test-session');
      testMessage1 = CoreMessage.user(messageId: 'msg-1', content: 'Hello');
      testMessage2 = CoreMessage.ai(messageId: 'msg-2', content: 'Hi there');
    });

    group('constructor', () {
      test('should create instance with required callbacks', () {
        final repo = CoreMessageRepository(onInitial: (s) async => [], onPut: (s, msgs) async {});

        expect(repo, isA<CoreMessageRepository>());
      });

      test('should create instance with optional onRemove callback', () {
        final repo = CoreMessageRepository(
          onInitial: (s) async => [],
          onPut: (s, msgs) async {},
          onRemove: (msgs) async {},
        );

        expect(repo, isA<CoreMessageRepository>());
      });
    });

    group('getMessages', () {
      test('should call onInitial callback with session and populate internal state', () async {
        var capturedSession;
        final repo = CoreMessageRepository(
          onInitial: (s) {
            capturedSession = s;
            return Future.value([testMessage1]);
          },
          onPut: (s, msgs) async {},
        );

        final result = await repo.getMessages(session);

        expect(capturedSession, equals(session));
        expect(result, equals([testMessage1]));
      });

      test('should sort messages by timestamp on initial load', () async {
        final now = DateTime.now();
        final msg1 = CoreMessage.user(messageId: '1', content: 'First');
        final msg2 = CoreMessage.ai(messageId: '2', content: 'Second');
        final msg3 = CoreMessage.user(messageId: '3', content: 'Third');

        // Return messages out of order
        final repo = CoreMessageRepository(
          onInitial: (s) async => [
            msg3.copyWith(timestamp: now.add(Duration(minutes: 2))),
            msg1.copyWith(timestamp: now),
            msg2.copyWith(timestamp: now.add(Duration(minutes: 1))),
          ],
          onPut: (s, msgs) async {},
        );

        final result = await repo.getMessages(session);

        // Should be sorted by timestamp
        expect(result.first.messageId, equals('1'));
        expect(result.elementAt(1).messageId, equals('2'));
        expect(result.last.messageId, equals('3'));
      });

      test('should populate internal state from onInitial callback', () async {
        final repo = CoreMessageRepository(
          onInitial: (s) async => [testMessage1, testMessage2],
          onPut: (s, msgs) async {},
        );

        await repo.getMessages(session);
        final result = await repo.getMessages(session);

        expect(result, equals([testMessage1, testMessage2]));
      });

      test('should cache state and not reload on subsequent getMessages calls', () async {
        var callCount = 0;
        final repo = CoreMessageRepository(
          onInitial: (s) async {
            callCount++;
            return callCount == 1 ? [testMessage1] : [testMessage2];
          },
          onPut: (s, msgs) async {},
        );

        final result1 = await repo.getMessages(session);
        final result2 = await repo.getMessages(session);

        expect(callCount, equals(1)); // Only called once
        expect(result1, equals([testMessage1]));
        expect(result2, equals([testMessage1])); // Returns cached state
      });

      test('should cache session for later use', () async {
        final repo = CoreMessageRepository(
          onInitial: (s) async => [testMessage1],
          onPut: (s, msgs) async {},
        );

        await repo.getMessages(session);

        final updatedMessage = testMessage1.copyWith(content: 'Updated');
        final result = await repo.updateMessages([updatedMessage]);

        expect(result, contains(updatedMessage));
      });
    });

    group('saveMessages', () {
      test('should call onPut callback with session and messages for persistence', () async {
        var capturedSession;
        var capturedMessages;
        final repo = CoreMessageRepository(
          onInitial: (s) async => [],
          onPut: (s, msgs) {
            capturedSession = s;
            capturedMessages = msgs;
            return Future.value(msgs);
          },
        );

        await repo.saveMessages(session: session, messages: [testMessage1]);

        expect(capturedSession, equals(session));
        expect(capturedMessages, equals([testMessage1]));
      });

      test('should add messages to internal state', () async {
        final repo = CoreMessageRepository(onInitial: (s) async => [], onPut: (s, msgs) async {});

        await repo.saveMessages(session: session, messages: [testMessage1]);
        final result = await repo.getMessages(session);

        expect(result, equals([testMessage1]));
      });

      test('should accumulate messages in internal state across multiple saves', () async {
        final repo = CoreMessageRepository(onInitial: (s) async => [], onPut: (s, msgs) async {});

        await repo.saveMessages(session: session, messages: [testMessage1]);
        await repo.saveMessages(session: session, messages: [testMessage2]);
        final result = await repo.getMessages(session);

        expect(result, equals([testMessage1, testMessage2]));
      });

      test('should cache session for later use', () async {
        final repo = CoreMessageRepository(onInitial: (s) async => [], onPut: (s, msgs) async {});

        await repo.saveMessages(session: session, messages: [testMessage1]);

        final updatedMessage = testMessage1.copyWith(content: 'Updated');
        final result = await repo.updateMessages([updatedMessage]);

        expect(result, contains(updatedMessage));
      });
    });

    group('updateMessages', () {
      test('should call onPut callback with cached session and messages for persistence', () async {
        var capturedSession;
        var capturedMessages;
        final repo = CoreMessageRepository(
          onInitial: (s) async => [testMessage1],
          onPut: (s, msgs) {
            capturedSession = s;
            capturedMessages = msgs;
            return Future.value(msgs);
          },
        );

        await repo.getMessages(session);
        await repo.updateMessages([testMessage1]);

        expect(capturedSession, equals(session));
        expect(capturedMessages, equals([testMessage1]));
      });

      test('should update messages in internal state', () async {
        final repo = CoreMessageRepository(
          onInitial: (s) async => [testMessage1],
          onPut: (s, msgs) async {},
        );

        await repo.getMessages(session);
        final updated = testMessage1.copyWith(content: 'Updated');
        await repo.updateMessages([updated]);
        final result = await repo.getMessages(session);

        expect(result.first.content, equals('Updated'));
      });

      test('should throw StateError when session not initialized', () async {
        final repo = CoreMessageRepository(onInitial: (s) async => [], onPut: (s, msgs) async {});

        expect(
          () => repo.updateMessages([testMessage1]),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('Session not initialized'),
            ),
          ),
        );
      });

      test('should use session from saveMessages if getMessages not called', () async {
        final repo = CoreMessageRepository(onInitial: (s) async => [], onPut: (s, msgs) async {});

        await repo.saveMessages(session: session, messages: [testMessage1]);
        final updated = testMessage1.copyWith(content: 'Updated');
        await repo.updateMessages([updated]);
        final result = await repo.getMessages(session);

        expect(result.first.content, equals('Updated'));
      });

      test('should only update existing messages, not add new ones', () async {
        final repo = CoreMessageRepository(
          onInitial: (s) async => [testMessage1],
          onPut: (s, msgs) async {},
        );

        await repo.getMessages(session);
        await repo.updateMessages([testMessage2]);
        final result = await repo.getMessages(session);

        expect(result, equals([testMessage1])); // testMessage2 not added
      });
    });

    group('removeMessages', () {
      test('should call onRemove callback when provided for persistence', () async {
        var capturedMessages;
        final repo = CoreMessageRepository(
          onInitial: (s) async => [testMessage1, testMessage2],
          onPut: (s, msgs) async {},
          onRemove: (msgs) {
            capturedMessages = msgs;
            return Future.value();
          },
        );

        await repo.getMessages(session);
        await repo.removeMessages([testMessage1]);

        expect(capturedMessages, equals([testMessage1]));
      });

      test('should remove messages from internal state', () async {
        final repo = CoreMessageRepository(
          onInitial: (s) async => [testMessage1, testMessage2],
          onPut: (s, msgs) async {},
        );

        await repo.getMessages(session);
        await repo.removeMessages([testMessage1]);
        final result = await repo.getMessages(session);

        expect(result, equals([testMessage2]));
      });

      test('should complete successfully when onRemove is null', () async {
        final repo = CoreMessageRepository(
          onInitial: (s) async => [testMessage1],
          onPut: (s, msgs) async {},
        );

        await repo.getMessages(session);
        await expectLater(repo.removeMessages([testMessage1]), completes);
      });

      test('should handle multiple messages in removeMessages', () async {
        final repo = CoreMessageRepository(
          onInitial: (s) async => [testMessage1, testMessage2],
          onPut: (s, msgs) async {},
        );

        await repo.getMessages(session);
        await repo.removeMessages([testMessage1, testMessage2]);
        final result = await repo.getMessages(session);

        expect(result, isEmpty);
      });
    });

    group('integration scenarios', () {
      test('should handle complete message lifecycle with persistence callbacks', () async {
        final persistedMessages = <CoreMessage>[];

        final repo = CoreMessageRepository(
          onInitial: (s) async => persistedMessages.toList(),
          onPut: (s, msgs) async {
            // Simulate upsert in persistence layer
            for (var msg in msgs) {
              final index = persistedMessages.indexWhere((m) => m.messageId == msg.messageId);
              if (index != -1) {
                persistedMessages[index] = msg;
              } else {
                persistedMessages.add(msg);
              }
            }
          },
          onRemove: (msgs) async {
            persistedMessages.removeWhere((m) => msgs.contains(m));
          },
        );

        // Initial load
        var current = await repo.getMessages(session);
        expect(current, isEmpty);

        // Save messages
        await repo.saveMessages(session: session, messages: [testMessage1, testMessage2]);
        current = await repo.getMessages(session);
        expect(current.length, equals(2));

        // Update message
        final updated = testMessage1.copyWith(content: 'Updated content');
        await repo.updateMessages([updated]);
        current = await repo.getMessages(session);
        expect(current.any((m) => m.content == 'Updated content'), isTrue);
        expect(current.length, equals(2)); // Still 2 messages, one updated

        // Remove message
        await repo.removeMessages([testMessage2]);
        current = await repo.getMessages(session);
        expect(current.length, equals(1));
        expect(current.first.messageId, equals(testMessage1.messageId));
        expect(current.first.content, equals('Updated content'));
      });

      test('should handle append-only pattern without onRemove', () async {
        final repo = CoreMessageRepository(onInitial: (s) async => [], onPut: (s, msgs) async {});

        await repo.saveMessages(session: session, messages: [testMessage1]);
        await repo.saveMessages(session: session, messages: [testMessage2]);

        final current = await repo.getMessages(session);
        expect(current.length, equals(2));

        // Remove removes from internal state even without onRemove callback
        await repo.removeMessages([testMessage1]);
        final afterRemove = await repo.getMessages(session);
        expect(afterRemove.length, equals(1)); // 1 removed, 1 remains
        expect(afterRemove.first.messageId, equals(testMessage2.messageId));
      });

      test('should maintain state independently of persistence layer', () async {
        var persistenceCallCount = 0;

        final repo = CoreMessageRepository(
          onInitial: (s) async {
            persistenceCallCount++;
            return [];
          },
          onPut: (s, msgs) async {},
        );

        // First load calls persistence
        await repo.getMessages(session);
        expect(persistenceCallCount, equals(1));

        // Subsequent reads use internal state, don't call persistence
        await repo.getMessages(session);
        expect(persistenceCallCount, equals(1)); // Still 1, not 2
      });
    });
  });
}
