import 'package:kai_engine/src/models/core_message.dart';

import 'models/query_context.dart';

/// Base context builder class to extend and use in the template
abstract interface class ContextBuilder {}

abstract interface class SequentialContextBuilder implements ContextBuilder {
  /// Build context in sequence, each step must complete before the next begins
  /// [input] is the formatted input from user, [previous] is the list of previous messages
  /// you can override that list to pass to next, eg build summarization etc
  /// return of [build] will be used as context for next step, return empty will
  /// effect overall next sequence and final prompt
  Future<List<CoreMessage>> build(
    QueryContext input,
    List<CoreMessage> previous,
  );
}

abstract interface class ParallelContextBuilder implements ContextBuilder {
  /// Build context in parallel, each step can be executed independently
  /// No awareness of other steps, the return of it doesn't effect final result
  /// return empty will only ignore it from final template
  Future<List<CoreMessage>> build(QueryContext input);
}

/// Prebuilt history context
class HistoryContext implements SequentialContextBuilder {
  @override
  Future<List<CoreMessage>> build(
    QueryContext input,
    List<CoreMessage> previous,
  ) async => previous;
}
