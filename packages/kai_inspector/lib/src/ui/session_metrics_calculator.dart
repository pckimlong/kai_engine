import 'package:kai_engine/src/inspector/models/timeline_session.dart';
import 'package:kai_engine/src/inspector/execution_timeline.dart';
import 'package:kai_engine/src/inspector/models/timeline_phase.dart';
import 'package:kai_engine/src/inspector/models/timeline_types.dart';
import 'debug_data_adapter.dart';

/// Calculates comprehensive metrics and analytics for debugging sessions
class SessionMetricsCalculator {
  /// Calculates real-time session metrics
  static SessionMetrics calculateSessionMetrics(TimelineSession session) {
    final timelines = session.timelines;
    if (timelines.isEmpty) {
      return SessionMetrics.empty(session.id);
    }

    final sessionDuration = session.duration ?? 
        DateTime.now().difference(session.startTime);

    // Performance metrics
    final performanceMetrics = _calculatePerformanceMetrics(timelines, sessionDuration);
    
    // Token economics
    final tokenEconomics = _calculateTokenEconomics(timelines, sessionDuration);
    
    // Quality metrics
    final qualityMetrics = _calculateQualityMetrics(timelines);
    
    // Streaming analytics
    final streamingAnalytics = _calculateStreamingAnalytics(timelines);

    return SessionMetrics(
      sessionId: session.id,
      startTime: session.startTime,
      endTime: session.endTime,
      duration: sessionDuration,
      messageCount: timelines.length,
      performanceMetrics: performanceMetrics,
      tokenEconomics: tokenEconomics,
      qualityMetrics: qualityMetrics,
      streamingAnalytics: streamingAnalytics,
    );
  }

  /// Calculates token usage trends over time
  static List<TokenUsagePoint> calculateTokenUsageTrend(TimelineSession session) {
    final points = <TokenUsagePoint>[];
    var cumulativeTokens = 0;

    for (final timeline in session.timelines) {
      final timelineTokens = _extractTimelineTokens(timeline);
      cumulativeTokens += timelineTokens;
      
      points.add(TokenUsagePoint(
        timestamp: timeline.endTime ?? timeline.startTime,
        cumulativeTokens: cumulativeTokens,
        timelineTokens: timelineTokens,
        timelineId: timeline.id,
        userMessage: timeline.userMessage.length > 50 
            ? '${timeline.userMessage.substring(0, 50)}...' 
            : timeline.userMessage,
      ));
    }

    return points;
  }

  /// Calculates phase performance comparison across messages
  static List<PhasePerformanceComparison> calculatePhasePerformanceComparison(
      TimelineSession session) {
    final phaseData = <String, List<PhasePerformanceData>>{};
    
    // Collect phase data from all timelines
    for (final timeline in session.timelines) {
      for (final phase in timeline.phases) {
        final phaseName = phase.name;
        final duration = phase.duration?.inMilliseconds ?? 0;
        final tokenUsage = _extractPhaseTokens(phase);
        
        phaseData.putIfAbsent(phaseName, () => []).add(
          PhasePerformanceData(
            timelineId: timeline.id,
            durationMs: duration,
            tokenUsage: tokenUsage,
            hasErrors: phase.logs.any((log) => log.severity == TimelineLogSeverity.error),
          ),
        );
      }
    }

    // Calculate comparison metrics
    return phaseData.entries.map((entry) {
      final phaseName = entry.key;
      final data = entry.value;
      final durations = data.map((d) => d.durationMs).where((d) => d > 0).toList();
      final tokens = data.map((d) => d.tokenUsage).where((t) => t > 0).toList();
      
      return PhasePerformanceComparison(
        phaseName: phaseName,
        executionCount: data.length,
        averageDurationMs: durations.isNotEmpty ? (durations.reduce((a, b) => a + b) / durations.length).round() : 0,
        minDurationMs: durations.isNotEmpty ? durations.reduce((a, b) => a < b ? a : b) : 0,
        maxDurationMs: durations.isNotEmpty ? durations.reduce((a, b) => a > b ? a : b) : 0,
        averageTokenUsage: tokens.isNotEmpty ? (tokens.reduce((a, b) => a + b) / tokens.length).round() : 0,
        totalTokenUsage: tokens.isNotEmpty ? tokens.reduce((a, b) => a + b) : 0,
        errorRate: data.where((d) => d.hasErrors).length / data.length,
        performanceData: data,
      );
    }).toList()
      ..sort((a, b) => b.totalTokenUsage.compareTo(a.totalTokenUsage));
  }

