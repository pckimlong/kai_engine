import 'dart:async';

import 'package:kai_engine/kai_engine.dart';
import 'package:kai_inspector/kai_inspector.dart';
import 'package:test/test.dart';

void main() {
  group('DefaultKaiInspector', () {
    late DefaultKaiInspector inspector;
    const sessionId = 'test-session-id';
    const timelineId = 'test-timeline-id';
    const userMessage = 'Hello, world!';
    const phaseId = 'test-phase-id';
    const phaseName = 'Test Phase';

    setUp(() {
      inspector = DefaultKaiInspector();
    });

    tearDown(() {
      inspector.dispose();
    });

    test('startSession creates a new session', () async {
      await inspector.startSession(sessionId);
      final session = await inspector.getSession(sessionId);
      expect(session, isNotNull);
      expect(session!.id, sessionId);
      expect(session.status, TimelineStatus.running);
      expect(session.timelines, isEmpty);
    });

    test('endSession marks session as completed', () async {
      await inspector.startSession(sessionId);
      await inspector.endSession(sessionId);
      final session = await inspector.getSession(sessionId);
      expect(session, isNotNull);
      expect(session!.status, TimelineStatus.completed);
      expect(session.endTime, isNotNull);
    });

    test('endSession with failed status marks session as failed', () async {
      await inspector.startSession(sessionId);
      await inspector.endSession(sessionId, status: TimelineStatus.failed);
      final session = await inspector.getSession(sessionId);
      expect(session, isNotNull);
      expect(session!.status, TimelineStatus.failed);
    });

    test('endSession with non-existent session does nothing', () async {
      // Should not throw an exception
      await expectLater(
        () => inspector.endSession('non-existent-session'),
        returnsNormally,
      );
    });

    test('startTimeline adds a timeline to the session', () async {
      await inspector.startSession(sessionId);
      await inspector.startTimeline(sessionId, timelineId, userMessage);
      final session = await inspector.getSession(sessionId);
      expect(session, isNotNull);
      expect(session!.timelines, hasLength(1));
      expect(session.timelines[0].id, timelineId);
      expect(session.timelines[0].userMessage, userMessage);
      expect(session.timelines[0].status, TimelineStatus.running);
    });

    test('startTimeline with non-existent session does nothing', () async {
      // Should not throw an exception
      await expectLater(
        () => inspector.startTimeline('non-existent-session', timelineId, userMessage),
        returnsNormally,
      );
    });

    test('endTimeline marks timeline as completed', () async {
      await inspector.startSession(sessionId);
      await inspector.startTimeline(sessionId, timelineId, userMessage);
      await inspector.endTimeline(sessionId, timelineId);
      final session = await inspector.getSession(sessionId);
      expect(session, isNotNull);
      expect(session!.timelines, hasLength(1));
      expect(session.timelines[0].status, TimelineStatus.completed);
      expect(session.timelines[0].endTime, isNotNull);
    });

    test('endTimeline with failed status marks timeline as failed', () async {
      await inspector.startSession(sessionId);
      await inspector.startTimeline(sessionId, timelineId, userMessage);
      await inspector.endTimeline(sessionId, timelineId, status: TimelineStatus.failed);
      final session = await inspector.getSession(sessionId);
      expect(session, isNotNull);
      expect(session!.timelines[0].status, TimelineStatus.failed);
    });

    test('endTimeline with non-existent session does nothing', () async {
      // Should not throw an exception
      await expectLater(
        () => inspector.endTimeline('non-existent-session', timelineId),
        returnsNormally,
      );
    });

    test('endTimeline with non-existent timeline does nothing', () async {
      await inspector.startSession(sessionId);
      // Should not throw an exception
      await expectLater(
        () => inspector.endTimeline(sessionId, 'non-existent-timeline'),
        returnsNormally,
      );
    });

    test('startPhase adds a phase to the timeline', () async {
      await inspector.startSession(sessionId);
      await inspector.startTimeline(sessionId, timelineId, userMessage);
      await inspector.startPhase(sessionId, timelineId, phaseId, phaseName);
      final session = await inspector.getSession(sessionId);
      expect(session, isNotNull);
      expect(session!.timelines, hasLength(1));
      expect(session.timelines[0].phases, hasLength(1));
      expect(session.timelines[0].phases[0].id, phaseId);
      expect(session.timelines[0].phases[0].name, phaseName);
      expect(session.timelines[0].phases[0].status, TimelineStatus.running);
    });

    test('startPhase with description adds a phase with description', () async {
      const description = 'A test phase description';
      await inspector.startSession(sessionId);
      await inspector.startTimeline(sessionId, timelineId, userMessage);
      await inspector.startPhase(
        sessionId,
        timelineId,
        phaseId,
        phaseName,
        description: description,
      );
      final session = await inspector.getSession(sessionId);
      expect(session, isNotNull);
      expect(session!.timelines[0].phases[0].description, description);
    });

    test('startPhase with non-existent session does nothing', () async {
      // Should not throw an exception
      await expectLater(
        () => inspector.startPhase(
          'non-existent-session',
          timelineId,
          phaseId,
          phaseName,
        ),
        returnsNormally,
      );
    });

    test('startPhase with non-existent timeline does nothing', () async {
      await inspector.startSession(sessionId);
      // Should not throw an exception
      await expectLater(
        () => inspector.startPhase(
          sessionId,
          'non-existent-timeline',
          phaseId,
          phaseName,
        ),
        returnsNormally,
      );
    });

    test('endPhase marks phase as completed', () async {
      await inspector.startSession(sessionId);
      await inspector.startTimeline(sessionId, timelineId, userMessage);
      await inspector.startPhase(sessionId, timelineId, phaseId, phaseName);
      await inspector.endPhase(sessionId, timelineId, phaseId);
      final session = await inspector.getSession(sessionId);
      expect(session, isNotNull);
      expect(session!.timelines[0].phases[0].status, TimelineStatus.completed);
      expect(session.timelines[0].phases[0].endTime, isNotNull);
    });

    test('endPhase with failed status marks phase as failed', () async {
      await inspector.startSession(sessionId);
      await inspector.startTimeline(sessionId, timelineId, userMessage);
      await inspector.startPhase(sessionId, timelineId, phaseId, phaseName);
      await inspector.endPhase(
        sessionId,
        timelineId,
        phaseId,
        status: TimelineStatus.failed,
      );
      final session = await inspector.getSession(sessionId);
      expect(session, isNotNull);
      expect(session!.timelines[0].phases[0].status, TimelineStatus.failed);
    });

    test('endPhase with non-existent session does nothing', () async {
      // Should not throw an exception
      await expectLater(
        () => inspector.endPhase('non-existent-session', timelineId, phaseId),
        returnsNormally,
      );
    });

    test('endPhase with non-existent timeline does nothing', () async {
      await inspector.startSession(sessionId);
      // Should not throw an exception
      await expectLater(
        () => inspector.endPhase(sessionId, 'non-existent-timeline', phaseId),
        returnsNormally,
      );
    });

    test('endPhase with non-existent phase does nothing', () async {
      await inspector.startSession(sessionId);
      await inspector.startTimeline(sessionId, timelineId, userMessage);
      // Should not throw an exception
      await expectLater(
        () => inspector.endPhase(sessionId, timelineId, 'non-existent-phase'),
        returnsNormally,
      );
    });

    test('recordStep adds a step to the phase', () async {
      const stepId = 'test-step-id';
      const stepName = 'Test Step';
      final step = TimelineStep(
        id: stepId,
        name: stepName,
        startTime: DateTime.now(),
      );

      await inspector.startSession(sessionId);
      await inspector.startTimeline(sessionId, timelineId, userMessage);
      await inspector.startPhase(sessionId, timelineId, phaseId, phaseName);
      await inspector.recordStep(sessionId, timelineId, phaseId, step);

      final session = await inspector.getSession(sessionId);
      expect(session, isNotNull);
      expect(session!.timelines[0].phases[0].steps, hasLength(1));
      expect(session.timelines[0].phases[0].steps[0].id, stepId);
      expect(session.timelines[0].phases[0].steps[0].name, stepName);
    });

    test('recordStep with non-existent session does nothing', () async {
      final step = TimelineStep(
        id: 'test-step-id',
        name: 'Test Step',
        startTime: DateTime.now(),
      );
      // Should not throw an exception
      await expectLater(
        () => inspector.recordStep(
          'non-existent-session',
          timelineId,
          phaseId,
          step,
        ),
        returnsNormally,
      );
    });

    test('recordStep with non-existent timeline does nothing', () async {
      await inspector.startSession(sessionId);
      final step = TimelineStep(
        id: 'test-step-id',
        name: 'Test Step',
        startTime: DateTime.now(),
      );
      // Should not throw an exception
      await expectLater(
        () => inspector.recordStep(
          sessionId,
          'non-existent-timeline',
          phaseId,
          step,
        ),
        returnsNormally,
      );
    });

    test('recordStep with non-existent phase does nothing', () async {
      await inspector.startSession(sessionId);
      await inspector.startTimeline(sessionId, timelineId, userMessage);
      final step = TimelineStep(
        id: 'test-step-id',
        name: 'Test Step',
        startTime: DateTime.now(),
      );
      // Should not throw an exception
      await expectLater(
        () => inspector.recordStep(
          sessionId,
          timelineId,
          'non-existent-phase',
          step,
        ),
        returnsNormally,
      );
    });

    test('recordPhaseLog adds a log to the phase', () async {
      const logMessage = 'Test log message';
      final log = TimelineLog(
        message: logMessage,
        timestamp: DateTime.now(),
      );

      await inspector.startSession(sessionId);
      await inspector.startTimeline(sessionId, timelineId, userMessage);
      await inspector.startPhase(sessionId, timelineId, phaseId, phaseName);
      await inspector.recordPhaseLog(sessionId, timelineId, phaseId, log);

      final session = await inspector.getSession(sessionId);
      expect(session, isNotNull);
      expect(session!.timelines[0].phases[0].logs, hasLength(1));
      expect(session.timelines[0].phases[0].logs[0].message, logMessage);
    });

    test('recordPhaseLog with non-existent session does nothing', () async {
      final log = TimelineLog(
        message: 'Test log message',
        timestamp: DateTime.now(),
      );
      // Should not throw an exception
      await expectLater(
        () => inspector.recordPhaseLog(
          'non-existent-session',
          timelineId,
          phaseId,
          log,
        ),
        returnsNormally,
      );
    });

    test('recordPhaseLog with non-existent timeline does nothing', () async {
      await inspector.startSession(sessionId);
      final log = TimelineLog(
        message: 'Test log message',
        timestamp: DateTime.now(),
      );
      // Should not throw an exception
      await expectLater(
        () => inspector.recordPhaseLog(
          sessionId,
          'non-existent-timeline',
          phaseId,
          log,
        ),
        returnsNormally,
      );
    });

    test('recordPhaseLog with non-existent phase does nothing', () async {
      await inspector.startSession(sessionId);
      await inspector.startTimeline(sessionId, timelineId, userMessage);
      final log = TimelineLog(
        message: 'Test log message',
        timestamp: DateTime.now(),
      );
      // Should not throw an exception
      await expectLater(
        () => inspector.recordPhaseLog(
          sessionId,
          timelineId,
          'non-existent-phase',
          log,
        ),
        returnsNormally,
      );
    });

    test('recordStepLog adds a log to the step', () async {
      const stepId = 'test-step-id';
      const stepName = 'Test Step';
      const logMessage = 'Test step log message';
      final step = TimelineStep(
        id: stepId,
        name: stepName,
        startTime: DateTime.now(),
      );
      final log = TimelineLog(
        message: logMessage,
        timestamp: DateTime.now(),
      );

      await inspector.startSession(sessionId);
      await inspector.startTimeline(sessionId, timelineId, userMessage);
      await inspector.startPhase(sessionId, timelineId, phaseId, phaseName);
      await inspector.recordStep(sessionId, timelineId, phaseId, step);
      await inspector.recordStepLog(
        sessionId,
        timelineId,
        phaseId,
        stepId,
        log,
      );

      final session = await inspector.getSession(sessionId);
      expect(session, isNotNull);
      expect(session!.timelines[0].phases[0].steps[0].logs, hasLength(1));
      expect(session.timelines[0].phases[0].steps[0].logs[0].message, logMessage);
    });

    test('recordStepLog with non-existent session does nothing', () async {
      final log = TimelineLog(
        message: 'Test log message',
        timestamp: DateTime.now(),
      );
      // Should not throw an exception
      await expectLater(
        () => inspector.recordStepLog(
          'non-existent-session',
          timelineId,
          phaseId,
          'step-id',
          log,
        ),
        returnsNormally,
      );
    });

    test('recordStepLog with non-existent timeline does nothing', () async {
      await inspector.startSession(sessionId);
      final log = TimelineLog(
        message: 'Test log message',
        timestamp: DateTime.now(),
      );
      // Should not throw an exception
      await expectLater(
        () => inspector.recordStepLog(
          sessionId,
          'non-existent-timeline',
          phaseId,
          'step-id',
          log,
        ),
        returnsNormally,
      );
    });

    test('recordStepLog with non-existent phase does nothing', () async {
      await inspector.startSession(sessionId);
      await inspector.startTimeline(sessionId, timelineId, userMessage);
      final log = TimelineLog(
        message: 'Test log message',
        timestamp: DateTime.now(),
      );
      // Should not throw an exception
      await expectLater(
        () => inspector.recordStepLog(
          sessionId,
          timelineId,
          'non-existent-phase',
          'step-id',
          log,
        ),
        returnsNormally,
      );
    });

    test('recordStepLog with non-existent step does nothing', () async {
      await inspector.startSession(sessionId);
      await inspector.startTimeline(sessionId, timelineId, userMessage);
      await inspector.startPhase(sessionId, timelineId, phaseId, phaseName);
      final log = TimelineLog(
        message: 'Test log message',
        timestamp: DateTime.now(),
      );
      // Should not throw an exception
      await expectLater(
        () => inspector.recordStepLog(
          sessionId,
          timelineId,
          phaseId,
          'non-existent-step',
          log,
        ),
        returnsNormally,
      );
    });

    test('getSessionStream provides session updates', () async {
      final sessionUpdates = <TimelineSession>[];
      inspector.getSessionStream(sessionId).listen(sessionUpdates.add);

      await inspector.startSession(sessionId);
      await Future.delayed(Duration(milliseconds: 10)); // Allow stream to process

      expect(sessionUpdates, hasLength(1));
      expect(sessionUpdates[0].id, sessionId);
      expect(sessionUpdates[0].status, TimelineStatus.running);

      await inspector.endSession(sessionId);
      await Future.delayed(Duration(milliseconds: 10)); // Allow stream to process

      expect(sessionUpdates, hasLength(2));
      expect(sessionUpdates[1].status, TimelineStatus.completed);
    });

    test('getSessionStream returns empty stream for non-existent session', () async {
      final stream = inspector.getSessionStream('non-existent-session');
      expect(stream, isNotNull);
      // The stream should be empty and not emit any values
      await expectLater(stream.isEmpty, completion(isTrue));
    });

    test('getSession returns null for non-existent session', () async {
      final session = await inspector.getSession('non-existent-session');
      expect(session, isNull);
    });

    test('updateSessionAggregates updates token usage and cost', () async {
      await inspector.startSession(sessionId);
      await inspector.updateSessionAggregates(
        sessionId,
        tokenUsage: 100,
        cost: 0.05,
      );

      final session = await inspector.getSession(sessionId);
      expect(session, isNotNull);
      expect(session!.totalTokenUsage, 100);
      expect(session.totalCost, 0.05);
    });

    test('updateSessionAggregates accumulates token usage and cost', () async {
      await inspector.startSession(sessionId);
      await inspector.updateSessionAggregates(
        sessionId,
        tokenUsage: 100,
        cost: 0.05,
      );
      await inspector.updateSessionAggregates(
        sessionId,
        tokenUsage: 50,
        cost: 0.03,
      );

      final session = await inspector.getSession(sessionId);
      expect(session, isNotNull);
      expect(session!.totalTokenUsage, 150);
      expect(session.totalCost, 0.08);
    });

    test('updateSessionAggregates with non-existent session does nothing', () async {
      // Should not throw an exception
      await expectLater(
        () => inspector.updateSessionAggregates(
          'non-existent-session',
          tokenUsage: 100,
          cost: 0.05,
        ),
        returnsNormally,
      );
    });

    test('inspectPhase runs a phase and tracks it', () async {
      final testPhase = TestKaiPhase<String, String>();
      final result = await inspector.inspectPhase(
        sessionId,
        timelineId,
        phaseName,
        testPhase,
        'test input',
      );

      expect(result, 'test input processed');
      final session = await inspector.getSession(sessionId);
      expect(session, isNotNull);
      expect(session!.timelines, isEmpty); // inspectPhase doesn't create timeline
    });

    test('inspectPhase handles phase errors', () async {
      final failingPhase = FailingKaiPhase<String, String>();
      await expectLater(
        () => inspector.inspectPhase(
          sessionId,
          timelineId,
          phaseName,
          failingPhase,
          'test input',
        ),
        throwsA(isA<TestException>()),
      );

      // Even though the phase failed, it should have been tracked
      final session = await inspector.getSession(sessionId);
      expect(session, isNotNull);
      expect(session!.timelines, isEmpty); // inspectPhase doesn't create timeline
    });

    test('dispose closes all streams and clears data', () async {
      await inspector.startSession(sessionId);
      await inspector.startTimeline(sessionId, timelineId, userMessage);
      inspector.dispose();

      // After dispose, accessing data should not throw exceptions
      final session = await inspector.getSession(sessionId);
      expect(session, isNull);

      // Streams should be closed
      final stream = inspector.getSessionStream(sessionId);
      await expectLater(
        stream.toList(),
        throwsA(isA<StateError>()),
      );
    });

    test('allSessions returns unmodifiable map of sessions', () async {
      await inspector.startSession(sessionId);
      final sessions = inspector.allSessions;
      expect(sessions, isNotNull);
      expect(sessions[sessionId], isNotNull);

      // Verify it's unmodifiable
      expect(
        () => sessions['new-session'] = TimelineSession(
          id: 'new-session',
          startTime: DateTime.now(),
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('removeSession removes session and closes its stream', () async {
      await inspector.startSession(sessionId);
      await inspector.removeSession(sessionId);

      final session = await inspector.getSession(sessionId);
      expect(session, isNull);

      // Stream should be closed
      final stream = inspector.getSessionStream(sessionId);
      await expectLater(
        stream.toList(),
        throwsA(isA<StateError>()),
      );
    });

    test('stats provides correct statistics', () async {
      // Initially stats should be zero
      var stats = inspector.stats;
      expect(stats.totalSessions, 0);
      expect(stats.activeStreams, 0);
      expect(stats.totalTimelines, 0);
      expect(stats.totalTokensTracked, 0);
      expect(stats.totalCostTracked, 0.0);

      // Add some data
      await inspector.startSession(sessionId);
      await inspector.startTimeline(sessionId, timelineId, userMessage);
      await inspector.updateSessionAggregates(
        sessionId,
        tokenUsage: 100,
        cost: 0.05,
      );

      stats = inspector.stats;
      expect(stats.totalSessions, 1);
      expect(stats.activeStreams, 1);
      expect(stats.totalTimelines, 1);
      expect(stats.totalTokensTracked, 100);
      expect(stats.totalCostTracked, 0.05);
    });
  });
}

// Test implementations
class TestKaiPhase<Input, Output> extends KaiPhase<Input, Output> {
  @override
  Future<Output> execute(Input input) async {
    // Simulate some work
    await Future.delayed(Duration(milliseconds: 1));
    return '$input processed' as Output;
  }
}

class FailingKaiPhase<Input, Output> extends KaiPhase<Input, Output> {
  @override
  Future<Output> execute(Input input) async {
    throw TestException('Test error');
  }
}

class TestException implements Exception {
  final String message;
  TestException(this.message);
  @override
  String toString() => 'TestException: $message';
}
