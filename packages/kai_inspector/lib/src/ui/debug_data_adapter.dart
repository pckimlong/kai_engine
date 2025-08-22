import 'package:kai_engine/src/inspector/execution_timeline.dart';
import 'package:kai_engine/src/inspector/models/timeline_session.dart';
import 'package:kai_engine/src/inspector/models/timeline_phase.dart';
import 'package:kai_engine/src/inspector/models/timeline_step.dart';
import 'package:kai_engine/src/inspector/models/timeline_types.dart';

/// Adapts inspector timeline data to UI-friendly format for debug screens
class DebugDataAdapter {
  /// Converts TimelineSession to UI timeline overview data
  static SessionOverviewData convertSessionOverview(TimelineSession session) {
    final timelines = session.timelines;
    final totalDuration = session.duration ?? 
        (timelines.isNotEmpty && timelines.last.endTime != null
            ? timelines.last.endTime!.difference(session.startTime)
            : null);

    // Aggregate phase statistics across all timelines
    final phaseStats = <String, PhaseStatistics>{};
    var totalErrors = 0;
    var totalWarnings = 0;

    for (final timeline in timelines) {
      for (final phase in timeline.phases) {
        final existing = phaseStats[phase.name];
        final duration = phase.duration?.inMilliseconds ?? 0;
        final errorCount = _countLogsByLevel(phase.logs, TimelineLogSeverity.error);
        final warningCount = _countLogsByLevel(phase.logs, TimelineLogSeverity.warning);

        if (existing == null) {
          phaseStats[phase.name] = PhaseStatistics(
            phaseName: phase.name,
            executionCount: 1,
            totalDurationMs: duration,
            averageDurationMs: duration,
            minDurationMs: duration,
            maxDurationMs: duration,
            errorCount: errorCount,
            warningCount: warningCount,
          );
        } else {
          final newCount = existing.executionCount + 1;
          final newTotal = existing.totalDurationMs + duration;
          phaseStats[phase.name] = existing.copyWith(
            executionCount: newCount,
            totalDurationMs: newTotal,
            averageDurationMs: (newTotal / newCount).round(),
            minDurationMs: duration < existing.minDurationMs ? duration : existing.minDurationMs,
            maxDurationMs: duration > existing.maxDurationMs ? duration : existing.maxDurationMs,
            errorCount: existing.errorCount + errorCount,
            warningCount: existing.warningCount + warningCount,
          );
        }

        totalErrors += errorCount;
        totalWarnings += warningCount;
      }
    }

    return SessionOverviewData(
      sessionId: session.id,
      startTime: session.startTime,
      endTime: session.endTime,
      duration: totalDuration,
      status: session.status,
      messageCount: timelines.length,
      totalTokenUsage: session.totalTokenUsage,
      totalCost: session.totalCost,
      totalErrors: totalErrors,
      totalWarnings: totalWarnings,
      phaseStatistics: phaseStats.values.toList()..sort((a, b) => a.phaseName.compareTo(b.phaseName)),
    );
  }

  /// Converts ExecutionTimeline to UI timeline data
  static TimelineOverviewData convertTimelineOverview(ExecutionTimeline timeline) {
    final duration = timeline.duration;
    final totalTokens = _extractTotalTokensFromPhases(timeline.phases);
    final errors = _countTimelineErrors(timeline);
    final warnings = _countTimelineWarnings(timeline);

    return TimelineOverviewData(
      timelineId: timeline.id,
      userMessage: timeline.userMessage,
      startTime: timeline.startTime,
      endTime: timeline.endTime,
      duration: duration,
      status: timeline.status,
      phaseCount: timeline.phases.length,
      totalTokens: totalTokens,
      errorCount: errors,
      warningCount: warnings,
      phases: timeline.phases.map(convertPhaseOverview).toList(),
    );
  }

  /// Converts TimelinePhase to UI phase data
  static PhaseOverviewData convertPhaseOverview(TimelinePhase phase) {
    final tokenMetadata = _extractTokenMetadata(phase);
    final streamingMetadata = _extractStreamingMetadata(phase);

    return PhaseOverviewData(
      phaseId: phase.id,
      phaseName: phase.name,
      description: phase.description,
      startTime: phase.startTime,
      endTime: phase.endTime,
      duration: phase.duration,
      status: phase.status,
      stepCount: phase.steps.length,
      logCount: phase.logs.length,
      errorCount: _countLogsByLevel(phase.logs, TimelineLogSeverity.error),
      warningCount: _countLogsByLevel(phase.logs, TimelineLogSeverity.warning),
      tokenMetadata: tokenMetadata,
      streamingMetadata: streamingMetadata,
      steps: phase.steps.map(convertStepOverview).toList(),
      logs: phase.logs.map(convertLog).toList(),
    );
  }

