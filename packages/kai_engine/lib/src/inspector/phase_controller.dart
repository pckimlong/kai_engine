/// Role: An internal, short-lived context carrier object.
///
/// Flow: This class is not intended for public use. The ChatController creates
/// an instance of this class before it runs a `KaiPhase`. It bundles together a
/// reference to the main `KaiInspector` service and the IDs for the current
/// session and timeline. It is then passed to an internal `run` method on the
/// `KaiPhase`, giving the phase's helper methods the context they need to
/// record data to the correct place.

import 'kai_inspector.dart';
import 'models/timeline_step.dart';
import 'models/timeline_types.dart';

class PhaseController {
  /// Creates a new PhaseController.
  PhaseController({
    required this.inspector,
    required this.sessionId,
    required this.timelineId,
    required this.phaseId,
    required this.phaseName,
    this.description,
  });

  /// The inspector service to record data to.
  final KaiInspector inspector;

  /// The current session ID.
  final String sessionId;

  /// The current timeline ID.
  final String timelineId;

  /// The current phase ID.
  final String phaseId;

  /// The human-readable name of the current phase.
  final String phaseName;

  /// Optional description of the current phase.
  final String? description;

  /// Records a step within this phase.
  Future<void> recordStep(TimelineStep step, {String? parentStepId}) async {
    await inspector.recordStep(sessionId, timelineId, phaseId, step, parentStepId: parentStepId);
  }

  /// Updates an existing step within this phase.
  Future<void> updateStep(TimelineStep step) async {
    await inspector.updateStep(sessionId, timelineId, phaseId, step);
  }

  /// Records a log entry for this phase.
  Future<void> recordPhaseLog(TimelineLog log) async {
    await inspector.recordPhaseLog(sessionId, timelineId, phaseId, log);
  }

  /// Records a log entry for a specific step within this phase.
  Future<void> recordStepLog(String stepId, TimelineLog log) async {
    await inspector.recordStepLog(sessionId, timelineId, phaseId, stepId, log);
  }

  /// Ends this phase with the given status.
  Future<void> endPhase({
    TimelineStatus status = TimelineStatus.completed,
  }) async {
    await inspector.endPhase(sessionId, timelineId, phaseId, status: status);
  }

  /// Updates session aggregates (e.g., token usage, cost).
  Future<void> updateSessionAggregates({int? tokenUsage, double? cost}) async {
    await inspector.updateSessionAggregates(
      sessionId,
      tokenUsage: tokenUsage,
      cost: cost,
    );
  }
}
