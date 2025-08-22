import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../models/core_message.dart';
import '../models/generation_result.dart';
import '../models/query_context.dart';
import 'debug_data.dart';
import 'debug_events.dart';
import 'debug_tracker.dart';

/// Mixin for debug tracking capabilities
mixin DebugTrackingMixin {
  DebugTrackerInterface get debugTracker => KaiDebugTracker.instance;

  void emitDebugEvent(DebugEvent event) {
    debugTracker.trackEvent(event);
  }

  void debugStartMessage(String messageId, String originalInput) {
    emitDebugEvent(MessageStartedEvent(messageId, originalInput));
  }

  void debugStartPhase(String messageId, String phase) {
    emitDebugEvent(PhaseStartedEvent(messageId, phase));
  }

  void debugEndPhase(String messageId, String phase) {
    emitDebugEvent(PhaseEndedEvent(messageId, phase));
  }

  void debugQueryProcessed(String messageId, QueryContext processedQuery) {
    emitDebugEvent(QueryProcessedEvent(messageId, processedQuery));
  }

  void debugContextBuilt(
    String messageId,
    IList<CoreMessage> contextMessages,
    IList<CoreMessage> finalPrompts,
  ) {
    emitDebugEvent(ContextBuiltEvent(messageId, contextMessages, finalPrompts));
  }

  void debugGenerationConfigured(
    String messageId,
    DebugGenerationConfig config,
  ) {
    emitDebugEvent(GenerationConfiguredEvent(messageId, config));
  }

  void debugStreamingChunk(String messageId, String chunk) {
    emitDebugEvent(StreamingChunkEvent(messageId, chunk));
  }

  void debugMessageCompleted(
    String messageId,
    IList<CoreMessage> generatedMessages, [
    GenerationUsage? usage,
  ]) {
    emitDebugEvent(MessageCompletedEvent(messageId, generatedMessages, usage));
  }

  void debugMessageFailed(String messageId, Exception error, String phase) {
    emitDebugEvent(MessageFailedEvent(messageId, error, phase));
  }

  void debugAddMetadata(String messageId, String key, dynamic value) {
    emitDebugEvent(MetadataAddedEvent(messageId, key, value));
  }

  // Post-response step tracking methods
  void debugStartPostResponseStep(
    String messageId,
    String stepName, {
    String? description,
    Map<String, dynamic>? data,
  }) {
    emitDebugEvent(
      PostResponseStepStartedEvent(
        messageId,
        stepName,
        description: description,
        data: data,
      ),
    );
  }

  void debugCompletePostResponseStep(
    String messageId,
    String stepName,
    Duration duration, {
    Map<String, dynamic>? result,
    String? status,
  }) {
    emitDebugEvent(
      PostResponseStepCompletedEvent(
        messageId,
        stepName,
        duration,
        result: result,
        status: status,
      ),
    );
  }

  void debugFailPostResponseStep(
    String messageId,
    String stepName,
    Duration duration,
    Exception error, {
    String? errorDetails,
  }) {
    emitDebugEvent(
      PostResponseStepFailedEvent(
        messageId,
        stepName,
        duration,
        error,
        errorDetails: errorDetails,
      ),
    );
  }

  void debugLogPostResponse(
    String messageId,
    String stepName,
    String level,
    String message, {
    Map<String, dynamic>? data,
  }) {
    emitDebugEvent(
      PostResponseLogEvent(messageId, stepName, level, message, data: data),
    );
  }
}
