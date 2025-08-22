
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kai_engine/src/inspector/kai_inspector.dart';
import 'package:kai_engine/src/inspector/execution_timeline.dart';
import 'debug_data_adapter.dart';
import 'widgets/shared_widgets.dart';

/// Debug screen for analyzing a specific user input message and its processing timeline
/// Shows detailed breakdown of what happened during processing of a single message
class MessageInputDebugScreen extends StatefulWidget {
  final String sessionId;
  final String messageId; // This is both the CoreMessage ID and timeline ID
  final KaiInspector inspector;
  final String? userInput; // Optional: display the original user input

  const MessageInputDebugScreen({
    super.key,
    required this.sessionId,
    required this.messageId,
    required this.inspector,
    this.userInput,
  });

  @override
  State<MessageInputDebugScreen> createState() => _MessageInputDebugScreenState();
}

class _MessageInputDebugScreenState extends State<MessageInputDebugScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  ExecutionTimeline? _timeline;
  TimelineOverviewData? _timelineData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTimelineData();
    _listenToUpdates();
  }

  void _loadTimelineData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final session = await widget.inspector.getSession(widget.sessionId);
      if (session != null) {
        // Find the timeline with the matching message ID
        final timeline = session.timelines.firstWhere(
          (t) => t.id == widget.messageId,
          orElse: () => throw Exception('Timeline not found for message ID: ${widget.messageId}'),
        );

        setState(() {
          _timeline = timeline;
          _timelineData = DebugDataAdapter.convertTimelineOverview(timeline);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Session not found';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _error = 'Failed to load timeline: $error';
        _isLoading = false;
      });
    }
  }

  void _listenToUpdates() {
    widget.inspector.getSessionStream(widget.sessionId).listen(
      (session) {
        if (mounted) {
          try {
            final timeline = session.timelines.firstWhere(
              (t) => t.id == widget.messageId,
            );
            setState(() {
              _timeline = timeline;
              _timelineData = DebugDataAdapter.convertTimelineOverview(timeline);
            });
          } catch (e) {
            // Timeline might not exist yet or might have been removed
            if (_timeline == null) {
              setState(() {
                _error = 'Timeline not found for this message';
              });
            }
          }
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _error = 'Stream error: $error';
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) {
      return Scaffold(
        appBar: AppBar(title: const Text('Debug')),
        body: const Center(
          child: Text('Debug information not available in release mode'),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading Message Debug...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _timeline == null || _timelineData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Message Debug Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Timeline data not available',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadTimelineData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Message: ${widget.messageId.substring(0, 8)}...'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTimelineData,
            tooltip: 'Refresh Timeline',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _exportTimelineData,
            tooltip: 'Export Timeline Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Timeline Overview'),
            Tab(text: 'Phase Details'),
            Tab(text: 'Logs & Metadata'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TimelineOverviewTab(
            timeline: _timeline!,
            timelineData: _timelineData!,
            userInput: widget.userInput,
          ),
          _PhaseDetailsTab(timelineData: _timelineData!),
          _LogsAndMetadataTab(timelineData: _timelineData!),
        ],
      ),
    );
  }

  void _exportTimelineData() {
    if (_timeline == null || _timelineData == null) return;

    final summary = _generateTimelineSummary();
    Clipboard.setData(ClipboardData(text: summary));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Timeline data exported to clipboard')),
    );
  }

  String _generateTimelineSummary() {
    if (_timeline == null || _timelineData == null) {
      return 'Timeline data not available';
    }

    final timeline = _timeline!;
    final data = _timelineData!;

    final buffer = StringBuffer();
    buffer.writeln('=== Message Processing Timeline ===');
    buffer.writeln();
    
    // Basic info
    buffer.writeln('Message ID: ${timeline.id}');
    buffer.writeln('User Input: ${timeline.userMessage}');
    buffer.writeln('Start Time: ${timeline.startTime.toIso8601String()}');
    buffer.writeln('End Time: ${timeline.endTime?.toIso8601String() ?? 'In Progress'}');
    buffer.writeln('Duration: ${data.duration?.inMilliseconds ?? 'N/A'}ms');
    buffer.writeln('Status: ${timeline.status}');
    buffer.writeln();

    // Summary metrics
    buffer.writeln('=== Summary Metrics ===');
    buffer.writeln('Phases: ${data.phaseCount}');
    buffer.writeln('Total Tokens: ${data.totalTokens}');
    buffer.writeln('Errors: ${data.errorCount}');
    buffer.writeln('Warnings: ${data.warningCount}');
    buffer.writeln();

    // Phase breakdown
    buffer.writeln('=== Phase Breakdown ===');
    for (final phase in data.phases) {
      buffer.writeln('${phase.phaseName}:');
      buffer.writeln('  Duration: ${phase.duration?.inMilliseconds ?? 'N/A'}ms');
      buffer.writeln('  Steps: ${phase.stepCount}');
      buffer.writeln('  Logs: ${phase.logCount}');
      if (phase.tokenMetadata != null && phase.tokenMetadata!.totalTokens > 0) {
        final token = phase.tokenMetadata!;
        buffer.writeln('  Tokens: ${token.totalTokens} (${token.inputTokens ?? 0} in, ${token.outputTokens ?? 0} out)');
        if (token.tokensPerSecond != null) {
          buffer.writeln('  Speed: ${token.tokensPerSecond!.toStringAsFixed(1)} tokens/sec');
        }
      }
      if (phase.streamingMetadata != null) {
        final streaming = phase.streamingMetadata!;
        buffer.writeln('  Streaming: ${streaming.chunksReceived} chunks, ${streaming.totalCharacters} chars');
        if (streaming.timeToFirstChunkMs != null) {
          buffer.writeln('  First Chunk: ${streaming.timeToFirstChunkMs}ms');
        }
      }
      if (phase.errorCount > 0 || phase.warningCount > 0) {
        buffer.writeln('  Issues: ${phase.errorCount} errors, ${phase.warningCount} warnings');
      }
      buffer.writeln();
    }

    // Detailed logs
    buffer.writeln('=== Detailed Logs ===');
    for (final phase in data.phases) {
      if (phase.logs.isNotEmpty) {
        buffer.writeln('--- ${phase.phaseName} ---');
        for (final log in phase.logs) {
          buffer.writeln('[${_formatTimestamp(log.timestamp)}] '
                       '[${log.severity.toString().split('.').last.toUpperCase()}] '
                       '${log.message}');
          if (log.metadata.isNotEmpty) {
            for (final entry in log.metadata.entries) {
              buffer.writeln('  ${entry.key}: ${entry.value}');
            }
          }
        }
        buffer.writeln();
      }

      // Step logs
      for (final step in phase.steps) {
        if (step.logs.isNotEmpty) {
          buffer.writeln('--- ${phase.phaseName} / ${step.stepName} ---');
          for (final log in step.logs) {
            buffer.writeln('[${_formatTimestamp(log.timestamp)}] '
                         '[${log.severity.toString().split('.').last.toUpperCase()}] '
                         '${log.message}');
            if (log.metadata.isNotEmpty) {
              for (final entry in log.metadata.entries) {
                buffer.writeln('  ${entry.key}: ${entry.value}');
              }
            }
          }
          buffer.writeln();
        }
      }
    }

    return buffer.toString();
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}:'
           '${timestamp.second.toString().padLeft(2, '0')}'
           '.${timestamp.millisecond.toString().padLeft(3, '0')}';
  }
}

