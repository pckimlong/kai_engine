import 'package:freezed_annotation/freezed_annotation.dart';

part 'tool_schema.freezed.dart';

@freezed
sealed class ToolResult<T> with _$ToolResult<T> {
  const ToolResult._();

  /// Represents a successful tool execution result.
  ///
  /// Contains the [data] returned by the tool and a [response] map that will be
  /// sent back to the AI provider. The [response] map typically includes structured
  /// data that provides context about the operation's result.
  const factory ToolResult.success(T data, Map<String, Object?> response) =
      _ToolResultSuccessWithData;

  /// Represents a failed tool execution result.
  ///
  /// Contains an [error] message describing what went wrong during tool execution.
  const factory ToolResult.failure(String error, StackTrace stackTrace) = _ToolResultFailure;
}

/// Encapsulates the definition of a tool that can be called by the AI.
///
/// This class holds the [name] of the tool and its [declaration], which contains
/// the structured information about the tool (such as its parameters and description)
/// that will be sent to the AI provider.
class ToolDeclaration<TDeclaration> {
  /// The name of the tool that the AI will use to identify and call it.
  final String name;

  /// The structured declaration of the tool, containing information about its
  /// parameters, description, and other metadata required by the AI provider.
  final TDeclaration declaration;

  const ToolDeclaration({required this.name, required this.declaration});
}

/// Represents a request from the AI to execute a specific tool.
///
/// Contains the [toolName] identifying which tool to call and the [arguments]
/// (parameters) that should be passed to the tool during execution.
class ToolCall {
  /// The name of the tool that the AI wants to execute.
  final String toolName;

  /// The arguments (parameters) that the AI wants to pass to the tool.
  ///
  /// These are typically key-value pairs where keys are parameter names and
  /// values are the corresponding parameter values.
  final Map<String, dynamic> arguments;

  const ToolCall({required this.toolName, required this.arguments});
}

/// Represents the result of a tool's execution that will be sent back to the AI.
///
/// Contains the [toolName] to identify which tool was executed and the [response]
/// data that resulted from the execution.
class ToolResponse {
  /// The name of the tool that was executed.
  final String toolName;

  /// The response data from the tool execution.
  ///
  /// This contains the structured result data that will be sent back to the AI,
  /// typically including either the successful result or error information.
  final Map<String, dynamic> response;

  const ToolResponse({required this.toolName, required this.response});
}

/// Defines the schema and execution logic for a tool that can be called by the AI.
///
/// This abstract base class provides the framework for implementing tools that
/// can be invoked by an AI. It handles the complete lifecycle of a tool call:
/// 1. Parsing the AI's request into a strongly-typed call object
/// 2. Executing the tool's business logic
/// 3. Building and returning a structured response
///
/// Generic type parameters:
/// - [TDeclaration]: The type of the tool declaration (depends on the AI provider)
/// - [TCall]: The strongly-typed representation of the tool call parameters
/// - [TResponse]: The type of data returned by the tool execution
///
/// Example implementation:
/// ```dart
/// // Define the tool call parameters
/// @freezed
/// sealed class SearchKgNodeTool with _$SearchKgNodeTool {
///   const SearchKgNodeTool._();
///
///   const factory SearchKgNodeTool({
///     required String query,
///   }) = _SearchKgNodeTool;
///
///   factory SearchKgNodeTool.fromJson(Map<String, dynamic> json) => _$SearchKgNodeToolFromJson(json);
/// }
///
/// // Implement the tool schema
/// final class SearchKgNodeToolSchema extends ToolSchema<FunctionDeclaration, SearchKgNodeTool, String> {
///   SearchKgNodeToolSchema()
///     : super(
///         name: 'searchKnowledgeNodeGraph',
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
///     try {
///       final result = await searchKnowledgeGraph(call.query);
///       return ToolResult.success(
///         result,
///         {
///           'query': call.query,
///           'resultCount': result.length,
///         },
///       );
///     } catch (e) {
///       return ToolResult.failure('Failed to search knowledge graph: $e');
///     }
///   }
/// }
/// ```

