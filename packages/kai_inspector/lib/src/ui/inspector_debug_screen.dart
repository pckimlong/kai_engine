import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kai_engine/src/inspector/kai_inspector.dart';
import 'package:kai_engine/src/inspector/models/timeline_session.dart';
import 'debug_data_adapter.dart';
import 'session_metrics_calculator.dart';
import 'widgets/session_dashboard_tab.dart';
import 'widgets/enhanced_timeline_tab.dart';
import 'widgets/token_analytics_tab.dart';
import 'widgets/advanced_logs_tab.dart';

/// Comprehensive debug screen using the new inspector system
/// Replaces the old MessageDebugScreen with session-based debugging
class InspectorDebugScreen extends StatefulWidget {
  final String sessionId;
  final KaiInspector inspector;

  const InspectorDebugScreen({
    super.key,
    required this.sessionId,
    required this.inspector,
  });

  @override
  State<InspectorDebugScreen> createState() => _InspectorDebugScreenState();
}

class _InspectorDebugScreenState extends State<InspectorDebugScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  TimelineSession? _session;
  SessionOverviewData? _sessionOverview;
  SessionMetrics? _sessionMetrics;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSessionData();
    _listenToSessionUpdates();
  }

  void _loadSessionData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final session = await widget.inspector.getSession(widget.sessionId);
      if (session != null) {
        setState(() {
          _session = session;
          _sessionOverview = DebugDataAdapter.convertSessionOverview(session);
          _sessionMetrics = SessionMetricsCalculator.calculateSessionMetrics(session);
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
        _error = 'Failed to load session: $error';
        _isLoading = false;
      });
    }
  }

  void _listenToSessionUpdates() {
    widget.inspector.getSessionStream(widget.sessionId).listen(
      (session) {
        if (mounted) {
          setState(() {
            _session = session;
            _sessionOverview = DebugDataAdapter.convertSessionOverview(session);
            _sessionMetrics = SessionMetricsCalculator.calculateSessionMetrics(session);
          });
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
        appBar: AppBar(title: const Text('Loading Debug Session...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _session == null || _sessionOverview == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Debug Session Error')),
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
                _error ?? 'Session data not available',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadSessionData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Session'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessionData,
            tooltip: 'Refresh Session',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _exportSessionData,
            tooltip: 'Export Session Data',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_json',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export as JSON'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_summary',
                child: Row(
                  children: [
                    Icon(Icons.summarize),
                    SizedBox(width: 8),
                    Text('Export Summary'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Session Dashboard'),
            Tab(text: 'Timeline Analysis'),
            Tab(text: 'Token Analytics'),
            Tab(text: 'Logs & Events'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SessionDashboardTab(
            session: _session!,
            sessionOverview: _sessionOverview!,
            sessionMetrics: _sessionMetrics!,
          ),
          EnhancedTimelineTab(
            session: _session!,
            sessionOverview: _sessionOverview!,
          ),
          TokenAnalyticsTab(
            session: _session!,
            sessionMetrics: _sessionMetrics!,
          ),
          AdvancedLogsTab(
            session: _session!,
            sessionOverview: _sessionOverview!,
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export_json':
        _exportFullSessionJson();
        break;
      case 'export_summary':
        _exportSessionSummary();
        break;
    }
  }

  void _exportSessionData() {
    if (_session == null || _sessionOverview == null) return;

    final summary = _generateSessionSummary();
    Clipboard.setData(ClipboardData(text: summary));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session summary exported to clipboard')),
    );
  }

  void _exportFullSessionJson() {
    if (_session == null) return;

    try {
      final jsonString = const JsonEncoder.withIndent('  ').convert(_session!.toJson());
      Clipboard.setData(ClipboardData(text: jsonString));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Full session JSON exported to clipboard')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export JSON: $error')),
      );
    }
  }

  void _exportSessionSummary() {
    final summary = _generateSessionSummary();
    Clipboard.setData(ClipboardData(text: summary));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session summary exported to clipboard')),
    );
  }

  String _generateSessionSummary() {
    if (_session == null || _sessionOverview == null || _sessionMetrics == null) {
      return 'Session data not available';
    }

    final session = _session!;
    final overview = _sessionOverview!;
    final metrics = _sessionMetrics!;

    final buffer = StringBuffer();
    buffer.writeln('=== Kai Engine Debug Session Summary ===');
    buffer.writeln();

    // Basic session info
    buffer.writeln('Session ID: ${session.id}');
    buffer.writeln('Start Time: ${session.startTime.toIso8601String()}');
    buffer.writeln('End Time: ${session.endTime?.toIso8601String() ?? 'In Progress'}');
    buffer.writeln('Duration: ${overview.duration?.inMilliseconds ?? 'N/A'}ms');
    buffer.writeln('Status: ${session.status}');
    buffer.writeln();

    // Performance metrics
    buffer.writeln('=== Performance Metrics ===');
    buffer.writeln('Messages: ${overview.messageCount}');
    buffer.writeln('Average Response Time: ${metrics.performanceMetrics.averageResponseTimeMs}ms');
    buffer.writeln('Fastest Response: ${metrics.performanceMetrics.fastestResponseTimeMs}ms');
    buffer.writeln('Slowest Response: ${metrics.performanceMetrics.slowestResponseTimeMs}ms');
    buffer.writeln(
        'Messages/Minute: ${metrics.performanceMetrics.messagesPerMinute.toStringAsFixed(1)}');
    buffer.writeln();

    // Token economics
    buffer.writeln('=== Token Usage ===');
    buffer.writeln('Total Tokens: ${overview.totalTokenUsage}');
    buffer.writeln('Average Tokens/Message: ${metrics.tokenEconomics.averageTokensPerMessage}');
    buffer.writeln('Min Tokens/Message: ${metrics.tokenEconomics.minTokensPerMessage}');
    buffer.writeln('Max Tokens/Message: ${metrics.tokenEconomics.maxTokensPerMessage}');
    buffer.writeln('Tokens/Minute: ${metrics.tokenEconomics.tokensPerMinute}');
    buffer.writeln('Total Cost: \$${overview.totalCost.toStringAsFixed(4)}');
    buffer.writeln();

    // Quality metrics
    buffer.writeln('=== Quality Metrics ===');
    buffer
        .writeln('Success Rate: ${(metrics.qualityMetrics.successRate * 100).toStringAsFixed(1)}%');
    buffer.writeln('Total Errors: ${overview.totalErrors}');
    buffer.writeln('Total Warnings: ${overview.totalWarnings}');
    buffer.writeln(
        'Avg Errors/Message: ${metrics.qualityMetrics.averageErrorsPerMessage.toStringAsFixed(1)}');
    buffer.writeln(
        'Avg Warnings/Message: ${metrics.qualityMetrics.averageWarningsPerMessage.toStringAsFixed(1)}');
    buffer.writeln();

    // Streaming analytics
    if (metrics.streamingAnalytics.totalStreamEvents > 0) {
      buffer.writeln('=== Streaming Analytics ===');
      buffer.writeln('Stream Events: ${metrics.streamingAnalytics.totalStreamEvents}');
      buffer.writeln('Chunks Received: ${metrics.streamingAnalytics.totalChunksReceived}');
      buffer.writeln('Characters Streamed: ${metrics.streamingAnalytics.totalCharactersStreamed}');
      buffer.writeln('Average Chunk Size: ${metrics.streamingAnalytics.averageChunkSize}');
      buffer.writeln(
          'Avg Time to First Chunk: ${metrics.streamingAnalytics.averageTimeToFirstChunkMs}ms');
      buffer.writeln();
    }

    // Phase statistics
    if (overview.phaseStatistics.isNotEmpty) {
      buffer.writeln('=== Phase Performance ===');
      for (final phase in overview.phaseStatistics) {
        buffer.writeln('${phase.phaseName}:');
        buffer.writeln('  Executions: ${phase.executionCount}');
        buffer.writeln('  Avg Duration: ${phase.averageDurationMs}ms');
        buffer.writeln('  Min/Max: ${phase.minDurationMs}ms / ${phase.maxDurationMs}ms');
        buffer.writeln('  Errors: ${phase.errorCount}, Warnings: ${phase.warningCount}');
        buffer.writeln();
      }
    }

    // Timeline summaries
    buffer.writeln('=== Message Timeline Summaries ===');
    for (var i = 0; i < session.timelines.length; i++) {
      final timeline = session.timelines[i];
      final timelineData = DebugDataAdapter.convertTimelineOverview(timeline);

      buffer.writeln('Message ${i + 1}:');
      buffer.writeln(
          '  Input: ${timeline.userMessage.length > 100 ? timeline.userMessage.substring(0, 100) + '...' : timeline.userMessage}');
      buffer.writeln('  Duration: ${timelineData.duration?.inMilliseconds ?? 'N/A'}ms');
      buffer.writeln('  Tokens: ${timelineData.totalTokens}');
      buffer.writeln('  Phases: ${timelineData.phaseCount}');
      buffer.writeln('  Status: ${timelineData.status}');
      if (timelineData.errorCount > 0 || timelineData.warningCount > 0) {
        buffer.writeln(
            '  Issues: ${timelineData.errorCount} errors, ${timelineData.warningCount} warnings');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }
}
