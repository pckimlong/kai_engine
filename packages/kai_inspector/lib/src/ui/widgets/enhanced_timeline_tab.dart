import 'package:flutter/material.dart';
import 'package:kai_engine/src/inspector/models/timeline_session.dart';
import 'package:kai_engine/src/inspector/models/timeline_types.dart';

import '../debug_data_adapter.dart';

/// Enhanced timeline visualization with mobile-first responsive design
class EnhancedTimelineTab extends StatefulWidget {
  final TimelineSession session;
  final SessionOverviewData sessionOverview;
  final Function(String sessionId, String messageId, String? userInput)? onNavigateToMessage;

  const EnhancedTimelineTab({
    super.key,
    required this.session,
    required this.sessionOverview,
    this.onNavigateToMessage,
  });

  @override
  State<EnhancedTimelineTab> createState() => _EnhancedTimelineTabState();
}

class _EnhancedTimelineTabState extends State<EnhancedTimelineTab> {
  int? _expandedTimelineIndex;

  @override
  Widget build(BuildContext context) {
    final timelines = widget.session.timelines;

    if (timelines.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Text(
              'No timeline data available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: timelines.length,
      itemBuilder: (context, index) {
        final timeline = timelines[index];
        final isExpanded = _expandedTimelineIndex == index;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _TimelineCard(
            timeline: timeline,
            index: index,
            isExpanded: isExpanded,
            onToggle: () {
              setState(() {
                _expandedTimelineIndex = isExpanded ? null : index;
              });
            },
            onNavigateToMessage: widget.onNavigateToMessage,
          ),
        );
      },
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final dynamic timeline; // ExecutionTimeline
  final int index;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Function(String sessionId, String messageId, String? userInput)? onNavigateToMessage;

  const _TimelineCard({
    required this.timeline,
    required this.index,
    required this.isExpanded,
    required this.onToggle,
    this.onNavigateToMessage,
  });

  @override
  Widget build(BuildContext context) {
    final timelineData = DebugDataAdapter.convertTimelineOverview(timeline);

    return Card(
      margin: EdgeInsets.zero,
      elevation: isExpanded ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor(timelineData.status).withAlpha(51),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header (always visible)
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(12),
              bottom: Radius.circular(isExpanded ? 0 : 12),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getStatusColor(timelineData.status).withAlpha(13),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(12),
                  bottom: Radius.circular(isExpanded ? 0 : 12),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Message number with status color
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getStatusColor(timelineData.status),
                          boxShadow: [
                            BoxShadow(
                              color: _getStatusColor(timelineData.status).withAlpha(77),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Message preview
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _truncateText(timeline.userMessage, 60),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(timelineData.status).withAlpha(26),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(timelineData.status).withAlpha(51),
                                ),
                              ),
                              child: Text(
                                _getStatusText(timelineData.status),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _getStatusColor(timelineData.status),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Action buttons
                      Row(
                        children: [
                          // Navigation button to view message details
                          if (onNavigateToMessage != null)
                            IconButton(
                              icon: Icon(
                                Icons.visibility,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () => onNavigateToMessage!(
                                timeline.id,
                                timeline.id,
                                timeline.userMessage,
                              ),
                              tooltip: 'View Message Details',
                              iconSize: 20,
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor.withAlpha(13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          const SizedBox(width: 4),
                          // Expand/collapse icon
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Quick stats row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.schedule,
                        label: timelineData.duration != null
                            ? '${timelineData.duration!.inMilliseconds}ms'
                            : 'Running',
                        color: Colors.blue,
                      ),
                      _InfoChip(
                        icon: Icons.token,
                        label: '${timelineData.totalTokens}',
                        color: Colors.green,
                      ),
                      _InfoChip(
                        icon: Icons.layers,
                        label: '${timelineData.phaseCount}',
                        color: Colors.purple,
                      ),
                      if (timelineData.errorCount > 0)
                        _InfoChip(
                          icon: Icons.error_outline,
                          label: '${timelineData.errorCount}',
                          color: Colors.red,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Expanded content
          if (isExpanded) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: _ExpandedContent(
                timeline: timeline,
                timelineData: timelineData,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  String _getStatusText(TimelineStatus status) {
    switch (status) {
      case TimelineStatus.running:
        return 'Running...';
      case TimelineStatus.completed:
        return 'Completed';
      case TimelineStatus.failed:
        return 'Failed';
    }
  }

  Color _getStatusColor(TimelineStatus status) {
    switch (status) {
      case TimelineStatus.running:
        return Colors.orange;
      case TimelineStatus.completed:
        return Colors.green;
      case TimelineStatus.failed:
        return Colors.red;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withAlpha(51),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(13),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color.withAlpha(204),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withAlpha(204),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandedContent extends StatelessWidget {
  final dynamic timeline; // ExecutionTimeline
  final TimelineOverviewData timelineData;

  const _ExpandedContent({
    required this.timeline,
    required this.timelineData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Messages section
          _MessageSection(
            userMessage: timeline.userMessage,
            aiResponse: timeline.aiResponse,
          ),
          const SizedBox(height: 16),
          // Performance metrics
          _MetricsSection(timelineData: timelineData),
          const SizedBox(height: 16),
          // Phases
          if (timelineData.phases.isNotEmpty) _PhasesSection(phases: timelineData.phases),
        ],
      ),
    );
  }
}

class _MessageSection extends StatelessWidget {
  final String userMessage;
  final String? aiResponse;

  const _MessageSection({
    required this.userMessage,
    required this.aiResponse,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User message
        _MessageBubble(
          title: 'User Input',
          message: userMessage,
          isUser: true,
        ),
        const SizedBox(height: 8),
        // AI response
        _MessageBubble(
          title: 'AI Response',
          message: aiResponse ?? 'No response available',
          isUser: false,
        ),
      ],
    );
  }
}

class _MessageBubble extends StatefulWidget {
  final String title;
  final String message;
  final bool isUser;

  const _MessageBubble({
    required this.title,
    required this.message,
    required this.isUser,
  });

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isLongMessage = widget.message.length > 100;
    final displayMessage =
        isLongMessage && !_isExpanded ? '${widget.message.substring(0, 100)}...' : widget.message;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isUser ? Colors.blue[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.isUser ? Colors.blue[200]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: widget.isUser ? Colors.blue[700] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayMessage,
            style: const TextStyle(fontSize: 14),
          ),
          if (isLongMessage)
            TextButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _isExpanded ? 'Show less' : 'Show more',
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricsSection extends StatelessWidget {
  final TimelineOverviewData timelineData;

  const _MetricsSection({required this.timelineData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Metrics',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MetricCard(
              label: 'Duration',
              value: timelineData.duration != null
                  ? '${timelineData.duration!.inMilliseconds}ms'
                  : 'N/A',
              icon: Icons.schedule,
              color: Colors.blue,
            ),
            _MetricCard(
              label: 'Tokens',
              value: '${timelineData.totalTokens}',
              icon: Icons.token,
              color: Colors.green,
            ),
            _MetricCard(
              label: 'Phases',
              value: '${timelineData.phaseCount}',
              icon: Icons.layers,
              color: Colors.purple,
            ),
            if (timelineData.errorCount > 0)
              _MetricCard(
                label: 'Errors',
                value: '${timelineData.errorCount}',
                icon: Icons.error_outline,
                color: Colors.red,
              ),
            if (timelineData.warningCount > 0)
              _MetricCard(
                label: 'Warnings',
                value: '${timelineData.warningCount}',
                icon: Icons.warning_outlined,
                color: Colors.orange,
              ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhasesSection extends StatelessWidget {
  final List<dynamic> phases;

  const _PhasesSection({required this.phases});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Execution Phases',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: phases.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final phase = phases[index];
            return _PhaseCard(phase: phase, index: index);
          },
        ),
      ],
    );
  }
}

class _PhaseCard extends StatelessWidget {
  final dynamic phase; // PhaseOverviewData
  final int index;

  const _PhaseCard({
    required this.phase,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.blue,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phase.phaseName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (phase.duration != null)
                  Text(
                    '${phase.duration!.inMilliseconds}ms',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          if (phase.errorCount > 0)
            Icon(
              Icons.error_outline,
              size: 16,
              color: Colors.red,
            ),
        ],
      ),
    );
  }
}
