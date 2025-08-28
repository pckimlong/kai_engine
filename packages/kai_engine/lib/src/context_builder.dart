import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:kai_engine/kai_engine.dart';

/// Base context builder class to extend and use in the template
abstract interface class ContextBuilder {}

/// Typedef to clear out that the result will use for the next sequential
typedef NextSequentialContext = IList<CoreMessage>;

abstract interface class SequentialContextBuilder implements ContextBuilder {
  /// Build context in sequence, each step must complete before the next begins
  /// [input] is the formatted input from user, [previous] is the list of previous messages
  /// you can override that list to pass to next, eg build summarization etc
  /// return of [build] will be used as context for next step, return empty will
  /// effect overall next sequence and final prompt
  Future<NextSequentialContext> build(QueryContext input, IList<CoreMessage> previous);
}

abstract interface class ParallelContextBuilder implements ContextBuilder {
  /// Build context in parallel, each step can be executed independently
  /// No awareness of other steps, the return of it doesn't effect final result
  /// return empty will only ignore it from final template
  /// unlike SequentialContextBuilder, return value will not be used for next step
  /// previous context will be use just for reference
  Future<IList<CoreMessage>> build(QueryContext input, IList<CoreMessage> context);
}

/// Prebuilt history context
class HistoryContext implements SequentialContextBuilder {
  @override
  Future<IList<CoreMessage>> build(QueryContext input, IList<CoreMessage> previous) async =>
      previous;
}
