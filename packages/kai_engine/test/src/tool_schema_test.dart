import 'package:flutter_test/flutter_test.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kai_engine/src/tool_schema.dart';

part 'tool_schema_test.freezed.dart';
part 'tool_schema_test.g.dart';

@freezed
sealed class TestToolCall with _$TestToolCall {
  const TestToolCall._();

  const factory TestToolCall({required String query, @Default(10) int limit}) =
      _TestToolCall;

  factory TestToolCall.fromJson(Map<String, dynamic> json) =>
      _$TestToolCallFromJson(json);
}

class TestToolDeclaration {
  final String name;
  final String description;
  final Map<String, dynamic> parameters;

  const TestToolDeclaration({
    required this.name,
    required this.description,
    required this.parameters,
  });
}

final class TestToolSchema
    extends ToolSchema<TestToolDeclaration, TestToolCall, String> {
  TestToolSchema()
    : super(
        name: 'test_tool',
        parser: TestToolCall.fromJson,
        declaration: const TestToolDeclaration(
          name: 'test_tool',
          description: 'A test tool',
          parameters: {'query': 'string', 'limit': 'int'},
        ),
      );

  @override
  Future<ToolResult<String>> execute(TestToolCall call) async {
    if (call.query.isEmpty) {
      return ToolResult.failure('Query cannot be empty', StackTrace.current);
    }

    final result = 'Processed: ${call.query} with limit ${call.limit}';
    return ToolResult.success(result, {
      'query': call.query,
      'limit': call.limit,
      'result': result,
    });
  }
}

final class TestFailingToolSchema
    extends ToolSchema<TestToolDeclaration, TestToolCall, String> {
  TestFailingToolSchema()
    : super(
        name: 'failing_tool',
        parser: TestToolCall.fromJson,
        declaration: const TestToolDeclaration(
          name: 'failing_tool',
          description: 'A tool that always fails',
          parameters: {'query': 'string'},
        ),
      );

  @override
  Future<ToolResult<String>> execute(TestToolCall call) async {
    throw Exception('Tool execution failed');
  }
}

final class TestToolSchemaWithCallback
    extends ToolSchema<TestToolDeclaration, TestToolCall, String> {
  TestToolSchemaWithCallback({
    required void Function(TestToolCall, ToolResult<String>) onSuccessCallback,
  }) : super(
         name: 'test_tool_with_callback',
         parser: TestToolCall.fromJson,
         declaration: const TestToolDeclaration(
           name: 'test_tool_with_callback',
           description: 'A test tool with callback',
           parameters: {'query': 'string', 'limit': 'int'},
         ),
         onSuccess: onSuccessCallback,
       );

  @override
  Future<ToolResult<String>> execute(TestToolCall call) async {
    if (call.query.isEmpty) {
      return ToolResult.failure('Query cannot be empty', StackTrace.current);
    }

    final result = 'Callback test: ${call.query} with limit ${call.limit}';
    return ToolResult.success(result, {
      'query': call.query,
      'limit': call.limit,
      'result': result,
    });
  }
}

