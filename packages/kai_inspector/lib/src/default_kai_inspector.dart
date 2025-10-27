import 'dart:async';

import 'package:kai_engine/kai_engine.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

/// A robust default implementation of KaiInspector that stores data in memory
/// and provides real-time streaming capabilities for debugging.
class DefaultKaiInspector implements KaiInspector {
  final Map<String, TimelineSession> _sessions = {};
  final Map<String, BehaviorSubject<TimelineSession>> _sessionStreams = {};
  bool _disposed = false;
  static const _uuid = Uuid();

  @override
  Future<void> startSession(String sessionId) async {
    final session = TimelineSession(
      id: sessionId,
      startTime: DateTime.now(),
    );
    _sessions[sessionId] = session;
    if (_sessionStreams.containsKey(sessionId) && !_sessionStreams[sessionId]!.isClosed) {
      _sessionStreams[sessionId]!.add(session);
    } else {
      _sessionStreams[sessionId] = BehaviorSubject<TimelineSession>.seeded(session);
    }
  }

  @override
  Future<void> endSession(String sessionId, {TimelineStatus status = TimelineStatus.completed}) async {
    final session = _sessions[sessionId];
    if (session == null) return;
    final updatedSession = session.complete(status: status);
    _sessions[sessionId] = updatedSession;
    _sessionStreams[sessionId]?.add(updatedSession);
  }

