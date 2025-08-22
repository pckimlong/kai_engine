import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kai_engine/src/inspector/execution_timeline.dart';
import 'package:kai_engine/src/inspector/kai_inspector.dart';

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
  State<MessageInputDebugScreen> createState() =>
      _MessageInputDebugScreenState();
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
          orElse: () => throw Exception(
              'Timeline not found for message ID: ${widget.messageId}'),
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
              _timelineData =
                  DebugDataAdapter.convertTimelineOverview(timeline);
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
    buffer.writeln(
        'End Time: ${timeline.endTime?.toIso8601String() ?? 'In Progress'}');
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
      buffer
          .writeln('  Duration: ${phase.duration?.inMilliseconds ?? 'N/A'}ms');
      buffer.writeln('  Steps: ${phase.stepCount}');
      buffer.writeln('  Logs: ${phase.logCount}');
      if (phase.tokenMetadata != null && phase.tokenMetadata!.totalTokens > 0) {
        final token = phase.tokenMetadata!;
        buffer.writeln(
            '  Tokens: ${token.totalTokens} (${token.inputTokens ?? 0} in, ${token.outputTokens ?? 0} out)');
        if (token.tokensPerSecond != null) {
          buffer.writeln(
              '  Speed: ${token.tokensPerSecond!.toStringAsFixed(1)} tokens/sec');
        }
      }
      if (phase.streamingMetadata != null) {
        final streaming = phase.streamingMetadata!;
        buffer.writeln(
            '  Streaming: ${streaming.chunksReceived} chunks, ${streaming.totalCharacters} chars');
        if (streaming.timeToFirstChunkMs != null) {
          buffer.writeln('  First Chunk: ${streaming.timeToFirstChunkMs}ms');
        }
      }
      if (phase.errorCount > 0 || phase.warningCount > 0) {
        buffer.writeln(
            '  Issues: ${phase.errorCount} errors, ${phase.warningCount} warnings');
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
          // 1. Prompt Pipeline Section (NEW - Top Priority)
          _PromptPipelineSection(
            timeline: timeline,
            timelineData: timelineData,
            userInput: userInput,
          ),
          const SizedBox(height: 16),
          // 2. Conversation Flow Section (NEW)
          _ConversationFlowSection(
            timeline: timeline,
            userInput: userInput,
          ),
          const SizedBox(height: 16),
          // 3. Enhanced Metrics Grid (expanded from 4 to 6 metrics)
          _TimelineMetricsGrid(timelineData: timelineData),
          const SizedBox(height: 16),
          // 4. Phase Timeline Visualization (existing)
          _PhaseTimelineVisualization(timelineData: timelineData),
        ],
      ),
    );
  }
}

/// NEW: Comprehensive Prompt Pipeline Section showing complete prompt construction
class _PromptPipelineSection extends StatefulWidget {
  final ExecutionTimeline timeline;
  final TimelineOverviewData timelineData;
  final String? userInput;

  const _PromptPipelineSection({
    required this.timeline,
    required this.timelineData,
    this.userInput,
  });

  @override
  State<_PromptPipelineSection> createState() => _PromptPipelineSectionState();
}

