import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/core_message.dart';
import 'debug_system.dart';

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
            Tab(icon: Icon(Icons.timeline), text: 'Timeline'),
            Tab(icon: Icon(Icons.message), text: 'Messages'),
            Tab(icon: Icon(Icons.settings), text: 'Config'),
            Tab(icon: Icon(Icons.analytics), text: 'Metrics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTimelineTab(), _buildMessagesTab(), _buildConfigTab(), _buildMetricsTab()],
      ),
    );
  }

  Widget _buildTimelineTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildOverviewCard(), const SizedBox(height: 16), _buildTimelineVisualization()],
      ),
    );
  }

  Widget _buildOverviewCard() {
    final info = _debugInfo!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  info.hasError
                      ? Icons.error
                      : info.isComplete
                      ? Icons.check_circle
                      : Icons.hourglass_empty,
                  color: info.hasError
                      ? Colors.red
                      : info.isComplete
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    info.originalInput,
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
                _buildInfoChip(
                  'Status',
                  info.hasError
                      ? 'Error'
                      : info.isComplete
                      ? 'Complete'
                      : 'In Progress',
                  info.hasError
                      ? Colors.red
                      : info.isComplete
                      ? Colors.green
                      : Colors.orange,
                ),
                if (info.totalDuration != null)
                  _buildInfoChip(
                    'Total Time',
                    '${info.totalDuration!.inMilliseconds}ms',
                    Colors.blue,
                  ),
                _buildInfoChip('Phases', '${info.phases.length}', Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.2),
        child: Text(
          label[0],
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
      label: Text('$label: $value'),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildTimelineVisualization() {
    final info = _debugInfo!;
    final phases = info.phases.values.toList();
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
              _buildTimelineChart(phases),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineChart(List<DebugPhase> phases) {
    final totalDuration =
        _debugInfo!.totalDuration?.inMilliseconds ??
        phases.last.startTime.difference(phases.first.startTime).inMilliseconds;

    // Group phases by main categories for hierarchical display
    final mainPhases = <String, List<DebugPhase>>{};
    final subPhases = <String, List<DebugPhase>>{};

    for (final phase in phases) {
      if (_isMainPhase(phase.name)) {
        mainPhases[phase.name] = [phase];
      } else {
        // Find the parent phase
        final parentPhase = _getParentPhase(phase.name);
        if (parentPhase != null) {
          subPhases.putIfAbsent(parentPhase, () => []).add(phase);
        } else {
          // If no parent found, treat as main phase
          mainPhases[phase.name] = [phase];
        }
      }
    }

    return Column(
      children: phases.where((phase) => _isMainPhase(phase.name)).map((mainPhase) {
        final subPhasesForMain = subPhases[mainPhase.name] ?? [];
        final hasSubPhases = subPhasesForMain.isNotEmpty;

        return _buildPhaseGroup(
          mainPhase: mainPhase,
          subPhases: subPhasesForMain,
          totalDuration: totalDuration,
          hasSubPhases: hasSubPhases,
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

  Widget _buildPhaseGroup({
    required DebugPhase mainPhase,
    required List<DebugPhase> subPhases,
    required int totalDuration,
    required bool hasSubPhases,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: hasSubPhases
          ? ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(left: 16),
              title: _buildPhaseRow(mainPhase, totalDuration, isMainPhase: true),
              children: subPhases
                  .map(
                    (subPhase) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: _buildPhaseRow(subPhase, totalDuration, isMainPhase: false),
                    ),
                  )
                  .toList(),
            )
          : _buildPhaseRow(mainPhase, totalDuration, isMainPhase: true),
    );
  }

  Widget _buildPhaseRow(DebugPhase phase, int totalDuration, {required bool isMainPhase}) {
    final startOffset = phase.startTime.difference(_debugInfo!.startTime).inMilliseconds;
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
                  color: _getPhaseColor(phase.name).withValues(alpha: isMainPhase ? 1.0 : 0.7),
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
    // Clean up phase names for better display
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

    // Convert kebab-case to title case
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

  Color _getPhaseColor(String phaseName) {
    final lowerName = phaseName.toLowerCase();

    switch (lowerName) {
      case 'query-processing':
        return Colors.blue;
      case 'context-building':
      case 'context-engine-processing':
        return Colors.orange;
      case 'ai-generation':
        return Colors.green;
      case 'post-response-processing':
        return Colors.red;
      default:
        // Context builder specific colors
        if (lowerName.startsWith('parallel-') || lowerName.startsWith('par-')) {
          return Colors.teal;
        }
        if (lowerName.startsWith('sequential-') || lowerName.startsWith('seq-')) {
          return Colors.indigo;
        }
        // Post-response engine specific colors
        if (lowerName.startsWith('post-response-')) {
          return Colors.pink;
        }
        return Colors.purple;
    }
  }

  Widget _buildMessagesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildContextMessagesSection(),
          const SizedBox(height: 16),
          _buildFinalPromptsSection(),
          const SizedBox(height: 16),
          _buildGeneratedMessagesSection(),
          const SizedBox(height: 16),
          _buildStreamingSection(),
        ],
      ),
    );
  }

  Widget _buildContextMessagesSection() {
    final contextMessages = _debugInfo!.contextMessages;

    return _buildExpandableSection(
      title: 'Context Messages',
      subtitle: contextMessages != null ? '${contextMessages.length} messages' : 'Not available',
      icon: Icons.history,
      child: contextMessages != null
          ? _buildMessagesList(contextMessages)
          : const Text('Context messages not available'),
    );
  }

  Widget _buildFinalPromptsSection() {
    final finalPrompts = _debugInfo!.finalPrompts;

    return _buildExpandableSection(
      title: 'Final Prompts',
      subtitle: finalPrompts != null ? '${finalPrompts.length} prompts' : 'Not available',
      icon: Icons.edit_note,
      child: finalPrompts != null
          ? _buildMessagesList(finalPrompts)
          : const Text('Final prompts not available'),
    );
  }

  Widget _buildGeneratedMessagesSection() {
    final generatedMessages = _debugInfo!.generatedMessages;

    return _buildExpandableSection(
      title: 'Generated Messages',
      subtitle: generatedMessages != null
          ? '${generatedMessages.length} messages'
          : 'Not available',
      icon: Icons.auto_awesome,
      child: generatedMessages != null
          ? _buildMessagesList(generatedMessages)
          : const Text('Generated messages not available'),
    );
  }

  Widget _buildStreamingSection() {
    final streaming = _debugInfo!.streaming;

    return _buildExpandableSection(
      title: 'Streaming Data',
      subtitle: '${streaming.eventCount} events, ${streaming.chunks.length} chunks',
      icon: Icons.stream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip('Events', '${streaming.eventCount}', Colors.blue),
              _buildInfoChip('Chunks', '${streaming.chunks.length}', Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          if (streaming.fullText.isNotEmpty) ...[
            const Text('Full Streaming Text:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(streaming.fullText, style: const TextStyle(fontFamily: 'monospace')),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessagesList(Iterable<CoreMessage> messages) {
    return Column(children: messages.map((message) => _buildMessageCard(message)).toList());
  }

  Widget _buildMessageCard(CoreMessage message) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: _getMessageTypeIcon(message.type),
        title: Text(
          _getMessageTypeLabel(message.type),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          message.content.length > 100
              ? '${message.content.substring(0, 100)}...'
              : message.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip('ID', message.messageId.substring(0, 8), Colors.grey),
                    _buildInfoChip(
                      'Background',
                      message.isBackgroundContext ? 'Yes' : 'No',
                      message.isBackgroundContext ? Colors.orange : Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Content:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: SelectableText(
                    message.content,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                  ),
                ),
                if (message.extensions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('Extensions:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: SelectableText(
                      const JsonEncoder.withIndent('  ').convert(message.extensions),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ],
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    TextButton.icon(
                      onPressed: () => _copyToClipboard(message.content),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy'),
                    ),
                    TextButton.icon(
                      onPressed: () => _showMessageDetail(message),
                      icon: const Icon(Icons.open_in_full, size: 16),
                      label: const Text('Detail'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getMessageTypeIcon(CoreMessageType type) {
    switch (type) {
      case CoreMessageType.user:
        return const Icon(Icons.person, color: Colors.blue);
      case CoreMessageType.ai:
        return const Icon(Icons.smart_toy, color: Colors.green);
      case CoreMessageType.system:
        return const Icon(Icons.settings, color: Colors.orange);
      case CoreMessageType.function:
        return const Icon(Icons.functions, color: Colors.purple);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  String _getMessageTypeLabel(CoreMessageType type) {
    switch (type) {
      case CoreMessageType.user:
        return 'User Message';
      case CoreMessageType.ai:
        return 'AI Response';
      case CoreMessageType.system:
        return 'System Prompt';
      case CoreMessageType.function:
        return 'Function Call';
      default:
        return 'Unknown';
    }
  }

  Widget _buildConfigTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGenerationConfigSection(),
          const SizedBox(height: 16),
          _buildQueryProcessingSection(),
          const SizedBox(height: 16),
          _buildMetadataSection(),
        ],
      ),
    );
  }

  Widget _buildGenerationConfigSection() {
    final config = _debugInfo!.generationConfig;

    return _buildExpandableSection(
      title: 'Generation Configuration',
      subtitle: config != null
          ? '${config.availableTools.length} tools, ${_debugInfo!.usage?.tokenCount ?? "Unknown"} tokens'
          : 'Not available',
      icon: Icons.settings,
      child: config != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_debugInfo!.usage?.tokenCount != null)
                  _buildConfigRow('Token Count', '${_debugInfo!.usage?.tokenCount}'),
                _buildConfigRow('Used Embedding', config.usedEmbedding ? 'Yes' : 'No'),
                const SizedBox(height: 12),
                const Text('Available Tools:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (config.availableTools.isEmpty)
                  const Text('No tools available')
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: config.availableTools
                        .map(
                          (tool) => Chip(
                            label: Text(tool),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 12),
                const Text('Configuration:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: SelectableText(
                    config.config.isEmpty
                        ? 'No configuration data'
                        : const JsonEncoder.withIndent('  ').convert(config.config),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ],
            )
          : const Text('Generation configuration not available'),
    );
  }

  Widget _buildQueryProcessingSection() {
    final query = _debugInfo!.processedQuery;

    return _buildExpandableSection(
      title: 'Query Processing',
      subtitle: query != null ? 'Query processed' : 'Not available',
      icon: Icons.search,
      child: query != null
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: SelectableText(
                query.toString(),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            )
          : const Text('Query processing information not available'),
    );
  }

  Widget _buildMetadataSection() {
    final metadata = _debugInfo!.metadata;

    return _buildExpandableSection(
      title: 'Custom Metadata',
      subtitle: '${metadata.length} entries',
      icon: Icons.data_object,
      child: metadata.isEmpty
          ? const Text('No custom metadata available')
          : Column(
              children: metadata.entries
                  .map((entry) => _buildConfigRow(entry.key, entry.value.toString()))
                  .toList(),
            ),
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }

  Widget _buildMetricsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPerformanceMetrics(),
          const SizedBox(height: 16),
          _buildPhaseBreakdown(),
          const SizedBox(height: 16),
          _buildTokenBreakdown(),
          const SizedBox(height: 16),
          _buildErrorSection(),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    final info = _debugInfo!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Performance Metrics', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Total Duration',
                    info.totalDuration != null
                        ? '${info.totalDuration!.inMilliseconds}ms'
                        : 'In Progress...',
                    Icons.timer,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Streaming Events',
                    '${info.streaming.eventCount}',
                    Icons.stream,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Token Count',
                    info.usage?.tokenCount != null ? '${info.usage?.tokenCount}' : 'Unknown',
                    Icons.token,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Phases',
                    '${info.phases.length}',
                    Icons.timeline,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseBreakdown() {
    final phases = _debugInfo!.phases.values.toList();
    phases.sort((a, b) => a.startTime.compareTo(b.startTime));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phase Breakdown', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (phases.isEmpty)
              const Text('No phase information available')
            else
              ...phases.map((phase) => _buildPhaseMetricRow(phase)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseMetricRow(DebugPhase phase) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: _getPhaseColor(phase.name), shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(phase.name, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text(
            phase.duration != null ? '${phase.duration!.inMilliseconds}ms' : 'In Progress...',
            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenBreakdown() {
    final info = _debugInfo!;
    int? totalInputTokens = info.usage?.inputToken;
    int? totalOutputTokens = info.usage?.outputToken;
    int? totalApiCalls = info.usage?.apiCallCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Token Breakdown', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildTokenMetricRow(
              'Total Input Tokens',
              totalInputTokens?.toString() ?? "Unknown",
              Icons.input,
            ),
            _buildTokenMetricRow(
              'Total Output Tokens',
              totalOutputTokens?.toString() ?? "Unknown",
              Icons.output,
            ),
            _buildTokenMetricRow(
              'Total API Calls',
              totalApiCalls?.toString() ?? "Unknown",
              Icons.api,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenMetricRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSection() {
    final info = _debugInfo!;

    if (!info.hasError) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 12),
              Text(
                'No Errors',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.green),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 12),
                Text(
                  'Error Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildConfigRow('Error Phase', info.errorPhase ?? 'Unknown'),
            const SizedBox(height: 8),
            const Text('Error Details:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: SelectableText(
                info.error?.toString() ?? 'No error details available',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        children: [Padding(padding: const EdgeInsets.all(16), child: child)],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
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

  void _showMessageDetail(CoreMessage message) {
    showDialog(
      context: context,
      builder: (context) => MessageDetailDialog(message: message),
    );
  }
}

/// Dialog for showing detailed message information
class MessageDetailDialog extends StatelessWidget {
  final CoreMessage message;

  const MessageDetailDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getMessageTypeIcon(message.type)),
                const SizedBox(width: 12),
                Text(
                  _getMessageTypeLabel(message.type),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Message ID', message.messageId),
                    _buildDetailRow('Type', message.type.name),
                    _buildDetailRow(
                      'Background Context',
                      message.isBackgroundContext ? 'Yes' : 'No',
                    ),
                    _buildDetailRow('Timestamp', message.timestamp.toString()),
                    const SizedBox(height: 16),
                    const Text('Content:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: SelectableText(
                        message.content,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    if (message.extensions.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('Extensions:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: SelectableText(
                          const JsonEncoder.withIndent('  ').convert(message.extensions),
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 16,
              runSpacing: 8,
              children: [
                TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: message.content));
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Content copied to clipboard')));
                  },
                  child: const Text('Copy Content'),
                ),
                TextButton(
                  onPressed: () {
                    final fullData = const JsonEncoder.withIndent('  ').convert({
                      'messageId': message.messageId,
                      'type': message.type.name,
                      'content': message.content,
                      'isBackgroundContext': message.isBackgroundContext,
                      'timestamp': message.timestamp.toIso8601String(),
                      'extensions': message.extensions,
                    });
                    Clipboard.setData(ClipboardData(text: fullData));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Full message data copied to clipboard')),
                    );
                  },
                  child: const Text('Copy All'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }

  IconData _getMessageTypeIcon(CoreMessageType type) {
    switch (type) {
      case CoreMessageType.user:
        return Icons.person;
      case CoreMessageType.ai:
        return Icons.smart_toy;
      case CoreMessageType.system:
        return Icons.settings;
      case CoreMessageType.function:
        return Icons.functions;
      default:
        return Icons.help_outline;
    }
  }

  String _getMessageTypeLabel(CoreMessageType type) {
    switch (type) {
      case CoreMessageType.user:
        return 'User Message';
      case CoreMessageType.ai:
        return 'AI Response';
      case CoreMessageType.system:
        return 'System Prompt';
      case CoreMessageType.function:
        return 'Function Call';
      default:
        return 'Unknown';
    }
  }
}