  /// Converts TimelineStep to UI step data
  static StepOverviewData convertStepOverview(TimelineStep step) {
    return StepOverviewData(
      stepId: step.id,
      stepName: step.name,
      description: step.description,
      startTime: step.startTime,
      endTime: step.endTime,
      duration: step.duration,
      status: step.status,
      logCount: step.logs.length,
      metadata: step.metadata,
      logs: step.logs.map(convertLog).toList(),
    );
  }

  /// Converts TimelineLog to UI log data
  static LogEntryData convertLog(TimelineLog log) {
    return LogEntryData(
      message: log.message,
      timestamp: log.timestamp,
      severity: log.severity,
      metadata: log.metadata,
    );
  }

  /// Extracts token metadata from phase logs and metadata
  static TokenMetadata? _extractTokenMetadata(TimelinePhase phase) {
    // Look for token metadata in phase logs
    for (final log in phase.logs) {
      final metadata = log.metadata;
      if (metadata.containsKey('total_tokens')) {
        return TokenMetadata(
          totalTokens: metadata['total_tokens'] as int? ?? 0,
          inputTokens: metadata['input_tokens'] as int?,
          outputTokens: metadata['output_tokens'] as int?,
          apiCallCount: metadata['api_call_count'] as int?,
          tokensPerSecond: double.tryParse(metadata['tokens_per_second']?.toString() ?? ''),
          tokensPerMs: double.tryParse(metadata['tokens_per_ms']?.toString() ?? ''),
        );
      }
    }
    return null;
  }

  /// Extracts streaming metadata from phase logs
  static StreamingMetadata? _extractStreamingMetadata(TimelinePhase phase) {
    for (final log in phase.logs) {
      final metadata = log.metadata;
      if (metadata.containsKey('stream_events')) {
        return StreamingMetadata(
          streamEvents: metadata['stream_events'] as int? ?? 0,
          chunksReceived: metadata['chunks_received'] as int? ?? 0,
          totalCharacters: metadata['total_characters'] as int? ?? 0,
          averageChunkSize: metadata['average_chunk_size'] as int? ?? 0,
          timeToFirstChunkMs: metadata['time_to_first_chunk_ms'] as int?,
          functionCallsMade: (metadata['function_calls_made'] as List?)?.cast<String>() ?? [],
        );
      }
    }
    return null;
  }

  /// Counts logs by severity level
  static int _countLogsByLevel(List<TimelineLog> logs, TimelineLogSeverity severity) {
    return logs.where((log) => log.severity == severity).length;
  }

  /// Counts total errors in timeline
  static int _countTimelineErrors(ExecutionTimeline timeline) {
    return timeline.phases.fold(0, (sum, phase) => 
        sum + _countLogsByLevel(phase.logs, TimelineLogSeverity.error));
  }

  /// Counts total warnings in timeline
  static int _countTimelineWarnings(ExecutionTimeline timeline) {
    return timeline.phases.fold(0, (sum, phase) => 
        sum + _countLogsByLevel(phase.logs, TimelineLogSeverity.warning));
  }

  /// Extracts total token usage from phases
  static int _extractTotalTokensFromPhases(List<TimelinePhase> phases) {
    for (final phase in phases) {
      final tokenMetadata = _extractTokenMetadata(phase);
      if (tokenMetadata != null && tokenMetadata.totalTokens > 0) {
        return tokenMetadata.totalTokens;
      }
    }
    return 0;
  }
}

/// UI-friendly data classes

class SessionOverviewData {
  final String sessionId;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final TimelineStatus status;
  final int messageCount;
  final int totalTokenUsage;
  final double totalCost;
  final int totalErrors;
  final int totalWarnings;
  final List<PhaseStatistics> phaseStatistics;

  const SessionOverviewData({
    required this.sessionId,
    required this.startTime,
    this.endTime,
    this.duration,
    required this.status,
    required this.messageCount,
    required this.totalTokenUsage,
    required this.totalCost,
    required this.totalErrors,
    required this.totalWarnings,
    required this.phaseStatistics,
  });
}

