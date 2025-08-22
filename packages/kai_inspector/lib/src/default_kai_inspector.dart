import 'dart:async';

import 'package:kai_engine/kai_engine.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

/// A robust default implementation of KaiInspector that stores data in memory
/// and provides real-time streaming capabilities for debugging.
///
/// This implementation is suitable for development, testing, and production use
/// where you need comprehensive debugging capabilities without external dependencies.
///
/// Features:
/// - In-memory storage with structured hierarchy (Session → Timeline → Phase → Step)
/// - Real-time streaming of session updates via BehaviorSubject
/// - Thread-safe operations with proper error handling
/// - Automatic cleanup and proper lifecycle management
/// - Support for aggregate data tracking (tokens, costs)
/// - Comprehensive logging and step recording
///
/// Usage:
/// ```dart
/// final inspector = DefaultKaiInspector();
///
/// // Use in ChatController
/// final chatController = ChatController(
///   // ... other dependencies
///   inspector: inspector,
/// );
///
/// // Listen to session updates for debugging
/// inspector.getSessionStream(sessionId).listen((session) {
///   print('Session updated: ${session.messageCount} messages');
/// });
/// ```
class DefaultKaiInspector implements KaiInspector {
  /// Internal storage for all sessions
  final Map<String, TimelineSession> _sessions = {};

  /// Stream controllers for real-time session updates
  final Map<String, BehaviorSubject<TimelineSession>> _sessionStreams = {};

  /// Flag to track if disposed
  bool _disposed = false;

  /// UUID generator for creating unique IDs
  static const _uuid = Uuid();

  @override
  Future<void> startSession(String sessionId) async {
    final session = TimelineSession(
      id: sessionId,
      startTime: DateTime.now(),
    );

    _sessions[sessionId] = session;

    // Use existing controller if available, otherwise create new one
    if (_sessionStreams.containsKey(sessionId) && !_sessionStreams[sessionId]!.isClosed) {
      _sessionStreams[sessionId]!.add(session);
    } else {
      _sessionStreams[sessionId] = BehaviorSubject<TimelineSession>.seeded(session);
    }
  }

  @override
  Future<void> endSession(
    String sessionId, {
    TimelineStatus status = TimelineStatus.completed,
  }) async {
    final session = _sessions[sessionId];
    if (session == null) return;

    final updatedSession = session.complete(status: status);
    _sessions[sessionId] = updatedSession;
    _sessionStreams[sessionId]?.add(updatedSession);
  }

  @override
  Future<void> startTimeline(
    String sessionId,
    String timelineId,
    String userMessage,
  ) async {
    final session = _sessions[sessionId];
    if (session == null) return;

    final timeline = ExecutionTimeline(
      id: timelineId,
      userMessage: userMessage,
      startTime: DateTime.now(),
    );

    final updatedSession = session.addTimeline(timeline);
    _sessions[sessionId] = updatedSession;
    _sessionStreams[sessionId]?.add(updatedSession);
  }

  @override
  Future<void> endTimeline(
    String sessionId,
    String timelineId, {
    TimelineStatus status = TimelineStatus.completed,
    String? aiResponse,
  }) async {
    final session = _sessions[sessionId];
    if (session == null) return;

    final timelineIndex = session.timelines.indexWhere((t) => t.id == timelineId);
    if (timelineIndex == -1) return;

    final timeline = session.timelines[timelineIndex];
    final updatedTimeline = timeline.complete(status: status, aiResponse: aiResponse);

    final updatedTimelines = List<ExecutionTimeline>.from(session.timelines);
    updatedTimelines[timelineIndex] = updatedTimeline;

    final updatedSession = session.copyWith(timelines: updatedTimelines);
    _sessions[sessionId] = updatedSession;
    _sessionStreams[sessionId]?.add(updatedSession);
  }

  @override
  Future<void> startPhase(
    String sessionId,
    String timelineId,
    String phaseId,
    String phaseName, {
    String? description,
  }) async {
    final session = _sessions[sessionId];
    if (session == null) return;

    final timelineIndex = session.timelines.indexWhere((t) => t.id == timelineId);
    if (timelineIndex == -1) return;

    final timeline = session.timelines[timelineIndex];
    final phase = TimelinePhase(
      id: phaseId,
      name: phaseName,
      description: description,
      startTime: DateTime.now(),
    );

    final updatedTimeline = timeline.addPhase(phase);
    final updatedTimelines = List<ExecutionTimeline>.from(session.timelines);
    updatedTimelines[timelineIndex] = updatedTimeline;

    final updatedSession = session.copyWith(timelines: updatedTimelines);
    _sessions[sessionId] = updatedSession;
    _sessionStreams[sessionId]?.add(updatedSession);
  }