class _TimelineOverviewTab extends StatelessWidget {
  final ExecutionTimeline timeline;
  final TimelineOverviewData timelineData;
  final String? userInput;

  const _TimelineOverviewTab({
    required this.timeline,
    required this.timelineData,
    this.userInput,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MessageHeaderCard(
            timeline: timeline,
            timelineData: timelineData,
            userInput: userInput,
          ),
          const SizedBox(height: 16),
          _TimelineMetricsGrid(timelineData: timelineData),
          const SizedBox(height: 16),
          _PhaseTimelineVisualization(timelineData: timelineData),
        ],
      ),
    );
  }
}

class _MessageHeaderCard extends StatelessWidget {
  final ExecutionTimeline timeline;
  final TimelineOverviewData timelineData;
  final String? userInput;

  const _MessageHeaderCard({
    required this.timeline,
    required this.timelineData,
    this.userInput,
  });

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
                  _getStatusIcon(timeline.status),
                  size: 28,
                  color: _getStatusColor(timeline.status),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Message Processing Timeline',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'ID: ${timeline.id}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Input:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userInput ?? timeline.userMessage,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(dynamic status) {
    switch (status.toString()) {
      case 'TimelineStatus.running':
        return Icons.play_circle;
      case 'TimelineStatus.completed':
        return Icons.check_circle;
      case 'TimelineStatus.failed':
        return Icons.error;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(dynamic status) {
    switch (status.toString()) {
      case 'TimelineStatus.running':
        return Colors.blue;
      case 'TimelineStatus.completed':
        return Colors.green;
      case 'TimelineStatus.failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _TimelineMetricsGrid extends StatelessWidget {
  final TimelineOverviewData timelineData;

  const _TimelineMetricsGrid({required this.timelineData});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _MetricCard(
          title: 'Duration',
          value: timelineData.duration != null
              ? '${timelineData.duration!.inMilliseconds}ms'
              : 'In Progress',
          icon: Icons.timer,
          color: Colors.blue,
        ),
        _MetricCard(
          title: 'Tokens Used',
          value: '${timelineData.totalTokens}',
          icon: Icons.token,
          color: Colors.green,
        ),
        _MetricCard(
          title: 'Phases',
          value: '${timelineData.phaseCount}',
          icon: Icons.timeline,
          color: Colors.purple,
        ),
        _MetricCard(
          title: 'Issues',
          value: '${timelineData.errorCount + timelineData.warningCount}',
          icon: Icons.warning,
          color: timelineData.errorCount > 0 ? Colors.red : Colors.grey,
        ),
      ],
    );
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
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
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

class _PhaseTimelineVisualization extends StatelessWidget {
  final TimelineOverviewData timelineData;

  const _PhaseTimelineVisualization({required this.timelineData});

  @override
  Widget build(BuildContext context) {
    if (timelineData.phases.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No phase data available')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Processing Timeline',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...timelineData.phases.map((phase) => _PhaseTimelineRow(
              phase: phase,
              totalDuration: timelineData.duration?.inMilliseconds ?? 1,
              timelineStart: timelineData.startTime,
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
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
                InfoChip(
                  label: 'Tokens',
                  value: '${phase.tokenMetadata!.totalTokens}',
                  color: Colors.green,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.7 * startPercent,
                  ),
                  width: MediaQuery.of(context).size.width * 0.7 * widthPercent,
                  height: 20,
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
        ],
      ),
    );
  }
}

class _PhaseDetailsTab extends StatelessWidget {
  final TimelineOverviewData timelineData;

  const _PhaseDetailsTab({required this.timelineData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phase Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...timelineData.phases.map((phase) => _PhaseDetailCard(phase: phase)),
        ],
      ),
    );
  }
}

class _PhaseDetailCard extends StatefulWidget {
  final PhaseOverviewData phase;

