import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../debug_system.dart';
import 'shared_widgets.dart';

class PostResponseTab extends StatelessWidget {
  final MessageDebugInfo debugInfo;

  const PostResponseTab({super.key, required this.debugInfo});

  @override
  Widget build(BuildContext context) {
    final steps = debugInfo.orderedPostResponseSteps;
    final postResponsePhases = _getPostResponsePhases();

    // Show empty state only if no phases AND no steps
    if (steps.isEmpty && postResponsePhases.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings_applications, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Post-Response Processing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Post-response phases and steps will appear here when they are executed',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostResponseOverview(steps: steps, phases: postResponsePhases),
          const SizedBox(height: 16),

          // Show phase information if available
          if (postResponsePhases.isNotEmpty) ...[
            // _PostResponsePhasesList(phases: postResponsePhases),
            if (steps.isNotEmpty) const SizedBox(height: 16),
          ],

          // Show detailed steps if available
          if (steps.isNotEmpty) _PostResponseStepsList(steps: steps),
        ],
      ),
    );
  }

  List<DebugPhase> _getPostResponsePhases() {
    return debugInfo.phases.values
        .where((phase) => phase.name.startsWith('post-response-'))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }
}

class _PostResponseOverview extends StatelessWidget {
  final List<PostResponseStep> steps;
  final List<DebugPhase> phases;

  const _PostResponseOverview({required this.steps, required this.phases});