  /// Calculates cost breakdown by phase and timeline
  static CostAnalysis calculateCostAnalysis(TimelineSession session, {double costPerToken = 0.0}) {
    if (costPerToken <= 0.0) {
      return CostAnalysis.zero(session.id);
    }

    final timelineCosts = <TimelineCostData>[];
    final phaseCosts = <String, double>{};
    var totalCost = 0.0;

    for (final timeline in session.timelines) {
      final timelineTokens = _extractTimelineTokens(timeline);
      final timelineCost = timelineTokens * costPerToken;
      totalCost += timelineCost;

      timelineCosts.add(TimelineCostData(
        timelineId: timeline.id,
        userMessage: timeline.userMessage,
        tokens: timelineTokens,
        cost: timelineCost,
        timestamp: timeline.startTime,
      ));

      // Phase-level costs
      for (final phase in timeline.phases) {
        final phaseTokens = _extractPhaseTokens(phase);
        final phaseCost = phaseTokens * costPerToken;
        phaseCosts[phase.name] = (phaseCosts[phase.name] ?? 0.0) + phaseCost;
      }
    }

    final phaseCostBreakdown = phaseCosts.entries.map((entry) => 
      PhaseCostData(
        phaseName: entry.key,
        totalCost: entry.value,
        percentage: totalCost > 0 ? (entry.value / totalCost) * 100 : 0.0,
      )).toList()
      ..sort((a, b) => b.totalCost.compareTo(a.totalCost));

    return CostAnalysis(
      sessionId: session.id,
      totalCost: totalCost,
      costPerToken: costPerToken,
      totalTokens: session.totalTokenUsage,
      averageCostPerMessage: timelineCosts.isNotEmpty ? totalCost / timelineCosts.length : 0.0,
      timelineCosts: timelineCosts,
      phaseCostBreakdown: phaseCostBreakdown,
    );
  }

  // Private helper methods

  static PerformanceMetrics _calculatePerformanceMetrics(
      List<ExecutionTimeline> timelines, Duration sessionDuration) {
    final durations = timelines
        .map((t) => t.duration?.inMilliseconds ?? 0)
        .where((d) => d > 0)
        .toList();

    return PerformanceMetrics(
      averageResponseTimeMs: durations.isNotEmpty ? (durations.reduce((a, b) => a + b) / durations.length).round() : 0,
      fastestResponseTimeMs: durations.isNotEmpty ? durations.reduce((a, b) => a < b ? a : b) : 0,
      slowestResponseTimeMs: durations.isNotEmpty ? durations.reduce((a, b) => a > b ? a : b) : 0,
      sessionDurationMs: sessionDuration.inMilliseconds,
      messagesPerMinute: sessionDuration.inMinutes > 0 ? timelines.length / sessionDuration.inMinutes : 0.0,
      totalPhaseExecutions: timelines.fold(0, (sum, timeline) => sum + timeline.phases.length),
    );
  }

  static TokenEconomics _calculateTokenEconomics(
      List<ExecutionTimeline> timelines, Duration sessionDuration) {
    final tokenCounts = timelines.map(_extractTimelineTokens).where((t) => t > 0).toList();
    final totalTokens = tokenCounts.isNotEmpty ? tokenCounts.reduce((a, b) => a + b) : 0;

    return TokenEconomics(
      totalTokensUsed: totalTokens,
      averageTokensPerMessage: tokenCounts.isNotEmpty ? (totalTokens / tokenCounts.length).round() : 0,
      minTokensPerMessage: tokenCounts.isNotEmpty ? tokenCounts.reduce((a, b) => a < b ? a : b) : 0,
      maxTokensPerMessage: tokenCounts.isNotEmpty ? tokenCounts.reduce((a, b) => a > b ? a : b) : 0,
      tokensPerMinute: sessionDuration.inMinutes > 0 ? (totalTokens / sessionDuration.inMinutes).round() : 0,
      efficiency: _calculateTokenEfficiency(timelines),
    );
  }

  static QualityMetrics _calculateQualityMetrics(List<ExecutionTimeline> timelines) {
    var totalErrors = 0;
    var totalWarnings = 0;
    var completedTimelines = 0;

    for (final timeline in timelines) {
      if (timeline.status == TimelineStatus.completed) {
        completedTimelines++;
      } else if (timeline.status == TimelineStatus.failed) {
        // Failed timeline - no additional tracking needed
      }

      for (final phase in timeline.phases) {
        totalErrors += phase.logs.where((log) => log.severity == TimelineLogSeverity.error).length;
        totalWarnings += phase.logs.where((log) => log.severity == TimelineLogSeverity.warning).length;
      }
    }

    return QualityMetrics(
      successRate: timelines.isNotEmpty ? completedTimelines / timelines.length : 0.0,
      totalErrors: totalErrors,
      totalWarnings: totalWarnings,
      averageErrorsPerMessage: timelines.isNotEmpty ? totalErrors / timelines.length : 0.0,
      averageWarningsPerMessage: timelines.isNotEmpty ? totalWarnings / timelines.length : 0.0,
    );
  }