  const _PhaseDetailCard({required this.phase});

  @override
  State<_PhaseDetailCard> createState() => _PhaseDetailCardState();
}

class _PhaseDetailCardState extends State<_PhaseDetailCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final phaseName = widget.phase.phaseName
        .split('-')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      phaseName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (widget.phase.duration != null)
                    InfoChip(
                      label: 'Duration',
                      value: '${widget.phase.duration!.inMilliseconds}ms',
                      color: Colors.blue,
                    ),
                  if (widget.phase.tokenMetadata != null &&
                      widget.phase.tokenMetadata!.totalTokens > 0) ...[
                    const SizedBox(width: 8),
                    InfoChip(
                      label: 'Tokens',
                      value: '${widget.phase.tokenMetadata!.totalTokens}',
                      color: Colors.green,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.all(16),
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
                  if (widget.phase.description != null) ...[
                    Text('Description: ${widget.phase.description}'),
                    const SizedBox(height: 8),
                  ],
                  if (widget.phase.tokenMetadata != null) ...[
                    const Text(
                      'Token Usage:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    _TokenMetadataDisplay(tokenMetadata: widget.phase.tokenMetadata!),
                    const SizedBox(height: 12),
                  ],
                  if (widget.phase.streamingMetadata != null) ...[
                    const Text(
                      'Streaming Performance:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    _StreamingMetadataDisplay(streamingMetadata: widget.phase.streamingMetadata!),
                    const SizedBox(height: 12),
                  ],
                  if (widget.phase.steps.isNotEmpty) ...[
                    Text(
                      'Steps (${widget.phase.steps.length}):',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    ...widget.phase.steps.map((step) => _StepDisplay(step: step)),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TokenMetadataDisplay extends StatelessWidget {
  final TokenMetadata tokenMetadata;

  const _TokenMetadataDisplay({required this.tokenMetadata});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        InfoChip(
          label: 'Total',
          value: '${tokenMetadata.totalTokens}',
          color: Colors.green,
        ),
        if (tokenMetadata.inputTokens != null)
          InfoChip(
            label: 'Input',
            value: '${tokenMetadata.inputTokens}',
            color: Colors.blue,
          ),
        if (tokenMetadata.outputTokens != null)
          InfoChip(
            label: 'Output',
            value: '${tokenMetadata.outputTokens}',
            color: Colors.purple,
          ),
        if (tokenMetadata.tokensPerSecond != null)
          InfoChip(
            label: 'Speed',
            value: '${tokenMetadata.tokensPerSecond!.toStringAsFixed(1)}/s',
            color: Colors.orange,
          ),
      ],
    );
  }
}

class _StreamingMetadataDisplay extends StatelessWidget {
  final StreamingMetadata streamingMetadata;

  const _StreamingMetadataDisplay({required this.streamingMetadata});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        InfoChip(
          label: 'Events',
          value: '${streamingMetadata.streamEvents}',
          color: Colors.purple,
        ),
        InfoChip(
          label: 'Chunks',
          value: '${streamingMetadata.chunksReceived}',
          color: Colors.blue,
        ),
        InfoChip(
          label: 'Avg Chunk',
          value: '${streamingMetadata.averageChunkSize}',
          color: Colors.green,
        ),
        if (streamingMetadata.timeToFirstChunkMs != null)
          InfoChip(
            label: 'First Chunk',
            value: '${streamingMetadata.timeToFirstChunkMs}ms',
            color: Colors.orange,
          ),
      ],
    );
  }
}

class _StepDisplay extends StatelessWidget {
  final StepOverviewData step;

