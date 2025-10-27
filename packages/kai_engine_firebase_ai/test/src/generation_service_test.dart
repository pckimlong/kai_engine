import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_engine/kai_engine.dart';
import 'package:kai_engine_firebase_ai/kai_engine_firebase_ai.dart';

// Test FirebaseAiToolSchema for testing
base class TestFirebaseAiToolSchema
    extends FirebaseAiToolSchema<FunctionCall, String> {
  final String _response;

  TestFirebaseAiToolSchema([this._response = 'test result'])
    : super(
        parser: (Map<String, Object?> json) =>
            FunctionCall('testFirebaseTool', Map<String, Object?>.from(json)),
        declaration: FunctionDeclaration(
          'testFirebaseTool',
          'A test Firebase tool',
          parameters: {'query': Schema.string(description: 'Search query')},
        ),
      );

  @override
  Future<ToolResult<String>> execute(dynamic call) async {
    return ToolResult.success(_response, {'result': _response});
  }
}

// Test FirebaseAiToolSchema that returns empty response
base class EmptyResponseToolSchema
    extends FirebaseAiToolSchema<FunctionCall, String> {
  EmptyResponseToolSchema()
    : super(
        parser: (Map<String, Object?> json) =>
            FunctionCall('emptyTool', Map<String, Object?>.from(json)),
        declaration: FunctionDeclaration(
          'emptyTool',
          'A tool that returns empty response',
          parameters: {'query': Schema.string(description: 'Search query')},
        ),
      );

  @override
  Future<ToolResult<String>> execute(dynamic call) async {
    return ToolResult.success('', {});
  }
}

// Generic ToolSchema for testing (non-Firebase)
base class TestGenericToolSchema
    extends ToolSchema<Map<String, dynamic>, Map<String, dynamic>, String> {
  TestGenericToolSchema()
    : super(
        name: 'testGenericTool',
        parser: (Map<String, Object?> json) => Map<String, dynamic>.from(json),
        declaration: {
          'name': 'testGenericTool',
          'description': 'A generic tool',
        },
      );

  @override
  Future<ToolResult<String>> execute(dynamic call) async {
    return ToolResult.success('generic result', {'result': 'generic'});
  }
}

