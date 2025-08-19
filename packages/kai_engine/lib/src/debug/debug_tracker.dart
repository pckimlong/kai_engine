import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../models/generation_result.dart';
import 'debug_data.dart';
import 'debug_events.dart';

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

  double _inputTokenCostPerMillion = 0.0;
  double _outputTokenCostPerMillion = 0.0;

  /// Set the cost per million input tokens
  void setInputTokenCostPerMillion(double cost) {
    _inputTokenCostPerMillion = cost;
  }

  /// Set the cost per million output tokens
  void setOutputTokenCostPerMillion(double cost) {
    _outputTokenCostPerMillion = cost;
  }

  /// Get the cost per million input tokens
  double getInputTokenCostPerMillion() {
    return _inputTokenCostPerMillion;
  }

  /// Get the cost per million output tokens
  double getOutputTokenCostPerMillion() {
    return _outputTokenCostPerMillion;
  }

  /// Calculate the total cost for a message based on its token usage
  double calculateTotalCost(GenerationUsage? usage) {
    if (usage == null) return 0.0;

    final inputTokens = usage.inputToken ?? 0;
    final outputTokens = usage.outputToken ?? 0;

    final inputCost = (inputTokens / 1000000) * _inputTokenCostPerMillion;
    final outputCost = (outputTokens / 1000000) * _outputTokenCostPerMillion;

    return inputCost + outputCost;
  }

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
          info.usage = event.usage; // Add this line
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
