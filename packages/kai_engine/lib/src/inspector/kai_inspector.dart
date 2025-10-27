import 'dart:async';

import 'package:uuid/uuid.dart';

import 'kai_phase.dart';
import 'models/timeline_session.dart';
import 'models/timeline_step.dart';
import 'models/timeline_types.dart';
import 'phase_controller.dart';

/// Role: The central Service Contract. This is the main "plug-in point" for the
/// entire inspection system.
///
/// Flow: The ChatController will interact with this abstract class, decoupling the
/// engine from any specific inspector implementation. A developer can provide their
/// own implementation (e.g., for custom storage) or use the default one provided
/// in the `kai_inspector` package.
abstract class KaiInspector {
  /// Starts a new session with the given ID.
  Future<void> startSession(String sessionId);

  /// Ends the session with the given ID.
  Future<void> endSession(
    String sessionId, {
    TimelineStatus status = TimelineStatus.completed,
  });

  /// Starts a new timeline within the given session.
  Future<void> startTimeline(
    String sessionId,
    String timelineId,
    String userMessage,
  );

  /// Ends the timeline with the given ID.
  Future<void> endTimeline(
    String sessionId,
    String timelineId, {
    TimelineStatus status = TimelineStatus.completed,
    String? aiResponse,
  });

  /// Starts a new phase within the given timeline.
  Future<void> startPhase(
    String sessionId,
    String timelineId,
    String phaseId,
    String phaseName, {
    String? description,
  });

  /// Ends the phase with the given ID.
  Future<void> endPhase(
    String sessionId,
    String timelineId,
    String phaseId, {
    TimelineStatus status = TimelineStatus.completed,
  });

  /// Records a step within the given phase.
  Future<void> recordStep(
    String sessionId,
    String timelineId,
    String phaseId,
    TimelineStep step, {
    String? parentStepId,
  });

  /// Updates an existing step within the given phase.
  Future<void> updateStep(
    String sessionId,
    String timelineId,
    String phaseId,
    TimelineStep step,
  );

  /// Records a log entry for the given phase.
  Future<void> recordPhaseLog(
    String sessionId,
    String timelineId,
    String phaseId,
    TimelineLog log,
  );

  /// Records a prompt messages log entry for the given phase.
  Future<void> recordPromptMessagesLog(
    String sessionId,
    String timelineId,
    String phaseId,
    PromptMessagesLog log,
  );

  /// Records a generated messages log entry for the given phase.
  Future<void> recordGeneratedMessagesLog(
    String sessionId,
    String timelineId,
    String phaseId,
    GeneratedMessagesLog log,
  );

  /// Records a log entry for the given step.
  Future<void> recordStepLog(
    String sessionId,
    String timelineId,
    String phaseId,
    String stepId,
    TimelineLog log,
  );

  /// Gets a stream of session updates for the given session ID.
  Stream<TimelineSession> getSessionStream(String sessionId);

  /// Gets the current session data for the given session ID.
  Future<TimelineSession?> getSession(String sessionId);

  /// Updates aggregate data for the session (e.g., total token usage, cost).
  Future<void> updateSessionAggregates(
    String sessionId, {
    int? tokenUsage,
    double? cost,
  });

  /// Helper method to run a KaiPhase with full inspection.
  ///
  /// This method encapsulates all the complexity of:
  /// 1. Starting a phase
  /// 2. Creating a PhaseController
  /// 3. Running the phase with inspection
  /// 4. Ending the phase with proper error handling
  ///
  /// Usage:
  /// ```dart
  /// final result = await _inspector.inspectPhase(
  ///   sessionId, timelineId, 'Query Processing', _queryEngine, input
  /// );
  /// ```
  Future<Output> inspectPhase<Input, Output>(
    String sessionId,
    String timelineId,
    String phaseName,
    KaiPhase<Input, Output> phaseToRun,
    Input input, {
    String? description,
  }) async {
    const uuid = Uuid();
    final phaseId = uuid.v4();

    await startPhase(
      sessionId,
      timelineId,
      phaseId,
      phaseName,
      description: description,
    );

    try {
      final result = await phaseToRun.run(
        input,
        PhaseController(
          inspector: this,
          sessionId: sessionId,
          timelineId: timelineId,
          phaseId: phaseId,
          phaseName: phaseName,
        ),
      );

      await endPhase(sessionId, timelineId, phaseId);
      return result;
    } catch (error) {
      await endPhase(
        sessionId,
        timelineId,
        phaseId,
        status: TimelineStatus.failed,
      );
      rethrow;
    }
  }
}

/// Role: The default "do-nothing" implementation of the KaiInspector.
///
/// Flow: This class is used by the ChatController when no inspector is provided.
/// It ensures the system is completely disabled by default with zero performance
/// overhead, as its methods will all be empty. This avoids the need for
/// null-checks in the ChatController's logic.
class NoOpKaiInspector implements KaiInspector {
  @override
  Future<void> startSession(String sessionId) async {}

  @override
  Future<void> endSession(
    String sessionId, {
    TimelineStatus status = TimelineStatus.completed,
  }) async {}

  @override
  Future<void> startTimeline(
    String sessionId,
    String timelineId,
    String userMessage,
  ) async {}

  @override
  Future<void> endTimeline(
    String sessionId,
    String timelineId, {
    TimelineStatus status = TimelineStatus.completed,
    String? aiResponse,
  }) async {}

  @override
  Future<void> startPhase(
    String sessionId,
    String timelineId,
    String phaseId,
    String phaseName, {
    String? description,
  }) async {}

  @override
  Future<void> endPhase(
    String sessionId,
    String timelineId,
    String phaseId, {
    TimelineStatus status = TimelineStatus.completed,
  }) async {}

  @override
  Future<void> recordStep(
    String sessionId,
    String timelineId,
    String phaseId,
    TimelineStep step, {
    String? parentStepId,
  }) async {}

  @override
  Future<void> updateStep(
    String sessionId,
    String timelineId,
    String phaseId,
    TimelineStep step,
  ) async {}

  @override
  Future<void> recordPhaseLog(
    String sessionId,
    String timelineId,
    String phaseId,
    TimelineLog log,
  ) async {}

  @override
  Future<void> recordPromptMessagesLog(
    String sessionId,
    String timelineId,
    String phaseId,
    PromptMessagesLog log,
  ) async {}

  @override
  Future<void> recordGeneratedMessagesLog(
    String sessionId,
    String timelineId,
    String phaseId,
    GeneratedMessagesLog log,
  ) async {}

  @override
  Future<void> recordStepLog(
    String sessionId,
    String timelineId,
    String phaseId,
    String stepId,
    TimelineLog log,
  ) async {}

  @override
  Stream<TimelineSession> getSessionStream(String sessionId) {
    return const Stream.empty();
  }

  @override
  Future<TimelineSession?> getSession(String sessionId) async => null;

  @override
  Future<void> updateSessionAggregates(
    String sessionId, {
    int? tokenUsage,
    double? cost,
  }) async {}

  @override
  Future<Output> inspectPhase<Input, Output>(
    String sessionId,
    String timelineId,
    String phaseName,
    KaiPhase<Input, Output> phaseToRun,
    Input input, {
    String? description,
  }) async {
    // For NoOpKaiInspector, just run the phase without inspection
    return phaseToRun.execute(input);
  }
}
