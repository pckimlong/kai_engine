import 'package:flutter/material.dart';
import 'package:kai_engine/kai_engine.dart';

/// Widget for displaying user input and AI response messages
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isRequest,
    required this.isEdited,
    required this.hasUnregeneratedEdit,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onEditPressed,
    required this.onResetPressed,
    this.onSelectionChanged,
    this.isSelected = false,
    this.showEditControls = true,
    this.showSelectionControls = true,
  });

  final CoreMessage message;
  final bool isRequest;
  final bool isEdited;
  final bool hasUnregeneratedEdit;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback onEditPressed;
  final VoidCallback onResetPressed;
  final ValueChanged<bool?>? onSelectionChanged;
  final bool isSelected;
  final bool showEditControls;
  final bool showSelectionControls;

  String _truncateContent(String content, int maxLength) {
    if (content.length <= maxLength) {
      return content;
    }

    // Find the last space before the maxLength to avoid cutting words
    final truncated = content.substring(0, maxLength);
    final lastSpaceIndex = truncated.lastIndexOf(' ');

    if (lastSpaceIndex > 0) {
      return '${truncated.substring(0, lastSpaceIndex)}...';
    } else {
      return '${truncated.substring(0, maxLength - 3)}...';
    }
  }

  /// Get message type display information
  (String label, IconData icon, Color color) _getMessageTypeInfo(BuildContext context) {
    switch (message.type) {
      case CoreMessageType.system:
        return (
          'System Prompt',
          Icons.settings_system_daydream,
          Theme.of(context).colorScheme.tertiary,
        );
      case CoreMessageType.user:
        return (
          'User Message',
          Icons.person_outline,
          Theme.of(context).colorScheme.primary,
        );
      case CoreMessageType.ai:
        return (
          'AI Response',
          Icons.smart_toy_outlined,
          Theme.of(context).colorScheme.secondary,
        );
      case CoreMessageType.function:
        return (
          'Function Call',
          Icons.functions,
          Theme.of(context).colorScheme.error,
        );
      case CoreMessageType.unknown:
        return (
          'Unknown Message',
          Icons.help_outline,
          Colors.grey,
        );
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (message.type) {
      case CoreMessageType.system:
        return Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.7);
      case CoreMessageType.user:
        return Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.8);
      case CoreMessageType.ai:
        return Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.6);
      case CoreMessageType.function:
        return Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.6);
      case CoreMessageType.unknown:
        return Colors.grey.shade100;
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (message.type) {
      case CoreMessageType.system:
        return Theme.of(context).colorScheme.onTertiaryContainer;
      case CoreMessageType.user:
        return Theme.of(context).colorScheme.onPrimaryContainer;
      case CoreMessageType.ai:
        return Theme.of(context).colorScheme.onSecondaryContainer;
      case CoreMessageType.function:
        return Theme.of(context).colorScheme.onErrorContainer;
      case CoreMessageType.unknown:
        return Colors.grey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final (label, icon, labelColor) = _getMessageTypeInfo(context);
    final backgroundColor = _getBackgroundColor(context);
    final textColor = _getTextColor(context);

    // Truncate content for preview when collapsed
    final previewContent = _truncateContent(message.content, 200);

    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
        border: isEdited
            ? Border.all(
                color: Colors.orange,
                width: 2.0,
              )
            : Border.all(
                color: labelColor.withValues(alpha: 0.3),
                width: 1.0,
              ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
            blurRadius: 12.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced message header with proper message type detection
          Container(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 12.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  labelColor.withValues(alpha: 0.08),
                  labelColor.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
              border: Border(
                bottom: BorderSide(
                  color: labelColor.withValues(alpha: 0.2),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              children: [
                // Selection checkbox for request messages only
                if (showSelectionControls && isRequest && onSelectionChanged != null) ...[
                  Transform.scale(
                    scale: 0.9,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: onSelectionChanged,
                      fillColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return labelColor;
                        }
                        return null;
                      }),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                ],

                // Message type icon and label
                Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: labelColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Icon(
                    icon,
                    size: 16.0,
                    color: labelColor,
                  ),
                ),
                const SizedBox(width: 12.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: labelColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                    ),
                    // Show edited indicator
                    if (isEdited)
                      Text(
                        'EDITED',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                            ),
                      ),
                  ],
                ),
                const Spacer(),

                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Character count badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: labelColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: labelColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '${message.content.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: labelColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Edit button (for request messages only)
                    if (showEditControls && isRequest)
                      _ActionButton(
                        icon: Icons.edit_outlined,
                        color: labelColor,
                        onPressed: onEditPressed,
                        tooltip: 'Edit message',
                      ),

                    // Reset button (only visible for edited messages)
                    if (showEditControls && isEdited && isRequest)
                      _ActionButton(
                        icon: Icons.undo_outlined,
                        color: Colors.orange,
                        onPressed: onResetPressed,
                        tooltip: 'Reset to original',
                      ),

                    // Expand/Collapse button
                    _ActionButton(
                      icon: isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: labelColor,
                      onPressed: onToggleExpanded,
                      tooltip: isExpanded ? 'Collapse message' : 'Expand message',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Message content with enhanced styling
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: labelColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: SelectableText(
                    isExpanded ? message.content : previewContent,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textColor,
                          height: 1.6,
                          letterSpacing: 0.1,
                          fontFamily: 'monospace',
                        ),
                  ),
                ),

                // Unregenerated changes indicator
                if (hasUnregeneratedEdit) ...[
                  const SizedBox(height: 12.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: Colors.orange,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pending_actions,
                          size: 16.0,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            'Message has been modified. Click "Regenerate" to apply changes.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
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

/// Helper widget for action buttons in message header
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6.0),
          child: Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              icon,
              size: 14.0,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
