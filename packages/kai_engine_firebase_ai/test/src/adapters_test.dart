import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:kai_engine/kai_engine.dart';
import 'package:kai_engine_firebase_ai/src/adapters.dart';
import 'package:test/test.dart';

void main() {
  group('FirebaseAiContentAdapter', () {
    late FirebaseAiContentAdapter adapter;

    setUp(() {
      adapter = const FirebaseAiContentAdapter();
    });

    group('CoreMessage to Content conversion', () {
      test('should create clean Content from user message', () {
        // Arrange
        final originalMessage = CoreMessage.user(
          messageId: 'test-id-123',
          content: 'Hello, world!',
        );

        // Act
        final content = adapter.fromCoreMessage(originalMessage);

        // Assert - Content should be clean without metadata
        expect(content.role, equals('user'));
        expect(content.parts, hasLength(1));
        expect(content.parts[0], isA<TextPart>());
        final textPart = content.parts[0] as TextPart;
        expect(textPart.text, equals('Hello, world!'));
      });

      test('should create clean Content from AI message', () {
        // Arrange
        final originalMessage = CoreMessage.ai(
          messageId: 'ai-msg-456',
          content: 'I am an AI assistant.',
        );

        // Act
        final content = adapter.fromCoreMessage(originalMessage);

        // Assert
        expect(content.role, equals('model'));
        expect(content.parts, hasLength(1));
        final textPart = content.parts[0] as TextPart;
        expect(textPart.text, equals('I am an AI assistant.'));
      });

      test('should create clean Content from system message', () {
        // Arrange
        final originalMessage = CoreMessage.system('You are a helpful assistant.');

        // Act
        final content = adapter.fromCoreMessage(originalMessage);

        // Assert
        expect(content.role, equals('system'));
        expect(content.parts, hasLength(1));
        final textPart = content.parts[0] as TextPart;
        expect(textPart.text, equals('You are a helpful assistant.'));
      });

      test('should not include messageId or extensions in Content', () {
        // Arrange
        final originalMessage = CoreMessage(
          messageId: 'important-id',
          type: CoreMessageType.user,
          content: 'Message with metadata',
          extensions: {'key': 'value'},
        );

        // Act
        final content = adapter.fromCoreMessage(originalMessage);

        // Assert - Content should only contain the text, no metadata
        expect(content.parts, hasLength(1));
        expect(content.parts[0], isA<TextPart>());
        final textPart = content.parts[0] as TextPart;
        expect(textPart.text, equals('Message with metadata'));
        expect(textPart.text, isNot(contains('important-id')));
        expect(textPart.text, isNot(contains('__METADATA__')));
      });
    });

    group('Content to CoreMessage conversion', () {
      test('should convert Content back to CoreMessage with correct type', () {
        // Arrange
        final content = Content('user', [TextPart('Hello from user')]);

        // Act
        final message = adapter.toCoreMessage(content);

        // Assert
        expect(message.type, equals(CoreMessageType.user));
        expect(message.content, equals('Hello from user'));
        expect(message.messageId, isNotEmpty); // New messages get auto-generated ID
      });

      test('should handle model role correctly', () {
        // Arrange
        final content = Content('model', [TextPart('AI response')]);

        // Act
        final message = adapter.toCoreMessage(content);

        // Assert
        expect(message.type, equals(CoreMessageType.ai));
        expect(message.content, equals('AI response'));
      });
    });

    group('Role mapping', () {
      test('should correctly map all message types to Content roles', () {
        final testCases = [
          (CoreMessageType.user, 'user'),
          (CoreMessageType.ai, 'model'),
          (CoreMessageType.system, 'system'),
          (CoreMessageType.function, 'function'),
          (CoreMessageType.unknown, null),
        ];

        for (final (messageType, expectedRole) in testCases) {
          final message = CoreMessage(
            messageId: 'test',
            type: messageType,
            content: 'Test content',
          );

          final content = adapter.fromCoreMessage(message);

          expect(content.role, equals(expectedRole), reason: 'Failed for type $messageType');
        }
      });

      test('should correctly map all Content roles to message types', () {
        final testCases = [
          ('user', CoreMessageType.user),
          ('model', CoreMessageType.ai),
          ('system', CoreMessageType.system),
          ('function', CoreMessageType.function),
          (null, CoreMessageType.unknown),
          ('unknown_role', CoreMessageType.unknown),
        ];

        for (final (role, expectedType) in testCases) {
          final content = Content(role, [TextPart('Test content')]);

          final message = adapter.toCoreMessage(content);

          expect(message.type, equals(expectedType), reason: 'Failed for role $role');
        }
      });
    });

    group('Function call handling with JSON storage', () {
      test('should preserve function calls via JSON storage', () {
        // Arrange
        final functionCall = FunctionCall('test_function', {
          'param1': 'value1',
          'param2': 42,
        }, id: 'call-123');

        final content = Content('model', [TextPart('I will call a function'), functionCall]);

        // Act - Convert to CoreMessage and back to Content
        final message = adapter.toCoreMessage(content);
        final reconstructedContent = adapter.fromCoreMessage(message);

        // Assert - Should have preserved everything via JSON storage
        expect(message.content, equals('I will call a function'));
        expect(message.extensions.containsKey('_originalContent'), isTrue);

        // Check reconstructed content
        expect(reconstructedContent.role, equals('model'));
        expect(reconstructedContent.parts, hasLength(2));

        final textParts = reconstructedContent.parts.whereType<TextPart>();
        expect(textParts.first.text, equals('I will call a function'));

        final functionCalls = reconstructedContent.parts.whereType<FunctionCall>();
        expect(functionCalls, hasLength(1));

        final reconstructedCall = functionCalls.first;
        expect(reconstructedCall.name, equals('test_function'));
        expect(reconstructedCall.args, equals({'param1': 'value1', 'param2': 42}));
        expect(reconstructedCall.id, equals('call-123'));
      });

      test('should preserve function responses via JSON storage', () {
        // Arrange
        final functionResponse = FunctionResponse('test_function', {
          'result': 'success',
          'data': [1, 2, 3],
        }, id: 'resp-456');

        final content = Content('function', [
          TextPart('Function executed successfully'),
          functionResponse,
        ]);

        // Act - Convert to CoreMessage and back to Content
        final message = adapter.toCoreMessage(content);
        final reconstructedContent = adapter.fromCoreMessage(message);

        // Assert
        expect(message.content, equals('Function executed successfully'));
        expect(message.extensions.containsKey('_originalContent'), isTrue);

        // Check reconstructed content
        expect(reconstructedContent.role, equals('function'));
        expect(reconstructedContent.parts, hasLength(2));

        final responses = reconstructedContent.parts.whereType<FunctionResponse>();
        expect(responses, hasLength(1));

        final reconstructedResponse = responses.first;
        expect(reconstructedResponse.name, equals('test_function'));
        expect(
          reconstructedResponse.response,
          equals({
            'result': 'success',
            'data': [1, 2, 3],
          }),
        );
        expect(reconstructedResponse.id, equals('resp-456'));
      });

      test('should handle multiple function calls and responses via JSON storage', () {
        // Arrange
        final content = Content('model', [
          TextPart('Processing multiple functions'),
          FunctionCall('func1', {'a': 1}, id: 'call1'),
          FunctionCall('func2', {'b': 2}), // No ID
          FunctionResponse('func1', {'result': 'done'}, id: 'resp1'),
        ]);

        // Act - Convert to CoreMessage and back to Content
        final message = adapter.toCoreMessage(content);
        final reconstructedContent = adapter.fromCoreMessage(message);

        // Assert
        expect(message.content, equals('Processing multiple functions'));
        expect(message.extensions.containsKey('_originalContent'), isTrue);

        // Check reconstructed content preserves all parts
        expect(reconstructedContent.parts, hasLength(4));

        final calls = reconstructedContent.parts.whereType<FunctionCall>().toList();
        expect(calls, hasLength(2));
        expect(calls[0].name, equals('func1'));
        expect(calls[0].id, equals('call1'));
        expect(calls[1].name, equals('func2'));
        expect(calls[1].id, isNull);

        final responses = reconstructedContent.parts.whereType<FunctionResponse>().toList();
        expect(responses, hasLength(1));
        expect(responses[0].name, equals('func1'));
        expect(responses[0].id, equals('resp1'));
      });
    });

    group('Edge cases', () {
      test('should handle empty content', () {
        // Arrange
        final originalMessage = CoreMessage(
          messageId: 'empty-content',
          type: CoreMessageType.user,
          content: '',
        );

        // Act
        final content = adapter.fromCoreMessage(originalMessage);
        final convertedMessage = adapter.toCoreMessage(content);

        // Assert
        expect(convertedMessage.type, equals(CoreMessageType.user));
        expect(convertedMessage.content, equals(''));
        expect(convertedMessage.messageId, isNotEmpty); // New messages get auto-generated ID
      });

      test('should handle whitespace-only content', () {
        // Arrange
        final originalMessage = CoreMessage(
          messageId: 'whitespace-test',
          type: CoreMessageType.user,
          content: '   \n\t  ',
        );

        // Act
        final content = adapter.fromCoreMessage(originalMessage);
        final convertedMessage = adapter.toCoreMessage(content);

        // Assert
        expect(convertedMessage.type, equals(CoreMessageType.user));
        expect(convertedMessage.content, equals('')); // Whitespace gets trimmed
        expect(convertedMessage.messageId, isNotEmpty); // New messages get auto-generated ID
      });

      test('should handle multiple text parts', () {
        // Arrange
        final content = Content('user', [
          TextPart('Part 1'),
          TextPart('Part 2'),
          TextPart('Part 3'),
        ]);

        // Act
        final message = adapter.toCoreMessage(content);

        // Assert
        expect(message.content, equals('Part 1\nPart 2\nPart 3'));
      });

      test('should handle Content with no parts', () {
        // Arrange
        final content = Content('user', []);

        // Act
        final message = adapter.toCoreMessage(content);

        // Assert
        expect(message.content, equals(''));
        expect(message.type, equals(CoreMessageType.user));
      });

      test('should handle text parts with special content', () {
        // Arrange
        final content = Content('user', [
          TextPart('Regular content'),
          TextPart('Special characters: __METADATA__invalid-json{'),
        ]);

        // Act
        final message = adapter.toCoreMessage(content);

        // Assert - Should combine all text parts normally
        expect(
          message.content,
          equals('Regular content\nSpecial characters: __METADATA__invalid-json{'),
        );
        expect(message.type, equals(CoreMessageType.user));
      });
    });

    group('Content cleanliness and function preservation', () {
      test('should produce clean Content suitable for AI model', () {
        // Arrange
        final originalMessage = CoreMessage(
          messageId: 'test-123',
          type: CoreMessageType.user,
          content: 'What is the weather like?',
          extensions: {'timestamp': '2024-01-01', 'sessionId': 'session-123'},
        );

        // Act
        final content = adapter.fromCoreMessage(originalMessage);

        // Assert - Content should be completely clean for AI consumption
        expect(content.role, equals('user'));
        expect(content.parts, hasLength(1));
        expect(content.parts[0], isA<TextPart>());
        final textPart = content.parts[0] as TextPart;
        expect(textPart.text, equals('What is the weather like?'));

        // Verify no internal data leaked into content
        final contentString = textPart.text;
        expect(contentString, isNot(contains('test-123')));
        expect(contentString, isNot(contains('timestamp')));
        expect(contentString, isNot(contains('sessionId')));
        expect(contentString, isNot(contains('__METADATA__')));
      });

      test('should handle complex Content with mixed parts correctly', () {
        // Arrange
        final content = Content('model', [
          TextPart('Starting response'),
          FunctionCall('calculate', {'x': 10, 'y': 20}),
          TextPart('Middle text'),
          FunctionResponse('calculate', {'result': 30}),
          TextPart('Final text'),
        ]);

        // Act - Convert to CoreMessage and back to Content
        final message = adapter.toCoreMessage(content);
        final reconstructedContent = adapter.fromCoreMessage(message);

        // Assert - Text should be combined, entire structure preserved via JSON
        expect(message.content, equals('Starting response\nMiddle text\nFinal text'));
        expect(message.extensions.containsKey('_originalContent'), isTrue);
        expect(message.type, equals(CoreMessageType.ai));

        // Verify complete structure is preserved in reconstructed content
        expect(reconstructedContent.role, equals('model'));
        expect(reconstructedContent.parts, hasLength(5));

        // Check that all parts are preserved in order
        expect(reconstructedContent.parts[0], isA<TextPart>());
        expect((reconstructedContent.parts[0] as TextPart).text, equals('Starting response'));

        expect(reconstructedContent.parts[1], isA<FunctionCall>());
        final call = reconstructedContent.parts[1] as FunctionCall;
        expect(call.name, equals('calculate'));
        expect(call.args, equals({'x': 10, 'y': 20}));

        expect(reconstructedContent.parts[2], isA<TextPart>());
        expect((reconstructedContent.parts[2] as TextPart).text, equals('Middle text'));

        expect(reconstructedContent.parts[3], isA<FunctionResponse>());
        final response = reconstructedContent.parts[3] as FunctionResponse;
        expect(response.name, equals('calculate'));
        expect(response.response, equals({'result': 30}));

        expect(reconstructedContent.parts[4], isA<TextPart>());
        expect((reconstructedContent.parts[4] as TextPart).text, equals('Final text'));
      });

      test('should ensure Content is ready for AI model consumption', () {
        // Test that Content objects created by the adapter are clean and ready
        // to be sent to Firebase AI without any internal metadata pollution

        final testMessages = [
          CoreMessage.user(messageId: 'user-1', content: 'Hello'),
          CoreMessage.ai(messageId: 'ai-1', content: 'Hi there!'),
          CoreMessage.system('You are helpful'),
          CoreMessage(
            messageId: 'complex-1',
            type: CoreMessageType.user,
            content: 'Complex query',
            extensions: {'context': 'important data'},
          ),
        ];

        for (final message in testMessages) {
          final content = adapter.fromCoreMessage(message);

          // Verify content contains only clean content
          final textParts = content.parts.whereType<TextPart>();
          final allText = textParts.map((p) => p.text).join('');

          // Should not contain any internal identifiers or metadata
          expect(allText, isNot(contains('messageId')));
          expect(allText, isNot(contains('extensions')));
          expect(allText, isNot(contains('__METADATA__')));
          expect(allText, isNot(contains('complex-1')));
          expect(allText, isNot(contains('user-1')));
          expect(allText, isNot(contains('ai-1')));
        }
      });

      test('should correctly handle CoreMessage without original content (fallback)', () {
        // Arrange - Create a CoreMessage without the _originalContent extension (legacy case)
        final messageWithoutOriginal = CoreMessage(
          messageId: '',
          type: CoreMessageType.ai,
          content: 'I will call some functions',
          extensions: {'someOtherKey': 'someValue'},
        );

        // Act
        final content = adapter.fromCoreMessage(messageWithoutOriginal);

        // Assert - Should fall back to simple text content
        expect(content.role, equals('model'));
        expect(content.parts.length, equals(1)); // Just the text part

        // Check text part
        final textParts = content.parts.whereType<TextPart>();
        expect(textParts, hasLength(1));
        expect(textParts.first.text, equals('I will call some functions'));
      });

      test(
        'should handle perfect round-trip with all accessible part types using JSON storage',
        () {
          // Arrange - Create Content with all publicly accessible types of parts
          final originalContent = Content('model', [
            TextPart('Processing your request'),
            FunctionCall('search', {'query': 'weather'}, id: 'search-1'),
            FunctionResponse('search', {
              'results': ['sunny', 'warm'],
            }, id: 'search-1'),
            TextPart('Based on the search results'),
            InlineDataPart('image/png', Uint8List.fromList([137, 80, 78, 71]), willContinue: false),
            FileData('image/jpeg', 'gs://bucket/image.jpg'),
          ]);

          // Act - Convert to CoreMessage and back to Content
          final coreMessage = adapter.toCoreMessage(originalContent);
          final reconstructedContent = adapter.fromCoreMessage(coreMessage);

          // Assert - Should preserve everything perfectly
          expect(reconstructedContent.role, equals('model'));
          expect(reconstructedContent.parts.length, equals(6));

          // Check text parts are preserved
          final textParts = reconstructedContent.parts.whereType<TextPart>().toList();
          expect(textParts, hasLength(2));
          expect(textParts[0].text, equals('Processing your request'));
          expect(textParts[1].text, equals('Based on the search results'));

          // Check function call is preserved
          final functionCalls = reconstructedContent.parts.whereType<FunctionCall>().toList();
          expect(functionCalls, hasLength(1));
          final call = functionCalls.first;
          expect(call.name, equals('search'));
          expect(call.args, equals({'query': 'weather'}));
          expect(call.id, equals('search-1'));

          // Check function response is preserved
          final responses = reconstructedContent.parts.whereType<FunctionResponse>().toList();
          expect(responses, hasLength(1));
          final response = responses.first;
          expect(response.name, equals('search'));
          expect(
            response.response,
            equals({
              'results': ['sunny', 'warm'],
            }),
          );
          expect(response.id, equals('search-1'));

          // Check inline data is preserved
          final inlineDataParts = reconstructedContent.parts.whereType<InlineDataPart>().toList();
          expect(inlineDataParts, hasLength(1));
          final inlineData = inlineDataParts.first;
          expect(inlineData.mimeType, equals('image/png'));
          expect(inlineData.bytes, equals(Uint8List.fromList([137, 80, 78, 71])));
          expect(inlineData.willContinue, equals(false));

          // Check file data is preserved
          final fileDataParts = reconstructedContent.parts.whereType<FileData>().toList();
          expect(fileDataParts, hasLength(1));
          final fileData = fileDataParts.first;
          expect(fileData.mimeType, equals('image/jpeg'));
          expect(fileData.fileUri, equals('gs://bucket/image.jpg'));
        },
      );
    });
  });
}
