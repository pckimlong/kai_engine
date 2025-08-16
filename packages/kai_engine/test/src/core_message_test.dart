import 'package:flutter_test/flutter_test.dart';
import 'package:kai_engine/src/models/core_message.dart';

void main() {
  group('CoreMessageType', () {
    test('has all expected values', () {
      expect(CoreMessageType.values, hasLength(5));
      expect(CoreMessageType.values, contains(CoreMessageType.system));
      expect(CoreMessageType.values, contains(CoreMessageType.user));
      expect(CoreMessageType.values, contains(CoreMessageType.ai));
      expect(CoreMessageType.values, contains(CoreMessageType.function));
      expect(CoreMessageType.values, contains(CoreMessageType.unknown));
    });
  });

  group('CoreMessage constructors', () {
    group('user factory', () {
      test('creates user message with content', () {
        const content = 'Hello, world!';
        final message = CoreMessage.user(content: content);

        expect(message.content, equals(content));
        expect(message.type, equals(CoreMessageType.user));
        expect(message.messageId, isNotEmpty);
        expect(message.extensions, equals({}));
      });

      test('creates user message with custom messageId', () {
        const messageId = 'custom-id';
        const content = 'Hello with custom ID';
        final message = CoreMessage.user(messageId: messageId, content: content);

        expect(message.messageId, equals(messageId));
        expect(message.content, equals(content));
        expect(message.type, equals(CoreMessageType.user));
      });

      test('generates unique messageId when not provided', () {
        final message1 = CoreMessage.user(content: 'Message 1');
        final message2 = CoreMessage.user(content: 'Message 2');

        expect(message1.messageId, isNot(equals(message2.messageId)));
        expect(message1.messageId, isNotEmpty);
        expect(message2.messageId, isNotEmpty);
      });
    });

    group('ai factory', () {
      test('creates ai message with content', () {
        const content = 'AI response here';
        final message = CoreMessage.ai(content: content);

        expect(message.content, equals(content));
        expect(message.type, equals(CoreMessageType.ai));
        expect(message.messageId, isNotEmpty);
        expect(message.extensions, equals({}));
      });

      test('creates ai message with custom messageId', () {
        const messageId = 'ai-custom-id';
        const content = 'AI with custom ID';
        final message = CoreMessage.ai(messageId: messageId, content: content);

        expect(message.messageId, equals(messageId));
        expect(message.content, equals(content));
        expect(message.type, equals(CoreMessageType.ai));
      });

      test('generates unique messageId when not provided', () {
        final message1 = CoreMessage.ai(content: 'AI Message 1');
        final message2 = CoreMessage.ai(content: 'AI Message 2');

        expect(message1.messageId, isNot(equals(message2.messageId)));
      });
    });

    group('system factory', () {
      test('creates system message with prompt', () {
        const prompt = 'You are a helpful assistant';
        final message = CoreMessage.system(prompt);

        expect(message.content, equals(prompt));
        expect(message.type, equals(CoreMessageType.system));
        expect(message.messageId, isNotEmpty);
        expect(message.extensions, equals({}));
      });

      test('generates unique messageId for system messages', () {
        final message1 = CoreMessage.system('System prompt 1');
        final message2 = CoreMessage.system('System prompt 2');

        expect(message1.messageId, isNot(equals(message2.messageId)));
      });
    });

    group('create factory', () {
      test('creates message with all parameters', () {
        const content = 'Custom message';
        const type = CoreMessageType.function;
        final extensions = {'key': 'value', 'number': 42};

        final message = CoreMessage.create(content: content, type: type, extensions: extensions);

        expect(message.content, equals(content));
        expect(message.type, equals(type));
        expect(message.extensions, equals(extensions));
        expect(message.messageId, isNotEmpty);
      });

      test('generates unique messageId', () {
        final message1 = CoreMessage.create(
          content: 'Message 1',
          type: CoreMessageType.unknown,
          extensions: {},
        );
        final message2 = CoreMessage.create(
          content: 'Message 2',
          type: CoreMessageType.unknown,
          extensions: {},
        );

        expect(message1.messageId, isNot(equals(message2.messageId)));
      });
    });

    group('main constructor', () {
      test('creates message with all parameters', () {
        const messageId = 'test-id';
        const type = CoreMessageType.user;
        const content = 'Test content';
        final extensions = {'test': true};

        final message = CoreMessage(
          messageId: messageId,
          type: type,
          content: content,
          extensions: extensions,
        );

        expect(message.messageId, equals(messageId));
        expect(message.type, equals(type));
        expect(message.content, equals(content));
        expect(message.extensions, equals(extensions));
      });

      test('uses empty extensions by default', () {
        const message = CoreMessage(
          messageId: 'test-id',
          type: CoreMessageType.ai,
          content: 'Test content',
        );

        expect(message.extensions, equals({}));
      });
    });
  });

  group('isDisplayable getter', () {
    test('returns true for user messages', () {
      final message = CoreMessage.user(content: 'User message');
      expect(message.isDisplayable, isTrue);
    });

    test('returns true for ai messages', () {
      final message = CoreMessage.ai(content: 'AI message');
      expect(message.isDisplayable, isTrue);
    });

    test('returns false for system messages', () {
      final message = CoreMessage.system('System prompt');
      expect(message.isDisplayable, isFalse);
    });

    test('returns false for function messages', () {
      final message = CoreMessage.create(
        content: 'Function result',
        type: CoreMessageType.function,
        extensions: {},
      );
      expect(message.isDisplayable, isFalse);
    });

    test('returns false for unknown messages', () {
      final message = CoreMessage.create(
        content: 'Unknown message',
        type: CoreMessageType.unknown,
        extensions: {},
      );
      expect(message.isDisplayable, isFalse);
    });
  });

  group('copyWithExtensions', () {
    test('updates existing extension values', () {
      final original = CoreMessage.user(
        content: 'Test',
      ).copyWith(extensions: {'key1': 'value1', 'key2': 'value2'});

      final updated = original.copyWithExtensions({'key1': 'updated_value1'});

      expect(updated.extensions['key1'], equals('updated_value1'));
      expect(updated.extensions['key2'], equals('value2'));
      expect(updated.content, equals(original.content));
      expect(updated.type, equals(original.type));
      expect(updated.messageId, equals(original.messageId));
    });

    test('adds new keys to extensions', () {
      final original = CoreMessage.user(
        content: 'Test',
      ).copyWith(extensions: {'existing': 'value'});

      final updated = original.copyWithExtensions({'existing': 'updated', 'new_key': 'new_value'});

      expect(updated.extensions['existing'], equals('updated'));
      expect(updated.extensions['new_key'], equals('new_value'));
      expect(updated.extensions, hasLength(2));
    });

    test('preserves original values when update map lacks keys', () {
      final original = CoreMessage.user(
        content: 'Test',
      ).copyWith(extensions: {'key1': 'value1', 'key2': 'value2'});

      final updated = original.copyWithExtensions({'key1': 'updated'});

      expect(updated.extensions['key1'], equals('updated'));
      expect(updated.extensions['key2'], equals('value2'));
    });

    test('adds extensions to empty extensions', () {
      final original = CoreMessage.user(content: 'Test');
      final updated = original.copyWithExtensions({'key': 'value'});

      expect(updated.extensions['key'], equals('value'));
      expect(updated.extensions, hasLength(1));
    });

    test('removes keys when null value is provided', () {
      final original = CoreMessage.user(
        content: 'Test',
      ).copyWith(extensions: {'key1': 'value1', 'key2': 'value2'});

      final updated = original.copyWithExtensions({'key1': null});

      expect(updated.extensions.containsKey('key1'), isFalse);
      expect(updated.extensions['key2'], equals('value2'));
      expect(updated.extensions, hasLength(1));
    });
  });

  group('JSON serialization', () {
    test('serializes and deserializes correctly', () {
      final extensions = {'metadata': 'test', 'count': 5};
      final original = CoreMessage.create(
        content: 'Test message',
        type: CoreMessageType.user,
        extensions: extensions,
      );

      final json = original.toJson();
      final deserialized = CoreMessage.fromJson(json);

      expect(deserialized.messageId, equals(original.messageId));
      expect(deserialized.type, equals(original.type));
      expect(deserialized.content, equals(original.content));
      expect(deserialized.extensions, equals(original.extensions));
    });

    test('handles empty extensions in JSON', () {
      final original = CoreMessage.user(content: 'Simple message');

      final json = original.toJson();
      final deserialized = CoreMessage.fromJson(json);

      expect(deserialized.extensions, equals({}));
    });

    test('preserves all message types through JSON', () {
      for (final type in CoreMessageType.values) {
        final original = CoreMessage.create(
          content: 'Content for $type',
          type: type,
          extensions: {},
        );

        final json = original.toJson();
        final deserialized = CoreMessage.fromJson(json);

        expect(deserialized.type, equals(type));
      }
    });
  });

  group('copyWith', () {
    test('creates copy with modified content', () {
      final original = CoreMessage.user(content: 'Original content');
      final modified = original.copyWith(content: 'Modified content');

      expect(modified.content, equals('Modified content'));
      expect(modified.messageId, equals(original.messageId));
      expect(modified.type, equals(original.type));
      expect(modified.extensions, equals(original.extensions));
    });

    test('creates copy with modified type', () {
      final original = CoreMessage.user(content: 'Test content');
      final modified = original.copyWith(type: CoreMessageType.ai);

      expect(modified.type, equals(CoreMessageType.ai));
      expect(modified.content, equals(original.content));
      expect(modified.messageId, equals(original.messageId));
    });

    test('creates copy with modified extensions', () {
      final original = CoreMessage.user(content: 'Test content');
      final newExtensions = {'new': 'data'};
      final modified = original.copyWith(extensions: newExtensions);

      expect(modified.extensions, equals(newExtensions));
      expect(modified.content, equals(original.content));
      expect(modified.type, equals(original.type));
    });
  });

  group('equality and immutability', () {
    test('two messages with same data are equal', () {
      const messageId = 'test-id';
      const content = 'Test content';
      const type = CoreMessageType.user;
      final extensions = {'key': 'value'};

      final message1 = CoreMessage(
        messageId: messageId,
        type: type,
        content: content,
        extensions: extensions,
      );

      final message2 = CoreMessage(
        messageId: messageId,
        type: type,
        content: content,
        extensions: extensions,
      );

      expect(message1, equals(message2));
      expect(message1.hashCode, equals(message2.hashCode));
    });

    test('messages with different content are not equal', () {
      final message1 = CoreMessage.user(content: 'Content 1');
      final message2 = CoreMessage.user(content: 'Content 2');

      expect(message1, isNot(equals(message2)));
    });

    test('messages are immutable', () {
      final message = CoreMessage.user(content: 'Original');
      final modified = message.copyWith(content: 'Modified');

      expect(message.content, equals('Original'));
      expect(modified.content, equals('Modified'));
      expect(message, isNot(equals(modified)));
    });
  });
}
