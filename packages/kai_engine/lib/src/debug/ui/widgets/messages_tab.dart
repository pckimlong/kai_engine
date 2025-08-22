import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/core_message.dart';
import '../../debug_system.dart';
import 'message_detail_dialog.dart';
import 'shared_widgets.dart';

class MessagesTab extends StatelessWidget {
  final MessageDebugInfo debugInfo;

  const MessagesTab({super.key, required this.debugInfo});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _ContextMessagesSection(debugInfo: debugInfo),
          const SizedBox(height: 16),
          _FinalPromptsSection(debugInfo: debugInfo),
          const SizedBox(height: 16),
          _GeneratedMessagesSection(debugInfo: debugInfo),
          const SizedBox(height: 16),
          _StreamingSection(debugInfo: debugInfo),
        ],
      ),
    );
  }
}

class _ContextMessagesSection extends StatelessWidget {
  final MessageDebugInfo debugInfo;

  const _ContextMessagesSection({required this.debugInfo});

  @override
  Widget build(BuildContext context) {
    final contextMessages = debugInfo.contextMessages;
    return ExpandableSectionCard(
      title: 'Context Messages',
      subtitle: contextMessages != null
          ? '${contextMessages.length} messages'
          : 'Not available',
      icon: Icons.history,
      initiallyExpanded: true,
      child: contextMessages != null
          ? _MessagesList(messages: contextMessages)
          : const Text('Context messages not available'),
    );
  }
}

class _FinalPromptsSection extends StatelessWidget {
  final MessageDebugInfo debugInfo;

  const _FinalPromptsSection({required this.debugInfo});

  @override
  Widget build(BuildContext context) {
    final finalPrompts = debugInfo.finalPrompts;
    return ExpandableSectionCard(
      title: 'Final Prompts',
      subtitle: finalPrompts != null
          ? '${finalPrompts.length} prompts'
          : 'Not available',
      icon: Icons.edit_note,
      child: finalPrompts != null
          ? _MessagesList(messages: finalPrompts)
          : const Text('Final prompts not available'),
    );
  }
}

class _GeneratedMessagesSection extends StatelessWidget {
  final MessageDebugInfo debugInfo;

  const _GeneratedMessagesSection({required this.debugInfo});

  @override
  Widget build(BuildContext context) {
    final generatedMessages = debugInfo.generatedMessages;
    return ExpandableSectionCard(
      title: 'Generated Messages',
      subtitle: generatedMessages != null
          ? '${generatedMessages.length} messages'
          : 'Not available',
      icon: Icons.auto_awesome,
      child: generatedMessages != null
          ? _MessagesList(messages: generatedMessages)
          : const Text('Generated messages not available'),
    );
  }
}

class _StreamingSection extends StatelessWidget {
  final MessageDebugInfo debugInfo;

  const _StreamingSection({required this.debugInfo});

  @override
  Widget build(BuildContext context) {
    final streaming = debugInfo.streaming;
    return ExpandableSectionCard(
      title: 'Streaming Data',
      subtitle:
          '${streaming.eventCount} events, ${streaming.chunks.length} chunks',
      icon: Icons.stream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoChip(
                label: 'Events',
                value: '${streaming.eventCount}',
                color: Colors.blue,
              ),
              InfoChip(
                label: 'Chunks',
                value: '${streaming.chunks.length}',
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (streaming.fullText.isNotEmpty) ...[
            const Text(
              'Full Streaming Text:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                streaming.fullText,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MessagesList extends StatelessWidget {
  final Iterable<CoreMessage> messages;

  const _MessagesList({required this.messages});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: messages
          .map((message) => _MessageCard(message: message))
          .toList(),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final CoreMessage message;

  const _MessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(_getMessageTypeIcon(message.type)),
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
                    InfoChip(
                      label: 'ID',
                      value: message.messageId.substring(0, 8),
                      color: Colors.grey,
                    ),
                    InfoChip(
                      label: 'Background',
                      value: message.isBackgroundContext ? 'Yes' : 'No',
                      color: message.isBackgroundContext
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Content:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
                if (message.extensions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Extensions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
                      const JsonEncoder.withIndent(
                        '  ',
                      ).convert(message.extensions),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    TextButton.icon(
                      onPressed: () =>
                          _copyToClipboard(context, message.content),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy'),
                    ),
                    TextButton.icon(
                      onPressed: () => _showMessageDetail(context, message),
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

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  void _showMessageDetail(BuildContext context, CoreMessage message) {
    showDialog(
      context: context,
      builder: (context) => MessageDetailDialog(message: message),
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
