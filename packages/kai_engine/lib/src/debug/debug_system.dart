import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../models/core_message.dart';
import '../models/query_context.dart';

/// Type-safe debug data classes
class DebugPhase {
  final String name;
  final DateTime startTime;
  DateTime? endTime;
  final Map<String, dynamic> metadata = {};

  DebugPhase(this.name) : startTime = DateTime.now();

  Duration? get duration => endTime?.difference(startTime);
  bool get isComplete => endTime != null;

  void complete() {
    endTime = DateTime.now();
  }
}

class DebugGenerationConfig {
  final List<String> availableTools;
  final Map<String, dynamic> config;
  final int? tokenCount;
  final bool usedEmbedding;

  const DebugGenerationConfig({
    required this.availableTools,
    required this.config,
    this.tokenCount,
    this.usedEmbedding = false,
  });
}

class DebugStreamingInfo {
  final List<String> chunks = [];
  int eventCount = 0;

  void addChunk(String chunk) {
    chunks.add(chunk);
    eventCount++;
  }

  String get fullText => chunks.join();
}

/// Complete debug information for a message
class MessageDebugInfo {
  final String messageId;
  final String originalInput;
  final DateTime startTime;
  DateTime? endTime;

  // Processing stages
  QueryContext? processedQuery;
  IList<CoreMessage>? contextMessages;
  IList<CoreMessage>? finalPrompts;
  DebugGenerationConfig? generationConfig;

  // Phases and timing
  final Map<String, DebugPhase> phases = {};

  // Streaming
  final DebugStreamingInfo streaming = DebugStreamingInfo();

  // Results
  IList<CoreMessage>? generatedMessages;
  Exception? error;
  String? errorPhase;

  // Custom metadata
  final Map<String, dynamic> metadata = {};

  MessageDebugInfo({required this.messageId, required this.originalInput})
    : startTime = DateTime.now();

  Duration? get totalDuration => endTime?.difference(startTime);
  bool get isComplete => endTime != null;
  bool get hasError => error != null;

  void startPhase(String name) {
    phases[name] = DebugPhase(name);
  }

  void endPhase(String name) {
    phases[name]?.complete();
  }

  void complete() {
    endTime = DateTime.now();
  }

  void fail(Exception error, String phase) {
    this.error = error;
    errorPhase = phase;
    endTime = DateTime.now();
  }
}

/// Debug events for decoupled tracking
abstract class DebugEvent {
  final String messageId;
  final DateTime timestamp;

  DebugEvent(this.messageId) : timestamp = DateTime.now();
}

class MessageStartedEvent extends DebugEvent {
  final String originalInput;
  MessageStartedEvent(super.messageId, this.originalInput);
}

class PhaseStartedEvent extends DebugEvent {
  final String phase;
  PhaseStartedEvent(super.messageId, this.phase);
}

class PhaseEndedEvent extends DebugEvent {
  final String phase;
  PhaseEndedEvent(super.messageId, this.phase);
}

class QueryProcessedEvent extends DebugEvent {
  final QueryContext processedQuery;
  QueryProcessedEvent(super.messageId, this.processedQuery);
}

class ContextBuiltEvent extends DebugEvent {
  final IList<CoreMessage> contextMessages;
  final IList<CoreMessage> finalPrompts;
  ContextBuiltEvent(super.messageId, this.contextMessages, this.finalPrompts);
}

class GenerationConfiguredEvent extends DebugEvent {
  final DebugGenerationConfig config;
  GenerationConfiguredEvent(super.messageId, this.config);
}

class StreamingChunkEvent extends DebugEvent {
  final String chunk;
  StreamingChunkEvent(super.messageId, this.chunk);
}

class MessageCompletedEvent extends DebugEvent {
  final IList<CoreMessage> generatedMessages;
  MessageCompletedEvent(super.messageId, this.generatedMessages);
}

class MessageFailedEvent extends DebugEvent {
  final Exception error;
  final String phase;
  MessageFailedEvent(super.messageId, this.error, this.phase);
}

class MetadataAddedEvent extends DebugEvent {
  final String key;
  final dynamic value;
  MetadataAddedEvent(super.messageId, this.key, this.value);
}

/// Debug tracker interface for testability
abstract class DebugTrackerInterface {
  void trackEvent(DebugEvent event);
  MessageDebugInfo? getMessageDebugInfo(String messageId);
  Stream<MessageDebugInfo> get debugInfoStream;
}

/// Main debug tracker implementation
class KaiDebugTracker implements DebugTrackerInterface {
  static KaiDebugTracker? _instance;
  static KaiDebugTracker get instance => _instance ??= KaiDebugTracker._();
  static set instance(KaiDebugTracker tracker) => _instance = tracker;

