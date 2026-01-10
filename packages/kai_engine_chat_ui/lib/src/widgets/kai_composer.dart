import 'package:flutter/material.dart';

/// State data provided to [KaiComposerBuilder].
class KaiComposerState {
  const KaiComposerState({
    required this.isGenerating,
    required this.isSending,
    required this.canSend,
    required this.text,
  });

  /// Whether the AI is currently generating a response.
  final bool isGenerating;

  /// Whether a send operation is in progress.
  final bool isSending;

  /// Whether the user can send a message (has text and not busy).
  final bool canSend;

  /// Current text in the input field.
  final String text;
}

/// Callbacks provided to [KaiComposerBuilder].
class KaiComposerCallbacks {
  const KaiComposerCallbacks({required this.onSend, this.onCancel, required this.onTextChanged});

  /// Send the current text in the input field.
  final Future<void> Function() onSend;

  /// Cancel the current generation (optional).
  final VoidCallback? onCancel;

  /// Called when the text field content changes.
  final void Function(String text) onTextChanged;
}

/// Builder that creates a custom composer widget.
///
/// This builder receives the [state] and [callbacks] to build a custom composer.
/// You can create your own text field, send button, and any additional UI elements.
///
/// Example - Create a custom composer with attachment button:
/// ```dart
/// KaiComposer(
///   onSend: (text) => controller.submit(text),
///   onCancel: () => controller.cancel(),
///   isGenerating: isGenerating,
///   builder: (context, state, callbacks) {
///     return Row(
///       children: [
///         IconButton(
///           icon: Icon(Icons.attach_file),
///           onPressed: () => _handleAttachment(),
///         ),
///         Expanded(
///           child: TextField(
///             decoration: InputDecoration(
///               hintText: 'Type a message...',
///               border: OutlineInputBorder(),
///             ),
///             onChanged: callbacks.onTextChanged,
///             onSubmitted: (_) => callbacks.onSend(),
///           ),
///         ),
///         if (state.isGenerating)
///           IconButton(
///             icon: Icon(Icons.stop),
///             onPressed: callbacks.onCancel,
///           )
///         else
///           IconButton(
///             icon: Icon(Icons.send),
///             onPressed: state.canSend ? callbacks.onSend : null,
///           ),
///       ],
///     );
///   },
/// )
/// ```
///
/// Example - Use with KaiChatView:
/// ```dart
/// KaiChatView(
///   controller: myController,
///   composerBuilder: (context, composer) {
///     return KaiComposer(
///       onSend: composer.onSend,
///       onCancel: composer.onCancel,
///       isGenerating: composer.isGenerating,
///       builder: (context, state, callbacks) {
///         // Custom composer UI
///         return YourCustomComposer(state: state, callbacks: callbacks);
///       },
///     );
///   },
/// )
/// ```
///
/// Example - Customize inline button:
/// ```dart
/// KaiComposer(
///   onSend: (text) => controller.submit(text),
///   isGenerating: isGenerating,
///   inlineButton: true,
///   sendIcon: Icons.send,
///   stopIcon: Icons.close,
///   buttonSize: 40,
///   buttonColor: Colors.blue,
/// )
/// ```
typedef KaiComposerBuilder =
    Widget Function(BuildContext context, KaiComposerState state, KaiComposerCallbacks callbacks);

class KaiComposer extends StatefulWidget {
  const KaiComposer({
    super.key,
    required this.onSend,
    this.onCancel,
    this.isGenerating = false,
    this.hintText = 'Type a message…',
    this.controller,
    this.autofocus = false,
    this.maxLines = 8,
    this.onError,
    this.builder,
    this.inlineButton = true,
    this.sendIcon,
    this.stopIcon,
    this.buttonSize = 36,
    this.buttonColor,
  });

  final Future<void> Function(String text) onSend;
  final VoidCallback? onCancel;
  final bool isGenerating;
  final String hintText;
  final TextEditingController? controller;
  final bool autofocus;
  final int maxLines;
  final void Function(Object error, StackTrace stackTrace)? onError;
  final KaiComposerBuilder? builder;
  final bool inlineButton;
  final IconData? sendIcon;
  final IconData? stopIcon;
  final double buttonSize;
  final Color? buttonColor;

  @override
  State<KaiComposer> createState() => _KaiComposerState();
}

class _KaiComposerState extends State<KaiComposer> {
  late final TextEditingController _controller;
  bool _ownsController = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (_sending || widget.isGenerating) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Clear text immediately for responsive UX (like Resonate pattern)
    _controller.clear();
    setState(() => _sending = true);

    try {
      await widget.onSend(text);
    } catch (e, s) {
      widget.onError?.call(e, s);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = widget.isGenerating || _sending;
    final canSend = _controller.text.trim().isNotEmpty && !isBusy;

    final state = KaiComposerState(
      isGenerating: widget.isGenerating,
      isSending: _sending,
      canSend: canSend,
      text: _controller.text,
    );

    final callbacks = KaiComposerCallbacks(
      onSend: _handleSend,
      onCancel: widget.onCancel,
      onTextChanged: (text) => setState(() {}),
    );

    if (widget.builder != null) {
      return widget.builder!(context, state, callbacks);
    }

    final colors = Theme.of(context).colorScheme;

    if (widget.inlineButton) {
      final effectiveButtonColor = widget.buttonColor ?? colors.primary;
      final effectiveSendIcon = widget.sendIcon ?? Icons.arrow_upward;
      final effectiveStopIcon = widget.stopIcon ?? Icons.stop;

      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autofocus,
              maxLines: widget.maxLines,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: widget.hintText,
                filled: true,
                fillColor: colors.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Semantics(
                    button: true,
                    label: widget.isGenerating ? 'Stop generating' : 'Send message',
                    child: Tooltip(
                      message: widget.isGenerating ? 'Stop' : 'Send message',
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: widget.buttonSize,
                          height: widget.buttonSize,
                          decoration: BoxDecoration(
                            color: effectiveButtonColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.outlineVariant.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: widget.isGenerating
                                ? widget.onCancel
                                : canSend
                                ? _handleSend
                                : null,
                            borderRadius: BorderRadius.circular(widget.buttonSize / 2),
                            child: Center(
                              child: Icon(
                                widget.isGenerating ? effectiveStopIcon : effectiveSendIcon,
                                color: effectiveButtonColor == colors.primary
                                    ? colors.onPrimary
                                    : colors.onPrimaryContainer,
                                size: widget.buttonSize * 0.56,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              onSubmitted: (_) => _handleSend(),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            autofocus: widget.autofocus,
            maxLines: widget.maxLines,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: widget.hintText,
              filled: true,
              fillColor: colors.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            onSubmitted: (_) => _handleSend(),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(width: 10),
        if (widget.isGenerating)
          IconButton(
            tooltip: 'Stop',
            onPressed: widget.onCancel,
            icon: const Icon(Icons.stop_circle_outlined),
          )
        else
          IconButton(
            tooltip: 'Send',
            onPressed: canSend ? _handleSend : null,
            icon: const Icon(Icons.send),
          ),
      ],
    );
  }
}