class PhaseStatistics {
  final String phaseName;
  final int executionCount;
  final int totalDurationMs;
  final int averageDurationMs;
  final int minDurationMs;
  final int maxDurationMs;
  final int errorCount;
  final int warningCount;

  const PhaseStatistics({
    required this.phaseName,
    required this.executionCount,
    required this.totalDurationMs,
    required this.averageDurationMs,
    required this.minDurationMs,
    required this.maxDurationMs,
    required this.errorCount,
    required this.warningCount,
  });

  PhaseStatistics copyWith({
    String? phaseName,
    int? executionCount,
    int? totalDurationMs,
    int? averageDurationMs,
    int? minDurationMs,
    int? maxDurationMs,
    int? errorCount,
    int? warningCount,
  }) {
    return PhaseStatistics(
      phaseName: phaseName ?? this.phaseName,
      executionCount: executionCount ?? this.executionCount,
      totalDurationMs: totalDurationMs ?? this.totalDurationMs,
      averageDurationMs: averageDurationMs ?? this.averageDurationMs,
      minDurationMs: minDurationMs ?? this.minDurationMs,
      maxDurationMs: maxDurationMs ?? this.maxDurationMs,
      errorCount: errorCount ?? this.errorCount,
      warningCount: warningCount ?? this.warningCount,
    );
  }
}

class TimelineOverviewData {
  final String timelineId;
  final String userMessage;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final TimelineStatus status;
  final int phaseCount;
  final int totalTokens;
  final int errorCount;
  final int warningCount;
  final List<PhaseOverviewData> phases;

  const TimelineOverviewData({
    required this.timelineId,
    required this.userMessage,
    required this.startTime,
    this.endTime,
    this.duration,
    required this.status,
    required this.phaseCount,
    required this.totalTokens,
    required this.errorCount,
    required this.warningCount,
    required this.phases,
  });
}

class PhaseOverviewData {
  final String phaseId;
  final String phaseName;
  final String? description;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final TimelineStatus status;
  final int stepCount;
  final int logCount;
  final int errorCount;
  final int warningCount;
  final TokenMetadata? tokenMetadata;
  final StreamingMetadata? streamingMetadata;
  final List<StepOverviewData> steps;
  final List<LogEntryData> logs;

  const PhaseOverviewData({
    required this.phaseId,
    required this.phaseName,
    this.description,
    required this.startTime,
    this.endTime,
    this.duration,
    required this.status,
    required this.stepCount,
    required this.logCount,
    required this.errorCount,
    required this.warningCount,
    this.tokenMetadata,
    this.streamingMetadata,
    required this.steps,
    required this.logs,
  });
}

class StepOverviewData {
  final String stepId;
  final String stepName;
  final String? description;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final TimelineStatus status;
  final int logCount;
  final Map<String, dynamic> metadata;
  final List<LogEntryData> logs;

  const StepOverviewData({
    required this.stepId,
    required this.stepName,
    this.description,
    required this.startTime,
    this.endTime,
    this.duration,
    required this.status,
    required this.logCount,
    required this.metadata,
    required this.logs,
  });
}

class LogEntryData {
  final String message;
  final DateTime timestamp;
  final TimelineLogSeverity severity;
  final Map<String, dynamic> metadata;

  const LogEntryData({
    required this.message,
    required this.timestamp,
    required this.severity,
    required this.metadata,
  });
}

class TokenMetadata {
  final int totalTokens;
  final int? inputTokens;
  final int? outputTokens;
  final int? apiCallCount;
  final double? tokensPerSecond;
  final double? tokensPerMs;

  const TokenMetadata({
    required this.totalTokens,
    this.inputTokens,
    this.outputTokens,
    this.apiCallCount,
    this.tokensPerSecond,
    this.tokensPerMs,
  });
}

class StreamingMetadata {
  final int streamEvents;
  final int chunksReceived;
  final int totalCharacters;
  final int averageChunkSize;
  final int? timeToFirstChunkMs;
  final List<String> functionCallsMade;

  const StreamingMetadata({
    required this.streamEvents,
    required this.chunksReceived,
    required this.totalCharacters,
    required this.averageChunkSize,
    this.timeToFirstChunkMs,
    required this.functionCallsMade,
  });
}