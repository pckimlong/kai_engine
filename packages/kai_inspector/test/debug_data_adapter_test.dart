import 'package:flutter_test/flutter_test.dart';
import 'package:kai_engine/src/inspector/execution_timeline.dart';
import 'package:kai_engine/src/inspector/models/timeline_phase.dart';
import 'package:kai_engine/src/inspector/models/timeline_step.dart';
import 'package:kai_engine/src/inspector/models/timeline_types.dart';
import 'package:kai_inspector/src/ui/debug_data_adapter.dart';

void main() {
  group('DebugDataAdapter Prompt Pipeline Tests', () {
    test('should extract prompt pipeline data from timeline', () {
      // Create mock timeline with context building and generation phases
      final contextPhase = TimelinePhase(
        id: 'context-1',
        name: 'Context Building',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(milliseconds: 100)),
        status: TimelineStatus.completed,
        logs: [
          TimelineLog(
            message: 'Processing prompt templates',
            timestamp: DateTime.now(),
            severity: TimelineLogSeverity.info,
            metadata: {'prompt-templates': 3, 'source-messages': 2},
          ),
          TimelineLog(
            message: 'Final context results',
            timestamp: DateTime.now(),
            severity: TimelineLogSeverity.info,
            metadata: {'final-context-messages': 2},
          ),
        ],
        steps: [],
      );

      final generationPhase = TimelinePhase(
        id: 'generation-1',
        name: 'AI Generation',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(milliseconds: 500)),
        status: TimelineStatus.completed,
        logs: [
          TimelineLog(
            message: 'Starting AI generation with 3 prompts',
            timestamp: DateTime.now(),
            severity: TimelineLogSeverity.info,
            metadata: {'prompt_count': 3},
          ),
        ],
        steps: [],
      );

      final timeline = ExecutionTimeline(
        id: 'timeline-1',
        userMessage: 'Hello, how are you?',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(seconds: 1)),
        status: TimelineStatus.completed,
        phases: [contextPhase, generationPhase],
        aiResponse: 'I am doing well, thank you!',
      );

      // Convert timeline to overview data
      final timelineData = DebugDataAdapter.convertTimelineOverview(timeline);

      // Verify prompt pipeline was extracted
      expect(timelineData.promptPipeline, isNotNull);
      expect(timelineData.promptPipeline!.segments.length, greaterThan(1));

      // Check that we have system prompt and user input segments
      final segmentTypes =
          timelineData.promptPipeline!.segments.map((s) => s.type).toSet();
      expect(segmentTypes, contains(PromptSegmentType.system));
      expect(segmentTypes, contains(PromptSegmentType.userInput));

      // Verify user input content matches
      final userInputSegment = timelineData.promptPipeline!.segments
          .firstWhere((s) => s.type == PromptSegmentType.userInput);
      expect(userInputSegment.content, equals('Hello, how are you?'));

      // Check character count calculation
      expect(
          timelineData.promptPipeline!.totalCharacterCount,
          equals(timelineData.promptPipeline!.segments
              .fold<int>(0, (sum, segment) => sum + segment.characterCount)));
    });

    test('should handle timeline without context data gracefully', () {
      // Create timeline without context building phase
      final timeline = ExecutionTimeline(
        id: 'timeline-2',
        userMessage: 'Test message',
        startTime: DateTime.now(),
        status: TimelineStatus.running,
        phases: [],
      );

      final timelineData = DebugDataAdapter.convertTimelineOverview(timeline);

      // Should still create basic prompt pipeline
      expect(timelineData.promptPipeline, isNotNull);
      expect(timelineData.promptPipeline!.segments.length,
          greaterThanOrEqualTo(1));

      // Should at least have user input
      final userInputExists = timelineData.promptPipeline!.segments
          .any((s) => s.type == PromptSegmentType.userInput);
      expect(userInputExists, isTrue);
    });
  });
}