  @override
  Future<void> endPhase(
    String sessionId,
    String timelineId,
    String phaseId, {
    TimelineStatus status = TimelineStatus.completed,
  }) async {
    final session = _sessions[sessionId];
    if (session == null) return;

    final timelineIndex = session.timelines.indexWhere((t) => t.id == timelineId);
    if (timelineIndex == -1) return;

    final timeline = session.timelines[timelineIndex];
    final phaseIndex = timeline.phases.indexWhere((p) => p.id == phaseId);
    if (phaseIndex == -1) return;

    final phase = timeline.phases[phaseIndex];
    final updatedPhase = phase.complete(status: status);

    final updatedPhases = List<TimelinePhase>.from(timeline.phases);
    updatedPhases[phaseIndex] = updatedPhase;

    final updatedTimeline = timeline.copyWith(phases: updatedPhases);
    final updatedTimelines = List<ExecutionTimeline>.from(session.timelines);
    updatedTimelines[timelineIndex] = updatedTimeline;

    final updatedSession = session.copyWith(timelines: updatedTimelines);
    _sessions[sessionId] = updatedSession;
    _sessionStreams[sessionId]?.add(updatedSession);
  }

  @override
  Future<void> recordStep(
    String sessionId,
    String timelineId,
    String phaseId,
    TimelineStep step,
  ) async {
    final session = _sessions[sessionId];
    if (session == null) return;

    final timelineIndex = session.timelines.indexWhere((t) => t.id == timelineId);
    if (timelineIndex == -1) return;

    final timeline = session.timelines[timelineIndex];
    final phaseIndex = timeline.phases.indexWhere((p) => p.id == phaseId);
    if (phaseIndex == -1) return;

    final phase = timeline.phases[phaseIndex];
    final updatedPhase = phase.addStep(step);

    final updatedPhases = List<TimelinePhase>.from(timeline.phases);
    updatedPhases[phaseIndex] = updatedPhase;

    final updatedTimeline = timeline.copyWith(phases: updatedPhases);
    final updatedTimelines = List<ExecutionTimeline>.from(session.timelines);
    updatedTimelines[timelineIndex] = updatedTimeline;

    final updatedSession = session.copyWith(timelines: updatedTimelines);
    _sessions[sessionId] = updatedSession;
    _sessionStreams[sessionId]?.add(updatedSession);
  }

  @override
  Future<void> recordPhaseLog(
    String sessionId,
    String timelineId,
    String phaseId,
    TimelineLog log,
  ) async {
    final session = _sessions[sessionId];
    if (session == null) return;

    final timelineIndex = session.timelines.indexWhere((t) => t.id == timelineId);
    if (timelineIndex == -1) return;

    final timeline = session.timelines[timelineIndex];
    final phaseIndex = timeline.phases.indexWhere((p) => p.id == phaseId);
    if (phaseIndex == -1) return;

    final phase = timeline.phases[phaseIndex];
    final updatedPhase = phase.addLog(log);

    final updatedPhases = List<TimelinePhase>.from(timeline.phases);
    updatedPhases[phaseIndex] = updatedPhase;

    final updatedTimeline = timeline.copyWith(phases: updatedPhases);
    final updatedTimelines = List<ExecutionTimeline>.from(session.timelines);
    updatedTimelines[timelineIndex] = updatedTimeline;

    final updatedSession = session.copyWith(timelines: updatedTimelines);
    _sessions[sessionId] = updatedSession;
    _sessionStreams[sessionId]?.add(updatedSession);
  }

  @override
  Future<void> recordStepLog(
    String sessionId,
    String timelineId,
    String phaseId,
    String stepId,
    TimelineLog log,
  ) async {
    final session = _sessions[sessionId];
    if (session == null) return;

    final timelineIndex = session.timelines.indexWhere((t) => t.id == timelineId);
    if (timelineIndex == -1) return;

    final timeline = session.timelines[timelineIndex];
    final phaseIndex = timeline.phases.indexWhere((p) => p.id == phaseId);
    if (phaseIndex == -1) return;

    final phase = timeline.phases[phaseIndex];
    final stepIndex = phase.steps.indexWhere((s) => s.id == stepId);
    if (stepIndex == -1) return;

    final step = phase.steps[stepIndex];
    final updatedStep = step.addLog(log);

    final updatedSteps = List<TimelineStep>.from(phase.steps);
    updatedSteps[stepIndex] = updatedStep;

    final updatedPhase = phase.copyWith(steps: updatedSteps);
    final updatedPhases = List<TimelinePhase>.from(timeline.phases);
    updatedPhases[phaseIndex] = updatedPhase;

    final updatedTimeline = timeline.copyWith(phases: updatedPhases);
    final updatedTimelines = List<ExecutionTimeline>.from(session.timelines);
    updatedTimelines[timelineIndex] = updatedTimeline;

    final updatedSession = session.copyWith(timelines: updatedTimelines);
    _sessions[sessionId] = updatedSession;
    _sessionStreams[sessionId]?.add(updatedSession);
  }

