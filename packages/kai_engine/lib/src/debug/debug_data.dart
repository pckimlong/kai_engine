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

class PostResponseStep {
  final String name;
  final String? description;
  final DateTime startTime;
  DateTime? endTime;
  final Map<String, dynamic> metadata;
  final List<PostResponseLog> logs = [];
  Exception? error;
  String? errorDetails;
  String? status;
  Map<String, dynamic>? result;

  PostResponseStep(
    this.name, {
    this.description,
    Map<String, dynamic>? metadata,
  }) : startTime = DateTime.now(),
       metadata = metadata ?? {};

  Duration? get duration => endTime?.difference(startTime);
  bool get isComplete => endTime != null;
  bool get hasError => error != null;
  bool get isSuccess => isComplete && !hasError;

  void complete({Map<String, dynamic>? result, String? status}) {
    endTime = DateTime.now();
    this.result = result;
    this.status = status ?? 'completed';
  }

  void fail(Exception error, {String? errorDetails}) {
    endTime = DateTime.now();
    this.error = error;
    this.errorDetails = errorDetails;
    this.status = 'failed';
  }

  void addLog(String level, String message, {Map<String, dynamic>? data}) {
    logs.add(PostResponseLog(level, message, data: data));
  }
}

class PostResponseLog {
  final DateTime timestamp;
  final String level;
  final String message;
  final Map<String, dynamic>? data;

  PostResponseLog(this.level, this.message, {this.data})
    : timestamp = DateTime.now();
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

  // Post-response processing steps
  final Map<String, PostResponseStep> postResponseSteps = {};
  PostResponseStep? _currentStep;

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

  // Post-response step management
  void startPostResponseStep(
    String stepName, {
    String? description,
    Map<String, dynamic>? data,
  }) {
    final step = PostResponseStep(
      stepName,
      description: description,
      metadata: data ?? {},
    );
    postResponseSteps[stepName] = step;
    _currentStep = step;
  }

  void completePostResponseStep(
    String stepName, {
    Map<String, dynamic>? result,
    String? status,
  }) {
    final step = postResponseSteps[stepName];
    if (step != null) {
      step.complete(result: result, status: status);
      if (_currentStep == step) {
        _currentStep = null;
      }
    }
  }

  void failPostResponseStep(
    String stepName,
    Exception error, {
    String? errorDetails,
  }) {
    final step = postResponseSteps[stepName];
    if (step != null) {
      step.fail(error, errorDetails: errorDetails);
      if (_currentStep == step) {
        _currentStep = null;
      }
    }
  }

  void logToCurrentStep(
    String level,
    String message, {
    Map<String, dynamic>? data,
  }) {
    _currentStep?.addLog(level, message, data: data);
  }

  void logToStep(
    String stepName,
    String level,
    String message, {
    Map<String, dynamic>? data,
  }) {
    postResponseSteps[stepName]?.addLog(level, message, data: data);
  }

  // Get all steps in chronological order
  List<PostResponseStep> get orderedPostResponseSteps {
    final steps = postResponseSteps.values.toList();
    steps.sort((a, b) => a.startTime.compareTo(b.startTime));
    return steps;
  }
}
