import 'package:flutter/material.dart';

import 'package:kai_engine/src/inspector/models/timeline_session.dart';
import 'package:kai_engine/src/inspector/models/timeline_types.dart';
import '../debug_data_adapter.dart';
import '../session_metrics_calculator.dart';
import 'shared_widgets.dart';

/// Session overview dashboard showing high-level metrics and summaries
class SessionDashboardTab extends StatelessWidget {
  final TimelineSession session;
  final SessionOverviewData sessionOverview;
  final SessionMetrics sessionMetrics;

  const SessionDashboardTab({
    super.key,
    required this.session,
    required this.sessionOverview,
    required this.sessionMetrics,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SessionHeaderCard(
            session: session,
            sessionOverview: sessionOverview,
          ),
          const SizedBox(height: 16),
          _MetricsOverviewGrid(sessionMetrics: sessionMetrics),
          const SizedBox(height: 16),
          // Changed from Row to Column for better mobile layout
          _MessagesTimelineCard(
            session: session,
            sessionOverview: sessionOverview,
          ),
          const SizedBox(height: 16),
          _PhasePerformanceCard(
            phaseStatistics: sessionOverview.phaseStatistics,
          ),
          const SizedBox(height: 16),
          _QualityInsightsCard(
            sessionMetrics: sessionMetrics,
            sessionOverview: sessionOverview,
          ),
        ],
      ),
    );
  }
}

class _SessionHeaderCard extends StatelessWidget {
  final TimelineSession session;
  final SessionOverviewData sessionOverview;

