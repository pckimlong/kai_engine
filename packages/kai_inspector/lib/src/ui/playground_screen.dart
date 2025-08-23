import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kai_engine/kai_engine.dart';
import 'package:kai_inspector/src/ui/debug_data_adapter.dart';

import 'playground/edit_generate_screen.dart';
import 'playground/message_bubble.dart';
import 'playground/prompts.dart';
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
    return widget.data.promptMessages?.messages.map((e) => e.coreMessage).toList() ?? [];
  }

  List<CoreMessage> get _generatedMessages {
    return widget.data.generatedMessages?.messages.map((e) => e.coreMessage).toList() ?? [];
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
          generatedMessages: _generatedMessages,
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

  /// Copy the full conversation to clipboard
  void _copyConversation() {
    final allMessages = [..._originalMessages, ..._generatedMessages];
    final xml = _messagesToXml(allMessages);
    Clipboard.setData(ClipboardData(text: xml));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Full conversation copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show a dialog to get an instruction and then copy an analysis prompt
  Future<void> _copyAnalysis() async {
    final instruction = await _showInstructionDialog(
      title: 'Analysis Instruction',
      initialValue: 'Analyze this conversation and response',
    );

    if (instruction == null || instruction.isEmpty || !mounted) return;

    final prompt = PlaygroundPrompts.analyzeConversation(
      _originalMessages,
      _generatedMessages,
      instruction,
    );
    Clipboard.setData(ClipboardData(text: prompt));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Analysis prompt copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Convert messages to XML format
  String _messagesToXml(List<CoreMessage> messages) {
    final result = StringBuffer();
    for (final msg in messages) {
      final tagName = msg.type.name;
      result.writeln('<${tagName}_message timestamp="${msg.timestamp.toIso8601String()}">');
      result.writeln(msg.content);
      result.writeln('</${tagName}_message>');
    }
    return result.toString();
  }

  /// Show a dialog to get a custom instruction from the user
  Future<String?> _showInstructionDialog({
    required String title,
    required String initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter your instruction',
            ),
            maxLines: null,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: const Text('Copy'),
            ),
          ],
        );
      },
    );
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
              Theme.of(context).colorScheme.surface.withOpacity(0.95),
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

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ..._originalMessages.map((m) => _buildMessageBubble(m, false)),
        _buildActionBar(),
        ..._generatedMessages.map((m) => _buildMessageBubble(m, false)),
        if (_generatedMessages.isNotEmpty) _buildResponseActionBar(),
        const SizedBox(height: 80),
      ],
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
    return _ActionBar(
      children: [
        ElevatedButton.icon(
          onPressed: _copyRequest,
          icon: const Icon(Icons.content_copy_outlined),
          label: const Text('Copy Request'),
        ),
        const SizedBox(width: 16.0),
        FilledButton.icon(
          onPressed: _openEditScreen,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit & Generate'),
        ),
      ],
    );
  }

  Widget _buildResponseActionBar() {
    return _ActionBar(
      children: [
        ElevatedButton.icon(
          onPressed: _copyConversation,
          icon: const Icon(Icons.copy_all_outlined),
          label: const Text('Copy Conversation'),
        ),
        const SizedBox(width: 16.0),
        FilledButton.icon(
          onPressed: _copyAnalysis,
          icon: const Icon(Icons.analytics_outlined),
          label: const Text('Copy Analysis'),
        ),
      ],
    );
  }
}

/// A consistent container for action buttons
class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final buttonStyle = ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 14.0,
            ),
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          );

          final smallScreen = constraints.maxWidth < 450;

          if (smallScreen) {
            // Vertical layout for small screens
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: children
                  .map<Widget>(
                    (child) => SizedBox(
                      width: double.infinity,
                      child: child,
                    ),
                  )
                  .expand((widget) => [widget, const SizedBox(height: 8)])
                  .toList()
                ..removeLast(),
            );
          } else {
            // Horizontal layout for larger screens
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children
                  .map<Widget>(
                    (child) => child is ButtonStyleButton
                        ? ElevatedButton(
                            onPressed: (child).onPressed,
                            style: buttonStyle,
                            child: (child as dynamic).child,
                          )
                        : child,
                  )
                  .toList(),
            );
          }
        },
      ),
    );
  }
}
