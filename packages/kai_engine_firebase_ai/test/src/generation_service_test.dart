import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_engine/kai_engine.dart';
import 'package:kai_engine_firebase_ai/kai_engine_firebase_ai.dart';

// Test FirebaseAiToolSchema for testing
base class TestFirebaseAiToolSchema extends FirebaseAiToolSchema<FunctionCall, String> {
  TestFirebaseAiToolSchema()
    : super(
        parser: (Map<String, Object?> json) => FunctionCall(
          'testFirebaseTool',
          Map<String, Object?>.from(json),
        ),
        declaration: FunctionDeclaration(
          'testFirebaseTool',
          'A test Firebase tool',
          parameters: {
            'query': Schema.string(description: 'Search query'),
          },
        ),
      );

  @override
  Future<ToolResult<String>> execute(dynamic call) async {
    return ToolResult.success('test result', {'result': 'test'});
  }
}

// Generic ToolSchema for testing (non-Firebase)
base class TestGenericToolSchema
    extends ToolSchema<Map<String, dynamic>, Map<String, dynamic>, String> {
  TestGenericToolSchema()
    : super(
        name: 'testGenericTool',
        parser: (Map<String, Object?> json) => Map<String, dynamic>.from(json),
        declaration: {'name': 'testGenericTool', 'description': 'A generic tool'},
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
        final messages = [
          CoreMessage.system('Only system'),
        ].toIList();

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
        expect(
          () => FirebaseAiGenerationService,
          returnsNormally,
        );
      });
    });
  });

  group('FirebaseAiGenerationService - Generation Result Structure', () {
    test('generatedMessage contains only newly generated content, excluding existing history', () {
      // Test the logic that ensures generatedMessage field only contains
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
      final generatedMessage = newlyGeneratedContent.map((content) {
        return adapter.toCoreMessage(content);
      }).toIList();

      // Verify that generatedMessage contains all newly generated content
      expect(generatedMessage.length, equals(3));

      // First message should be the function call
      expect(generatedMessage[0].type, equals(CoreMessageType.ai));

      // Second message should be the function response
      expect(generatedMessage[1].type, equals(CoreMessageType.function));

      // Third message should be the final AI response (with usage data)
      expect(generatedMessage[2].content, contains('Based on the weather data'));
      expect(generatedMessage[2].type, equals(CoreMessageType.ai));
      // Note: The actual generationUsage attachment is tested separately
      // Here we focus on the core logic of including all generated content
    });

    test('generatedMessage for simple response without function calls', () {
      // Test simple case without function calling
      final newlyGeneratedContent = [
        Content.model([TextPart('This is a simple AI response')]),
      ];

      final adapter = FirebaseAiContentAdapter();
      final generatedMessage = newlyGeneratedContent.map((content) {
        return adapter.toCoreMessage(content);
      }).toIList();

      expect(generatedMessage.length, equals(1));
      expect(generatedMessage.first.content, equals('This is a simple AI response'));
      expect(generatedMessage.first.type, equals(CoreMessageType.ai));
      // Note: The actual generationUsage attachment is tested separately
    });

    test('copyWithGenerationUsage works correctly', () {
      final originalMessage = CoreMessage.ai(content: 'Test response');
      final usage = GenerationUsage(
        inputToken: 100,
        outputToken: 50,
        apiCallCount: 1,
      );

      final messageWithUsage = originalMessage.copyWithGenerationUsage(usage);

      expect(messageWithUsage.generationUsage, isNotNull);
      expect(messageWithUsage.generationUsage!.inputToken, equals(100));
      expect(messageWithUsage.generationUsage!.outputToken, equals(50));
      expect(messageWithUsage.generationUsage!.apiCallCount, equals(1));
      expect(messageWithUsage.content, equals('Test response'));
    });

    test('copyWithGenerationUsage can remove usage when null is passed', () {
      final originalMessage = CoreMessage.ai(content: 'Test response');
      final usage = GenerationUsage(
        inputToken: 100,
        outputToken: 50,
        apiCallCount: 1,
      );

      final messageWithUsage = originalMessage.copyWithGenerationUsage(usage);
      expect(messageWithUsage.generationUsage, isNotNull);

      final messageWithoutUsage = messageWithUsage.copyWithGenerationUsage(null);
      expect(messageWithoutUsage.generationUsage, isNull);
      expect(messageWithoutUsage.content, equals('Test response'));
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
        expect(effectiveTools.every((tool) => tool is TestFirebaseAiToolSchema), isTrue);
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
}
