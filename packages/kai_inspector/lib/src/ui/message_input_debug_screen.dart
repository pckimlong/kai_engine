import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kai_engine/kai_engine.dart';
import 'package:kai_inspector/src/ui/playground_screen.dart';

import 'debug_data_adapter.dart';
import 'widgets/shared_widgets.dart';

/// Debug screen for analyzing a specific user input message and its processing timeline
/// Shows detailed breakdown of what happened during processing of a single message
class MessageInputDebugScreen extends StatefulWidget {
  final String sessionId;
  final String messageId; // This is both the CoreMessage ID and timeline ID
  final KaiInspector inspector;
  final String? userInput; // Optional: display the original user input
  /// Allow playground feature if provided
  final GenerationServiceBase? generationService;

  const MessageInputDebugScreen({
    super.key,
    required this.sessionId,
    required this.messageId,
    required this.inspector,
    this.userInput,
    this.generationService,
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
      floatingActionButton: widget.generationService != null && _timelineData != null
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PlaygroundScreen(
                      generationService: widget.generationService!,
                      data: _timelineData!,
                    ),
                  ),
                );
              },
              tooltip: 'Open Playground',
              child: const Icon(Icons.science_outlined),
            )
          : null,
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
        buffer.writeln(
            '  Tokens: ${token.totalTokens} (${token.inputTokens ?? 0} in, ${token.outputTokens ?? 0} out)');
        if (token.tokensPerSecond != null) {
          buffer.writeln('  Speed: ${token.tokensPerSecond!.toStringAsFixed(1)} tokens/sec');
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Overview Section (Simple timeline summary)
          _OverviewSection(
            timeline: timeline,
            timelineData: timelineData,
          ),
          const SizedBox(height: 16),
          // 2. Conversation Flow Section (NEW)
          _ConversationFlowSection(
            timelineData: timelineData,
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

/// Simple Overview Section showing basic timeline information
class _OverviewSection extends StatelessWidget {
  final ExecutionTimeline timeline;
  final TimelineOverviewData timelineData;

  const _OverviewSection({
    required this.timeline,
    required this.timelineData,
  });

  @override
  Widget build(BuildContext context) {
    final startTime = timeline.startTime;
    final endTime = timeline.endTime;
    final duration = timelineData.duration;
    final status = timeline.status;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    Icons.info_outline,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildOverviewRow('Original Input', timeline.userMessage),
            const SizedBox(height: 8),
            _buildOverviewRow('Start Time', _formatDateTime(startTime)),
            const SizedBox(height: 8),
            if (endTime != null) _buildOverviewRow('End Time', _formatDateTime(endTime)),
            if (endTime != null) const SizedBox(height: 8),
            if (duration != null) _buildOverviewRow('Duration', '${duration.inMilliseconds}ms'),
            if (duration != null) const SizedBox(height: 8),
            _buildOverviewRow('Status', status.name.toUpperCase()),
            const SizedBox(height: 8),
            _buildOverviewRow('Total Phases', '${timelineData.phaseCount}'),
            if (timelineData.totalTokens > 0) const SizedBox(height: 8),
            if (timelineData.totalTokens > 0)
              _buildOverviewRow('Total Tokens', '${timelineData.totalTokens}'),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}

/// Enhanced Conversation Flow Section with improved visual design and interactions
class _ConversationFlowSection extends StatelessWidget {
  final TimelineOverviewData timelineData;
  final String? userInput;

  const _ConversationFlowSection({
    required this.timelineData,
    this.userInput,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.02),
              Colors.transparent,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced header with better visual hierarchy
              _buildSectionHeader(context),
              const SizedBox(height: 20),
              // Conversation flow with visual connection
              _buildConversationFlow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.forum_rounded,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Conversation Flow',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                'Interactive message exchange breakdown',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      height: 1.2,
                    ),
              ),
            ],
          ),
        ),
        // Quick stats
        _buildQuickStats(),
      ],
    );
  }

  Widget _buildQuickStats() {
    final promptCount = timelineData.promptMessages?.messages.length ?? 0;
    final responseCount = timelineData.generatedMessages?.messages.length ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.swap_vert, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            '${promptCount + responseCount} msgs',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationFlow() {
    return Column(
      children: [
        // User Input Card with enhanced design
        _EnhancedUserInputCard(
          userInput: userInput ?? timelineData.userMessage,
          promptMessages: timelineData.promptMessages?.messages ?? [],
        ),

        // Visual connector with animation
        _buildFlowConnector(),

        // AI Response Card with enhanced design
        _EnhancedAIResponseCard(
          aiResponse: _getAIResponse(timelineData),
          generatedMessages: timelineData.generatedMessages?.messages ?? [],
        ),
      ],
    );
  }

  Widget _buildFlowConnector() {
    return Container(
      height: 40,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vertical line
          Container(
            width: 2,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.withOpacity(0.3),
                  Colors.green.withOpacity(0.3),
                ],
              ),
            ),
          ),
          // Arrow indicator
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_downward_rounded,
              size: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _getAIResponse(TimelineOverviewData timelineData) {
    // Try to get AI response from generated messages
    if (timelineData.generatedMessages?.messages.isNotEmpty == true) {
      final aiMessages = timelineData.generatedMessages!.messages
          .where((msg) => msg.type == MessageType.ai)
          .toList();
      if (aiMessages.isNotEmpty) {
        return aiMessages.first.content;
      }
    }
    return 'Response not available or still processing...';
  }
}

