import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:kai_engine/kai_engine.dart';

/// Base context builder class to extend and use in the template
abstract interface class ContextBuilder {}

/// Typedef to clear out that the result will use for the next sequential
typedef NextSequentialContext = List<CoreMessage>;

abstract interface class SequentialContextBuilder implements ContextBuilder {
  /// Build context in sequence, each step must complete before the next begins
  /// [input] is the formatted input from user, [previous] is the list of previous messages
  /// you can override that list to pass to next, eg build summarization etc
  /// return of [build] will be used as context for next step, return empty will
  /// effect overall next sequence and final prompt
  Future<NextSequentialContext> build(
    QueryContext input,
    List<CoreMessage> previous,
  );
}

/// Enhanced SequentialContextBuilder with debug tracking
mixin SequentialContextBuilderDebugMixin on SequentialContextBuilder
    implements DebugTrackingMixin {
  @override
  DebugTrackerInterface get debugTracker => KaiDebugTracker.instance;

  @override
  void emitDebugEvent(DebugEvent event) {
    debugTracker.trackEvent(event);
  }

  /// Enhanced build method with debug tracking
  Future<NextSequentialContext> buildWithDebug(
    QueryContext input,
    List<CoreMessage> previous,
    String messageId,
  ) async {
    final builderName = 'seq-${runtimeType.toString()}';
    debugStartPhase(messageId, builderName);

    try {
      final result = await build(input, previous);
      debugAddMetadata(messageId, '${builderName}-result-count', result.length);
      debugEndPhase(messageId, builderName);
      return result;
    } catch (e) {
      debugMessageFailed(messageId, Exception(e.toString()), builderName);
      rethrow;
    }
  }

  @override
  void debugStartMessage(String messageId, String originalInput) =>
      emitDebugEvent(MessageStartedEvent(messageId, originalInput));
  @override
  void debugStartPhase(String messageId, String phase) =>
      emitDebugEvent(PhaseStartedEvent(messageId, phase));
  @override
  void debugEndPhase(String messageId, String phase) =>
      emitDebugEvent(PhaseEndedEvent(messageId, phase));
  @override
  void debugQueryProcessed(String messageId, QueryContext processedQuery) =>
      emitDebugEvent(QueryProcessedEvent(messageId, processedQuery));
  @override
  void debugContextBuilt(
    String messageId,
    IList<CoreMessage> contextMessages,
    IList<CoreMessage> finalPrompts,
  ) => emitDebugEvent(
    ContextBuiltEvent(messageId, contextMessages, finalPrompts),
  );
  @override
  void debugGenerationConfigured(
    String messageId,
    DebugGenerationConfig config,
  ) => emitDebugEvent(GenerationConfiguredEvent(messageId, config));
  @override
  void debugStreamingChunk(String messageId, String chunk) =>
      emitDebugEvent(StreamingChunkEvent(messageId, chunk));
  @override
  void debugMessageCompleted(
    String messageId,
    IList<CoreMessage> generatedMessages, [
    GenerationUsage? usage,
  ]) => emitDebugEvent(
    MessageCompletedEvent(messageId, generatedMessages, usage),
  );
  @override
  void debugMessageFailed(String messageId, Exception error, String phase) =>
      emitDebugEvent(MessageFailedEvent(messageId, error, phase));
  @override
  void debugAddMetadata(String messageId, String key, dynamic value) =>
      emitDebugEvent(MetadataAddedEvent(messageId, key, value));
}

abstract interface class ParallelContextBuilder implements ContextBuilder {
  /// Build context in parallel, each step can be executed independently
  /// No awareness of other steps, the return of it doesn't effect final result
  /// return empty will only ignore it from final template
  /// unlike SequentialContextBuilder, return value will not be used for next step
  /// previous context will be use just for reference
  Future<List<CoreMessage>> build(
    QueryContext input,
    IList<CoreMessage> context,
  );
}

/// Enhanced ParallelContextBuilder with debug tracking
mixin ParallelContextBuilderDebugMixin on ParallelContextBuilder
    implements DebugTrackingMixin {
  @override
  DebugTrackerInterface get debugTracker => KaiDebugTracker.instance;

  @override
  void emitDebugEvent(DebugEvent event) {
    debugTracker.trackEvent(event);
  }

  /// Enhanced build method with debug tracking
  Future<List<CoreMessage>> buildWithDebug(
    QueryContext input,
    IList<CoreMessage> context,
    String messageId,
  ) async {
    final builderName = 'par-${runtimeType.toString()}';
    debugStartPhase(messageId, builderName);

    try {
      final result = await build(input, context);
      debugAddMetadata(messageId, '${builderName}-result-count', result.length);
      debugEndPhase(messageId, builderName);
      return result;
    } catch (e) {
      debugMessageFailed(messageId, Exception(e.toString()), builderName);
      rethrow;
    }
  }

  @override
  void debugStartMessage(String messageId, String originalInput) =>
      emitDebugEvent(MessageStartedEvent(messageId, originalInput));
  @override
  void debugStartPhase(String messageId, String phase) =>
      emitDebugEvent(PhaseStartedEvent(messageId, phase));
  @override
  void debugEndPhase(String messageId, String phase) =>
      emitDebugEvent(PhaseEndedEvent(messageId, phase));
  @override
  void debugQueryProcessed(String messageId, QueryContext processedQuery) =>
      emitDebugEvent(QueryProcessedEvent(messageId, processedQuery));
  @override
  void debugContextBuilt(
    String messageId,
    IList<CoreMessage> contextMessages,
    IList<CoreMessage> finalPrompts,
  ) => emitDebugEvent(
    ContextBuiltEvent(messageId, contextMessages, finalPrompts),
  );
  @override
  void debugGenerationConfigured(
    String messageId,
    DebugGenerationConfig config,
  ) => emitDebugEvent(GenerationConfiguredEvent(messageId, config));
  @override
  void debugStreamingChunk(String messageId, String chunk) =>
      emitDebugEvent(StreamingChunkEvent(messageId, chunk));
  @override
  void debugMessageCompleted(
    String messageId,
    IList<CoreMessage> generatedMessages, [
    GenerationUsage? usage,
  ]) => emitDebugEvent(
    MessageCompletedEvent(messageId, generatedMessages, usage),
  );
  @override
  void debugMessageFailed(String messageId, Exception error, String phase) =>
      emitDebugEvent(MessageFailedEvent(messageId, error, phase));
  @override
  void debugAddMetadata(String messageId, String key, dynamic value) =>
      emitDebugEvent(MetadataAddedEvent(messageId, key, value));
}

/// Prebuilt history context
class HistoryContext implements SequentialContextBuilder {
  @override
  Future<List<CoreMessage>> build(
    QueryContext input,
    List<CoreMessage> previous,
  ) async => previous;
}
