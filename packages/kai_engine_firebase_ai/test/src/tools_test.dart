import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_engine/kai_engine.dart';
import 'package:kai_engine_firebase_ai/src/tools.dart';

// Concrete implementation of FirebaseAiToolSchema for testing
final class TestFirebaseAiToolSchema extends FirebaseAiToolSchema<FunctionCall, String> {
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
            'limit': Schema.integer(description: 'Result limit'),
          },
        ),
      );

  @override
  Future<ToolResult<String>> execute(dynamic call) async {
    final functionCall = call as FunctionCall;
    final query = functionCall.args['query'] as String? ?? '';
    final limit = functionCall.args['limit'] as int? ?? 10;

    if (query.isEmpty) {
      return const ToolResult.failure('Query cannot be empty');
    }

    final result = 'Firebase tool processed: $query with limit $limit';
    return ToolResult.success(result, {
      'query': query,
      'limit': limit,
      'result': result,
    });
  }
}

// Failing tool for error testing
final class FailingFirebaseAiToolSchema extends FirebaseAiToolSchema<FunctionCall, String> {
  FailingFirebaseAiToolSchema()
    : super(
        parser: (Map<String, Object?> json) => FunctionCall(
          'failingFirebaseTool',
          Map<String, Object?>.from(json),
        ),
        declaration: FunctionDeclaration(
          'failingFirebaseTool',
          'A failing Firebase tool',
          parameters: {
            'query': Schema.string(),
          },
        ),
      );

  @override
  Future<ToolResult<String>> execute(dynamic call) async {
    throw Exception('Tool execution failed');
  }
}

