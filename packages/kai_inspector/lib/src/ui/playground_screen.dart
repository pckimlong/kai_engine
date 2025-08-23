import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kai_engine/kai_engine.dart';
import 'package:kai_inspector/src/ui/debug_data_adapter.dart';

import 'playground/edit_generate_screen.dart';
import 'playground/message_bubble.dart';
import 'playground/system_message_bubble.dart';

/// Simplified playground screen for viewing messages and launching editor
class PlaygroundScreen extends StatefulWidget {
  const PlaygroundScreen({
    super.key,
    required this.generationService,
    required this.data,
  });

  final TimelineOverviewData data;
  final GenerationServiceBase generationService;

  @override
  State<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends State<PlaygroundScreen> {
  // Simple UI state
  final Map<String, bool> _expandedStates = {};

  // Original messages converted to CoreMessages for display
  List<CoreMessage> get _originalMessages {
    return widget.data.promptMessages?.messages
            .map((e) => e.coreMessage)
            .toList() ??
        [];
  }

  List<CoreMessage> get _generatedMessages {
    return widget.data.generatedMessages?.messages
            .map((e) => e.coreMessage)
            .toList() ??
        [];
  }

  /// Toggle message expansion state
  void _toggleExpansion(String messageId) {
    setState(() {
      _expandedStates[messageId] = !(_expandedStates[messageId] ?? false);
    });
  }

  /// Open the Edit & Generate screen
  void _openEditScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditGenerateScreen(
          originalMessages: _originalMessages,
          generationService: widget.generationService,
        ),
      ),
    );
  }

  /// Copy request messages as XML to clipboard
  void _copyRequest() {
    final xml = _messagesToXml(_originalMessages);
    Clipboard.setData(ClipboardData(text: xml));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Convert messages to XML format
  String _messagesToXml(List<CoreMessage> messages) {
    final result = StringBuffer();
    for (final msg in messages) {
      final tagName = msg.type.name;
      result
          .writeln('<$tagName timestamp="${msg.timestamp.toIso8601String()}">');
      result.writeln(msg.content);
      result.writeln('</$tagName>');
    }
    return result.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'AI Playground',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
            ],
          ),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_originalMessages.isEmpty && _generatedMessages.isEmpty) {
      return const Center(
        child: Text('No messages to display'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _originalMessages.length + 1 + _generatedMessages.length + 1,
      itemBuilder: (context, index) {
        // Original messages
        if (index < _originalMessages.length) {
          final message = _originalMessages[index];
          return _buildMessageBubble(message, false);
        }

        // Action bar between request and response
        if (index == _originalMessages.length) {
          return _buildActionBar();
        }

        // Generated messages
        if (index < _originalMessages.length + 1 + _generatedMessages.length) {
          final messageIndex = index - _originalMessages.length - 1;
          final message = _generatedMessages[messageIndex];
          return _buildMessageBubble(message, false);
        }

        // Bottom padding
        return const SizedBox(height: 80);
      },
    );
  }

  Widget _buildMessageBubble(CoreMessage message, bool isEditable) {
    // System message gets special treatment
    if (message.type == CoreMessageType.system) {
      return SystemMessageBubble(
        message: message,
        isExpanded: _expandedStates[message.messageId] ?? false,
        onToggleExpanded: () => _toggleExpansion(message.messageId),
        showEditControls: false,
      );
    }

    // Regular message bubble (read-only)
    return MessageBubble(
      message: message,
      isRequest: message.type != CoreMessageType.ai,
      isEdited: false,
      hasUnregeneratedEdit: false,
      isExpanded: _expandedStates[message.messageId] ?? false,
      onToggleExpanded: () => _toggleExpansion(message.messageId),
      // Remove all editing functionality
      onEditPressed: () {},
      onResetPressed: () {},
      showEditControls: false,
      showSelectionControls: false,
    );
  }

  Widget _buildActionBar() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use a responsive layout that adapts to screen size
          if (constraints.maxWidth < 400) {
            // Vertical layout for small screens
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _copyRequest,
                    icon: const Icon(Icons.content_copy_outlined),
                    label: const Text('Copy Request'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _openEditScreen,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit & Generate'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Horizontal layout for larger screens
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _copyRequest,
                  icon: const Icon(Icons.content_copy_outlined),
                  label: const Text('Copy Request'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 14.0,
                    ),
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                FilledButton.icon(
                  onPressed: _openEditScreen,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit & Generate'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 14.0,
                    ),
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