  const _StepDisplay({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              step.stepName,
              style: const TextStyle(fontSize: 12),
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
    );
  }
}

class _LogsAndMetadataTab extends StatelessWidget {
  final TimelineOverviewData timelineData;

  const _LogsAndMetadataTab({required this.timelineData});

  @override
  Widget build(BuildContext context) {
    final allLogs = <LogEntryData>[];
    
    // Collect all logs from phases and steps
    for (final phase in timelineData.phases) {
      allLogs.addAll(phase.logs);
      for (final step in phase.steps) {
        allLogs.addAll(step.logs);
      }
    }
    
    // Sort by timestamp
    allLogs.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline Logs (${allLogs.length})',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (allLogs.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No logs available'),
              ),
            )
          else
            ...allLogs.map((log) => _LogEntryCard(log: log)),
        ],
      ),
    );
  }
}

class _LogEntryCard extends StatelessWidget {
  final LogEntryData log;

  const _LogEntryCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(log.severity);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: severityColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    log.severity.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: severityColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTimestamp(log.timestamp),
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              log.message,
              style: const TextStyle(fontSize: 13),
            ),
            if (log.metadata.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: log.metadata.entries.map((entry) => 
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              '${entry.key}:',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value.toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(dynamic severity) {
    switch (severity.toString()) {
      case 'TimelineLogSeverity.debug':
        return Colors.grey;
      case 'TimelineLogSeverity.info':
        return Colors.blue;
      case 'TimelineLogSeverity.warning':
        return Colors.orange;
      case 'TimelineLogSeverity.error':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}:'
           '${timestamp.second.toString().padLeft(2, '0')}'
           '.${timestamp.millisecond.toString().padLeft(3, '0')}';
  }
}