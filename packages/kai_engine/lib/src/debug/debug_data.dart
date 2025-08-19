import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../models/core_message.dart';
import '../models/generation_result.dart';
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
  final bool usedEmbedding;

  const DebugGenerationConfig({
    required this.availableTools,
    required this.config,
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
  GenerationUsage? usage;
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