  @override
  Future<void> startTimeline(String sessionId, String timelineId, String userMessage) async {
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
  Future<void> endTimeline(String sessionId, String timelineId, {TimelineStatus status = TimelineStatus.completed, String? aiResponse}) async {
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
  Future<void> startPhase(String sessionId, String timelineId, String phaseId, String phaseName, {String? description}) async {
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
  Future<void> endPhase(String sessionId, String timelineId, String phaseId, {TimelineStatus status = TimelineStatus.completed}) async {
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
  Future<void> recordStep(String sessionId, String timelineId, String phaseId, TimelineStep step, {String? parentStepId}) async {
    final session = _sessions[sessionId];
    if (session == null) return;
    final timelineIndex = session.timelines.indexWhere((t) => t.id == timelineId);
    if (timelineIndex == -1) return;
    final timeline = session.timelines[timelineIndex];
    final phaseIndex = timeline.phases.indexWhere((p) => p.id == phaseId);
    if (phaseIndex == -1) return;
    final phase = timeline.phases[phaseIndex];

    TimelinePhase updatedPhase;
    if (parentStepId == null) {
      updatedPhase = phase.addStep(step);
    } else {
      final updatedSteps = _addNestedStep(phase.steps, parentStepId, step);
      updatedPhase = phase.copyWith(steps: updatedSteps);
    }

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
  Future<void> recordPhaseLog(String sessionId, String timelineId, String phaseId, TimelineLog log) async {
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
  Future<void> recordPromptMessagesLog(String sessionId, String timelineId, String phaseId, PromptMessagesLog log) async {
    final session = _sessions[sessionId];
    if (session == null) return;
    final timelineIndex = session.timelines.indexWhere((t) => t.id == timelineId);
    if (timelineIndex == -1) return;
    final timeline = session.timelines[timelineIndex];
    final phaseIndex = timeline.phases.indexWhere((p) => p.id == phaseId || p.name == phaseId);
    if (phaseIndex == -1) return;
    final phase = timeline.phases[phaseIndex];
    final updatedPhase = phase.addPromptMessagesLog(log);
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
  Future<void> recordGeneratedMessagesLog(String sessionId, String timelineId, String phaseId, GeneratedMessagesLog log) async {
    final session = _sessions[sessionId];
    if (session == null) return;
    final timelineIndex = session.timelines.indexWhere((t) => t.id == timelineId);
    if (timelineIndex == -1) return;
    final timeline = session.timelines[timelineIndex];
    final phaseIndex = timeline.phases.indexWhere((p) => p.id == phaseId || p.name == phaseId);
    if (phaseIndex == -1) return;
    final phase = timeline.phases[phaseIndex];
    final updatedPhase = phase.addGeneratedMessagesLog(log);
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
  Future<void> recordStepLog(String sessionId, String timelineId, String phaseId, String stepId, TimelineLog log) async {
    final session = _sessions[sessionId];
    if (session == null) return;
    final timelineIndex = session.timelines.indexWhere((t) => t.id == timelineId);
    if (timelineIndex == -1) return;
    final timeline = session.timelines[timelineIndex];
    final phaseIndex = timeline.phases.indexWhere((p) => p.id == phaseId);
    if (phaseIndex == -1) return;
    final phase = timeline.phases[phaseIndex];
    final updatedSteps = _addLogToStep(phase.steps, stepId, log);
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
  Future<void> updateStep(String sessionId, String timelineId, String phaseId, TimelineStep step) async {
    final session = _sessions[sessionId];
    if (session == null) return;
    final timelineIndex = session.timelines.indexWhere((t) => t.id == timelineId);
    if (timelineIndex == -1) return;
    final timeline = session.timelines[timelineIndex];
    final phaseIndex = timeline.phases.indexWhere((p) => p.id == phaseId);
    if (phaseIndex == -1) return;
    final phase = timeline.phases[phaseIndex];
    final updatedSteps = _updateStepRecursively(phase.steps, step);
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

  List<TimelineStep> _updateStepRecursively(List<TimelineStep> steps, TimelineStep updatedStep) {
    return steps.map((step) {
      if (step.id == updatedStep.id) {
        return updatedStep;
      }
      if (step.steps.isNotEmpty) {
        return step.copyWith(steps: _updateStepRecursively(step.steps, updatedStep));
      }
      return step;
    }).toList();
  }

  List<TimelineStep> _addNestedStep(List<TimelineStep> steps, String parentId, TimelineStep newStep) {
    return steps.map((step) {
      if (step.id == parentId) {
        return step.addStep(newStep);
      }
      if (step.steps.isNotEmpty) {
        return step.copyWith(steps: _addNestedStep(step.steps, parentId, newStep));
      }
      return step;
    }).toList();
  }

  List<TimelineStep> _addLogToStep(List<TimelineStep> steps, String stepId, TimelineLog log) {
    return steps.map((step) {
      if (step.id == stepId) {
        return step.addLog(log);
      }
      if (step.steps.isNotEmpty) {
        return step.copyWith(steps: _addLogToStep(step.steps, stepId, log));
      }
      return step;
    }).toList();
  }

  @override
  Stream<TimelineSession> getSessionStream(String sessionId) {
    if (_disposed) {
      return Stream.error(StateError('Inspector has been disposed'));
    }
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
  Future<void> updateSessionAggregates(String sessionId, {int? tokenUsage, double? cost}) async {
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
  Future<Output> inspectPhase<Input, Output>(String sessionId, String timelineId, String phaseName, KaiPhase<Input, Output> phaseToRun, Input input, {String? description}) async {
    final phaseId = _uuid.v4();
    if (!_sessions.containsKey(sessionId)) {
      await startSession(sessionId);
    }
    await startPhase(sessionId, timelineId, phaseId, phaseName, description: description);
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

  Map<String, TimelineSession> get allSessions => Map.unmodifiable(_sessions);

  Future<void> removeSession(String sessionId) async {
    _sessions.remove(sessionId);
    final controller = _sessionStreams.remove(sessionId);
    if (controller != null && !controller.isClosed) {
      controller.close();
    }
  }

  InspectorStats get stats => InspectorStats(
        totalSessions: _sessions.length,
        activeStreams: _sessionStreams.length,
        totalTimelines: _sessions.values.fold(0, (sum, session) => sum + session.timelines.length),
        totalTokensTracked: _sessions.values.fold(0, (sum, session) => sum + session.totalTokenUsage),
        totalCostTracked: _sessions.values.fold(0.0, (sum, session) => sum + session.totalCost),
      );
}

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