import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:kai_engine/kai_engine.dart';

import '../kai_chat_theme.dart';

typedef KaiMessageContentBuilder = Widget Function(BuildContext context, CoreMessage message);

/// Default bubble used by [KaiMessageList] / [KaiChatView].
class KaiMessageBubble extends StatelessWidget {
  const KaiMessageBubble({
    super.key,
    required this.message,
    this.contentBuilder,
    this.onTap,
    this.isUserMessage,
    this.semanticLabel,
    this.showTimeLabel = false,
  });

  final CoreMessage message;
  final KaiMessageContentBuilder? contentBuilder;
  final VoidCallback? onTap;
  final bool? isUserMessage;
  final String? semanticLabel;
  final bool showTimeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.kaiChatTheme;
    final isUser = isUserMessage ?? message.type == CoreMessageType.user;

    final colors = Theme.of(context).colorScheme;
    final bubbleColor = isUser
        ? (theme.userBubbleColor ?? colors.primary)
        : (theme.aiBubbleColor ?? colors.surfaceContainerHighest);
    final textColor = isUser
        ? (theme.userTextColor ?? colors.onPrimary)
        : (theme.aiTextColor ?? colors.onSurface);

    final textStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: textColor, height: 1.35);

    final content =
        contentBuilder?.call(context, message) ??
        (isUser
            ? Text(message.content, style: textStyle)
            : GptMarkdown(message.content, style: textStyle));

    final child = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        content,
        if (showTimeLabel)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _formatTime(message.timestamp),
              style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.6)),
            ),
          ),
      ],
    );

    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Semantics(
            container: true,
            label: semanticLabel ?? (isUser ? 'Message from you' : 'Message'),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width >= 1024
                    ? theme.maxBubbleWidthDesktop
                    : theme.maxBubbleWidthMobile,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(theme.bubbleRadius),
                  child: Container(
                    padding: theme.bubblePadding,
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.circular(theme.bubbleRadius).copyWith(
                        bottomLeft: isUser
                            ? Radius.circular(theme.bubbleRadius)
                            : const Radius.circular(6),
                        bottomRight: isUser
                            ? const Radius.circular(6)
                            : Radius.circular(theme.bubbleRadius),
                      ),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: isUser ? 0.15 : 0.35),
                        width: 1,
                      ),
                    ),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(color: textColor),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
