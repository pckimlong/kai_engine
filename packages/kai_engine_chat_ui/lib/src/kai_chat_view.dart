import 'package:flutter/material.dart';
import 'package:kai_engine/kai_engine.dart';

import 'kai_chat_theme.dart';
import 'widgets/kai_composer.dart';
import 'widgets/kai_message_list.dart';

/// A batteries-included chat view: message list + composer.
///
/// You control state by providing [messages],
/// [generationState], and callbacks.
class KaiChatView extends StatefulWidget {
  const KaiChatView({
    super.key,
    required this.messages,
    required this.onSend,
    this.generationState,
    this.onCancel,
    this.messageFilter,
    this.messageBuilder,
    this.transientBuilder,
    this.onMessageTap,
    this.reverse = true,
    this.controller,
    this.composerPadding = const EdgeInsets.fromLTRB(16, 0, 16, 12),
    this.listPadding,
    this.composerBuilder,
  });

  final List<CoreMessage> messages;
  final GenerationState<GenerationResult>? generationState;
  final Future<void> Function(String text) onSend;
  final VoidCallback? onCancel;

  final KaiMessageFilter? messageFilter;
  final KaiMessageBuilder? messageBuilder;
  final KaiTransientBuilder? transientBuilder;
  final void Function(CoreMessage message)? onMessageTap;

  final bool reverse;
  final ScrollController? controller;
  final EdgeInsetsGeometry composerPadding;
  final EdgeInsetsGeometry? listPadding;

  final Widget Function(BuildContext context, KaiComposer composer)?
  composerBuilder;

  @override
  State<KaiChatView> createState() => _KaiChatViewState();
}

class _KaiChatViewState extends State<KaiChatView> {
  late final ScrollController _scrollController;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _scrollController = widget.controller!;
    } else {
      _scrollController = ScrollController();
      _ownsController = true;
    }
  }

  @override
  void dispose() {
    if (_ownsController) _scrollController.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    if (!_scrollController.hasClients) return;
    final target = widget.reverse
        ? 0.0
        : _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.kaiChatTheme;
    final composer = KaiComposer(
      onSend: (text) async {
        await widget.onSend(text);
        scrollToBottom();
      },
      onCancel: widget.onCancel,
      isGenerating: widget.generationState?.isGenerating ?? false,
    );

    return Column(
      children: [
        Expanded(
          child: KaiMessageList(
            controller: _scrollController,
            messages: widget.messages,
            generationState: widget.generationState,
            reverse: widget.reverse,
            messageFilter: widget.messageFilter ?? defaultKaiMessageFilter,
            messageBuilder: widget.messageBuilder,
            transientBuilder: widget.transientBuilder,
            onMessageTap: widget.onMessageTap,
            padding: widget.listPadding ?? theme.listPadding,
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: widget.composerPadding,
            child: widget.composerBuilder?.call(context, composer) ?? composer,
          ),
        ),
      ],
    );
  }
}
