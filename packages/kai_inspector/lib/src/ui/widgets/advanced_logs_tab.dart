import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kai_engine/src/inspector/models/timeline_session.dart';
import 'package:kai_engine/src/inspector/models/timeline_types.dart';
import '../debug_data_adapter.dart';

/// Advanced logging interface with filtering, search, and export capabilities
class AdvancedLogsTab extends StatefulWidget {
  final TimelineSession session;
  final SessionOverviewData sessionOverview;

  const AdvancedLogsTab({
    super.key,
    required this.session,
    required this.sessionOverview,
  });

  @override
  State<AdvancedLogsTab> createState() => _AdvancedLogsTabState();
}

class _AdvancedLogsTabState extends State<AdvancedLogsTab> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Set<TimelineLogSeverity> _selectedSeverities = TimelineLogSeverity.values.toSet();
  Set<String> _selectedPhases = <String>{};
  Set<String> _selectedTimelines = <String>{};
  String _searchQuery = '';
  bool _autoScroll = true;
  List<LogEntryWithContext> _allLogs = [];
  List<LogEntryWithContext> _filteredLogs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadLogs() {
    final logs = <LogEntryWithContext>[];
    
    for (final timeline in widget.session.timelines) {
      final timelineData = DebugDataAdapter.convertTimelineOverview(timeline);
      
      for (final phase in timelineData.phases) {
        for (final log in phase.logs) {
          logs.add(LogEntryWithContext(
            log: log,
            timelineId: timeline.id,
            timelineName: timeline.userMessage.length > 50
                ? '${timeline.userMessage.substring(0, 50)}...'
                : timeline.userMessage,
            phaseId: phase.phaseId,
            phaseName: phase.phaseName,
          ));
        }
        
        for (final step in phase.steps) {
          for (final log in step.logs) {
            logs.add(LogEntryWithContext(
              log: log,
              timelineId: timeline.id,
              timelineName: timeline.userMessage.length > 50
                  ? '${timeline.userMessage.substring(0, 50)}...'
                  : timeline.userMessage,
              phaseId: phase.phaseId,
              phaseName: phase.phaseName,
              stepId: step.stepId,
              stepName: step.stepName,
            ));
          }
        }
      }
    }

    logs.sort((a, b) => a.log.timestamp.compareTo(b.log.timestamp));

    setState(() {
      _allLogs = logs;
      _selectedPhases = logs.map((e) => e.phaseName).toSet();
      _selectedTimelines = logs.map((e) => e.timelineId).toSet();
      _applyFilters();
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredLogs = _allLogs.where((logEntry) {
      // Severity filter
      if (!_selectedSeverities.contains(logEntry.log.severity)) {
        return false;
      }

      // Phase filter
      if (!_selectedPhases.contains(logEntry.phaseName)) {
        return false;
      }

      // Timeline filter
      if (!_selectedTimelines.contains(logEntry.timelineId)) {
        return false;
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return logEntry.log.message.toLowerCase().contains(query) ||
               logEntry.phaseName.toLowerCase().contains(query) ||
               (logEntry.stepName?.toLowerCase().contains(query) ?? false);
      }

      return true;
    }).toList();

    if (_autoScroll && _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LogsControlPanel(
          searchController: _searchController,
          selectedSeverities: _selectedSeverities,
          selectedPhases: _selectedPhases,
          selectedTimelines: _selectedTimelines,
          autoScroll: _autoScroll,
          totalLogs: _allLogs.length,
          filteredLogs: _filteredLogs.length,
          onSeverityChanged: (severity, selected) {
            setState(() {
              if (selected) {
                _selectedSeverities.add(severity);
              } else {
                _selectedSeverities.remove(severity);
              }
              _applyFilters();
            });
          },
          onPhaseChanged: (phase, selected) {
            setState(() {
              if (selected) {
                _selectedPhases.add(phase);
              } else {
                _selectedPhases.remove(phase);
              }
              _applyFilters();
            });
          },
          onTimelineChanged: (timeline, selected) {
            setState(() {
              if (selected) {
                _selectedTimelines.add(timeline);
              } else {
                _selectedTimelines.remove(timeline);
              }
              _applyFilters();
            });
          },
          onAutoScrollChanged: (value) {
            setState(() {
              _autoScroll = value;
            });
          },
          onClearFilters: () {
            setState(() {
              _selectedSeverities = TimelineLogSeverity.values.toSet();
              _selectedPhases = _allLogs.map((e) => e.phaseName).toSet();
              _selectedTimelines = _allLogs.map((e) => e.timelineId).toSet();
              _searchController.clear();
              _applyFilters();
            });
          },
          onExportLogs: _exportLogs,
        ),
        const Divider(height: 1),
        Expanded(
          child: _LogsListView(
            logs: _filteredLogs,
            scrollController: _scrollController,
            session: widget.session,
          ),
        ),
      ],
    );
  }

  void _exportLogs() {
    final buffer = StringBuffer();
    buffer.writeln('=== Kai Engine Session Logs Export ===');
    buffer.writeln('Session ID: ${widget.session.id}');
    buffer.writeln('Export Time: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Total Logs: ${_filteredLogs.length}');
    buffer.writeln();

    for (final logEntry in _filteredLogs) {
      buffer.writeln('[${_formatTimestamp(logEntry.log.timestamp)}] '
                   '[${logEntry.log.severity.toString().split('.').last.toUpperCase()}] '
                   '[${logEntry.phaseName}${logEntry.stepName != null ? '/${logEntry.stepName}' : ''}] '
                   '${logEntry.log.message}');
      
      if (logEntry.log.metadata.isNotEmpty) {
        for (final entry in logEntry.log.metadata.entries) {
          buffer.writeln('  ${entry.key}: ${entry.value}');
        }
      }
      buffer.writeln();
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logs exported to clipboard')),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}:'
           '${timestamp.second.toString().padLeft(2, '0')}'
           '.${timestamp.millisecond.toString().padLeft(3, '0')}';
  }
}

class _LogsControlPanel extends StatelessWidget {
  final TextEditingController searchController;
  final Set<TimelineLogSeverity> selectedSeverities;
  final Set<String> selectedPhases;
  final Set<String> selectedTimelines;
  final bool autoScroll;
  final int totalLogs;
  final int filteredLogs;
  final Function(TimelineLogSeverity, bool) onSeverityChanged;
  final Function(String, bool) onPhaseChanged;
  final Function(String, bool) onTimelineChanged;
  final Function(bool) onAutoScrollChanged;
  final VoidCallback onClearFilters;
  final VoidCallback onExportLogs;

  const _LogsControlPanel({
    required this.searchController,
    required this.selectedSeverities,
    required this.selectedPhases,
    required this.selectedTimelines,
    required this.autoScroll,
    required this.totalLogs,
    required this.filteredLogs,
    required this.onSeverityChanged,
    required this.onPhaseChanged,
    required this.onTimelineChanged,
    required this.onAutoScrollChanged,
    required this.onClearFilters,
    required this.onExportLogs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search logs...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$filteredLogs / $totalLogs logs',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.clear_all),
                onPressed: onClearFilters,
                tooltip: 'Clear Filters',
              ),
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: onExportLogs,
                tooltip: 'Export Logs',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Severity:',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 4,
                  children: TimelineLogSeverity.values.map((severity) {
                    final isSelected = selectedSeverities.contains(severity);
                    return FilterChip(
                      label: Text(
                        severity.toString().split('.').last.toUpperCase(),
                        style: const TextStyle(fontSize: 11),
                      ),
                      selected: isSelected,
                      onSelected: (selected) => onSeverityChanged(severity, selected),
                      backgroundColor: _getSeverityColor(severity).withAlpha(26),
                      selectedColor: _getSeverityColor(severity).withAlpha(77),
                    );
                  }).toList(),
                ),
              ),
              Switch(
                value: autoScroll,
                onChanged: onAutoScrollChanged,
              ),
              const Text('Auto Scroll', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  'Phases:',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(width: 8),
                ...selectedPhases.take(10).map((phase) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: FilterChip(
                      label: Text(
                        _formatPhaseName(phase),
                        style: const TextStyle(fontSize: 10),
                      ),
                      selected: true,
                      onSelected: (selected) => onPhaseChanged(phase, selected),
                    ),
                  );
                }),
                if (selectedPhases.length > 10)
                  Text(
                    '... +${selectedPhases.length - 10} more',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(TimelineLogSeverity severity) {
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

  String _formatPhaseName(String phaseName) {
    return phaseName
        .split('-')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

class _LogsListView extends StatelessWidget {
  final List<LogEntryWithContext> logs;
  final ScrollController scrollController;
  final TimelineSession session;

  const _LogsListView({
    required this.logs,
    required this.scrollController,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No logs match the current filters',
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
      controller: scrollController,
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final logEntry = logs[index];
        final isFirstOfTimeline = index == 0 ||
            logs[index - 1].timelineId != logEntry.timelineId;

        return Column(
          children: [
            if (isFirstOfTimeline) _TimelineSeparator(logEntry: logEntry),
            _LogEntryItem(logEntry: logEntry),
          ],
        );
      },
    );
  }
}

class _TimelineSeparator extends StatelessWidget {
  final LogEntryWithContext logEntry;

  const _TimelineSeparator({required this.logEntry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.withAlpha(26),
      child: Row(
        children: [
          Icon(
            Icons.timeline,
            size: 16,
            color: Colors.blue[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Timeline: ${logEntry.timelineName}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogEntryItem extends StatefulWidget {
  final LogEntryWithContext logEntry;

  const _LogEntryItem({required this.logEntry});

  @override
  State<_LogEntryItem> createState() => _LogEntryItemState();
}

class _LogEntryItemState extends State<_LogEntryItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final log = widget.logEntry.log;
    final hasMetadata = log.metadata.isNotEmpty;
    final severityColor = _getSeverityColor(log.severity);

    return InkWell(
      onTap: hasMetadata ? () => setState(() => _isExpanded = !_isExpanded) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: severityColor,
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: severityColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTimestamp(log.timestamp),
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    _formatPhaseName(widget.logEntry.phaseName),
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.grey,
                    ),
                  ),
                ),
                if (widget.logEntry.stepName != null) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      widget.logEntry.stepName!,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (hasMetadata)
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: Colors.grey,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              log.message,
              style: const TextStyle(fontSize: 13),
            ),
            if (_isExpanded && hasMetadata) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metadata:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...log.metadata.entries.map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
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
                    )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(TimelineLogSeverity severity) {
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

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}:'
           '${timestamp.second.toString().padLeft(2, '0')}'
           '.${timestamp.millisecond.toString().padLeft(3, '0')}';
  }

  String _formatPhaseName(String phaseName) {
    return phaseName
        .split('-')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

class LogEntryWithContext {
  final LogEntryData log;
  final String timelineId;
  final String timelineName;
  final String phaseId;
  final String phaseName;
  final String? stepId;
  final String? stepName;

  const LogEntryWithContext({
    required this.log,
    required this.timelineId,
    required this.timelineName,
    required this.phaseId,
    required this.phaseName,
    this.stepId,
    this.stepName,
  });
}