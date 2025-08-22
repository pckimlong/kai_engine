import 'package:flutter/material.dart';

import '../../../inspector/models/timeline_session.dart';
import '../../../inspector/models/timeline_types.dart';
import '../debug_data_adapter.dart';
import 'shared_widgets.dart';

/// Enhanced timeline visualization showing hierarchical phase/step breakdown
class EnhancedTimelineTab extends StatefulWidget {
  final TimelineSession session;
  final SessionOverviewData sessionOverview;

  const EnhancedTimelineTab({
    super.key,
    required this.session,
    required this.sessionOverview,
  });

  @override
  State<EnhancedTimelineTab> createState() => _EnhancedTimelineTabState();
}

class _EnhancedTimelineTabState extends State<EnhancedTimelineTab> {
  int _selectedTimelineIndex = 0;

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
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
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

    return Row(
      children: [
        // Timeline selector sidebar
        SizedBox(
          width: 300,
          child: _TimelineSidebar(
            timelines: timelines,
            selectedIndex: _selectedTimelineIndex,
            onTimelineSelected: (index) {
              setState(() {
                _selectedTimelineIndex = index;
              });
            },
          ),
        ),
        const VerticalDivider(width: 1),
        // Timeline detail view
        Expanded(
          child: _TimelineDetailView(
            timeline: timelines[_selectedTimelineIndex],
          ),
        ),
      ],
    );
  }
}

class _TimelineSidebar extends StatelessWidget {
  final List<dynamic> timelines; // ExecutionTimeline list
  final int selectedIndex;
  final ValueChanged<int> onTimelineSelected;

