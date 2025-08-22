import 'package:firebase_ai/firebase_ai.dart';
import 'package:kai_engine/kai_engine.dart';

/// A base class for Firebase AI tool schemas that provides a foundation for creating
/// custom tool implementations. This class extends the generic ToolSchema with
/// Firebase-specific functionality.
///
/// To create a custom tool schema, extend this class and implement:
/// 1. A parser function to convert JSON to your tool call object
/// 2. A FunctionDeclaration that describes the tool to the AI model
/// 3. An execute method that implements the tool's functionality
///
/// Example implementation:
/// ```dart
/// final class SearchKgNodeToolSchema extends FirebaseAiToolSchema<SearchKgNodeTool, String> {
///   SearchKgNodeToolSchema()
///     : super(
///         parser: SearchKgNodeTool.fromJson,
///         declaration: FunctionDeclaration(
///           'searchKnowledgeNodeGraph',
///           'Search knowledge node graph',
///           parameters: {
///             'query': Schema.string(),
///           },
///         ),
///       );
///
///   @override
///   Future<ToolResult<String>> execute(SearchKgNodeTool call) async {
///     return ToolResult.success(
///       'The result of searching knowledge node graph for query',
///       {
///         'query': call.query,
///       },
///     );
///   }
/// }
/// ```

abstract base class FirebaseAiToolSchema<TCall, TResponse>
    extends ToolSchema<FunctionDeclaration, TCall, TResponse> {
  FirebaseAiToolSchema({
    required super.parser,
    required super.declaration,
    super.onSuccess,
  }) : super(name: declaration.name);

  Future<FunctionResponse> toFunctionResponse(FunctionCall functionCall) async {
    final toolCall = ToolCall(
      toolName: functionCall.name,
      arguments: functionCall.args,
    );
    final result = await call(toolCall);
    return FunctionResponse(functionCall.name, result.response);
  }
}

extension FirebaseAiToolSchemaListHelper on List<FirebaseAiToolSchema> {
  /// Convert type-safe tool schema to firebase tool
  List<Tool>? toFirebaseAiTools() {
    if (isEmpty) return null;
    return [Tool.functionDeclarations(map((e) => e.declaration).toList())];
  }

  Future<List<FunctionResponse>> executes(List<FunctionCall> calls) {
    final maps = {for (var tool in this) tool.declaration.name: tool};
    final futures = calls.map((call) async {
      final tool = maps[call.name];
      if (tool != null) {
        try {
          return await tool.toFunctionResponse(call);
        } catch (e) {
          // This error is unexpected, we need to catch and force error
          // unlike Tool response which return error, it handle by executor
          throw KaiException.toolFailure(e.toString());
        }
      } else {
        // This issue might be cause by incorrect configuration
        throw KaiException.toolFailure('Tool not found: ${call.name}');
      }
    });

    return Future.wait(futures);
  }
}
