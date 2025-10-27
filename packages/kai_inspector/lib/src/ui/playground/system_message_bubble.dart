import 'package:flutter/material.dart';
import 'package:kai_engine/kai_engine.dart';

/// Widget for displaying system prompt messages
class SystemMessageBubble extends StatelessWidget {
  const SystemMessageBubble({
    super.key,
    required this.message,
    required this.isExpanded,
    required this.onToggleExpanded,
    this.isEdited = false,
    this.onEditPressed,
    this.onResetPressed,
    this.showEditControls = true,
  });

  final CoreMessage message;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final bool isEdited;
  final VoidCallback? onEditPressed;
  final VoidCallback? onResetPressed;
  final bool showEditControls;

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

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.7);
    final textColor = Theme.of(context).colorScheme.onTertiaryContainer;
    final labelColor = Theme.of(context).colorScheme.tertiary;

    // Truncate content for preview when collapsed
    final previewContent = _truncateContent(message.content, 200);

    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.3),
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
          // System message header
          Container(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 12.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.settings_system_daydream,
                      size: 18.0,
                      color: labelColor,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'System Prompt',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: labelColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (isEdited) ...[
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          'EDITED',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
                const Spacer(),
                // Action buttons
                if (showEditControls && onEditPressed != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEditPressed,
                    tooltip: 'Edit system prompt',
                    iconSize: 18.0,
                  ),
                if (showEditControls && isEdited && onResetPressed != null)
                  IconButton(
                    icon: const Icon(Icons.undo_outlined),
                    onPressed: onResetPressed,
                    tooltip: 'Reset to original',
                    iconSize: 18.0,
                  ),
                // Expand/Collapse button
                IconButton(
                  icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: onToggleExpanded,
                  tooltip: isExpanded ? 'Collapse message' : 'Expand message',
                  iconSize: 18.0,
                ),
              ],
            ),
          ),
          // Message content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 20.0),
            child: SelectableText(
              isExpanded ? message.content : previewContent,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    height: 1.5,
                    letterSpacing: 0.1,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