  @override
  Stream<TimelineSession> getSessionStream(String sessionId) {
    if (_disposed) {
      return Stream.error(StateError('Inspector has been disposed'));
    }

    // Always create a BehaviorSubject if it doesn't exist
    if (!_sessionStreams.containsKey(sessionId)) {
      _sessionStreams[sessionId] = BehaviorSubject<TimelineSession>();
    }

    final controller = _sessionStreams[sessionId]!;
    if (controller.isClosed) {
      return Stream.error(StateError('Stream has been closed'));
    }

    return controller.stream;
  }

  @override
  Future<TimelineSession?> getSession(String sessionId) async {
    return _sessions[sessionId];
  }

  @override
  Future<void> updateSessionAggregates(
    String sessionId, {
    int? tokenUsage,
    double? cost,
  }) async {
    final session = _sessions[sessionId];
    if (session == null) return;

    final updatedSession = session.updateAggregates(
      tokenUsage: tokenUsage,
      cost: cost,
    );

    _sessions[sessionId] = updatedSession;
    _sessionStreams[sessionId]?.add(updatedSession);
  }

  @override
  Future<Output> inspectPhase<Input, Output>(
    String sessionId,
    String timelineId,
    String phaseName,
    KaiPhase<Input, Output> phaseToRun,
    Input input, {
    String? description,
  }) async {
    final phaseId = _uuid.v4();

    // Ensure session exists, but don't create timeline
    if (!_sessions.containsKey(sessionId)) {
      await startSession(sessionId);
    }

    // Only start phase if timeline exists (the test expects this to be a no-op if timeline doesn't exist)
    await startPhase(sessionId, timelineId, phaseId, phaseName, description: description);

    // KaiPhase.run() handles endPhase internally, so we don't need to call it here
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

    return result;
  }

  /// Disposes of all resources and closes all streams.
  /// Call this when the inspector is no longer needed to prevent memory leaks.
  void dispose() {
    _disposed = true;
    for (final controller in _sessionStreams.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _sessionStreams.clear();
    _sessions.clear();
  }

  /// Gets all sessions currently stored in memory.
  /// Useful for debugging or exporting session data.
  Map<String, TimelineSession> get allSessions => Map.unmodifiable(_sessions);

  /// Removes a session from memory and closes its stream.
  /// Useful for cleanup when sessions are no longer needed.
  Future<void> removeSession(String sessionId) async {
    _sessions.remove(sessionId);
    final controller = _sessionStreams.remove(sessionId);
    if (controller != null && !controller.isClosed) {
      controller.close();
    }
  }

  /// Gets basic statistics about the inspector's current state.
  /// Useful for monitoring memory usage and performance.
  InspectorStats get stats => InspectorStats(
        totalSessions: _sessions.length,
        activeStreams: _sessionStreams.length,
        totalTimelines: _sessions.values.fold(0, (sum, session) => sum + session.timelines.length),
        totalTokensTracked:
            _sessions.values.fold(0, (sum, session) => sum + session.totalTokenUsage),
        totalCostTracked: _sessions.values.fold(0.0, (sum, session) => sum + session.totalCost),
      );
}

/// Statistics about the DefaultKaiInspector's current state
class InspectorStats {
  final int totalSessions;
  final int activeStreams;
  final int totalTimelines;
  final int totalTokensTracked;
  final double totalCostTracked;

  const InspectorStats({
    required this.totalSessions,
    required this.activeStreams,
    required this.totalTimelines,
    required this.totalTokensTracked,
    required this.totalCostTracked,
  });

  @override
  String toString() => 'InspectorStats('
      'sessions: $totalSessions, '
      'streams: $activeStreams, '
      'timelines: $totalTimelines, '
      'tokens: $totalTokensTracked, '
      'cost: \$${totalCostTracked.toStringAsFixed(4)}'
      ')';
}
