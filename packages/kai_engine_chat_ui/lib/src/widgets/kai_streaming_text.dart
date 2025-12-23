import 'package:flutter/material.dart';

/// Animated streaming text with a blinking cursor.
class KaiStreamingText extends StatefulWidget {
  const KaiStreamingText({
    super.key,
    required this.text,
    this.style,
    this.cursorWidth = 2,
    this.cursorHeight,
    this.cursorColor,
  });

  final String text;
  final TextStyle? style;
  final double cursorWidth;
  final double? cursorHeight;
  final Color? cursorColor;

  @override
  State<KaiStreamingText> createState() => _KaiStreamingTextState();
}

class _KaiStreamingTextState extends State<KaiStreamingText> with TickerProviderStateMixin {
  late AnimationController _textController;
  late Animation<int> _characterCount;

  late AnimationController _cursorController;
  late Animation<double> _cursorOpacity;

  String _previousText = '';
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _startTextAnimation();
  }

  void _initializeControllers() {
    _textController = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.text.length * 15)),
      vsync: this,
    );

    _characterCount = IntTween(begin: 0, end: widget.text.length).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _cursorController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this)
      ..repeat(reverse: true);

    _cursorOpacity = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _cursorController, curve: Curves.easeInOut),
    );
  }

  void _startTextAnimation() {
    if (widget.text.isEmpty) return;
    _isStreaming = true;
    _textController.reset();
    _textController.forward().whenComplete(() {
      if (mounted) setState(() => _isStreaming = false);
    });
  }

  @override
  void didUpdateWidget(KaiStreamingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text == widget.text) return;

    _previousText = oldWidget.text;

    final isAppend = widget.text.startsWith(_previousText) && widget.text.length > _previousText.length;
    final begin = isAppend ? _previousText.length : 0;

    _characterCount = IntTween(begin: begin, end: widget.text.length).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    final remaining = widget.text.length - begin;
    _textController.duration = Duration(milliseconds: 200 + (remaining * 12));
    _startTextAnimation();
  }

  @override
  void dispose() {
    _textController.dispose();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = widget.style ?? DefaultTextStyle.of(context).style;
    final cursorColor = widget.cursorColor ?? effectiveStyle.color ?? Theme.of(context).colorScheme.onSurface;
    final cursorHeight = widget.cursorHeight ?? (effectiveStyle.fontSize ?? 16);

    return AnimatedBuilder(
      animation: _characterCount,
      builder: (context, _) {
        final count = _characterCount.value;
        final visibleText = (count <= 0)
            ? ''
            : (count >= widget.text.length)
                ? widget.text
                : widget.text.substring(0, count);

        return Text.rich(
          TextSpan(
            children: [
              TextSpan(text: visibleText, style: effectiveStyle),
              if (_isStreaming)
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: AnimatedBuilder(
                    animation: _cursorOpacity,
                    builder: (context, _) {
                      return Opacity(
                        opacity: _cursorOpacity.value,
                        child: Container(
                          width: widget.cursorWidth,
                          height: cursorHeight,
                          margin: const EdgeInsets.only(left: 1),
                          decoration: BoxDecoration(
                            color: cursorColor,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

