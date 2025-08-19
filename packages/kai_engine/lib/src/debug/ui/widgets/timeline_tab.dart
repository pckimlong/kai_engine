import 'package:flutter/material.dart';

import '../../debug_system.dart';
import 'shared_widgets.dart';

class TimelineTab extends StatelessWidget {
  final MessageDebugInfo debugInfo;

  const TimelineTab({super.key, required this.debugInfo});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OverviewCard(debugInfo: debugInfo),
          const SizedBox(height: 16),
          _TimelineVisualization(debugInfo: debugInfo),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final MessageDebugInfo debugInfo;

  const _OverviewCard({required this.debugInfo});

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
                  debugInfo.hasError
                      ? Icons.error
                      : debugInfo.isComplete
                          ? Icons.check_circle
                          : Icons.hourglass_empty,
                  color: debugInfo.hasError
                      ? Colors.red
                      : debugInfo.isComplete
                          ? Colors.green
                          : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    debugInfo.originalInput,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                InfoChip(
                  label: 'Status',
                  value: debugInfo.hasError
                      ? 'Error'
                      : debugInfo.isComplete
                          ? 'Complete'
                          : 'In Progress',
                  color: debugInfo.hasError
                      ? Colors.red
                      : debugInfo.isComplete
                          ? Colors.green
                          : Colors.orange,
                ),
                if (debugInfo.totalDuration != null)
                  InfoChip(
                    label: 'Total Time',
                    value: '${debugInfo.totalDuration!.inMilliseconds}ms',
                    color: Colors.blue,
                  ),
                InfoChip(
                  label: 'Phases',
                  value: '${debugInfo.phases.length}',
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineVisualization extends StatelessWidget {
  final MessageDebugInfo debugInfo;

  const _TimelineVisualization({required this.debugInfo});

  @override
  Widget build(BuildContext context) {
    final phases = debugInfo.phases.values.toList();
    phases.sort((a, b) => a.startTime.compareTo(b.startTime));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Execution Timeline', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (phases.isEmpty)
              const Center(child: Text('No phase information available'))
            else
              _TimelineChart(debugInfo: debugInfo, phases: phases),
          ],
        ),
      ),
    );
  }
}

class _TimelineChart extends StatelessWidget {
  final MessageDebugInfo debugInfo;
  final List<DebugPhase> phases;

  const _TimelineChart({required this.debugInfo, required this.phases});

  @override
  Widget build(BuildContext context) {
    final totalDuration = debugInfo.totalDuration?.inMilliseconds ??
        phases.last.startTime.difference(phases.first.startTime).inMilliseconds;

    final mainPhases = <String, List<DebugPhase>>{};
    final subPhases = <String, List<DebugPhase>>{};

    for (final phase in phases) {
      if (_isMainPhase(phase.name)) {
        mainPhases[phase.name] = [phase];
      } else {
        final parentPhase = _getParentPhase(phase.name);
        if (parentPhase != null) {
          subPhases.putIfAbsent(parentPhase, () => []).add(phase);
        } else {
          mainPhases[phase.name] = [phase];
        }
      }
    }

    return Column(
      children: phases.where((phase) => _isMainPhase(phase.name)).map((mainPhase) {
        final subPhasesForMain = subPhases[mainPhase.name] ?? [];
        final hasSubPhases = subPhasesForMain.isNotEmpty;

        return _PhaseGroup(
          mainPhase: mainPhase,
          subPhases: subPhasesForMain,
          totalDuration: totalDuration,
          hasSubPhases: hasSubPhases,
          debugInfo: debugInfo,
        );
      }).toList(),
    );
  }

  bool _isMainPhase(String phaseName) {
    return phaseName == 'query-processing' ||
        phaseName == 'context-building' ||
        phaseName == 'context-engine-processing' ||
        phaseName == 'ai-generation' ||
        phaseName == 'post-response-processing';
  }

  String? _getParentPhase(String phaseName) {
    if (phaseName.startsWith('parallel-') || phaseName.startsWith('sequential-')) {
      return 'context-building';
    }
    if (phaseName.startsWith('par-') || phaseName.startsWith('seq-')) {
      return 'context-engine-processing';
    }
    if (phaseName.startsWith('post-response-')) {
      return 'post-response-processing';
    }
    return null;
  }
}

