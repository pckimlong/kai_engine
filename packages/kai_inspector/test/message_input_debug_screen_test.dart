import 'package:flutter_test/flutter_test.dart';
import 'package:kai_engine/src/inspector/execution_timeline.dart';
import 'package:kai_engine/src/inspector/models/timeline_phase.dart';
import 'package:kai_engine/src/inspector/models/timeline_types.dart';
import 'package:kai_inspector/src/ui/debug_data_adapter.dart';

void main() {
  group('Message Input Debug Screen Integration Tests', () {
    test('should integrate prompt pipeline extraction with comprehensive UI data', () {
      // Create phases with realistic logs that match our extraction logic
      final contextPhase = TimelinePhase(
        id: 'context-phase-1',
        name: 'Context Building',
        description: 'Building contextual prompt from conversation history',
        startTime: DateTime(2024, 1, 1, 10, 0, 0),
        endTime: DateTime(2024, 1, 1, 10, 0, 0, 150),
        status: TimelineStatus.completed,
        logs: [
          TimelineLog(
            message: 'Processing prompt templates',
            timestamp: DateTime(2024, 1, 1, 10, 0, 0, 10),
            severity: TimelineLogSeverity.info,
            metadata: {'prompt-templates': 3, 'source-messages': 5},
          ),
          TimelineLog(
            message: 'Final context results',
            timestamp: DateTime(2024, 1, 1, 10, 0, 0, 140),
            severity: TimelineLogSeverity.info,
            metadata: {'final-context-messages': 3, 'total-prompt-messages': 4},
          ),
        ],
        steps: [],
      );

      final generationPhase = TimelinePhase(
        id: 'generation-phase-1',
        name: 'AI Generation',
        description: 'Streaming response from AI service',
        startTime: DateTime(2024, 1, 1, 10, 0, 0, 200),
        endTime: DateTime(2024, 1, 1, 10, 0, 1, 500),
        status: TimelineStatus.completed,
        logs: [
          TimelineLog(
            message: 'Starting AI generation with 4 prompts',
            timestamp: DateTime(2024, 1, 1, 10, 0, 0, 210),
            severity: TimelineLogSeverity.info,
            metadata: {'prompt_count': 4},
          ),
          TimelineLog(
            message: 'Generation completed successfully',
            timestamp: DateTime(2024, 1, 1, 10, 0, 1, 490),
            severity: TimelineLogSeverity.info,
            metadata: {
              'total_tokens': 256,
              'input_tokens': 128,
              'output_tokens': 128,
            },
          ),
        ],
        steps: [],
      );

      final timeline = ExecutionTimeline(
        id: 'msg-123456789',
        userMessage: 'Can you help me understand how neural networks work?',
        startTime: DateTime(2024, 1, 1, 10, 0, 0),
        endTime: DateTime(2024, 1, 1, 10, 0, 2),
        status: TimelineStatus.completed,
        phases: [contextPhase, generationPhase],
        aiResponse: 'Neural networks are computational models...',
      );

      // Test the complete data extraction pipeline
      final timelineData = DebugDataAdapter.convertTimelineOverview(timeline);

      // Verify comprehensive data extraction
      expect(timelineData.timelineId, equals('msg-123456789'));
      expect(timelineData.userMessage, 
             equals('Can you help me understand how neural networks work?'));
      expect(timelineData.phaseCount, equals(2));
      expect(timelineData.totalTokens, equals(256));
      
      // Test prompt pipeline data extraction
      expect(timelineData.promptPipeline, isNotNull);
      final promptPipeline = timelineData.promptPipeline!;
      
      // Should have multi-part prompt structure based on metadata
      expect(promptPipeline.segments.length, greaterThanOrEqualTo(2));
      
      // Should include system prompt (inferred from template count >= 3)
      final systemSegments = promptPipeline.segments
          .where((s) => s.type == PromptSegmentType.system);
      expect(systemSegments.isNotEmpty, isTrue);
      
      // Should include user input
      final userSegment = promptPipeline.segments
          .where((s) => s.type == PromptSegmentType.userInput)
          .first;
      expect(userSegment.content, 
             equals('Can you help me understand how neural networks work?'));
      expect(userSegment.characterCount, equals(userSegment.content.length));
      
      // Verify character count calculation is consistent
      final expectedTotal = promptPipeline.segments
          .fold<int>(0, (sum, segment) => sum + segment.characterCount);
      expect(promptPipeline.totalCharacterCount, equals(expectedTotal));

      // Test phase data conversion with token metadata
      final generationPhaseData = timelineData.phases
          .firstWhere((p) => p.phaseName == 'AI Generation');
      expect(generationPhaseData.tokenMetadata, isNotNull);
      expect(generationPhaseData.tokenMetadata!.totalTokens, equals(256));
      expect(generationPhaseData.tokenMetadata!.inputTokens, equals(128));
      expect(generationPhaseData.tokenMetadata!.outputTokens, equals(128));
      
      print('✅ Comprehensive debugging tool integration test passed!');
      print('📊 Extracted ${promptPipeline.segments.length} prompt segments');
      print('⏱️  Processed ${timelineData.phaseCount} phases with token data');
    });

    test('should handle minimal data gracefully', () {
      // Test with minimal timeline data
      final timeline = ExecutionTimeline(
        id: 'minimal-timeline',
        userMessage: 'Hello',
        startTime: DateTime.now(),
        status: TimelineStatus.running,
        phases: [],
      );

      final data = DebugDataAdapter.convertTimelineOverview(timeline);
      expect(data.promptPipeline, isNotNull);
      expect(data.promptPipeline!.segments.isNotEmpty, isTrue);
      
      // Should at least have user input segment
      final userInputSegment = data.promptPipeline!.segments
          .firstWhere((s) => s.type == PromptSegmentType.userInput);
      expect(userInputSegment.content, equals('Hello'));
      
      print('✅ Minimal data handling verified!');
    });
  });
}