  @override
  Widget build(BuildContext context) {
    final totalSteps = steps.length;
    final completedSteps = steps.where((s) => s.isComplete).length;
    final failedSteps = steps.where((s) => s.hasError).length;
    final runningSteps = steps.where((s) => !s.isComplete && !s.hasError).length;

    final totalPhases = phases.length;
    final completedPhases = phases.where((p) => p.isComplete).length;
    final phaseDuration = _calculatePhaseDuration();

    final totalDuration = _calculateTotalDuration();
    final averageDuration = totalSteps > 0 ? totalDuration / totalSteps : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings_applications, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  'Post-Response Processing Overview',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _exportStepsData(context),
                  tooltip: 'Export Steps Data',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (totalPhases > 0) ...[
                  InfoChip(label: 'Engines', value: '$totalPhases', color: Colors.deepPurple),
                  if (phaseDuration > 0)
                    InfoChip(
                      label: 'Engine Time',
                      value: '${phaseDuration.toInt()}ms',
                      color: Colors.purple,
                    ),
                ],
                if (totalSteps > 0) ...[
                  InfoChip(label: 'Total Steps', value: '$totalSteps', color: Colors.blue),
                  InfoChip(label: 'Completed', value: '$completedSteps', color: Colors.green),
                  if (failedSteps > 0)
                    InfoChip(label: 'Failed', value: '$failedSteps', color: Colors.red),
                  if (runningSteps > 0)
                    InfoChip(label: 'Running', value: '$runningSteps', color: Colors.orange),
                  if (totalDuration > 0)
                    InfoChip(
                      label: 'Step Time',
                      value: '${totalDuration.toInt()}ms',
                      color: Colors.cyan,
                    ),
                  if (averageDuration > 0)
                    InfoChip(
                      label: 'Avg Step',
                      value: '${averageDuration.toInt()}ms',
                      color: Colors.indigo,
                    ),
                ],
              ],
            ),
            if (totalSteps > 1) ...[
              const SizedBox(height: 16),
              _ProgressBar(
                total: totalSteps,
                completed: completedSteps,
                failed: failedSteps,
                running: runningSteps,
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _calculateTotalDuration() {
    return steps
        .map((s) => s.duration?.inMilliseconds.toDouble() ?? 0.0)
        .fold(0.0, (a, b) => a + b);
  }

  double _calculatePhaseDuration() {
    return phases
        .map((p) => p.duration?.inMilliseconds.toDouble() ?? 0.0)
        .fold(0.0, (a, b) => a + b);
  }

  void _exportStepsData(BuildContext context) {
    final stepsData = {
      'postResponseSteps': steps
          .map(
            (step) => {
              'name': step.name,
              'description': step.description,
              'startTime': step.startTime.toIso8601String(),
              'endTime': step.endTime?.toIso8601String(),
              'duration': step.duration?.inMilliseconds,
              'isComplete': step.isComplete,
              'hasError': step.hasError,
              'status': step.status,
              'result': step.result,
              'metadata': step.metadata,
              'logs': step.logs
                  .map(
                    (log) => {
                      'timestamp': log.timestamp.toIso8601String(),
                      'level': log.level,
                      'message': log.message,
                      'data': log.data,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(stepsData);
    Clipboard.setData(ClipboardData(text: jsonString));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Post-response steps data copied to clipboard')));
  }
}

class _ProgressBar extends StatelessWidget {
  final int total;
  final int completed;
  final int failed;
  final int running;

  const _ProgressBar({
    required this.total,
    required this.completed,
    required this.failed,
    required this.running,
  });

  @override
  Widget build(BuildContext context) {
    final pending = total - completed - failed - running;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Progress', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey[300],
          ),
          child: Row(
            children: [
              if (completed > 0)
                Expanded(
                  flex: completed,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
              if (running > 0)
                Expanded(
                  flex: running,
                  child: Container(color: Colors.orange),
                ),
              if (failed > 0)
                Expanded(
                  flex: failed,
                  child: Container(color: Colors.red),
                ),
              if (pending > 0)
                Expanded(
                  flex: pending,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _ProgressLegendItem(color: Colors.green, label: 'Completed ($completed)'),
            const SizedBox(width: 16),
            if (running > 0) ...[
              _ProgressLegendItem(color: Colors.orange, label: 'Running ($running)'),
              const SizedBox(width: 16),
            ],
            if (failed > 0) ...[
              _ProgressLegendItem(color: Colors.red, label: 'Failed ($failed)'),
              const SizedBox(width: 16),
            ],
            if (pending > 0) _ProgressLegendItem(color: Colors.grey, label: 'Pending ($pending)'),
          ],
        ),
      ],
    );
  }
}

class _ProgressLegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _ProgressLegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _PostResponseStepsList extends StatelessWidget {
  final List<PostResponseStep> steps;

  const _PostResponseStepsList({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Processing Steps', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ...steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isLast = index == steps.length - 1;

              return _StepCard(step: step, stepNumber: index + 1, isLast: isLast);
            }),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatefulWidget {
  final PostResponseStep step;
  final int stepNumber;
  final bool isLast;

  const _StepCard({required this.step, required this.stepNumber, required this.isLast});

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final statusColor = _getStatusColor(step);
    final statusIcon = _getStatusIcon(step);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Step number and connector
                      Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(51),
                              shape: BoxShape.circle,
                              border: Border.all(color: statusColor, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '${widget.stepNumber}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          if (!widget.isLast)
                            Container(
                              width: 2,
                              height: 20,
                              color: Colors.grey[300],
                              margin: const EdgeInsets.only(top: 4),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Step content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(statusIcon, size: 16, color: statusColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    step.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                if (step.duration != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: statusColor.withAlpha(51),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${step.duration!.inMilliseconds}ms',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (step.description != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                step.description!,
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _StatusChip(step: step),
                                const SizedBox(width: 8),
                                if (step.logs.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withAlpha(51),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${step.logs.length} logs',
                                      style: const TextStyle(fontSize: 11, color: Colors.blue),
                                    ),
                                  ),
                                const Spacer(),
                                if (step.logs.isNotEmpty)
                                  Icon(
                                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                                    color: Colors.grey[600],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded content
              if (_isExpanded) ...[const Divider(height: 1), _ExpandedStepContent(step: step)],
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(PostResponseStep step) {
    if (step.hasError) return Colors.red;
    if (step.isComplete) return Colors.green;
    return Colors.orange;
  }

  IconData _getStatusIcon(PostResponseStep step) {
    if (step.hasError) return Icons.error;
    if (step.isComplete) return Icons.check_circle;
    return Icons.pending;
  }
}

class _StatusChip extends StatelessWidget {
  final PostResponseStep step;

  const _StatusChip({required this.step});

  @override
  Widget build(BuildContext context) {
    final status =
        step.status ??
        (step.hasError
            ? 'failed'
            : step.isComplete
            ? 'completed'
            : 'running');
    final color = step.hasError
        ? Colors.red
        : step.isComplete
        ? Colors.green
        : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withAlpha(51), borderRadius: BorderRadius.circular(8)),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

class _ExpandedStepContent extends StatefulWidget {
  final PostResponseStep step;

  const _ExpandedStepContent({required this.step});

  @override
  State<_ExpandedStepContent> createState() => _ExpandedStepContentState();
}

class _ExpandedStepContentState extends State<_ExpandedStepContent> {
  String _selectedLogLevel = 'all';

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final filteredLogs = _getFilteredLogs();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timing information
          ...[
            _InfoSection(
              title: 'Timing',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: 'Started', value: _formatTime(step.startTime)),
                  if (step.endTime != null)
                    _InfoRow(label: 'Ended', value: _formatTime(step.endTime!)),
                  if (step.duration != null)
                    _InfoRow(label: 'Duration', value: '${step.duration!.inMilliseconds}ms'),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Result data
          if (step.result != null) ...[
            _InfoSection(
              title: 'Result Data',
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  const JsonEncoder.withIndent('  ').convert(step.result),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Error information
          if (step.hasError) ...[
            _InfoSection(
              title: 'Error Details',
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.error.toString(),
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                    ),
                    if (step.errorDetails != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        step.errorDetails!,
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Logs section
          if (step.logs.isNotEmpty) ...[
            _InfoSection(
              title: 'Logs',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Log level filter
                  Row(
                    children: [
                      const Text('Filter: ', style: TextStyle(fontSize: 12)),
                      ...['all', 'error', 'warning', 'info', 'debug'].map(
                        (level) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(level, style: const TextStyle(fontSize: 10)),
                            selected: _selectedLogLevel == level,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedLogLevel = level);
                              }
                            },
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: SingleChildScrollView(
                      child: Column(
                        children: filteredLogs.map((log) => _LogEntry(log: log)).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<PostResponseLog> _getFilteredLogs() {
    if (_selectedLogLevel == 'all') {
      return widget.step.logs;
    }
    return widget.step.logs.where((log) => log.level == _selectedLogLevel).toList();
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}'
        '.${time.millisecond.toString().padLeft(3, '0')}';
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }
}

class _LogEntry extends StatelessWidget {
  final PostResponseLog log;

  const _LogEntry({required this.log});

  @override
  Widget build(BuildContext context) {
    final levelColor = _getLevelColor(log.level);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: levelColor.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: levelColor.withAlpha(76),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              log.level.substring(0, 1).toUpperCase(),
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: levelColor),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _formatTime(log.timestamp),
            style: TextStyle(fontSize: 10, color: Colors.grey[600], fontFamily: 'monospace'),
          ),
          const SizedBox(width: 6),
          Expanded(child: Text(log.message, style: const TextStyle(fontSize: 11))),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      case 'debug':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}'
        '.${time.millisecond.toString().padLeft(3, '0')}';
  }
}
