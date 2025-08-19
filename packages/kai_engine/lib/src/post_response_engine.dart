// Run after the response is generated
// we can use this to perform same enhancements on the response
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:kai_engine/kai_engine.dart';

interface class PostResponseEngine {
  /// Process post-response actions
  /// This should run before save to database
  /// [result] are the generated responses from the AI after process
  /// [input] is the original query context
  /// [conversationManager] is the conversation manager for the current session, to access conversation state use [conversationManager.getMessages()]
  Future<void> process({
    required QueryContext input,
    required GenerationResult result,
    required ConversationManager conversationManager,
  }) async {
    // DO Nothings by default
  }
}

/// Enhanced PostResponseEngine with debug tracking capabilities
mixin PostResponseEngineDebugMixin on PostResponseEngine implements DebugTrackingMixin {
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
    required GenerationResult result,
    required ConversationManager conversationManager,
  }) async {
    // Extract messageId from the first generated message
    final messageId = result.generatedMessage.isNotEmpty 
        ? result.generatedMessage.first.messageId
        : result.displayMessage.messageId;

    final engineName = 'post-response-${runtimeType.toString()}';
    debugStartPhase(messageId, engineName);
    debugAddMetadata(messageId, '${engineName}-generated-messages', result.generatedMessage.length);
    
    try {
      await processWithDebug(
        input: input,
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
    required GenerationResult result,
    required ConversationManager conversationManager,
    required String messageId,
  });

  @override
  void debugStartMessage(String messageId, String originalInput) => emitDebugEvent(MessageStartedEvent(messageId, originalInput));
  @override
  void debugStartPhase(String messageId, String phase) => emitDebugEvent(PhaseStartedEvent(messageId, phase));
  @override
  void debugEndPhase(String messageId, String phase) => emitDebugEvent(PhaseEndedEvent(messageId, phase));
  @override
  void debugQueryProcessed(String messageId, QueryContext processedQuery) => emitDebugEvent(QueryProcessedEvent(messageId, processedQuery));
  @override
  void debugContextBuilt(String messageId, IList<CoreMessage> contextMessages, IList<CoreMessage> finalPrompts) => emitDebugEvent(ContextBuiltEvent(messageId, contextMessages, finalPrompts));
  @override
  void debugGenerationConfigured(String messageId, DebugGenerationConfig config) => emitDebugEvent(GenerationConfiguredEvent(messageId, config));
  @override
  void debugStreamingChunk(String messageId, String chunk) => emitDebugEvent(StreamingChunkEvent(messageId, chunk));
  @override
  void debugMessageCompleted(String messageId, IList<CoreMessage> generatedMessages) => emitDebugEvent(MessageCompletedEvent(messageId, generatedMessages));
  @override
  void debugMessageFailed(String messageId, Exception error, String phase) => emitDebugEvent(MessageFailedEvent(messageId, error, phase));
  @override
  void debugAddMetadata(String messageId, String key, dynamic value) => emitDebugEvent(MetadataAddedEvent(messageId, key, value));
}