  static StreamingAnalytics _calculateStreamingAnalytics(List<ExecutionTimeline> timelines) {
    var totalChunks = 0;
    var totalCharacters = 0;
    var totalFirstChunkTimes = <int>[];
    var totalStreamEvents = 0;

    for (final timeline in timelines) {
      for (final phase in timeline.phases) {
        final streamingMetadata = _extractStreamingMetadata(phase);
        if (streamingMetadata != null) {
          totalChunks += streamingMetadata.chunksReceived;
          totalCharacters += streamingMetadata.totalCharacters;
          totalStreamEvents += streamingMetadata.streamEvents;
          
          if (streamingMetadata.timeToFirstChunkMs != null) {
            totalFirstChunkTimes.add(streamingMetadata.timeToFirstChunkMs!);
          }
        }
      }
    }

    return StreamingAnalytics(
      totalStreamEvents: totalStreamEvents,
      totalChunksReceived: totalChunks,
      totalCharactersStreamed: totalCharacters,
      averageChunkSize: totalChunks > 0 ? (totalCharacters / totalChunks).round() : 0,
      averageTimeToFirstChunkMs: totalFirstChunkTimes.isNotEmpty
          ? (totalFirstChunkTimes.reduce((a, b) => a + b) / totalFirstChunkTimes.length).round()
          : 0,
    );
  }

  static double _calculateTokenEfficiency(List<ExecutionTimeline> timelines) {
    // Calculate efficiency as average tokens per millisecond
    var totalTokens = 0;
    var totalTime = 0;

    for (final timeline in timelines) {
      final tokens = _extractTimelineTokens(timeline);
      final duration = timeline.duration?.inMilliseconds ?? 0;
      
      if (tokens > 0 && duration > 0) {
        totalTokens += tokens;
        totalTime += duration;
      }
    }

    return totalTime > 0 ? totalTokens / totalTime : 0.0;
  }

  static int _extractTimelineTokens(ExecutionTimeline timeline) {
    for (final phase in timeline.phases) {
      final tokenMetadata = _extractTokenMetadata(phase);
      if (tokenMetadata != null && tokenMetadata.totalTokens > 0) {
        return tokenMetadata.totalTokens;
      }
    }
    return 0;
  }

  static int _extractPhaseTokens(TimelinePhase phase) {
    final tokenMetadata = _extractTokenMetadata(phase);
    return tokenMetadata?.totalTokens ?? 0;
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
}

// Data classes for metrics

class SessionMetrics {
  final String sessionId;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final int messageCount;
  final PerformanceMetrics performanceMetrics;
  final TokenEconomics tokenEconomics;
  final QualityMetrics qualityMetrics;
  final StreamingAnalytics streamingAnalytics;

  const SessionMetrics({
    required this.sessionId,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.messageCount,
    required this.performanceMetrics,
    required this.tokenEconomics,
    required this.qualityMetrics,
    required this.streamingAnalytics,
  });

  static SessionMetrics empty(String sessionId) {
    return SessionMetrics(
      sessionId: sessionId,
      startTime: DateTime.now(),
      duration: Duration.zero,
      messageCount: 0,
      performanceMetrics: const PerformanceMetrics(
        averageResponseTimeMs: 0,
        fastestResponseTimeMs: 0,
        slowestResponseTimeMs: 0,
        sessionDurationMs: 0,
        messagesPerMinute: 0,
        totalPhaseExecutions: 0,
      ),
      tokenEconomics: const TokenEconomics(
        totalTokensUsed: 0,
        averageTokensPerMessage: 0,
        minTokensPerMessage: 0,
        maxTokensPerMessage: 0,
        tokensPerMinute: 0,
        efficiency: 0,
      ),
      qualityMetrics: const QualityMetrics(
        successRate: 0,
        totalErrors: 0,
        totalWarnings: 0,
        averageErrorsPerMessage: 0,
        averageWarningsPerMessage: 0,
      ),
      streamingAnalytics: const StreamingAnalytics(
        totalStreamEvents: 0,
        totalChunksReceived: 0,
        totalCharactersStreamed: 0,
        averageChunkSize: 0,
        averageTimeToFirstChunkMs: 0,
      ),
    );
  }
}

class PerformanceMetrics {
  final int averageResponseTimeMs;
  final int fastestResponseTimeMs;
  final int slowestResponseTimeMs;
  final int sessionDurationMs;
  final double messagesPerMinute;
  final int totalPhaseExecutions;

