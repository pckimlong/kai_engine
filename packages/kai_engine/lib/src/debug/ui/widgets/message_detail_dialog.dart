import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/core_message.dart';

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
                    const Text(
                      'Content:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
                      const Text(
                        'Extensions:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                          const JsonEncoder.withIndent(
                            '  ',
                          ).convert(message.extensions),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Content copied to clipboard'),
                      ),
                    );
                  },
                  child: const Text('Copy Content'),
                ),
                TextButton(
                  onPressed: () {
                    final fullData = const JsonEncoder.withIndent('  ')
                        .convert({
                          'messageId': message.messageId,
                          'type': message.type.name,
                          'content': message.content,
                          'isBackgroundContext': message.isBackgroundContext,
                          'timestamp': message.timestamp.toIso8601String(),
                          'extensions': message.extensions,
                        });
                    Clipboard.setData(ClipboardData(text: fullData));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Full message data copied to clipboard'),
                      ),
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
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
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