class _PhaseGroup extends StatelessWidget {
  final DebugPhase mainPhase;
  final List<DebugPhase> subPhases;
  final int totalDuration;
  final bool hasSubPhases;
  final MessageDebugInfo debugInfo;

  const _PhaseGroup({
    required this.mainPhase,
    required this.subPhases,
    required this.totalDuration,
    required this.hasSubPhases,
    required this.debugInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: hasSubPhases
          ? ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(left: 16),
              title: _PhaseRow(
                phase: mainPhase,
                totalDuration: totalDuration,
                isMainPhase: true,
                debugInfo: debugInfo,
              ),
              children: subPhases
                  .map(
                    (subPhase) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: _PhaseRow(
                        phase: subPhase,
                        totalDuration: totalDuration,
                        isMainPhase: false,
                        debugInfo: debugInfo,
                      ),
                    ),
                  )
                  .toList(),
            )
          : _PhaseRow(
              phase: mainPhase,
              totalDuration: totalDuration,
              isMainPhase: true,
              debugInfo: debugInfo,
            ),
    );
  }
}

class _PhaseRow extends StatelessWidget {
  final DebugPhase phase;
  final int totalDuration;
  final bool isMainPhase;
  final MessageDebugInfo debugInfo;

  const _PhaseRow({
    required this.phase,
    required this.totalDuration,
    required this.isMainPhase,
    required this.debugInfo,
  });

  @override
  Widget build(BuildContext context) {
    final startOffset = phase.startTime.difference(debugInfo.startTime).inMilliseconds;
    final phaseDuration = phase.duration?.inMilliseconds ?? 0;
    final startPercent = totalDuration > 0 ? (startOffset / totalDuration) : 0.0;
    final widthPercent = totalDuration > 0 ? (phaseDuration / totalDuration) : 0.1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: isMainPhase ? 120 : 100,
              child: Text(
                _formatPhaseName(phase.name),
                style: TextStyle(
                  fontWeight: isMainPhase ? FontWeight.w600 : FontWeight.w400,
                  fontSize: isMainPhase ? 14 : 13,
                  color: isMainPhase ? null : Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              phase.duration != null ? '${phase.duration!.inMilliseconds}ms' : 'In Progress...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isMainPhase ? 12 : 11,
                fontWeight: isMainPhase ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            if (!isMainPhase && phase.metadata.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                _formatMetadata(phase.metadata),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: isMainPhase ? 24 : 16,
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
                height: isMainPhase ? 24 : 16,
                decoration: BoxDecoration(
                  color: getPhaseColor(phase.name).withAlpha((255 * (isMainPhase ? 1.0 : 0.7)).round()),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    phase.duration != null ? '${phase.duration!.inMilliseconds}ms' : '...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMainPhase ? 10 : 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatPhaseName(String phaseName) {
    if (phaseName.startsWith('parallel-')) {
      return phaseName.replaceFirst('parallel-', '↻ ');
    }
    if (phaseName.startsWith('sequential-')) {
      return phaseName.replaceFirst('sequential-', '→ ');
    }
    if (phaseName.startsWith('par-')) {
      return phaseName.replaceFirst('par-', '↻ ');
    }
    if (phaseName.startsWith('seq-')) {
      return phaseName.replaceFirst('seq-', '→ ');
    }
    if (phaseName.startsWith('post-response-')) {
      return phaseName.replaceFirst('post-response-', '⚡ ');
    }

    return phaseName
        .split('-')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatMetadata(Map<String, dynamic> metadata) {
    final items = <String>[];

    if (metadata.containsKey('result-count')) {
      items.add('${metadata['result-count']} msgs');
    }
    if (metadata.containsKey('messages')) {
      items.add('${metadata['messages']} msgs');
    }
    if (metadata.containsKey('context-size')) {
      items.add('ctx:${metadata['context-size']}');
    }

    return items.join(', ');
  }
}
