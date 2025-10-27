import 'package:test/test.dart';
import 'package:kai_engine/src/inspector/kai_phase.dart';
import 'package:kai_engine/src/inspector/kai_inspector.dart';
import 'package:kai_engine/src/inspector/models/timeline_step.dart';
import 'package:kai_engine/src/inspector/models/timeline_types.dart';
import 'package:kai_engine/src/inspector/models/timeline_session.dart';
import 'package:kai_engine/src/inspector/phase_controller.dart';

class TestPhase extends KaiPhase<String, String> {
  @override
  Future<String> execute(String input) async {
    return await withStep(
      'Process input',
      operation: (step) async {
        await step.addLogMessage('Processing: $input');
        await step.addLogMessage(
          'Query context created',
          metadata: {
            'strategy': 'test_strategy',
            'processed_query': input.toUpperCase(),
            'has_embedding': true,
          },
        );
        return input.toUpperCase();
      },
    );
  }
}

class MockKaiInspector implements KaiInspector {
  final List<String> startedSessions = [];
  final List<String> endedSessions = [];
  final List<String> startedTimelines = [];
  final List<String> endedTimelines = [];
  final List<String> startedPhases = [];
  final List<String> endedPhases = [];
  final List<TimelineStep> recordedSteps = [];
  final List<TimelineStep> updatedSteps = [];
  final List<TimelineLog> phaseLogs = [];
  final List<TimelineLog> stepLogs = [];

  @override
  Future<void> startSession(String sessionId) async {
    startedSessions.add(sessionId);
  }

  @override
  Future<void> endSession(
    String sessionId, {
    TimelineStatus status = TimelineStatus.completed,
  }) async {
    endedSessions.add(sessionId);
  }

  @override
  Future<void> startTimeline(
    String sessionId,
    String timelineId,
    String userMessage,
  ) async {
    startedTimelines.add(timelineId);
  }

  @override
  Future<void> endTimeline(
    String sessionId,
    String timelineId, {
    TimelineStatus status = TimelineStatus.completed,
    String? aiResponse,
  }) async {
    endedTimelines.add(timelineId);
  }

  @override
  Future<void> startPhase(
    String sessionId,
    String timelineId,
    String phaseId,
    String phaseName, {
    String? description,
  }) async {
    startedPhases.add(phaseId);
  }

  @override
  Future<void> endPhase(
    String sessionId,
    String timelineId,
    String phaseId, {
    TimelineStatus status = TimelineStatus.completed,
  }) async {
    endedPhases.add(phaseId);
  }

  @override
  Future<void> recordStep(
    String sessionId,
    String timelineId,
    String phaseId,
    TimelineStep step, {
    String? parentStepId,
  }) async {
    recordedSteps.add(step);
  }

  @override
  Future<void> updateStep(
    String sessionId,
    String timelineId,
    String phaseId,
    TimelineStep step,
  ) async {
    updatedSteps.add(step);
  }

  @override
  Future<void> recordPhaseLog(
    String sessionId,
    String timelineId,
    String phaseId,
    TimelineLog log,
  ) async {
    phaseLogs.add(log);
  }

  @override
  Future<void> recordStepLog(
    String sessionId,
    String timelineId,
    String phaseId,
    String stepId,
    TimelineLog log,
  ) async {
    stepLogs.add(log);
  }

  @override
  Stream<TimelineSession> getSessionStream(String sessionId) =>
      const Stream.empty();

  @override
  Future<TimelineSession?> getSession(String sessionId) async => null;

  @override
  Future<void> updateSessionAggregates(
    String sessionId, {
    int? tokenUsage,
    double? cost,
  }) async {}

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
  Future<T> inspectPhase<Input, T>(
    String sessionId,
    String timelineId,
    String phaseName,
    KaiPhase<Input, T> phaseToRun,
    Input input, {
    String? description,
  }) async {
    // Not used in this test
    throw UnimplementedError();
  }
}

void main() {
  group('KaiPhase withStep logging', () {
    late MockKaiInspector mockInspector;
    late TestPhase testPhase;
    late PhaseController phaseController;

    setUp(() {
      mockInspector = MockKaiInspector();
      testPhase = TestPhase();
      phaseController = PhaseController(
        inspector: mockInspector,
        sessionId: 'session-1',
        timelineId: 'timeline-1',
        phaseId: 'phase-1',
        phaseName: 'Test Phase',
      );
    });

    test('withStep captures log messages correctly', () async {
      // Run the phase with inspection
      const input = 'test input';
      final result = await testPhase.run(input, phaseController);

      // Verify the result
      expect(result, equals('TEST INPUT'));

      // Verify step was recorded
      expect(mockInspector.recordedSteps, hasLength(1));
      final recordedStep = mockInspector.recordedSteps.first;
      expect(recordedStep.name, equals('Process input'));
      expect(recordedStep.status, equals(TimelineStatus.running));

      // Verify step was updated multiple times (for each log message + completion)
      expect(mockInspector.updatedSteps.length, greaterThanOrEqualTo(3));

      // Find the updated steps with logs
      final stepsWithLogs = mockInspector.updatedSteps
          .where((step) => step.logs.isNotEmpty)
          .toList();
      expect(stepsWithLogs, isNotEmpty);

      // Verify the logs were captured
      final finalStep = mockInspector.updatedSteps.last;
      expect(finalStep.logs, hasLength(2));

      expect(finalStep.logs[0].message, equals('Processing: test input'));
      expect(finalStep.logs[1].message, equals('Query context created'));
      expect(finalStep.logs[1].metadata['strategy'], equals('test_strategy'));
      expect(
        finalStep.logs[1].metadata['processed_query'],
        equals('TEST INPUT'),
      );
      expect(finalStep.logs[1].metadata['has_embedding'], equals(true));

      // Verify step completion
      expect(finalStep.status, equals(TimelineStatus.completed));
      expect(finalStep.endTime, isNotNull);
    });

    test('withStep works without inspector (no-op mode)', () async {
      // Run without inspector
      const input = 'test input';
      final result = await testPhase.execute(input);

      // Should still work and return correct result
      expect(result, equals('TEST INPUT'));

      // No inspector calls should have been made
      expect(mockInspector.recordedSteps, isEmpty);
      expect(mockInspector.updatedSteps, isEmpty);
    });

    test('ManagedTimelineStep provides correct step properties', () async {
      await testPhase.run('test', phaseController);

      final finalStep = mockInspector.updatedSteps.last;
      expect(finalStep.id, isNotNull);
      expect(finalStep.name, equals('Process input'));
      expect(finalStep.startTime, isNotNull);
      expect(finalStep.endTime, isNotNull);
      expect(finalStep.duration, isNotNull);
      expect(finalStep.logs, hasLength(2));
    });
  });
}