  KaiDebugTracker._();

  final Map<String, MessageDebugInfo> _debugInfo = {};
  final BehaviorSubject<MessageDebugInfo> _debugInfoController =
      BehaviorSubject<MessageDebugInfo>();

  bool get isEnabled => !kReleaseMode;

  @override
  void trackEvent(DebugEvent event) {
    if (!isEnabled) return;

    switch (event) {
      case MessageStartedEvent():
        final info = MessageDebugInfo(
          messageId: event.messageId,
          originalInput: event.originalInput,
        );
        _debugInfo[event.messageId] = info;
        _debugInfoController.add(info);

      case PhaseStartedEvent():
        _debugInfo[event.messageId]?.startPhase(event.phase);

      case PhaseEndedEvent():
        final info = _debugInfo[event.messageId];
        info?.endPhase(event.phase);
        if (info != null) _debugInfoController.add(info);

      case QueryProcessedEvent():
        final info = _debugInfo[event.messageId];
        if (info != null) {
          info.processedQuery = event.processedQuery;
          _debugInfoController.add(info);
        }

      case ContextBuiltEvent():
        final info = _debugInfo[event.messageId];
        if (info != null) {
          info.contextMessages = event.contextMessages;
          info.finalPrompts = event.finalPrompts;
          _debugInfoController.add(info);
        }

      case GenerationConfiguredEvent():
        final info = _debugInfo[event.messageId];
        if (info != null) {
          info.generationConfig = event.config;
          _debugInfoController.add(info);
        }

      case StreamingChunkEvent():
        final info = _debugInfo[event.messageId];
        if (info != null) {
          info.streaming.addChunk(event.chunk);
          _debugInfoController.add(info);
        }

      case MessageCompletedEvent():
        final info = _debugInfo[event.messageId];
        if (info != null) {
          info.generatedMessages = event.generatedMessages;
          info.complete();
          _debugInfoController.add(info);
        }

      case MessageFailedEvent():
        final info = _debugInfo[event.messageId];
        if (info != null) {
          info.fail(event.error, event.phase);
          _debugInfoController.add(info);
        }

      case MetadataAddedEvent():
        final info = _debugInfo[event.messageId];
        if (info != null) {
          info.metadata[event.key] = event.value;
          _debugInfoController.add(info);
        }
    }

    _cleanup();
  }

  @override
  MessageDebugInfo? getMessageDebugInfo(String messageId) {
    if (!isEnabled) return null;
    return _debugInfo[messageId];
  }

  @override
  Stream<MessageDebugInfo> get debugInfoStream => _debugInfoController.stream;

  List<MessageDebugInfo> getRecentMessages({int limit = 20}) {
    if (!isEnabled) return [];
    final messages = _debugInfo.values.toList();
    messages.sort((a, b) => b.startTime.compareTo(a.startTime));
    return messages.take(limit).toList();
  }

  void _cleanup() {
    if (_debugInfo.length > 100) {
      final messages = _debugInfo.values.toList();
      messages.sort((a, b) => b.startTime.compareTo(a.startTime));
      final toKeep = messages.take(50).map((m) => m.messageId).toSet();
      _debugInfo.removeWhere((key, value) => !toKeep.contains(key));
    }
  }

  void dispose() {
    _debugInfoController.close();
  }
}

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

  void debugGenerationConfigured(String messageId, DebugGenerationConfig config) {
    emitDebugEvent(GenerationConfiguredEvent(messageId, config));
  }

  void debugStreamingChunk(String messageId, String chunk) {
    emitDebugEvent(StreamingChunkEvent(messageId, chunk));
  }

  void debugMessageCompleted(String messageId, IList<CoreMessage> generatedMessages) {
    emitDebugEvent(MessageCompletedEvent(messageId, generatedMessages));
  }

  void debugMessageFailed(String messageId, Exception error, String phase) {
    emitDebugEvent(MessageFailedEvent(messageId, error, phase));
  }

  void debugAddMetadata(String messageId, String key, dynamic value) {
    emitDebugEvent(MetadataAddedEvent(messageId, key, value));
  }
}

/// Easy access utilities
class KaiDebug {
  static MessageDebugInfo? getMessageInfo(String messageId) {
    return KaiDebugTracker.instance.getMessageDebugInfo(messageId);
  }

  static List<MessageDebugInfo> getRecentMessages({int limit = 20}) {
    return KaiDebugTracker.instance.getRecentMessages(limit: limit);
  }

  static Stream<MessageDebugInfo> get stream => KaiDebugTracker.instance.debugInfoStream;
}