abstract base class ToolSchema<TDeclaration, TCall, TResponse> {
  /// Creates a new tool schema.
  ///
  /// [name] is the unique identifier for this tool.
  /// [parser] is a function that converts JSON map to a strongly-typed call object.
  /// [declaration] is the structured tool definition sent to the AI provider.
  /// [onSuccess] is an optional callback executed after successful tool execution.
  const ToolSchema({
    required this.name,
    required this.parser,
    required this.declaration,
    this.onSuccess,
  });

  /// The unique name of this tool.
  ///
  /// This name is used by the AI to identify and call this specific tool.
  final String name;

  /// Function that parses a JSON map into a strongly-typed call object.
  ///
  /// This parser converts the raw arguments received from the AI into a
  /// type-safe object that can be used in the [execute] method.
  final TCall Function(Map<String, Object?> json) parser;

  /// The structured declaration of the tool sent to the AI provider.
  ///
  /// This contains information about the tool's purpose, parameters, and other
  /// metadata required by the AI provider to understand how to use the tool.
  final TDeclaration declaration;

  /// Optional callback executed after successful tool execution.
  ///
  /// This function is called with the parsed call object and the execution result
  /// after the tool has been executed but before the response is sent back to the AI.
  final void Function(TCall call, ToolResult<TResponse> result)? onSuccess;

  /// Converts this tool schema into a [ToolDeclaration] that can be sent to the AI provider.
  ///
  /// This method packages the tool's name and declaration into a format that
  /// can be registered with the AI provider.
  ToolDeclaration toKaiTool() => ToolDeclaration(name: name, declaration: declaration);

  /// Executes the tool's business logic with the provided call parameters.
  ///
  /// This is the core implementation of the tool where the actual work is done.
  /// Subclasses must override this method to provide the specific functionality.
  ///
  /// Parameters:
  /// - [call]: The strongly-typed call object parsed from the AI's request.
  ///
  /// Returns:
  /// - A [ToolResult] containing either the successful result or an error.
  Future<ToolResult<TResponse>> execute(TCall call);

  /// Builds the response map that will be sent back to the AI.
  ///
  /// This method converts a [ToolResult] into a map that will be included in
  /// the [ToolResponse] sent back to the AI. By default, it extracts the response
  /// data from successful results or creates an error map for failures.
  ///
  /// Subclasses can override this method to customize what data is sent back
  /// to the AI while keeping the result data separate for internal use.
  ///
  /// Parameters:
  /// - [result]: The result of executing the tool.
  ///
  /// Returns:
  /// - A map containing the data to send back to the AI.
  Map<String, Object?> buildResponse(ToolResult<TResponse> result) {
    return result.when(
      success: (data, response) => response,
      failure: (error, _) => {'error': error},
    );
  }

  /// Main entry point for processing a tool call from the AI.
  ///
  /// This method orchestrates the complete tool execution flow:
  /// 1. Parses the raw arguments from the [toolCall] into a strongly-typed object
  /// 2. Executes the tool's business logic via the [execute] method
  /// 3. Calls the [onSuccess] callback if registered and execution was successful
  /// 4. Builds and returns a structured response for the AI
  ///
  /// Parameters:
  /// - [toolCall]: The raw tool call request from the AI.
  ///
  /// Returns:
  /// - A [ToolResponse] containing the tool's name and execution result.
  Future<ToolResponse> call(ToolCall toolCall) async {
    if (toolCall.toolName != name) {
      throw ArgumentError(
        'Tool call name "${toolCall.toolName}" does not match schema name "$name".',
      );
    }

    final params = parser(toolCall.arguments);
    final result = await execute(params);
    onSuccess?.call(params, result);
    return ToolResponse(toolName: name, response: buildResponse(result));
  }
}