void main() {
  group('FirebaseAiToolSchema', () {
    late TestFirebaseAiToolSchema toolSchema;

    setUp(() {
      toolSchema = TestFirebaseAiToolSchema();
    });

    test('has correct name from declaration', () {
      expect(toolSchema.name, equals('testFirebaseTool'));
      expect(toolSchema.declaration.name, equals('testFirebaseTool'));
    });

    test('declaration has correct description', () {
      final declaration = toolSchema.declaration;
      expect(declaration.description, equals('A test Firebase tool'));
    });

    test('execute returns success for valid input', () async {
      final functionCall = FunctionCall('testFirebaseTool', {
        'query': 'test query',
        'limit': 5,
      });
      final result = await toolSchema.execute(functionCall);

      expect(result, isA<ToolResult<String>>());
      result.when(
        success: (data, response) {
          expect(data, contains('test query'));
          expect(data, contains('5'));
          expect(response['query'], equals('test query'));
          expect(response['limit'], equals(5));
        },
        failure: (error) => fail('Expected success, got failure: $error'),
      );
    });

    test('execute returns failure for invalid input', () async {
      final functionCall = FunctionCall('testFirebaseTool', {
        'query': '',
        'limit': 10,
      });
      final result = await toolSchema.execute(functionCall);

      expect(result, isA<ToolResult<String>>());
      result.when(
        success: (data, response) => fail('Expected failure, got success'),
        failure: (error) => expect(error, equals('Query cannot be empty')),
      );
    });

    test('toFunctionResponse converts FunctionCall to FunctionResponse for success', () async {
      final functionCall = FunctionCall('testFirebaseTool', {
        'query': 'test query',
        'limit': 3,
      });

      final response = await toolSchema.toFunctionResponse(functionCall);

      expect(response.name, equals('testFirebaseTool'));
      expect(response.response, isA<Map<String, dynamic>>());
      final responseData = response.response as Map<String, dynamic>;
      expect(responseData['query'], equals('test query'));
      expect(responseData['limit'], equals(3));
      expect(responseData['result'], contains('test query'));
    });

    test('toFunctionResponse handles execution failure', () async {
      final functionCall = FunctionCall('testFirebaseTool', {
        'query': '',
        'limit': 5,
      });

      final response = await toolSchema.toFunctionResponse(functionCall);

      expect(response.name, equals('testFirebaseTool'));
      final responseData = response.response as Map<String, dynamic>;
      expect(responseData['error'], equals('Query cannot be empty'));
    });
  });

  group('FirebaseAiToolSchemaListHelper', () {
    late List<FirebaseAiToolSchema> toolSchemas;
    late TestFirebaseAiToolSchema testTool;
    late FailingFirebaseAiToolSchema failingTool;

    setUp(() {
      testTool = TestFirebaseAiToolSchema();
      failingTool = FailingFirebaseAiToolSchema();
      toolSchemas = [testTool, failingTool];
    });

    test('toFirebaseAiTools returns null for empty list', () {
      final emptyList = <FirebaseAiToolSchema>[];
      final result = emptyList.toFirebaseAiTools();

      expect(result, isNull);
    });

    test('toFirebaseAiTools returns Tool list for non-empty schemas', () {
      final tools = toolSchemas.toFirebaseAiTools();

      expect(tools, isNotNull);
      expect(tools!.length, equals(1));
      expect(tools.first, isA<Tool>());
    });

    test('toFirebaseAiTools includes all declarations', () {
      final tools = toolSchemas.toFirebaseAiTools();
      final tool = tools!.first;

      // Verify the tool contains function declarations
      expect(tool, isA<Tool>());
    });

    test('executes handles successful tool execution', () async {
      final functionCalls = [
        FunctionCall('testFirebaseTool', {
          'query': 'test query',
          'limit': 5,
        }),
      ];

      final responses = await toolSchemas.executes(functionCalls);

      expect(responses.length, equals(1));
      final response = responses.first;
      expect(response.name, equals('testFirebaseTool'));
      final responseData = response.response as Map<String, dynamic>;
      expect(responseData['query'], equals('test query'));
      expect(responseData['limit'], equals(5));
    });

    test('executes handles tool execution failure', () async {
      final functionCalls = [
        FunctionCall('testFirebaseTool', {
          'query': '',
          'limit': 5,
        }),
      ];

      final responses = await toolSchemas.executes(functionCalls);

      expect(responses.length, equals(1));
      final response = responses.first;
      expect(response.name, equals('testFirebaseTool'));
      final responseData = response.response as Map<String, dynamic>;
      expect(responseData['error'], equals('Query cannot be empty'));
    });

    test('executes throws KaiException for tool not found', () async {
      final functionCalls = [
        FunctionCall('nonexistentTool', {
          'query': 'test',
        }),
      ];

      expect(
        () => toolSchemas.executes(functionCalls),
        throwsA(
          predicate(
            (e) => e is KaiException && e.toString().contains('Tool not found: nonexistentTool'),
          ),
        ),
      );
    });

    test('executes throws KaiException for unexpected tool failures', () async {
      final functionCalls = [
        FunctionCall('failingFirebaseTool', {
          'query': 'test',
        }),
      ];

      expect(
        () => toolSchemas.executes(functionCalls),
        throwsA(
          predicate((e) => e is KaiException && e.toString().contains('Tool execution failed')),
        ),
      );
    });

    test('executes handles multiple tool calls', () async {
      final functionCalls = [
        FunctionCall('testFirebaseTool', {
          'query': 'first query',
          'limit': 3,
        }),
        FunctionCall('testFirebaseTool', {
          'query': 'second query',
          'limit': 7,
        }),
      ];

      final responses = await toolSchemas.executes(functionCalls);

      expect(responses.length, equals(2));

      final firstResponse = responses[0];
      expect(firstResponse.name, equals('testFirebaseTool'));
      final firstData = firstResponse.response as Map<String, dynamic>;
      expect(firstData['query'], equals('first query'));
      expect(firstData['limit'], equals(3));

      final secondResponse = responses[1];
      expect(secondResponse.name, equals('testFirebaseTool'));
      final secondData = secondResponse.response as Map<String, dynamic>;
      expect(secondData['query'], equals('second query'));
      expect(secondData['limit'], equals(7));
    });

    test('executes handles mixed success and failure calls', () async {
      final functionCalls = [
        FunctionCall('testFirebaseTool', {
          'query': 'valid query',
          'limit': 5,
        }),
        FunctionCall('testFirebaseTool', {
          'query': '',
          'limit': 3,
        }),
      ];

      final responses = await toolSchemas.executes(functionCalls);

      expect(responses.length, equals(2));

      // First call should succeed
      final successResponse = responses[0];
      final successData = successResponse.response as Map<String, dynamic>;
      expect(successData['query'], equals('valid query'));
      expect(successData['result'], contains('valid query'));

      // Second call should fail
      final failureResponse = responses[1];
      final failureData = failureResponse.response as Map<String, dynamic>;
      expect(failureData['error'], equals('Query cannot be empty'));
    });
  });
}