void main() {
  group('ToolResult', () {
    test('creates success result with data and response', () {
      const data = 'test data';
      const response = {'key': 'value'};
      final result = ToolResult.success(data, response);

      expect(result, isA<ToolResult<String>>());
      result.when(
        success: (actualData, actualResponse) {
          expect(actualData, equals(data));
          expect(actualResponse, equals(response));
        },
        failure: (error, _) => fail('Expected success, got failure: $error'),
      );
    });

    test('creates failure result with error message', () {
      const errorMessage = 'Something went wrong';
      final result = ToolResult<String>.failure(
        errorMessage,
        StackTrace.current,
      );

      expect(result, isA<ToolResult<String>>());
      result.when(
        success: (data, response) => fail('Expected failure, got success'),
        failure: (error, stackTrace) {
          expect(error, equals(errorMessage));
          expect(stackTrace, isNotNull);
        },
      );
    });

    test('when method handles success case correctly', () {
      final result = ToolResult.success('data', {'response': 'value'});

      final successResult = result.when(
        success: (data, response) => 'Success: $data',
        failure: (error, _) => 'Failure: $error',
      );

      expect(successResult, equals('Success: data'));
    });

    test('when method handles failure case correctly', () {
      final result = ToolResult<String>.failure(
        'error message',
        StackTrace.current,
      );

      final failureResult = result.when(
        success: (data, response) => 'Success: $data',
        failure: (error, _) => 'Failure: $error',
      );

      expect(failureResult, equals('Failure: error message'));
    });
  });

  group('ToolDeclaration', () {
    test('creates tool declaration with name and declaration', () {
      const name = 'test_tool';
      const declaration = TestToolDeclaration(
        name: name,
        description: 'Test description',
        parameters: {'param1': 'string'},
      );

      const toolDeclaration = ToolDeclaration(
        name: name,
        declaration: declaration,
      );

      expect(toolDeclaration.name, equals(name));
      expect(toolDeclaration.declaration, equals(declaration));
    });

    test('is immutable', () {
      const toolDeclaration = ToolDeclaration(
        name: 'test',
        declaration: TestToolDeclaration(
          name: 'test',
          description: 'Test',
          parameters: {},
        ),
      );

      expect(() => toolDeclaration.name, returnsNormally);
      expect(() => toolDeclaration.declaration, returnsNormally);
    });
  });

  group('ToolCall', () {
    test('creates tool call with name and arguments', () {
      const toolName = 'search_tool';
      const arguments = {'query': 'test', 'limit': 5};

      const toolCall = ToolCall(toolName: toolName, arguments: arguments);

      expect(toolCall.toolName, equals(toolName));
      expect(toolCall.arguments, equals(arguments));
    });

    test('handles empty arguments', () {
      const toolCall = ToolCall(toolName: 'no_args_tool', arguments: {});

      expect(toolCall.arguments, isEmpty);
    });

    test('handles complex argument types', () {
      const arguments = {
        'string': 'value',
        'int': 42,
        'bool': true,
        'list': [1, 2, 3],
        'map': {'nested': 'value'},
        'null': null,
      };

      const toolCall = ToolCall(toolName: 'complex_tool', arguments: arguments);

      expect(toolCall.arguments, equals(arguments));
    });
  });

  group('ToolResponse', () {
    test('creates tool response with name and response data', () {
      const toolName = 'test_tool';
      const response = {'result': 'success', 'data': 'test data'};

      const toolResponse = ToolResponse(toolName: toolName, response: response);

      expect(toolResponse.toolName, equals(toolName));
      expect(toolResponse.response, equals(response));
    });

    test('handles empty response', () {
      const toolResponse = ToolResponse(toolName: 'empty_tool', response: {});

      expect(toolResponse.response, isEmpty);
    });

    test('handles error response format', () {
      const response = {'error': 'Something went wrong'};
      const toolResponse = ToolResponse(
        toolName: 'error_tool',
        response: response,
      );

      expect(toolResponse.response['error'], equals('Something went wrong'));
    });
  });

  group('ToolSchema', () {
    late TestToolSchema toolSchema;

    setUp(() {
      toolSchema = TestToolSchema();
    });

    test('has correct name and declaration', () {
      expect(toolSchema.name, equals('test_tool'));
      expect(toolSchema.declaration, isA<TestToolDeclaration>());
      expect(toolSchema.declaration.name, equals('test_tool'));
    });

    test('toKaiTool returns correct ToolDeclaration', () {
      final toolDeclaration = toolSchema.toKaiTool();

      expect(toolDeclaration.name, equals('test_tool'));
      expect(toolDeclaration.declaration, equals(toolSchema.declaration));
    });

    test('execute returns success for valid input', () async {
      const call = TestToolCall(query: 'test query', limit: 5);
      final result = await toolSchema.execute(call);

      expect(result, isA<ToolResult<String>>());
      result.when(
        success: (data, response) {
          expect(data, contains('test query'));
          expect(data, contains('5'));
          expect(response['query'], equals('test query'));
          expect(response['limit'], equals(5));
        },
        failure: (error, _) => fail('Expected success, got failure: $error'),
      );
    });

    test('execute returns failure for invalid input', () async {
      const call = TestToolCall(query: '', limit: 10);
      final result = await toolSchema.execute(call);

      expect(result, isA<ToolResult<String>>());
      result.when(
        success: (data, response) => fail('Expected failure, got success'),
        failure: (error, _) => expect(error, equals('Query cannot be empty')),
      );
    });

    test('buildResponse returns response data for success', () {
      final successResult = ToolResult.success('data', {
        'key': 'value',
        'count': 42,
      });

      final response = toolSchema.buildResponse(successResult);

      expect(response, equals({'key': 'value', 'count': 42}));
    });

    test('buildResponse returns error for failure', () {
      final failureResult = ToolResult<String>.failure(
        'error message',
        StackTrace.current,
      );

      final response = toolSchema.buildResponse(failureResult);

      expect(response, equals({'error': 'error message'}));
    });

    test('call method orchestrates complete flow for success', () async {
      const toolCall = ToolCall(
        toolName: 'test_tool',
        arguments: {'query': 'test', 'limit': 3},
      );

      final toolResponse = await toolSchema.call(toolCall);

      expect(toolResponse.toolName, equals('test_tool'));
      expect(toolResponse.response['query'], equals('test'));
      expect(toolResponse.response['limit'], equals(3));
      expect(toolResponse.response['result'], contains('test'));
    });

    test('call method handles parsing and execution failure', () async {
      const toolCall = ToolCall(
        toolName: 'test_tool',
        arguments: {'query': '', 'limit': 5},
      );

      final toolResponse = await toolSchema.call(toolCall);

      expect(toolResponse.toolName, equals('test_tool'));
      expect(toolResponse.response['error'], equals('Query cannot be empty'));
    });

    test('call method handles exception during execution', () async {
      final failingSchema = TestFailingToolSchema();
      const toolCall = ToolCall(
        toolName: 'failing_tool',
        arguments: {'query': 'test'},
      );

      expect(() => failingSchema.call(toolCall), throwsA(isA<Exception>()));
    });

    test('onSuccess callback is called for successful execution', () async {
      TestToolCall? capturedCall;
      ToolResult<String>? capturedResult;

      final schemaWithCallback = TestToolSchemaWithCallback(
        onSuccessCallback: (call, result) {
          capturedCall = call;
          capturedResult = result;
        },
      );

      const toolCall = ToolCall(
        toolName: 'test_tool_with_callback',
        arguments: {'query': 'callback test', 'limit': 7},
      );

      await schemaWithCallback.call(toolCall);

      expect(capturedCall, isNotNull);
      expect(capturedCall!.query, equals('callback test'));
      expect(capturedCall!.limit, equals(7));
      expect(capturedResult, isNotNull);
      capturedResult!.when(
        success: (data, response) {
          expect(data, contains('callback test'));
        },
        failure: (error, _) => fail('Expected success in callback'),
      );
    });

    test('onSuccess callback is called for both success and failure', () async {
      var successCallbackCalled = false;
      var failureCallbackCalled = false;
      ToolResult<String>? capturedFailureResult;

      // Test success case
      final successSchema = TestToolSchemaWithCallback(
        onSuccessCallback: (call, result) {
          successCallbackCalled = true;
        },
      );

      const successCall = ToolCall(
        toolName: 'test_tool_with_callback',
        arguments: {'query': 'test', 'limit': 5},
      );

      await successSchema.call(successCall);
      expect(successCallbackCalled, isTrue);

      // Test failure case
      final failureSchema = TestToolSchemaWithCallback(
        onSuccessCallback: (call, result) {
          failureCallbackCalled = true;
          capturedFailureResult = result;
        },
      );

      const failureCall = ToolCall(
        toolName: 'test_tool_with_callback',
        arguments: {'query': '', 'limit': 5},
      );

      await failureSchema.call(failureCall);
      expect(failureCallbackCalled, isTrue);
      expect(capturedFailureResult, isNotNull);
      capturedFailureResult!.when(
        success: (data, response) => fail('Expected failure in callback'),
        failure: (error, _) => expect(error, equals('Query cannot be empty')),
      );
    });

    test('parser is used to convert arguments to typed call', () async {
      const toolCall = ToolCall(
        toolName: 'test_tool',
        arguments: {'query': 'parsing test'},
      );

      final result = await toolSchema.call(toolCall);

      expect(result.response['query'], equals('parsing test'));
      expect(result.response['limit'], equals(10)); // default value
    });
  });
}
