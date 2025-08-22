/// Role: The base class for all major, "inspectable" operations in the engine,
/// such as QueryEngineBase or GenerationServiceBase.
///
/// Flow: A core engine component (e.g., GenerationServiceBase) will extend this
/// class. This provides two benefits:
/// 1. It standardizes the operation under a single `execute(Input)` method.
/// 2. It seamlessly provides developer-facing helper methods (`withStep`, `addLog`)
///    that can be called with `this.` from inside the implementation. These helpers
///    get the context they need from the private `PhaseController`.

import 'models/timeline_step.dart';
import 'models/timeline_types.dart';
import 'phase_controller.dart';

abstract class KaiPhase<Input, Output> {
  PhaseController? _phaseController;

  /// The developer-facing method to implement the phase's logic.
  Future<Output> execute(Input input);

  /// Internal method called by ChatController to run the phase with inspection.
  Future<Output> run(Input input, PhaseController phaseController) async {
    _phaseController = phaseController;

    try {
      final result = await execute(input);
      await _phaseController?.endPhase(status: TimelineStatus.completed);
      return result;
    } catch (error) {
      await _phaseController?.endPhase(status: TimelineStatus.failed);
      rethrow;
    }
  }

  /// Helper method to create a timed step within this phase.
  ///
  /// Usage:
  /// ```dart
  /// await withStep('Fetch RAG documents', (step) async {
  ///   final documents = await fetchDocuments();
  ///   step.addLog('Found ${documents.length} documents.');
  ///   return documents;
  /// });
  /// ```
  Future<T> withStep<T>(
    String stepName, {
    String? description,
    Map<String, dynamic>? metadata,
    required Future<T> Function(TimelineStep step) operation,
  }) async {
    if (_phaseController == null) {
      // If no inspector is active, just run the operation
      return operation(_createDummyStep(stepName, description, metadata));
    }

    final stepId = _generateId();
    final step = TimelineStep(
      id: stepId,
      name: stepName,
      description: description,
      startTime: DateTime.now(),
      metadata: metadata ?? {},
    );

    try {
      await _phaseController!.recordStep(step);
      final result = await operation(step);
      step.complete(status: TimelineStatus.completed);
      await _phaseController!.recordStep(step);
      return result;
    } catch (error) {
      step.complete(status: TimelineStatus.failed);
      await _phaseController!.recordStep(step);
      rethrow;
    }
  }

  /// Helper method to add a log entry to the current phase.
  ///
  /// Usage:
  /// ```dart
  /// addLog('Processing user query: $query');
  /// addLog('Found 3 relevant documents', severity: TimelineLogSeverity.info);
  /// ```
  void addLog(
    String message, {
    TimelineLogSeverity severity = TimelineLogSeverity.info,
    Map<String, dynamic>? metadata,
  }) {
    if (_phaseController == null) return;

    final log = TimelineLog(
      message: message,
      timestamp: DateTime.now(),
      severity: severity,
      metadata: metadata ?? {},
    );

    _phaseController!.recordPhaseLog(log);
  }

  /// Helper method to update session aggregates like token usage and cost.
  ///
  /// Usage:
  /// ```dart
  /// updateAggregates(tokenUsage: 150, cost: 0.002);
  /// ```
  void updateAggregates({int? tokenUsage, double? cost}) {
    if (_phaseController == null) return;

    _phaseController!.updateSessionAggregates(tokenUsage: tokenUsage, cost: cost);
  }

  /// Creates a dummy step for when no inspector is active.
  TimelineStep _createDummyStep(String name, String? description, Map<String, dynamic>? metadata) {
    return TimelineStep(
      id: 'dummy',
      name: name,
      description: description,
      startTime: DateTime.now(),
      metadata: metadata ?? {},
    );
  }

  /// Generates a unique ID for steps.
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