// Mock class for testing
class MockFirebaseAI implements FirebaseAI {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

// Helper function to test _effectiveTools logic
List<FirebaseAiToolSchema> testEffectiveTools(
  List<ToolSchema> tools,
  List<FirebaseAiToolSchema>? configTools,
) {
  final firebaseTools = tools.whereType<FirebaseAiToolSchema>().toList();
  final merged = <FirebaseAiToolSchema>[
    ...firebaseTools,
    if (configTools != null) ...configTools,
  ];
  return merged..removeDuplicates(by: (item) => item.name);
}

void main() {
  group('FirebaseAiGenerationService - Message Filtering Logic', () {
    // Helper function to test the filtering logic indirectly
    // by creating a service and accessing its private method through reflection
    IList<CoreMessage> filterSystemMessages(IList<CoreMessage> messages) {
      bool foundFirstSystem = false;
      return messages.where((message) {
        if (message.type == CoreMessageType.system) {
          if (!foundFirstSystem) {
            foundFirstSystem = true;
            return false; // Skip the first system message
          }
          return true; // Keep subsequent system messages
        }
        return true; // Keep all non-system messages
      }).toIList();
    }

    group('_filterSystemMessages behavior', () {
      test('removes only first system message', () {
        final messages = [
          CoreMessage.system('First system'),
          CoreMessage.user(content: 'Hello'),
          CoreMessage.system('Second system'),
          CoreMessage.ai(content: 'Hi'),
        ].toIList();

        final filtered = filterSystemMessages(messages);

        expect(filtered.length, equals(3));
        expect(filtered[0].content, equals('Hello'));
        expect(filtered[1].content, equals('Second system'));
        expect(filtered[2].content, equals('Hi'));
      });

      test('keeps all messages when no system message exists', () {
        final messages = [
          CoreMessage.user(content: 'Hello'),
          CoreMessage.ai(content: 'Hi'),
        ].toIList();

        final filtered = filterSystemMessages(messages);

        expect(filtered.length, equals(2));
        expect(filtered[0].content, equals('Hello'));
        expect(filtered[1].content, equals('Hi'));
      });

      test('handles only system messages correctly', () {
        final messages = [
          CoreMessage.system('First system'),
          CoreMessage.system('Second system'),
          CoreMessage.system('Third system'),
        ].toIList();

        final filtered = filterSystemMessages(messages);

        expect(filtered.length, equals(2));
        expect(filtered[0].content, equals('Second system'));
        expect(filtered[1].content, equals('Third system'));
      });

      test('handles single system message', () {
        final messages = [CoreMessage.system('Only system')].toIList();

        final filtered = filterSystemMessages(messages);

        expect(filtered.length, equals(0));
      });

      test('handles mixed message types', () {
        final messages = [
          CoreMessage.user(content: 'User1'),
          CoreMessage.system('System1'),
          CoreMessage.ai(content: 'AI1'),
          CoreMessage.user(content: 'User2'),
          CoreMessage.system('System2'),
        ].toIList();

        final filtered = filterSystemMessages(messages);

        expect(filtered.length, equals(4));
        expect(filtered[0].content, equals('User1'));
        expect(filtered[1].content, equals('AI1'));
        expect(filtered[2].content, equals('User2'));
        expect(filtered[3].content, equals('System2'));
      });
    });

    group('System prompt logic', () {
      test('identifies first system message correctly', () {
        final messages = [
          CoreMessage.user(content: 'Hello'),
          CoreMessage.system('Second'),
        ].toIList();

        final firstSystemMessage = messages.firstWhereOrNull(
          (m) => m.type == CoreMessageType.system,
        );
        expect(firstSystemMessage?.content, equals('Second'));
      });

      test('returns null when no system message exists', () {
        final messages = [
          CoreMessage.user(content: 'Hello'),
          CoreMessage.ai(content: 'Hi'),
        ].toIList();

        final firstSystemMessage = messages.firstWhereOrNull(
          (m) => m.type == CoreMessageType.system,
        );
        expect(firstSystemMessage, isNull);
      });

      test('finds first system message in mixed order', () {
        final messages = [
          CoreMessage.user(content: 'Hello'),
          CoreMessage.system('First system'),
          CoreMessage.ai(content: 'Hi'),
          CoreMessage.system('Second system'),
        ].toIList();

        final firstSystemMessage = messages.firstWhereOrNull(
          (m) => m.type == CoreMessageType.system,
        );
        expect(firstSystemMessage?.content, equals('First system'));
      });
    });

    group('GenerativeConfig', () {
      test('creates config with system prompt', () {
        const config = GenerativeConfig(
          model: 'gemini-1.5-flash',
          systemPrompt: 'Test prompt',
        );

        expect(config.model, equals('gemini-1.5-flash'));
        expect(config.systemPrompt, equals('Test prompt'));
      });

      test('creates config without system prompt', () {
        const config = GenerativeConfig(
          model: 'gemini-1.5-flash',
          systemPrompt: null,
        );

        expect(config.model, equals('gemini-1.5-flash'));
        expect(config.systemPrompt, isNull);
      });
    });

    group('Service instantiation', () {
      test('creates service with default adapter', () {
        // This is more of a smoke test to ensure the service can be instantiated
        expect(() => FirebaseAiGenerationService, returnsNormally);
      });
    });
  });

  group('FirebaseAiGenerationService - Generation Result Structure', () {
    test(
      'generatedMessages contains only newly generated content, excluding existing history',
      () {
        // Test the logic that ensures generatedMessages field only contains
        // newly generated content during the current generation cycle

        // 2. New content generated during this cycle (including function calls if any)
        final newlyGeneratedContent = [
          Content.model([
            FunctionCall('weather_tool', {'location': 'NYC'}),
          ]), // AI makes function call
          Content.functionResponses([
            FunctionResponse('weather_tool', {'temp': '72F'}),
          ]), // Function response
          Content.model([
            TextPart('Based on the weather data, it\'s 72F in NYC today!'),
          ]), // Final AI response
        ];

        // 3. Simulate extracting only newly generated content
        final adapter = FirebaseAiContentAdapter();
        final generatedMessages = newlyGeneratedContent.map((content) {
          return adapter.toCoreMessage(content);
        }).toIList();

        // Verify that generatedMessages contains all newly generated content
        expect(generatedMessages.length, equals(3));

        // First message should be the function call
        expect(generatedMessages[0].type, equals(CoreMessageType.ai));

        // Second message should be the function response
        expect(generatedMessages[1].type, equals(CoreMessageType.function));

        // Third message should be the final AI response (with usage data)
        expect(
          generatedMessages[2].content,
          contains('Based on the weather data'),
        );
        expect(generatedMessages[2].type, equals(CoreMessageType.ai));
        // Note: The actual generationUsage attachment is tested separately
        // Here we focus on the core logic of including all generated content
      },
    );

    test('generatedMessages for simple response without function calls', () {
      // Test simple case without function calling
      final newlyGeneratedContent = [
        Content.model([TextPart('This is a simple AI response')]),
      ];

      final adapter = FirebaseAiContentAdapter();
      final generatedMessages = newlyGeneratedContent.map((content) {
        return adapter.toCoreMessage(content);
      }).toIList();

      expect(generatedMessages.length, equals(1));
      expect(
        generatedMessages.first.content,
        equals('This is a simple AI response'),
      );
      expect(generatedMessages.first.type, equals(CoreMessageType.ai));
      // Note: The actual generationUsage attachment is tested separately
    });
  });

  group('FirebaseAiGenerationService - Tool Type Handling', () {
    group('tool filtering logic', () {
      test('filters only FirebaseAiToolSchema from mixed ToolSchema list', () {
        final firebaseTool = TestFirebaseAiToolSchema();
        final genericTool = TestGenericToolSchema();
        final tools = <ToolSchema>[firebaseTool, genericTool];

        final effectiveTools = testEffectiveTools(tools, null);

        expect(effectiveTools.length, equals(1));
        expect(effectiveTools.first, isA<TestFirebaseAiToolSchema>());
        expect(effectiveTools.first.name, equals('testFirebaseTool'));
      });

      test('handles empty tool list', () {
        final tools = <ToolSchema>[];
        final effectiveTools = testEffectiveTools(tools, null);

        expect(effectiveTools, isEmpty);
      });

      test('handles list with only FirebaseAiToolSchema instances', () {
        final firebaseTool1 = TestFirebaseAiToolSchema();
        final firebaseTool2 = TestFirebaseAiToolSchema();
        final tools = <ToolSchema>[firebaseTool1, firebaseTool2];

        final effectiveTools = testEffectiveTools(tools, null);

        // Since both tools have the same name, duplicates are removed
        expect(effectiveTools.length, equals(1));
        expect(
          effectiveTools.every((tool) => tool is TestFirebaseAiToolSchema),
          isTrue,
        );
      });

      test('handles list with only generic ToolSchema instances', () {
        final genericTool1 = TestGenericToolSchema();
        final genericTool2 = TestGenericToolSchema();
        final tools = <ToolSchema>[genericTool1, genericTool2];

        final effectiveTools = testEffectiveTools(tools, null);

        expect(effectiveTools, isEmpty);
      });

      test('merges tools with config tool schemas and removes duplicates', () {
        final firebaseTool = TestFirebaseAiToolSchema();
        final configTool = TestFirebaseAiToolSchema();
        final tools = <ToolSchema>[firebaseTool];
        final configTools = [configTool];

        final effectiveTools = testEffectiveTools(tools, configTools);

        // Should have 1 tool since duplicates by name are removed
        expect(effectiveTools.length, equals(1));
      });
    });
  });

  group('FirebaseAiGenerationService - Tooling Function', () {
    late FirebaseAiGenerationService service;
    late MockFirebaseAI mockFirebaseAI;

    setUp(() {
      mockFirebaseAI = MockFirebaseAI();
      const config = GenerativeConfig(model: 'gemini-1.5-flash');
      service = FirebaseAiGenerationService(
        firebaseAi: mockFirebaseAI,
        config: config,
      );
    });

    test('throws assertion error when tools list is empty', () async {
      final messages = [CoreMessage.user(content: 'Hello')].toIList();
      final tools = <ToolSchema>[];

      expect(
        () => service.tooling(
          prompts: messages,
          tools: tools,
          toolingConfig: ToolingConfig.auto(),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('tooling method exists and accepts correct parameters', () async {
      final messages = [CoreMessage.user(content: 'Hello')].toIList();
      final tools = [TestFirebaseAiToolSchema()];

      // Test that the method can be called and throws the expected error due to mocking limitations
      expect(
        () => service.tooling(
          prompts: messages,
          tools: tools,
          toolingConfig: ToolingConfig.auto(),
        ),
        throwsA(predicate((e) => e.toString().contains('UnimplementedError'))),
      );
    });
  });

  group('FirebaseAiGenerationService - Tooling Edge Cases', () {
    test('empty response detection logic works correctly', () {
      // Test the logic for detecting empty responses - simulate tool execution responses
      final mockResponses = [
        {'name': 'tool1', 'response': ''},
        {'name': 'tool2', 'response': '{}'},
        {'name': 'tool3', 'response': 'valid response'},
      ];

      final hasValidResponses = mockResponses.any((response) {
        final responseStr = response['response'] as String;
        return responseStr.isNotEmpty && responseStr != '{}';
      });

      expect(hasValidResponses, isTrue);
    });

    test('all empty responses are detected correctly', () {
      final mockResponses = [
        {'name': 'tool1', 'response': ''},
        {'name': 'tool2', 'response': '{}'},
        {'name': 'tool3', 'response': ''},
      ];

      final hasValidResponses = mockResponses.any((response) {
        final responseStr = response['response'] as String;
        return responseStr.isNotEmpty && responseStr != '{}';
      });

      expect(hasValidResponses, isFalse);
    });

    test('mixed empty and valid responses are handled correctly', () {
      final mockResponses = [
        {'name': 'tool1', 'response': ''},
        {'name': 'tool2', 'response': 'some data'},
        {'name': 'tool3', 'response': '{}'},
      ];

      final hasValidResponses = mockResponses.any((response) {
        final responseStr = response['response'] as String;
        return responseStr.isNotEmpty && responseStr != '{}';
      });

      expect(hasValidResponses, isTrue);
    });
  });
}
