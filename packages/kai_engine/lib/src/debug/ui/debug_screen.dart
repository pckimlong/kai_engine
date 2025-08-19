import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../debug_system.dart';
import 'widgets/config_tab.dart';
import 'widgets/messages_tab.dart';
import 'widgets/metrics_tab.dart';
import 'widgets/timeline_tab.dart';

/// Comprehensive debug screen for message analysis
class MessageDebugScreen extends StatefulWidget {
  final String messageId;

  const MessageDebugScreen({super.key, required this.messageId});

  @override
  State<MessageDebugScreen> createState() => _MessageDebugScreenState();
}

class _MessageDebugScreenState extends State<MessageDebugScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  MessageDebugInfo? _debugInfo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDebugInfo();
  }

  void _loadDebugInfo() {
    setState(() {
      _debugInfo = KaiDebug.getMessageInfo(widget.messageId);
    });
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
        body: const Center(child: Text('Debug information not available in release mode')),
      );
    }

    if (_debugInfo == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Debug Message')),
        body: const Center(child: Text('Debug information not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Debug: ${widget.messageId.substring(0, 8)}...'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDebugInfo,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _exportDebugInfo,
            tooltip: 'Copy Debug Info',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Timeline'),
            Tab(text: 'Messages'),
            Tab(text: 'Config'),
            Tab(text: 'Metrics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TimelineTab(debugInfo: _debugInfo!),
          MessagesTab(debugInfo: _debugInfo!),
          ConfigTab(debugInfo: _debugInfo!),
          MetricsTab(debugInfo: _debugInfo!),
        ],
      ),
    );
  }

  void _exportDebugInfo() {
    final info = _debugInfo!;
    final exportData = {
      'messageId': info.messageId,
      'originalInput': info.originalInput,
      'startTime': info.startTime.toIso8601String(),
      'endTime': info.endTime?.toIso8601String(),
      'totalDuration': info.totalDuration?.inMilliseconds,
      'isComplete': info.isComplete,
      'hasError': info.hasError,
      'error': info.error?.toString(),
      'errorPhase': info.errorPhase,
      'phases': info.phases.map(
        (key, phase) => MapEntry(key, {
          'name': phase.name,
          'startTime': phase.startTime.toIso8601String(),
          'endTime': phase.endTime?.toIso8601String(),
          'duration': phase.duration?.inMilliseconds,
          'metadata': phase.metadata,
        }),
      ),
      'generationConfig': info.generationConfig != null
          ? {
              'availableTools': info.generationConfig!.availableTools,
              'config': info.generationConfig!.config,
              'tokenCount': info.usage?.tokenCount,
              'usedEmbedding': info.generationConfig!.usedEmbedding,
            }
          : null,
      'streaming': {
        'eventCount': info.streaming.eventCount,
        'chunkCount': info.streaming.chunks.length,
        'fullText': info.streaming.fullText,
      },
      'metadata': info.metadata,
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
    Clipboard.setData(ClipboardData(text: jsonString));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Debug info exported to clipboard')));
  }
}