  const _SessionHeaderCard({
    required this.session,
    required this.sessionOverview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = session.status == TimelineStatus.running;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isActive ? Icons.play_circle : Icons.check_circle,
                  size: 32,
                  color: isActive ? Colors.blue : Colors.green,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Debug Session',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'ID: ${session.id}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(session.status).withAlpha(51),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getStatusColor(session.status).withAlpha(102),
                    ),
                  ),
                  child: Text(
                    session.status.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(session.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _SessionStat(
                  icon: Icons.schedule,
                  label: 'Started',
                  value: _formatDateTime(session.startTime),
                  color: Colors.blue,
                ),
                if (session.endTime != null)
                  _SessionStat(
                    icon: Icons.flag,
                    label: 'Ended',
                    value: _formatDateTime(session.endTime!),
                    color: Colors.green,
                  ),
                _SessionStat(
                  icon: Icons.timer,
                  label: 'Duration',
                  value: sessionOverview.duration != null
                      ? '${sessionOverview.duration!.inMilliseconds}ms'
                      : _formatDuration(
                          DateTime.now().difference(session.startTime)),
                  color: Colors.purple,
                ),
                _SessionStat(
                  icon: Icons.message,
                  label: 'Messages',
                  value: '${sessionOverview.messageCount}',
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TimelineStatus status) {
    switch (status) {
      case TimelineStatus.running:
        return Colors.blue;
      case TimelineStatus.completed:
        return Colors.green;
      case TimelineStatus.failed:
        return Colors.red;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}

class _SessionStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SessionStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricsOverviewGrid extends StatelessWidget {
  final SessionMetrics sessionMetrics;

  const _MetricsOverviewGrid({required this.sessionMetrics});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount =
        screenWidth < 600 ? 2 : 4; // 2 columns on mobile, 4 on wider screens

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio:
          screenWidth < 600 ? 1.4 : 1.2, // Adjust aspect ratio for mobile
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _MetricCard(
          title: 'Avg Response',
          value: '${sessionMetrics.performanceMetrics.averageResponseTimeMs}ms',
          icon: Icons.speed,
          color: Colors.blue,
        ),
        _MetricCard(
          title: 'Total Tokens',
          value: _formatNumber(sessionMetrics.tokenEconomics.totalTokensUsed),
          icon: Icons.token,
          color: Colors.green,
        ),
        _MetricCard(
          title: 'Success Rate',
          value:
              '${(sessionMetrics.qualityMetrics.successRate * 100).toStringAsFixed(1)}%',
          icon: Icons.check_circle,
          color: sessionMetrics.qualityMetrics.successRate >= 0.9
              ? Colors.green
              : Colors.orange,
        ),
        _MetricCard(
          title: 'Issues',
          value:
              '${sessionMetrics.qualityMetrics.totalErrors + sessionMetrics.qualityMetrics.totalWarnings}',
          icon: Icons.warning,
          color: sessionMetrics.qualityMetrics.totalErrors > 0
              ? Colors.red
              : Colors.grey,
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagesTimelineCard extends StatelessWidget {
  final TimelineSession session;
  final SessionOverviewData sessionOverview;

  const _MessagesTimelineCard({
    required this.session,
    required this.sessionOverview,
  });

  @override
  Widget build(BuildContext context) {
    final timelines = session.timelines;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Message Timeline',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            if (timelines.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No messages yet'),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  itemCount: timelines.length,
                  itemBuilder: (context, index) {
                    final timeline = timelines[index];
                    final timelineData =
                        DebugDataAdapter.convertTimelineOverview(timeline);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: _MessageTimelineItem(
                        index: index + 1,
                        timelineData: timelineData,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageTimelineItem extends StatelessWidget {
  final int index;
  final TimelineOverviewData timelineData;

  const _MessageTimelineItem({
    required this.index,
    required this.timelineData,
  });

  @override
  Widget build(BuildContext context) {
    final hasIssues =
        timelineData.errorCount > 0 || timelineData.warningCount > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withAlpha(51),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _getStatusColor(timelineData.status),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  timelineData.userMessage.length > 80
                      ? '${timelineData.userMessage.substring(0, 80)}...'
                      : timelineData.userMessage,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              InfoChip(
                label: 'Time',
                value: timelineData.duration != null
                    ? '${timelineData.duration!.inMilliseconds}ms'
                    : 'In progress',
                color: Colors.blue,
              ),
              if (timelineData.totalTokens > 0)
                InfoChip(
                  label: 'Tokens',
                  value: '${timelineData.totalTokens}',
                  color: Colors.green,
                ),
              InfoChip(
                label: 'Phases',
                value: '${timelineData.phaseCount}',
                color: Colors.purple,
              ),
              if (hasIssues)
                InfoChip(
                  label: 'Issues',
                  value:
                      '${timelineData.errorCount + timelineData.warningCount}',
                  color: Colors.red,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TimelineStatus status) {
    switch (status) {
      case TimelineStatus.running:
        return Colors.blue;
      case TimelineStatus.completed:
        return Colors.green;
      case TimelineStatus.failed:
        return Colors.red;
    }
  }
}

class _PhasePerformanceCard extends StatelessWidget {
  final List<PhaseStatistics> phaseStatistics;

  const _PhasePerformanceCard({required this.phaseStatistics});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phase Performance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            if (phaseStatistics.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No phase data available'),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  itemCount: phaseStatistics.length,
                  itemBuilder: (context, index) {
                    final phase = phaseStatistics[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: _PhasePerformanceItem(phase: phase),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PhasePerformanceItem extends StatelessWidget {
  final PhaseStatistics phase;

  const _PhasePerformanceItem({required this.phase});

  @override
  Widget build(BuildContext context) {
    final phaseName = phase.phaseName
        .split('-')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withAlpha(51)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  phaseName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                '${phase.executionCount}x',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            children: [
              InfoChip(
                label: 'Avg',
                value: '${phase.averageDurationMs}ms',
                color: Colors.blue,
              ),
              InfoChip(
                label: 'Range',
                value: '${phase.minDurationMs}-${phase.maxDurationMs}ms',
                color: Colors.grey,
              ),
              if (phase.errorCount > 0 || phase.warningCount > 0)
                InfoChip(
                  label: 'Issues',
                  value: '${phase.errorCount + phase.warningCount}',
                  color: Colors.red,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QualityInsightsCard extends StatelessWidget {
  final SessionMetrics sessionMetrics;
  final SessionOverviewData sessionOverview;

  const _QualityInsightsCard({
    required this.sessionMetrics,
    required this.sessionOverview,
  });

  @override
  Widget build(BuildContext context) {
    final insights = _generateInsights();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quality Insights',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            ...insights.map((insight) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: _InsightItem(insight: insight),
                )),
          ],
        ),
      ),
    );
  }

  List<QualityInsight> _generateInsights() {
    final insights = <QualityInsight>[];
    final performance = sessionMetrics.performanceMetrics;
    final quality = sessionMetrics.qualityMetrics;
    final tokens = sessionMetrics.tokenEconomics;

    // Performance insights
    if (performance.averageResponseTimeMs > 5000) {
      insights.add(QualityInsight(
        type: InsightType.warning,
        title: 'Slow Response Times',
        description:
            'Average response time is ${performance.averageResponseTimeMs}ms. Consider optimizing phases.',
      ));
    } else if (performance.averageResponseTimeMs < 1000) {
      insights.add(QualityInsight(
        type: InsightType.positive,
        title: 'Fast Response Times',
        description:
            'Excellent average response time of ${performance.averageResponseTimeMs}ms.',
      ));
    }

    // Quality insights
    if (quality.successRate < 0.9) {
      insights.add(QualityInsight(
        type: InsightType.error,
        title: 'Low Success Rate',
        description:
            'Success rate is ${(quality.successRate * 100).toStringAsFixed(1)}%. Review error patterns.',
      ));
    } else if (quality.successRate >= 0.98) {
      insights.add(QualityInsight(
        type: InsightType.positive,
        title: 'High Reliability',
        description:
            'Excellent success rate of ${(quality.successRate * 100).toStringAsFixed(1)}%.',
      ));
    }

    // Token efficiency insights
    if (tokens.averageTokensPerMessage > 4000) {
      insights.add(QualityInsight(
        type: InsightType.warning,
        title: 'High Token Usage',
        description:
            'Average ${tokens.averageTokensPerMessage} tokens/message. Consider context optimization.',
      ));
    }

    // Error pattern insights
    if (quality.totalErrors > 0) {
      insights.add(QualityInsight(
        type: InsightType.info,
        title: 'Error Analysis',
        description:
            '${quality.totalErrors} errors across ${sessionOverview.messageCount} messages. Check logs for patterns.',
      ));
    }

    if (insights.isEmpty) {
      insights.add(QualityInsight(
        type: InsightType.positive,
        title: 'All Systems Nominal',
        description:
            'Session is performing well with no significant issues detected.',
      ));
    }

    return insights;
  }
}

class _InsightItem extends StatelessWidget {
  final QualityInsight insight;

  const _InsightItem({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          _getInsightIcon(insight.type),
          size: 16,
          color: _getInsightColor(insight.type),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                insight.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              Text(
                insight.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.positive:
        return Icons.check_circle;
      case InsightType.warning:
        return Icons.warning;
      case InsightType.error:
        return Icons.error;
      case InsightType.info:
        return Icons.info;
    }
  }

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.positive:
        return Colors.green;
      case InsightType.warning:
        return Colors.orange;
      case InsightType.error:
        return Colors.red;
      case InsightType.info:
        return Colors.blue;
    }
  }
}

class QualityInsight {
  final InsightType type;
  final String title;
  final String description;

  const QualityInsight({
    required this.type,
    required this.title,
    required this.description,
  });
}

enum InsightType { positive, warning, error, info }