  const PerformanceMetrics({
    required this.averageResponseTimeMs,
    required this.fastestResponseTimeMs,
    required this.slowestResponseTimeMs,
    required this.sessionDurationMs,
    required this.messagesPerMinute,
    required this.totalPhaseExecutions,
  });
}

class TokenEconomics {
  final int totalTokensUsed;
  final int averageTokensPerMessage;
  final int minTokensPerMessage;
  final int maxTokensPerMessage;
  final int tokensPerMinute;
  final double efficiency;

  const TokenEconomics({
    required this.totalTokensUsed,
    required this.averageTokensPerMessage,
    required this.minTokensPerMessage,
    required this.maxTokensPerMessage,
    required this.tokensPerMinute,
    required this.efficiency,
  });
}

class QualityMetrics {
  final double successRate;
  final int totalErrors;
  final int totalWarnings;
  final double averageErrorsPerMessage;
  final double averageWarningsPerMessage;

  const QualityMetrics({
    required this.successRate,
    required this.totalErrors,
    required this.totalWarnings,
    required this.averageErrorsPerMessage,
    required this.averageWarningsPerMessage,
  });
}

class StreamingAnalytics {
  final int totalStreamEvents;
  final int totalChunksReceived;
  final int totalCharactersStreamed;
  final int averageChunkSize;
  final int averageTimeToFirstChunkMs;

  const StreamingAnalytics({
    required this.totalStreamEvents,
    required this.totalChunksReceived,
    required this.totalCharactersStreamed,
    required this.averageChunkSize,
    required this.averageTimeToFirstChunkMs,
  });
}

class TokenUsagePoint {
  final DateTime timestamp;
  final int cumulativeTokens;
  final int timelineTokens;
  final String timelineId;
  final String userMessage;

  const TokenUsagePoint({
    required this.timestamp,
    required this.cumulativeTokens,
    required this.timelineTokens,
    required this.timelineId,
    required this.userMessage,
  });
}

class PhasePerformanceComparison {
  final String phaseName;
  final int executionCount;
  final int averageDurationMs;
  final int minDurationMs;
  final int maxDurationMs;
  final int averageTokenUsage;
  final int totalTokenUsage;
  final double errorRate;
  final List<PhasePerformanceData> performanceData;

  const PhasePerformanceComparison({
    required this.phaseName,
    required this.executionCount,
    required this.averageDurationMs,
    required this.minDurationMs,
    required this.maxDurationMs,
    required this.averageTokenUsage,
    required this.totalTokenUsage,
    required this.errorRate,
    required this.performanceData,
  });
}

class PhasePerformanceData {
  final String timelineId;
  final int durationMs;
  final int tokenUsage;
  final bool hasErrors;

  const PhasePerformanceData({
    required this.timelineId,
    required this.durationMs,
    required this.tokenUsage,
    required this.hasErrors,
  });
}

class CostAnalysis {
  final String sessionId;
  final double totalCost;
  final double costPerToken;
  final int totalTokens;
  final double averageCostPerMessage;
  final List<TimelineCostData> timelineCosts;
  final List<PhaseCostData> phaseCostBreakdown;

  const CostAnalysis({
    required this.sessionId,
    required this.totalCost,
    required this.costPerToken,
    required this.totalTokens,
    required this.averageCostPerMessage,
    required this.timelineCosts,
    required this.phaseCostBreakdown,
  });

  static CostAnalysis zero(String sessionId) {
    return CostAnalysis(
      sessionId: sessionId,
      totalCost: 0.0,
      costPerToken: 0.0,
      totalTokens: 0,
      averageCostPerMessage: 0.0,
      timelineCosts: [],
      phaseCostBreakdown: [],
    );
  }
}

class TimelineCostData {
  final String timelineId;
  final String userMessage;
  final int tokens;
  final double cost;
  final DateTime timestamp;

  const TimelineCostData({
    required this.timelineId,
    required this.userMessage,
    required this.tokens,
    required this.cost,
    required this.timestamp,
  });
}

class PhaseCostData {
  final String phaseName;
  final double totalCost;
  final double percentage;

  const PhaseCostData({
    required this.phaseName,
    required this.totalCost,
    required this.percentage,
  });
}