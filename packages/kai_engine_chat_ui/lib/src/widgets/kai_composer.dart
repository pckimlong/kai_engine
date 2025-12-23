import 'package:flutter/material.dart';

class KaiComposer extends StatefulWidget {
  const KaiComposer({
    super.key,
    required this.onSend,
    this.onCancel,
    this.isGenerating = false,
    this.hintText = 'Type a message…',
    this.controller,
    this.autofocus = false,
    this.maxLines = 6,
    this.onError,
  });

  final Future<void> Function(String text) onSend;
  final VoidCallback? onCancel;
  final bool isGenerating;
  final String hintText;
  final TextEditingController? controller;
  final bool autofocus;
  final int maxLines;
  final void Function(Object error, StackTrace stackTrace)? onError;

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

    setState(() => _sending = true);
    try {
      await widget.onSend(text);
      if (mounted) _controller.clear();
    } catch (e, s) {
      widget.onError?.call(e, s);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isBusy = widget.isGenerating || _sending;
    final canSend = _controller.text.trim().isNotEmpty && !isBusy;

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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
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
