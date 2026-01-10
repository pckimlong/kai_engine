import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:kai_engine/kai_engine.dart';

import 'kai_chat_theme.dart';
import 'widgets/kai_composer.dart';
import 'widgets/kai_message_list.dart';

/// A batteries-included chat view: message list + composer.
///
/// Provide a [ChatControllerBase] to manage messages and generation state.
/// The view listens to the controller's streams and rebuilds efficiently.
class KaiChatView extends StatefulWidget {
  const KaiChatView({
    super.key,
    required this.controller,
    this.onMessageSent,
    this.onError,
    this.messageFilter,
    this.messageBuilder,
    this.messageItemBuilder,
    this.transientBuilder,
    this.transientItemBuilder,
    this.functionCallBuilder,
    this.onMessageTap,
    this.reverse = true,
    this.scrollController,
    this.composerPadding = const EdgeInsets.fromLTRB(16, 0, 16, 12),
    this.listPadding,
    this.composerBuilder,
    this.showTimeLabel = false,
  });

  final ChatControllerBase controller;

  /// Called immediately when user sends a message (before awaiting result).
  /// Useful for scrolling to bottom, clearing focus, etc.
  final VoidCallback? onMessageSent;

  /// Called when an error occurs during message submission.
  /// Provides [BuildContext] for showing dialogs and [KaiException] for error details.
  final void Function(BuildContext context, KaiException error)? onError;

  /// Additional filter applied on top of the default filter.
  /// Default filter already excludes non-displayable and background context messages.
  /// Use this to add custom filtering rules without rewriting the defaults.
  ///
  /// Example - Filter out function call messages:
  /// ```dart
  /// KaiChatView(
  ///   messageFilter: (message) => !message.content.contains('"functionCall":'),
  ///   // ...
  /// )
  /// ```
  final KaiMessageFilter? messageFilter;
  final KaiMessageBuilder? messageBuilder;
  final KaiMessageItemBuilder? messageItemBuilder;
  final KaiTransientBuilder? transientBuilder;
  final KaiTransientItemBuilder? transientItemBuilder;
  final KaiFunctionCallBuilder? functionCallBuilder;
  final void Function(CoreMessage message)? onMessageTap;

  final bool reverse;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry composerPadding;
  final EdgeInsetsGeometry? listPadding;

  final Widget Function(BuildContext context, KaiComposer composer)? composerBuilder;
  final bool showTimeLabel;

  @override
  State<KaiChatView> createState() => _KaiChatViewState();
}

class _KaiChatViewState extends State<KaiChatView> {
  late final ScrollController _scrollController;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.scrollController != null) {
      _scrollController = widget.scrollController!;
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

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    final target = widget.reverse ? 0.0 : _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _handleSend(String text) async {
    widget.onMessageSent?.call();
    _scrollToBottom();

    final result = await widget.controller.submit(text);
    if (result.isError && widget.onError != null && mounted) {
      final error = (result as GenerationErrorState).exception;
      widget.onError!(context, error);
    }
  }

  void _handleCancel() {
    widget.controller.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.kaiChatTheme;

    return StreamBuilder<GenerationState<GenerationResult>>(
      stream: widget.controller.generationStateStream,
      initialData: GenerationState.initial(),
      builder: (context, stateSnapshot) {
        final generationState = stateSnapshot.data ?? GenerationState.initial();
        final isGenerating = generationState.isGenerating;

        final composer = KaiComposer(
          onSend: _handleSend,
          onCancel: _handleCancel,
          isGenerating: isGenerating,
        );

        return Column(
          children: [
            Expanded(
              child: StreamBuilder<IList<CoreMessage>>(
                stream: widget.controller.messagesStream,
                initialData: const IListConst([]),
                builder: (context, messagesSnapshot) {
                  final messages = messagesSnapshot.data ?? const IListConst([]);
                  final combinedFilter = widget.messageFilter != null
                      ? (CoreMessage m) => defaultKaiMessageFilter(m) && widget.messageFilter!(m)
                      : defaultKaiMessageFilter;
                  return KaiMessageList(
                    controller: _scrollController,
                    messages: messages,
                    generationState: generationState,
                    reverse: widget.reverse,
                    messageFilter: combinedFilter,
                    messageBuilder: widget.messageBuilder,
                    messageItemBuilder: widget.messageItemBuilder,
                    transientBuilder: widget.transientBuilder,
                    transientItemBuilder: widget.transientItemBuilder,
                    functionCallBuilder: widget.functionCallBuilder,
                    onMessageTap: widget.onMessageTap,
                    padding: widget.listPadding ?? theme.listPadding,
                    showTimeLabel: widget.showTimeLabel,
                  );
                },
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
      },
    );
  }
}