/// Enhanced User Input Card with improved design and animations
class _EnhancedUserInputCard extends StatefulWidget {
  final String userInput;
  final List<MessageDisplayData> promptMessages;

  const _EnhancedUserInputCard({
    required this.userInput,
    required this.promptMessages,
  });

  @override
  State<_EnhancedUserInputCard> createState() => _EnhancedUserInputCardState();
}

class _EnhancedUserInputCardState extends State<_EnhancedUserInputCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Colors.blue[600]!;
    final lightColor = Colors.blue[50]!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isExpanded ? color.withOpacity(0.4) : Colors.grey[300]!,
          width: _isExpanded ? 2 : 1,
        ),
        boxShadow: _isExpanded
            ? [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced header
          _buildHeader(color, lightColor),
          // Content with smooth animation
          _buildContent(color, lightColor),
        ],
      ),
    );
  }

  Widget _buildHeader(Color color, Color lightColor) {
    return InkWell(
      onTap: _toggleExpansion,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              lightColor,
              lightColor.withOpacity(0.7),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(
          children: [
            // Enhanced icon with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _isExpanded ? color : color.withOpacity(0.8),
                borderRadius: BorderRadius.circular(6),
                boxShadow: _isExpanded
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                Icons.person_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Input',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: color,
                      fontSize: 16,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.userInput.length > 60
                        ? '${widget.userInput.substring(0, 60)}...'
                        : widget.userInput,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Action buttons
            _buildActionButtons(color),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Message count badge
        if (widget.promptMessages.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.message, size: 12, color: color),
                const SizedBox(width: 4),
                Text(
                  '${widget.promptMessages.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(width: 8),
        // Copy button
        _buildActionButton(
          icon: Icons.copy_rounded,
          color: color,
          onTap: () => _copyToClipboard(widget.userInput, 'User Input'),
        ),
        const SizedBox(width: 6),
        // Expand button
        _buildActionButton(
          icon: _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
          color: color,
          onTap: _toggleExpansion,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _buildContent(Color color, Color lightColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Column(
        children: [
          // Original input section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input text with better formatting
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    widget.userInput,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // Expandable messages section
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: widget.promptMessages.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.layers_rounded, size: 14, color: color),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Prompt Messages (${widget.promptMessages.length})',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...widget.promptMessages.map((message) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: EnhancedMessageTile(message: message),
                                )),
                          ],
                        )
                      : Container(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String content, String label) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// Enhanced AI Response Card with improved design and animations
class _EnhancedAIResponseCard extends StatefulWidget {
  final String aiResponse;
  final List<MessageDisplayData> generatedMessages;

  const _EnhancedAIResponseCard({
    required this.aiResponse,
    required this.generatedMessages,
  });

  @override
  State<_EnhancedAIResponseCard> createState() => _EnhancedAIResponseCardState();
}

class _EnhancedAIResponseCardState extends State<_EnhancedAIResponseCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Colors.green[600]!;
    final lightColor = Colors.green[50]!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isExpanded ? color.withOpacity(0.4) : Colors.grey[300]!,
          width: _isExpanded ? 2 : 1,
        ),
        boxShadow: _isExpanded
            ? [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced header
          _buildHeader(color, lightColor),
          // Content with smooth animation
          _buildContent(color, lightColor),
        ],
      ),
    );
  }

  Widget _buildHeader(Color color, Color lightColor) {
    return InkWell(
      onTap: _toggleExpansion,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              lightColor,
              lightColor.withOpacity(0.7),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Row(
          children: [
            // Enhanced icon with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _isExpanded ? color : color.withOpacity(0.8),
                borderRadius: BorderRadius.circular(6),
                boxShadow: _isExpanded
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                Icons.smart_toy_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Response',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: color,
                      fontSize: 16,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getResponsePreview(),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Action buttons
            _buildActionButtons(color),
          ],
        ),
      ),
    );
  }

  String _getResponsePreview() {
    if (widget.aiResponse.isEmpty ||
        widget.aiResponse == 'Response not available or still processing...') {
      return 'Processing response...';
    }
    return widget.aiResponse.length > 60
        ? '${widget.aiResponse.substring(0, 60)}...'
        : widget.aiResponse;
  }

  Widget _buildActionButtons(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Message count badge
        if (widget.generatedMessages.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 12, color: color),
                const SizedBox(width: 4),
                Text(
                  '${widget.generatedMessages.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(width: 8),
        // Copy button
        _buildActionButton(
          icon: Icons.copy_rounded,
          color: color,
          onTap: () => _copyToClipboard(widget.aiResponse, 'AI Response'),
        ),
        const SizedBox(width: 6),
        // Expand button
        _buildActionButton(
          icon: _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
          color: color,
          onTap: _toggleExpansion,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _buildContent(Color color, Color lightColor) {
    final isProcessing = widget.aiResponse.isEmpty ||
        widget.aiResponse == 'Response not available or still processing...';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Column(
        children: [
          // Response content section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Response text with better formatting
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isProcessing ? Colors.orange[50] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isProcessing ? Colors.orange[200]! : Colors.grey[200]!,
                    ),
                  ),
                  child: isProcessing
                      ? Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'AI response is being generated...',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: Colors.orange[800],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          widget.aiResponse,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                ),

                // Expandable messages section
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: widget.generatedMessages.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.auto_awesome, size: 14, color: color),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Generated Messages (${widget.generatedMessages.length})',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...widget.generatedMessages.map((message) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: EnhancedMessageTile(message: message),
                                )),
                          ],
                        )
                      : Container(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String content, String label) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
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
                phase.duration != null ? '${phase.duration!.inMilliseconds}ms' : 'In Progress...',
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
                      phase.duration != null ? '${phase.duration!.inMilliseconds}ms' : '...',
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
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
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
                      if (widget.phase.errorCount > 0 || widget.phase.warningCount > 0)
                        _CompactChip(
                          label: '${widget.phase.errorCount + widget.phase.warningCount}',
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
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Column(
                children: [
                  // Phase Metadata Section
                  _buildExpandableSection(
                    title: 'Phase Metadata',
                    icon: Icons.info_outline,
                    color: Colors.indigo,
                    isExpanded: _showMetadata,
                    onToggle: () => setState(() => _showMetadata = !_showMetadata),
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
    if (phase.contains('query') || phase.contains('process')) return Icons.search;
    if (phase.contains('context') || phase.contains('build')) return Icons.build;
    if (phase.contains('generation') || phase.contains('ai')) return Icons.smart_toy;
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
      if (phase.duration != null) 'Duration': '${phase.duration!.inMilliseconds}ms',
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
        children: steps.map((step) => _EnhancedStepDisplay(step: step)).toList(),
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
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
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
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    ...widget.step.metadata.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: const TextStyle(fontSize: 9, fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (widget.step.logs.isNotEmpty) ...[
                    Text(
                      'Logs (${widget.step.logs.length}):',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    ...widget.step.logs.take(3).map(
                          (log) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1),
                            child: Text(
                              '[${log.severity.toString().split('.').last.toUpperCase()}] ${log.message}',
                              style: const TextStyle(fontSize: 9, fontFamily: 'monospace'),
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
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: _getSeverityColor(log.severity).withAlpha(51),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        log.severity.toString().split('.').last.toUpperCase().substring(0, 1),
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

/// Enhanced Message Tile with improved design and better interaction
class EnhancedMessageTile extends StatefulWidget {
  final MessageDisplayData message;

  const EnhancedMessageTile({
    super.key,
    required this.message,
  });

  @override
  State<EnhancedMessageTile> createState() => _EnhancedMessageTileState();
}

class _EnhancedMessageTileState extends State<EnhancedMessageTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final color = _getMessageTypeColor(message.type);
    final icon = _getMessageTypeIcon(message.type);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isExpanded ? color.withOpacity(0.4) : color.withOpacity(0.2),
          width: _isExpanded ? 2 : 1,
        ),
        color: Colors.white,
        boxShadow: _isExpanded
            ? [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with message type and controls
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.08),
                    color.withOpacity(0.04),
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(12),
                  bottom: Radius.circular(_isExpanded ? 0 : 12),
                ),
              ),
              child: Row(
                children: [
                  // Enhanced icon
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _isExpanded ? color : color.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(icon, size: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  // Message type label
                  Text(
                    _getMessageTypeLabel(message.type),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color,
                      fontSize: 13,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Content preview
                  Expanded(
                    child: Text(
                      _getTruncatedContent(message.content),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Character count badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${message.characterCount}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Copy button
                  InkWell(
                    onTap: () => _copyToClipboard(message.content),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.copy,
                        size: 12,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Expand/collapse icon
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _isExpanded ? 0.5 : 0,
                    child: Icon(
                      Icons.expand_more,
                      size: 16,
                      color: color.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expanded content with animation
          if (_isExpanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timestamp if available
                  if (message.timestamp != null) ...[
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Timestamp: ${message.timestamp}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Full message content with enhanced styling
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.1)),
                    ),
                    child: SelectableText(
                      message.content,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        height: 1.4,
                        color: Colors.black87,
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

  Color _getMessageTypeColor(MessageType type) {
    switch (type) {
      case MessageType.system:
        return Colors.deepPurple;
      case MessageType.human:
        return Colors.blue;
      case MessageType.ai:
        return Colors.green;
      case MessageType.functionCall:
        return Colors.orange;
      case MessageType.functionResponse:
        return Colors.teal;
      case MessageType.unknown:
        return Colors.grey;
    }
  }

  IconData _getMessageTypeIcon(MessageType type) {
    switch (type) {
      case MessageType.system:
        return Icons.settings;
      case MessageType.human:
        return Icons.person;
      case MessageType.ai:
        return Icons.smart_toy;
      case MessageType.functionCall:
        return Icons.functions;
      case MessageType.functionResponse:
        return Icons.receipt;
      case MessageType.unknown:
        return Icons.help_outline;
    }
  }

  String _getMessageTypeLabel(MessageType type) {
    switch (type) {
      case MessageType.system:
        return 'SYSTEM';
      case MessageType.human:
        return 'HUMAN';
      case MessageType.ai:
        return 'AI';
      case MessageType.functionCall:
        return 'FUNCTION CALL';
      case MessageType.functionResponse:
        return 'FUNCTION RESPONSE';
      case MessageType.unknown:
        return 'UNKNOWN';
    }
  }

  String _getTruncatedContent(String content) {
    if (content.length <= 50) return content;
    return '${content.substring(0, 50)}...';
  }

  void _copyToClipboard(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Message content copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
