import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:kai_engine/kai_engine.dart';

/// Standalone screen for editing messages and generating responses
class EditGenerateScreen extends StatefulWidget {
  const EditGenerateScreen({
    super.key,
    required this.originalMessages,
    required this.generationService,
  });

  final List<CoreMessage> originalMessages;
  final GenerationServiceBase generationService;

  @override
  State<EditGenerateScreen> createState() => _EditGenerateScreenState();
}

class _EditGenerateScreenState extends State<EditGenerateScreen> {
  late List<TextEditingController> _controllers;
  String? _generatedResponse;
  bool _isGenerating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with original message content
    _controllers =
        widget.originalMessages.map((msg) => TextEditingController(text: msg.content)).toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Generate response using current message content
  Future<void> _generateResponse() async {
    if (_isGenerating) return;

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _generatedResponse = null;
    });

    try {
      // Build messages from current text field content
      final messages = <CoreMessage>[];
      for (int i = 0; i < widget.originalMessages.length; i++) {
        final originalMessage = widget.originalMessages[i];
        final currentContent = _controllers[i].text;

        // Create new message with updated content
        switch (originalMessage.type) {
          case CoreMessageType.system:
            messages.add(CoreMessage.system(currentContent));
            break;
          case CoreMessageType.user:
            messages.add(CoreMessage.user(content: currentContent));
            break;
          case CoreMessageType.ai:
            messages.add(CoreMessage.ai(content: currentContent));
            break;
          case CoreMessageType.function:
          case CoreMessageType.unknown:
            messages.add(CoreMessage.ai(content: currentContent));
            break;
        }
      }

      // Call generation service
      final response = await widget.generationService.invoke(IList(messages));

      if (mounted) {
        setState(() {
          _generatedResponse = response;
          _isGenerating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isGenerating = false;
        });
      }
    }
  }

  /// Get message type display name
  String _getMessageTypeName(CoreMessageType type) {
    switch (type) {
      case CoreMessageType.system:
        return 'System Prompt';
      case CoreMessageType.user:
        return 'User Message';
      case CoreMessageType.ai:
        return 'AI Message';
      case CoreMessageType.function:
        return 'Function Call';
      case CoreMessageType.unknown:
        return 'Unknown Message';
    }
  }

  /// Get message type icon
  IconData _getMessageTypeIcon(CoreMessageType type) {
    switch (type) {
      case CoreMessageType.system:
        return Icons.settings_system_daydream;
      case CoreMessageType.user:
        return Icons.person_outline;
      case CoreMessageType.ai:
        return Icons.smart_toy_outlined;
      case CoreMessageType.function:
        return Icons.functions;
      case CoreMessageType.unknown:
        return Icons.help_outline;
    }
  }

  /// Get message type color
  Color _getMessageTypeColor(BuildContext context, CoreMessageType type) {
    switch (type) {
      case CoreMessageType.system:
        return Theme.of(context).colorScheme.tertiary;
      case CoreMessageType.user:
        return Theme.of(context).colorScheme.primary;
      case CoreMessageType.ai:
        return Theme.of(context).colorScheme.secondary;
      case CoreMessageType.function:
        return Theme.of(context).colorScheme.error;
      case CoreMessageType.unknown:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Edit & Generate',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          FilledButton.icon(
            onPressed: _isGenerating ? null : _generateResponse,
            icon: _isGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome, size: 18),
            label: Text(_isGenerating ? 'Generating...' : 'Generate'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          const SizedBox(width: 16),
        ],
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
        child: Column(
          children: [
            // Message editor list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 50),
                itemCount: widget.originalMessages.length +
                    (_generatedResponse != null ? 1 : 0) +
                    (_errorMessage != null ? 1 : 0),
                itemBuilder: (context, index) {
                  // Message editors
                  if (index < widget.originalMessages.length) {
                    final message = widget.originalMessages[index];
                    final controller = _controllers[index];
                    final typeColor = _getMessageTypeColor(context, message.type);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: typeColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Message type header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.08),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              border: Border(
                                bottom: BorderSide(
                                  color: typeColor.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: typeColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getMessageTypeIcon(message.type),
                                    size: 18,
                                    color: typeColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _getMessageTypeName(message.type),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: typeColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          // Text editor
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: TextField(
                              controller: controller,
                              maxLines: null,
                              minLines: 3,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    height: 1.5,
                                    fontFamily: 'monospace',
                                  ),
                              decoration: InputDecoration(
                                hintText: 'Enter message content...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Generated response
                  if (_generatedResponse != null && index == widget.originalMessages.length) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Response header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.08),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              border: Border(
                                bottom: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome,
                                    size: 18,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Generated Response',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          // Response content
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: SelectableText(
                              _generatedResponse!,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    height: 1.5,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Error message
                  if (_errorMessage != null &&
                      index ==
                          widget.originalMessages.length + (_generatedResponse != null ? 1 : 0)) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[300]!, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Generation Failed',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: Colors.red[800],
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _errorMessage!,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.red[700],
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
