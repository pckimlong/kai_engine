import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../debug_system.dart';

/// Simple debug info widget that shows debug data for a specific message
class MessageDebugWidget extends StatelessWidget {
  final String messageId;

  const MessageDebugWidget({super.key, required this.messageId});

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) return const SizedBox.shrink();

    final debugInfo = KaiDebug.getMessageInfo(messageId);
    if (debugInfo == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(4),
      child: Padding(
        padding: const EdgeInsets.all(8),
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
                  size: 16,
                  color: debugInfo.hasError
                      ? Colors.red
                      : debugInfo.isComplete
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  'Debug: ${messageId.substring(0, 8)}...',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (debugInfo.totalDuration != null)
                  Text(
                    '${debugInfo.totalDuration!.inMilliseconds}ms',
                    style: const TextStyle(fontSize: 10),
                  ),
              ],
            ),
            if (debugInfo.usage?.tokenCount != null)
              Text('Tokens: ${debugInfo.usage!.tokenCount}', style: const TextStyle(fontSize: 10)),
            if (debugInfo.usage != null)
              Text(
                'Usage: ${debugInfo.usage!.inputToken ?? 0} in, ${debugInfo.usage!.outputToken ?? 0} out',
                style: const TextStyle(fontSize: 10),
              ),
            if (debugInfo.streaming.eventCount > 0)
              Text(
                'Streaming: ${debugInfo.streaming.eventCount} events',
                style: const TextStyle(fontSize: 10),
              ),
            if (debugInfo.phases.isNotEmpty)
              Wrap(
                spacing: 4,
                children: debugInfo.phases.entries
                    .map(
                      (e) => Chip(
                        label: Text(
                          '${e.key}: ${e.value.duration?.inMilliseconds ?? "?"}ms',
                          style: const TextStyle(fontSize: 8),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

/// Floating debug overlay showing recent messages
class DebugFloatingOverlay extends StatefulWidget {
  final Widget child;

  const DebugFloatingOverlay({super.key, required this.child});

  @override
  State<DebugFloatingOverlay> createState() => _DebugFloatingOverlayState();
}

class _DebugFloatingOverlayState extends State<DebugFloatingOverlay> {
  bool _showDebug = false;

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) return widget.child;

    return Stack(
      children: [widget.child, if (_showDebug) _buildDebugPanel(), _buildToggleButton()],
    );
  }

  Widget _buildToggleButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      right: 10,
      child: FloatingActionButton.small(
        onPressed: () => setState(() => _showDebug = !_showDebug),
        child: Icon(_showDebug ? Icons.close : Icons.bug_report),
        backgroundColor: Colors.red.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildDebugPanel() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 70,
      right: 10,
      bottom: 100,
      width: 350,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 2),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bug_report, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Debug Messages',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<MessageDebugInfo>(
                stream: KaiDebug.stream,
                builder: (context, snapshot) {
                  final recentMessages = KaiDebug.getRecentMessages();

                  if (recentMessages.isEmpty) {
                    return const Center(child: Text('No debug messages'));
                  }

                  return ListView.builder(
                    itemCount: recentMessages.length,
                    itemBuilder: (context, index) => _buildMessageItem(recentMessages[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(MessageDebugInfo info) {
    return ExpansionTile(
      title: Text(
        info.originalInput.length > 30
            ? '${info.originalInput.substring(0, 30)}...'
            : info.originalInput,
        style: const TextStyle(fontSize: 12),
      ),
      subtitle: Row(
        children: [
          Icon(
            info.hasError
                ? Icons.error
                : info.isComplete
                ? Icons.check_circle
                : Icons.hourglass_empty,
            size: 16,
            color: info.hasError
                ? Colors.red
                : info.isComplete
                ? Colors.green
                : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            info.totalDuration?.inMilliseconds != null
                ? '${info.totalDuration!.inMilliseconds}ms'
                : 'Running...',
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Message ID', info.messageId),
              _buildInfoRow('Start Time', info.startTime.toString()),
              if (info.usage?.tokenCount != null)
                _buildInfoRow('Tokens', info.usage!.tokenCount.toString()),
              if (info.usage != null)
                _buildInfoRow(
                  'Usage',
                  '${info.usage!.inputToken ?? 0} in, ${info.usage!.outputToken ?? 0} out',
                ),
              if (info.generationConfig?.availableTools.isNotEmpty == true)
                _buildInfoRow('Tools', info.generationConfig!.availableTools.join(', ')),
              _buildInfoRow('Streaming Events', info.streaming.eventCount.toString()),
              if (info.generationConfig?.usedEmbedding == true)
                _buildInfoRow('Used Embedding', 'Yes'),
              if (info.error != null) _buildInfoRow('Error', info.error.toString()),
              const Divider(height: 16),
              const Text(
                'Phase Durations:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
              ),
              ...info.phases.entries.map(
                (e) => _buildInfoRow(
                  e.key,
                  e.value.duration?.inMilliseconds != null
                      ? '${e.value.duration!.inMilliseconds}ms'
                      : 'In Progress...',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 10))),
        ],
      ),
    );
  }
}

/// Simple stats widget
class DebugStatsWidget extends StatelessWidget {
  const DebugStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) return const SizedBox.shrink();

    return StreamBuilder<MessageDebugInfo>(
      stream: KaiDebug.stream,
      builder: (context, snapshot) {
        final messages = KaiDebug.getRecentMessages();
        final completedMessages = messages.where((m) => m.isComplete).toList();
        final errorMessages = messages.where((m) => m.hasError).toList();

        if (messages.isEmpty) return const SizedBox.shrink();

        final avgDuration = completedMessages.isNotEmpty
            ? completedMessages
                      .map((m) => m.totalDuration?.inMilliseconds ?? 0)
                      .reduce((a, b) => a + b) /
                  completedMessages.length
            : 0.0;

        return Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.analytics, size: 16, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                'Messages: ${messages.length} | '
                'Avg: ${avgDuration.round()}ms | '
                'Errors: ${errorMessages.length}',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}