class _PromptPipelineSectionState extends State<_PromptPipelineSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final promptData = _extractPromptData();
    final totalChars = promptData.totalCharacters;

    return Card(
      elevation: 2,
      child: Column(
        children: [
          // Collapsed Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(12),
              bottom: Radius.circular(_isExpanded ? 0 : 12),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withAlpha(13),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(12),
                  bottom: Radius.circular(_isExpanded ? 0 : 12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.code,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prompt Pipeline Construction',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              'Total: ${_formatCharCount(totalChars)} characters',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Preview of final prompt (2 lines)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      promptData.preview,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expanded Content
          if (_isExpanded)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: _buildExpandedPromptContent(promptData),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandedPromptContent(_PromptData promptData) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // System Prompt Segment
          if (promptData.systemPrompt.isNotEmpty) ...[
            _buildPromptSegment(
              'System Prompt',
              promptData.systemPrompt,
              Colors.blue,
              Icons.settings,
            ),
            const SizedBox(height: 16),
          ],
          // Context Messages Segment
          if (promptData.contextMessages.isNotEmpty) ...[
            _buildPromptSegment(
              'Context Messages',
              promptData.contextMessages,
              Colors.purple,
              Icons.history,
            ),
            const SizedBox(height: 16),
          ],
          // User Input Segment
          _buildPromptSegment(
            'User Input',
            promptData.userInput,
            Colors.green,
            Icons.person,
          ),
          const SizedBox(height: 16),
          // Copy All Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  _copyToClipboard(promptData.fullPrompt, 'Complete prompt'),
              icon: const Icon(Icons.copy_all),
              label: const Text('Copy Complete Prompt'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptSegment(
      String title, String content, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color.withAlpha(204),
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_formatCharCount(content.length)} chars',
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withAlpha(153),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _copyToClipboard(content, title),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color.withAlpha(51),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.copy,
                      size: 12,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                content.isEmpty ? '(No content)' : content,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  height: 1.4,
                  color: content.isEmpty ? Colors.grey[500] : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _PromptData _extractPromptData() {
    // Use the actual prompt pipeline data from the timeline if available
    final timelineOverview =
        DebugDataAdapter.convertTimelineOverview(widget.timeline);
    final promptPipeline = timelineOverview.promptPipeline;

    if (promptPipeline != null && promptPipeline.segments.isNotEmpty) {
      // Extract from actual prompt pipeline data
      String systemPrompt = '';
      String contextMessages = '';
      String userInput = widget.userInput ?? widget.timeline.userMessage;

      for (final segment in promptPipeline.segments) {
        switch (segment.type) {
          case PromptSegmentType.system:
            systemPrompt = segment.content;
            break;
          case PromptSegmentType.context:
            contextMessages = segment.content;
            break;
          case PromptSegmentType.userInput:
            userInput = segment.content;
            break;
        }
      }

      final fullPrompt = promptPipeline.segments
          .map((segment) => segment.content)
          .join('\n\n---\n\n');

      final preview = fullPrompt.length > 200
          ? '${fullPrompt.substring(0, 200)}...'
          : fullPrompt;

      return _PromptData(
        systemPrompt: systemPrompt,
        contextMessages: contextMessages,
        userInput: userInput,
        fullPrompt: fullPrompt,
        preview: preview,
        totalCharacters: promptPipeline.totalCharacterCount,
      );
    }

    // Fallback to extracting from phase logs and metadata
    final userInput = widget.userInput ?? widget.timeline.userMessage;
    final systemPrompt = _findSystemPrompt();
    final contextMessages = _findContextMessages();

    final fullPrompt = [systemPrompt, contextMessages, userInput]
        .where((s) => s.isNotEmpty)
        .join('\n\n---\n\n');

    final preview = fullPrompt.length > 200
        ? '${fullPrompt.substring(0, 200)}...'
        : fullPrompt;

    return _PromptData(
      systemPrompt: systemPrompt,
      contextMessages: contextMessages,
      userInput: userInput,
      fullPrompt: fullPrompt,
      preview: preview,
      totalCharacters: fullPrompt.length,
    );
  }

  String _findSystemPrompt() {
    // Look for system prompt in phase logs/metadata
    for (final phase in widget.timeline.phases) {
      for (final log in phase.logs) {
        if (log.metadata.containsKey('system_prompt')) {
          return log.metadata['system_prompt'].toString();
        }
      }
    }
    return 'You are a helpful AI assistant.'; // Default/mock
  }

  String _findContextMessages() {
    // Look for context messages in phase logs/metadata
    for (final phase in widget.timeline.phases) {
      for (final log in phase.logs) {
        if (log.metadata.containsKey('context_messages')) {
          final context = log.metadata['context_messages'];
          if (context is List) {
            return context.map((msg) => msg.toString()).join('\n');
          }
          return context.toString();
        }
      }
    }
    return ''; // No context found
  }

  String _formatCharCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  void _copyToClipboard(String content, String label) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied to clipboard')),
    );
  }
}

class _PromptData {
  final String systemPrompt;
  final String contextMessages;
  final String userInput;
  final String fullPrompt;
  final String preview;
  final int totalCharacters;

  const _PromptData({
    required this.systemPrompt,
    required this.contextMessages,
    required this.userInput,
    required this.fullPrompt,
    required this.preview,
    required this.totalCharacters,
  });
}

/// NEW: Conversation Flow Section showing user input and AI response
class _ConversationFlowSection extends StatelessWidget {
  final ExecutionTimeline timeline;
  final String? userInput;

  const _ConversationFlowSection({
    required this.timeline,
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
                  Icons.chat,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Conversation Flow',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // User Input Card
            _ConversationCard(
              title: 'User Input',
              content: userInput ?? timeline.userMessage,
              isUser: true,
            ),
            const SizedBox(height: 12),
            // AI Response Card
            _ConversationCard(
              title: 'AI Response',
              content: timeline.aiResponse ??
                  'Response not available or still processing...',
              isUser: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationCard extends StatefulWidget {
  final String title;
  final String content;
  final bool isUser;

  const _ConversationCard({
    required this.title,
    required this.content,
    required this.isUser,
  });

  @override
  State<_ConversationCard> createState() => _ConversationCardState();
}

class _ConversationCardState extends State<_ConversationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isLongContent = widget.content.length > 200;
    final displayContent = isLongContent && !_isExpanded
        ? '${widget.content.substring(0, 200)}...'
        : widget.content;

    final color = widget.isUser ? Colors.blue : Colors.green;
    final icon = widget.isUser ? Icons.person : Icons.smart_toy;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color.withAlpha(204),
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_formatCharCount(widget.content.length)} chars',
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withAlpha(153),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _copyToClipboard(widget.content, widget.title),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color.withAlpha(51),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.copy,
                      size: 12,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    displayContent,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                if (isLongContent)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: InkWell(
                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _isExpanded ? 'Show less' : 'Show more',
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
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

  String _formatCharCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  void _copyToClipboard(String content, String label) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied to clipboard')),
    );
  }
}

/// Enhanced Metrics Grid: From 4 to 6 metrics with responsive layout (2 mobile, 3 tablet, 6 desktop)
class _TimelineMetricsGrid extends StatelessWidget {
  final TimelineOverviewData timelineData;

  const _TimelineMetricsGrid({required this.timelineData});

  @override
  Widget build(BuildContext context) {
    // Extract token data from phases
    final tokenData = _extractEnhancedTokenData();

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 2; // Mobile: 2 columns
        } else if (constraints.maxWidth < 1024) {
          crossAxisCount = 3; // Tablet: 3 columns
        } else {
          crossAxisCount = 6; // Desktop: 6 columns
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: crossAxisCount == 6 ? 1.0 : 1.2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _MetricCard(
              title: 'Duration',
              value: timelineData.duration != null
                  ? '${timelineData.duration!.inMilliseconds}ms'
                  : 'Running',
              icon: Icons.timer,
              color: Colors.blue,
            ),
            _MetricCard(
              title: 'Input Tokens',
              value: '${tokenData.inputTokens}',
              icon: Icons.input,
              color: Colors.indigo,
            ),
            _MetricCard(
              title: 'Output Tokens',
              value: '${tokenData.outputTokens}',
              icon: Icons.output,
              color: Colors.teal,
            ),
            _MetricCard(
              title: 'API Calls',
              value: '${tokenData.apiCallCount}',
              icon: Icons.api,
              color: Colors.orange,
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
      },
    );
  }

  _EnhancedTokenData _extractEnhancedTokenData() {
    int inputTokens = 0;
    int outputTokens = 0;
    int apiCallCount = 0;

    for (final phase in timelineData.phases) {
      if (phase.tokenMetadata != null) {
        final token = phase.tokenMetadata!;
        inputTokens += token.inputTokens ?? 0;
        outputTokens += token.outputTokens ?? 0;
        apiCallCount += token.apiCallCount ?? 0;
      }
    }

    return _EnhancedTokenData(
      inputTokens: inputTokens,
      outputTokens: outputTokens,
      apiCallCount: apiCallCount,
    );
  }
}

class _EnhancedTokenData {
  final int inputTokens;
  final int outputTokens;
  final int apiCallCount;

  const _EnhancedTokenData({
    required this.inputTokens,
    required this.outputTokens,
    required this.apiCallCount,
  });
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
    final startOffset =
        phase.startTime.difference(timelineStart).inMilliseconds;
    final phaseDuration = phase.duration?.inMilliseconds ?? 0;
    final startPercent =
        totalDuration > 0 ? (startOffset / totalDuration) : 0.0;
    final widthPercent =
        totalDuration > 0 ? (phaseDuration / totalDuration) : 0.1;

    final phaseName = phase.phaseName
        .split('-')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
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
              if (phase.tokenMetadata != null &&
                  phase.tokenMetadata!.totalTokens > 0)
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
                    left:
                        MediaQuery.of(context).size.width * 0.7 * startPercent,
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

/// Enhanced Phase Detail Card with nested expandable sections and 3-level progressive disclosure
class _PhaseDetailCard extends StatefulWidget {
  final PhaseOverviewData phase;

  const _PhaseDetailCard({required this.phase});

  @override
  State<_PhaseDetailCard> createState() => _PhaseDetailCardState();
}

class _PhaseDetailCardState extends State<_PhaseDetailCard> {
  bool _isExpanded = false;
  bool _showMetadata = false;
  bool _showSteps = false;
  bool _showLogs = false;

  @override
  Widget build(BuildContext context) {
    final phaseName = widget.phase.phaseName
        .split('-')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: _isExpanded ? 4 : 1,
      child: Column(
        children: [
          // Level 1: Header (always visible)
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: _isExpanded
                    ? LinearGradient(
                        colors: [
                          getPhaseColor(widget.phase.phaseName).withAlpha(13),
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(12),
                  bottom: Radius.circular(_isExpanded ? 0 : 12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: getPhaseColor(widget.phase.phaseName),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getPhaseIcon(widget.phase.phaseName),
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          phaseName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (widget.phase.description != null)
                          Text(
                            widget.phase.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Wrap(
                    spacing: 6,
                    children: [
                      if (widget.phase.duration != null)
                        _CompactChip(
                          label: '${widget.phase.duration!.inMilliseconds}ms',
                          color: Colors.blue,
                          icon: Icons.timer,
                        ),
                      if (widget.phase.tokenMetadata != null &&
                          widget.phase.tokenMetadata!.totalTokens > 0)
                        _CompactChip(
                          label: '${widget.phase.tokenMetadata!.totalTokens}',
                          color: Colors.green,
                          icon: Icons.token,
                        ),
                      if (widget.phase.errorCount > 0 ||
                          widget.phase.warningCount > 0)
                        _CompactChip(
                          label:
                              '${widget.phase.errorCount + widget.phase.warningCount}',
                          color: Colors.red,
                          icon: Icons.error_outline,
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          // Level 2: Expandable sections
          if (_isExpanded)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Column(
                children: [
                  // Phase Metadata Section
                  _buildExpandableSection(
                    title: 'Phase Metadata',
                    icon: Icons.info_outline,
                    color: Colors.indigo,
                    isExpanded: _showMetadata,
                    onToggle: () =>
                        setState(() => _showMetadata = !_showMetadata),
                    child: _PhaseMetadataContent(phase: widget.phase),
                  ),
                  // Nested Steps Section
                  if (widget.phase.steps.isNotEmpty)
                    _buildExpandableSection(
                      title: 'Nested Steps (${widget.phase.steps.length})',
                      icon: Icons.list_alt,
                      color: Colors.teal,
                      isExpanded: _showSteps,
                      onToggle: () => setState(() => _showSteps = !_showSteps),
                      child: _NestedStepsContent(steps: widget.phase.steps),
                    ),
                  // Phase Logs Section
                  if (widget.phase.logs.isNotEmpty)
                    _buildExpandableSection(
                      title: 'Phase Logs (${widget.phase.logs.length})',
                      icon: Icons.article,
                      color: Colors.purple,
                      isExpanded: _showLogs,
                      onToggle: () => setState(() => _showLogs = !_showLogs),
                      child: _PhaseLogsContent(logs: widget.phase.logs),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required Color color,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(8),
              bottom: Radius.circular(isExpanded ? 0 : 8),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withAlpha(13),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(8),
                  bottom: Radius.circular(isExpanded ? 0 : 8),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: color.withAlpha(153),
                  ),
                ],
              ),
            ),
          ),
          // Level 3: Nested content
          if (isExpanded)
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              child: child,
            ),
        ],
      ),
    );
  }

  IconData _getPhaseIcon(String phaseName) {
    final phase = phaseName.toLowerCase();
    if (phase.contains('query') || phase.contains('process'))
      return Icons.search;
    if (phase.contains('context') || phase.contains('build'))
      return Icons.build;
    if (phase.contains('generation') || phase.contains('ai'))
      return Icons.smart_toy;
    if (phase.contains('response') || phase.contains('post')) return Icons.send;
    return Icons.timeline;
  }
}

class _CompactChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _CompactChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseMetadataContent extends StatelessWidget {
  final PhaseOverviewData phase;

  const _PhaseMetadataContent({required this.phase});

  @override
  Widget build(BuildContext context) {
    final metadataItems = <String, String>{
      'Phase ID': phase.phaseId,
      'Start Time': phase.startTime.toIso8601String(),
      if (phase.endTime != null) 'End Time': phase.endTime!.toIso8601String(),
      if (phase.duration != null)
        'Duration': '${phase.duration!.inMilliseconds}ms',
      'Status': phase.status.toString().split('.').last,
      'Step Count': '${phase.stepCount}',
      'Log Count': '${phase.logCount}',
      'Error Count': '${phase.errorCount}',
      'Warning Count': '${phase.warningCount}',
    };

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: metadataItems.entries
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        '${entry.key}:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NestedStepsContent extends StatelessWidget {
  final List<StepOverviewData> steps;

  const _NestedStepsContent({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children:
            steps.map((step) => _EnhancedStepDisplay(step: step)).toList(),
      ),
    );
  }
}

class _EnhancedStepDisplay extends StatefulWidget {
  final StepOverviewData step;

  const _EnhancedStepDisplay({required this.step});

  @override
  State<_EnhancedStepDisplay> createState() => _EnhancedStepDisplayState();
}

class _EnhancedStepDisplayState extends State<_EnhancedStepDisplay> {
  bool _showStepDetails = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _showStepDetails = !_showStepDetails),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(6),
              bottom: Radius.circular(_showStepDetails ? 0 : 6),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(
                    _showStepDetails ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.step.stepName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (widget.step.duration != null)
                    Text(
                      '${widget.step.duration!.inMilliseconds}ms',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  if (widget.step.logCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(51),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${widget.step.logCount}',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_showStepDetails)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.step.description != null) ...[
                    Text(
                      'Description: ${widget.step.description}',
                      style: const TextStyle(fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (widget.step.metadata.isNotEmpty) ...[
                    const Text(
                      'Metadata:',
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    ...widget.step.metadata.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: const TextStyle(
                              fontSize: 9, fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (widget.step.logs.isNotEmpty) ...[
                    Text(
                      'Logs (${widget.step.logs.length}):',
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    ...widget.step.logs.take(3).map(
                          (log) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1),
                            child: Text(
                              '[${log.severity.toString().split('.').last.toUpperCase()}] ${log.message}',
                              style: const TextStyle(
                                  fontSize: 9, fontFamily: 'monospace'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    if (widget.step.logs.length > 3)
                      Text(
                        '... and ${widget.step.logs.length - 3} more',
                        style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                      ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PhaseLogsContent extends StatelessWidget {
  final List<LogEntryData> logs;

  const _PhaseLogsContent({required this.logs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: logs
            .take(10)
            .map(
              (log) => // Show first 10 logs
                  Container(
                margin: const EdgeInsets.symmetric(vertical: 1),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: _getSeverityColor(log.severity).withAlpha(51),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        log.severity
                            .toString()
                            .split('.')
                            .last
                            .toUpperCase()
                            .substring(0, 1),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: _getSeverityColor(log.severity),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        log.message,
                        style: const TextStyle(
                          fontSize: 10,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                  children: log.metadata.entries
                      .map(
                        (entry) => Padding(
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
                      )
                      .toList(),
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
