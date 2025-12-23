import 'package:flutter/material.dart';
import 'package:kai_engine/kai_engine.dart';

import '../kai_chat_theme.dart';
import 'kai_message_bubble.dart';
import 'kai_streaming_text.dart';
import 'kai_typing_indicator.dart';

typedef KaiMessageBuilder = Widget Function(BuildContext context, CoreMessage message);
typedef KaiTransientBuilder = Widget Function(BuildContext context, GenerationState<GenerationResult> state);
typedef KaiMessageFilter = bool Function(CoreMessage message);

bool defaultKaiMessageFilter(CoreMessage m) => m.isDisplayable && !m.isBackgroundContext;

class KaiMessageList extends StatelessWidget {
  const KaiMessageList({
    super.key,
    required this.messages,
    this.generationState,
    this.controller,
    this.reverse = true,
    this.messageFilter = defaultKaiMessageFilter,
    this.messageBuilder,
    this.transientBuilder,
    this.onMessageTap,
    this.padding,
    this.physics,
  });

  final List<CoreMessage> messages;
  final GenerationState<GenerationResult>? generationState;
  final ScrollController? controller;
  final bool reverse;
  final KaiMessageFilter messageFilter;
  final KaiMessageBuilder? messageBuilder;
  final KaiTransientBuilder? transientBuilder;
  final void Function(CoreMessage message)? onMessageTap;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final theme = context.kaiChatTheme;
    final filtered = messages.where(messageFilter).toList(growable: false);
    final transient = generationState != null && generationState!.isGenerating;
    final totalCount = filtered.length + (transient ? 1 : 0);
    final transientIndex = reverse ? 0 : filtered.length;

    return ListView.builder(
      controller: controller,
      reverse: reverse,
      padding: padding ?? theme.listPadding,
      physics: physics ?? const BouncingScrollPhysics(),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        final isTransientIndex = transient && index == transientIndex;
        if (isTransientIndex) {
          final state = generationState!;
          final built = transientBuilder?.call(context, state) ?? _defaultTransient(context, state);
          return Padding(
            padding: EdgeInsets.only(bottom: theme.itemSpacing),
            child: built,
          );
        }

        final messageIndex = reverse
            ? (filtered.length - 1 - (index - (transient ? 1 : 0)))
            : index;
        final message = filtered[messageIndex];

        final bubble = messageBuilder?.call(context, message) ??
            KaiMessageBubble(
              message: message,
              isUserMessage: message.type == CoreMessageType.user,
              onTap: onMessageTap == null ? null : () => onMessageTap!(message),
            );

        return Padding(
          padding: EdgeInsets.only(bottom: theme.itemSpacing),
          child: bubble,
        );
      },
    );
  }

  Widget _defaultTransient(BuildContext context, GenerationState<GenerationResult> state) {
    return switch (state) {
      GenerationLoadingState() || GenerationFunctionCallingState() => KaiMessageBubble(
          message: CoreMessage.ai(content: ''),
          isUserMessage: false,
          contentBuilder: (_, __) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: KaiTypingIndicator(),
          ),
        ),
      GenerationStreamingTextState(text: final text) => KaiMessageBubble(
          message: CoreMessage.ai(content: text),
          isUserMessage: false,
          contentBuilder: (context, _) => KaiStreamingText(
            text: text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