  const _TimelineSidebar({
    required this.timelines,
    required this.selectedIndex,
    required this.onTimelineSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Message Timelines (${timelines.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: timelines.length,
            itemBuilder: (context, index) {
              final timeline = timelines[index];
              final timelineData = DebugDataAdapter.convertTimelineOverview(timeline);
              final isSelected = index == selectedIndex;

              return _TimelineSidebarItem(
                index: index + 1,
                timelineData: timelineData,
                isSelected: isSelected,
                onTap: () => onTimelineSelected(index),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TimelineSidebarItem extends StatelessWidget {
  final int index;
  final TimelineOverviewData timelineData;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimelineSidebarItem({
    required this.index,
    required this.timelineData,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withAlpha(26) : null,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Theme.of(context).primaryColor.withAlpha(102))
              : null,
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
                    timelineData.userMessage.length > 40
                        ? '${timelineData.userMessage.substring(0, 40)}...'
                        : timelineData.userMessage,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              children: [
                _SidebarChip(
                  label: timelineData.duration != null
                      ? '${timelineData.duration!.inMilliseconds}ms'
                      : 'Running',
                  color: Colors.blue,
                ),
                if (timelineData.totalTokens > 0)
                  _SidebarChip(
                    label: '${timelineData.totalTokens} tokens',
                    color: Colors.green,
                  ),
                _SidebarChip(
                  label: '${timelineData.phaseCount} phases',
                  color: Colors.purple,
                ),
                if (timelineData.errorCount > 0)
                  _SidebarChip(
                    label: '${timelineData.errorCount} errors',
                    color: Colors.red,
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
}

class _SidebarChip extends StatelessWidget {
  final String label;
  final Color color;

  const _SidebarChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _TimelineDetailView extends StatelessWidget {
  final dynamic timeline; // ExecutionTimeline

  const _TimelineDetailView({required this.timeline});

  @override
  Widget build(BuildContext context) {
    final timelineData = DebugDataAdapter.convertTimelineOverview(timeline);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimelineHeader(timelineData: timelineData),
          const SizedBox(height: 20),
          _TimelineVisualization(timelineData: timelineData),
          const SizedBox(height: 20),
          _PhaseDetailsView(phases: timelineData.phases),
        ],
      ),
    );
  }
}

class _TimelineHeader extends StatelessWidget {
  final TimelineOverviewData timelineData;

  const _TimelineHeader({required this.timelineData});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(timelineData.status),
                  color: _getStatusColor(timelineData.status),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    timelineData.userMessage,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                InfoChip(
                  label: 'Status',
                  value: timelineData.status.toString().split('.').last.toUpperCase(),
                  color: _getStatusColor(timelineData.status),
                ),
                InfoChip(
                  label: 'Duration',
                  value: timelineData.duration != null
                      ? '${timelineData.duration!.inMilliseconds}ms'
                      : 'In Progress',
                  color: Colors.blue,
                ),
                InfoChip(
                  label: 'Phases',
                  value: '${timelineData.phaseCount}',
                  color: Colors.purple,
                ),
                if (timelineData.totalTokens > 0)
                  InfoChip(
                    label: 'Tokens',
                    value: '${timelineData.totalTokens}',
                    color: Colors.green,
                  ),
                if (timelineData.errorCount > 0)
                  InfoChip(
                    label: 'Errors',
                    value: '${timelineData.errorCount}',
                    color: Colors.red,
                  ),
                if (timelineData.warningCount > 0)
                  InfoChip(
                    label: 'Warnings',
                    value: '${timelineData.warningCount}',
                    color: Colors.orange,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(TimelineStatus status) {
    switch (status) {
      case TimelineStatus.running:
        return Icons.play_circle;
      case TimelineStatus.completed:
        return Icons.check_circle;
      case TimelineStatus.failed:
        return Icons.error;
    }
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

class _TimelineVisualization extends StatelessWidget {
  final TimelineOverviewData timelineData;

  const _TimelineVisualization({required this.timelineData});

  @override
  Widget build(BuildContext context) {
    if (timelineData.phases.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text('No phase data available'),
          ),
        ),
      );
    }

    final totalDuration = timelineData.duration?.inMilliseconds ??
        timelineData.phases.last.endTime?.difference(timelineData.phases.first.startTime).inMilliseconds ??
        1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Execution Timeline',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...timelineData.phases.map((phase) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: _PhaseTimelineRow(
                phase: phase,
                totalDuration: totalDuration,
                timelineStart: timelineData.startTime,
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _PhaseTimelineRow extends StatelessWidget {
  final PhaseOverviewData phase;
  final int totalDuration;
  final DateTime timelineStart;

  const _PhaseTimelineRow({
    required this.phase,
    required this.totalDuration,
    required this.timelineStart,
  });

  @override
  Widget build(BuildContext context) {
    final startOffset = phase.startTime.difference(timelineStart).inMilliseconds;
    final phaseDuration = phase.duration?.inMilliseconds ?? 0;
    final startPercent = totalDuration > 0 ? (startOffset / totalDuration) : 0.0;
    final widthPercent = totalDuration > 0 ? (phaseDuration / totalDuration) : 0.1;

    final phaseName = phase.phaseName
        .split('-')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 140,
              child: Text(
                phaseName,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              phase.duration != null
                  ? '${phase.duration!.inMilliseconds}ms'
                  : 'In Progress...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const Spacer(),
            if (phase.tokenMetadata != null && phase.tokenMetadata!.totalTokens > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(51),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${phase.tokenMetadata!.totalTokens} tokens',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (phase.errorCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(51),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${phase.errorCount} errors',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 24,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.6 * startPercent,
                ),
                width: MediaQuery.of(context).size.width * 0.6 * widthPercent,
                height: 24,
                decoration: BoxDecoration(
                  color: getPhaseColor(phase.phaseName).withAlpha(204),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    phase.duration != null
                        ? '${phase.duration!.inMilliseconds}ms'
                        : '...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (phase.steps.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: _StepsTimeline(
              steps: phase.steps,
              phaseStart: phase.startTime,
              phaseDuration: phaseDuration,
            ),
          ),
        ],
      ],
    );
  }
}

class _StepsTimeline extends StatelessWidget {
  final List<StepOverviewData> steps;
  final DateTime phaseStart;
  final int phaseDuration;

  const _StepsTimeline({
    required this.steps,
    required this.phaseStart,
    required this.phaseDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: steps.map((step) {
        final stepStartOffset = step.startTime.difference(phaseStart).inMilliseconds;
        final stepDuration = step.duration?.inMilliseconds ?? 0;
        final stepStartPercent = phaseDuration > 0 ? (stepStartOffset / phaseDuration) : 0.0;
        final stepWidthPercent = phaseDuration > 0 ? (stepDuration / phaseDuration) : 0.1;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  step.stepName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.4 * stepStartPercent,
                        ),
                        width: MediaQuery.of(context).size.width * 0.4 * stepWidthPercent,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha(153),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                step.duration != null ? '${step.duration!.inMilliseconds}ms' : '...',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PhaseDetailsView extends StatefulWidget {
  final List<PhaseOverviewData> phases;

  const _PhaseDetailsView({required this.phases});

  @override
  State<_PhaseDetailsView> createState() => _PhaseDetailsViewState();
}

class _PhaseDetailsViewState extends State<_PhaseDetailsView> {
  final Set<String> _expandedPhases = {};

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phase Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.phases.map((phase) => _PhaseDetailCard(
              phase: phase,
              isExpanded: _expandedPhases.contains(phase.phaseId),
              onExpandToggle: () {
                setState(() {
                  if (_expandedPhases.contains(phase.phaseId)) {
                    _expandedPhases.remove(phase.phaseId);
                  } else {
                    _expandedPhases.add(phase.phaseId);
                  }
                });
              },
            )),
          ],
        ),
      ),
    );
  }
}

class _PhaseDetailCard extends StatelessWidget {
  final PhaseOverviewData phase;
  final bool isExpanded;
  final VoidCallback onExpandToggle;

  const _PhaseDetailCard({
    required this.phase,
    required this.isExpanded,
    required this.onExpandToggle,
  });

  @override
  Widget build(BuildContext context) {
    final phaseName = phase.phaseName
        .split('-')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withAlpha(51)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onExpandToggle,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      phaseName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  _buildPhaseStats(),
                ],
              ),
            ),
          ),
          if (isExpanded) _buildExpandedContent(),
        ],
      ),
    );
  }

  Widget _buildPhaseStats() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (phase.duration != null)
          InfoChip(
            label: 'Duration',
            value: '${phase.duration!.inMilliseconds}ms',
            color: Colors.blue,
          ),
        if (phase.tokenMetadata != null && phase.tokenMetadata!.totalTokens > 0) ...[
          const SizedBox(width: 4),
          InfoChip(
            label: 'Tokens',
            value: '${phase.tokenMetadata!.totalTokens}',
            color: Colors.green,
          ),
        ],
        if (phase.stepCount > 0) ...[
          const SizedBox(width: 4),
          InfoChip(
            label: 'Steps',
            value: '${phase.stepCount}',
            color: Colors.purple,
          ),
        ],
        if (phase.errorCount > 0) ...[
          const SizedBox(width: 4),
          InfoChip(
            label: 'Errors',
            value: '${phase.errorCount}',
            color: Colors.red,
          ),
        ],
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (phase.description != null) ...[
            Text(
              'Description: ${phase.description}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
          ],
          if (phase.tokenMetadata != null) _buildTokenMetadata(),
          if (phase.streamingMetadata != null) _buildStreamingMetadata(),
          if (phase.steps.isNotEmpty) _buildStepsSection(),
          if (phase.logs.isNotEmpty) _buildLogsSection(),
        ],
      ),
    );
  }

  Widget _buildTokenMetadata() {
    final token = phase.tokenMetadata!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Token Usage:',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: [
            if (token.inputTokens != null)
              InfoChip(
                label: 'Input',
                value: '${token.inputTokens}',
                color: Colors.blue,
              ),
            if (token.outputTokens != null)
              InfoChip(
                label: 'Output',
                value: '${token.outputTokens}',
                color: Colors.green,
              ),
            if (token.tokensPerSecond != null)
              InfoChip(
                label: 'Speed',
                value: '${token.tokensPerSecond!.toStringAsFixed(1)}/s',
                color: Colors.orange,
              ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildStreamingMetadata() {
    final streaming = phase.streamingMetadata!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Streaming Performance:',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: [
            InfoChip(
              label: 'Events',
              value: '${streaming.streamEvents}',
              color: Colors.purple,
            ),
            InfoChip(
              label: 'Chunks',
              value: '${streaming.chunksReceived}',
              color: Colors.blue,
            ),
            InfoChip(
              label: 'Avg Chunk',
              value: '${streaming.averageChunkSize}',
              color: Colors.green,
            ),
            if (streaming.timeToFirstChunkMs != null)
              InfoChip(
                label: 'First Chunk',
                value: '${streaming.timeToFirstChunkMs}ms',
                color: Colors.orange,
              ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Steps (${phase.steps.length}):',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        ),
        const SizedBox(height: 4),
        ...phase.steps.map((step) => Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.withAlpha(51)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  step.stepName,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              if (step.duration != null)
                Text(
                  '${step.duration!.inMilliseconds}ms',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        )),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildLogsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Logs (${phase.logs.length}):',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        ),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 150),
          child: SingleChildScrollView(
            child: Column(
              children: phase.logs.map((log) => Container(
                margin: const EdgeInsets.symmetric(vertical: 1),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getLogColor(log.severity).withAlpha(51),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        log.severity.toString().split('.').last.toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          color: _getLogColor(log.severity),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        log.message,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Color _getLogColor(TimelineLogSeverity severity) {
    switch (severity) {
      case TimelineLogSeverity.debug:
        return Colors.grey;
      case TimelineLogSeverity.info:
        return Colors.blue;
      case TimelineLogSeverity.warning:
        return Colors.orange;
      case TimelineLogSeverity.error:
        return Colors.red;
    }
  }
}