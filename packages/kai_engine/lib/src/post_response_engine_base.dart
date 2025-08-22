// Run after the response is generated
// we can use this to perform same enhancements on the response
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:kai_engine/kai_engine.dart';

abstract class PostResponseEngineBase {
  /// Process post-response actions
  /// This should run before save to database
  /// [result] are the generated responses from the AI after process
  /// [requestMessages] are the original messages sent along with user input to AI to process.
  /// [input] is the original query context
  /// [conversationManager] is the conversation manager for the current session, to access conversation state use [conversationManager.getMessages()]
  Future<void> process({
    required QueryContext input,
    required IList<CoreMessage> requestMessages,
    required GenerationResult result,
    required ConversationManager conversationManager,
  }) async {
    // DO Nothings by default
  }
}

/// Enhanced PostResponseEngine with debug tracking capabilities
mixin PostResponseEngineDebugMixin on PostResponseEngineBase implements DebugTrackingMixin {
  @override
  DebugTrackerInterface get debugTracker => KaiDebugTracker.instance;

  @override
  void emitDebugEvent(DebugEvent event) {
    debugTracker.trackEvent(event);
  }

  /// Enhanced process method with debug tracking
  /// Implementations should override [processWithDebug] instead of [process]
  @override
  Future<void> process({
    required QueryContext input,
    required IList<CoreMessage> requestMessages,
    required GenerationResult result,
    required ConversationManager conversationManager,
  }) async {
    // Extract messageId from the first generated message
    final messageId = result.generatedMessages.isNotEmpty
        ? result.generatedMessages.first.messageId
        : result.displayMessage.messageId;

    final engineName = 'post-response-${runtimeType.toString()}';
    debugStartPhase(messageId, engineName);
    debugAddMetadata(
      messageId,
      '${engineName}-generated-messages',
      result.generatedMessages.length,
    );

    try {
      await processWithDebug(
        input: input,
        requestMessages: requestMessages,
        result: result,
        conversationManager: conversationManager,
        messageId: messageId,
      );
      debugEndPhase(messageId, engineName);
    } catch (e) {
      debugMessageFailed(messageId, Exception(e.toString()), engineName);
      rethrow;
    }
  }

  /// Process method with debug tracking capabilities
  /// Override this method in implementations instead of [process]
  Future<void> processWithDebug({
    required QueryContext input,
    required IList<CoreMessage> requestMessages,
    required GenerationResult result,
    required ConversationManager conversationManager,
    required String messageId,
  });

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
  ) => emitDebugEvent(ContextBuiltEvent(messageId, contextMessages, finalPrompts));
  @override
  void debugGenerationConfigured(String messageId, DebugGenerationConfig config) =>
      emitDebugEvent(GenerationConfiguredEvent(messageId, config));
  @override
  void debugStreamingChunk(String messageId, String chunk) =>
      emitDebugEvent(StreamingChunkEvent(messageId, chunk));
  @override
  void debugMessageCompleted(
    String messageId,
    IList<CoreMessage> generatedMessages, [
    GenerationUsage? usage,
  ]) => emitDebugEvent(MessageCompletedEvent(messageId, generatedMessages, usage));
  @override
  void debugMessageFailed(String messageId, Exception error, String phase) =>
      emitDebugEvent(MessageFailedEvent(messageId, error, phase));
  @override
  void debugAddMetadata(String messageId, String key, dynamic value) =>
      emitDebugEvent(MetadataAddedEvent(messageId, key, value));

  // Post-response step tracking methods
  @override
  void debugStartPostResponseStep(
    String messageId,
    String stepName, {
    String? description,
    Map<String, dynamic>? data,
  }) => emitDebugEvent(
    PostResponseStepStartedEvent(messageId, stepName, description: description, data: data),
  );

  @override
  void debugCompletePostResponseStep(
    String messageId,
    String stepName,
    Duration duration, {
    Map<String, dynamic>? result,
    String? status,
  }) => emitDebugEvent(
    PostResponseStepCompletedEvent(messageId, stepName, duration, result: result, status: status),
  );

  @override
  void debugFailPostResponseStep(
    String messageId,
    String stepName,
    Duration duration,
    Exception error, {
    String? errorDetails,
  }) => emitDebugEvent(
    PostResponseStepFailedEvent(messageId, stepName, duration, error, errorDetails: errorDetails),
  );

  @override
  void debugLogPostResponse(
    String messageId,
    String stepName,
    String level,
    String message, {
    Map<String, dynamic>? data,
  }) => emitDebugEvent(PostResponseLogEvent(messageId, stepName, level, message, data: data));

  /// Create a convenient logger for this engine's post-response processing
  PostResponseLogger createLogger(String messageId) {
    return PostResponseLogger(messageId);
  }
}
