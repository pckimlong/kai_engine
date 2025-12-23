import 'package:flutter/widgets.dart';

/// A lightweight 3-dot typing indicator.
class KaiTypingIndicator extends StatefulWidget {
  const KaiTypingIndicator({
    super.key,
    this.dotSize = 8,
    this.dotSpacing = 4,
    this.color,
  });

  final double dotSize;
  final double dotSpacing;
  final Color? color;

  @override
  State<KaiTypingIndicator> createState() => _KaiTypingIndicatorState();
}

class _KaiTypingIndicatorState extends State<KaiTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _dot1;
  late final Animation<double> _dot2;
  late final Animation<double> _dot3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _dot1 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    );
    _dot2 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
    );
    _dot3 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.color ?? const Color(0xFF6B7280);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Dot(anim: _dot1, size: widget.dotSize, color: base),
        SizedBox(width: widget.dotSpacing),
        _Dot(anim: _dot2, size: widget.dotSize, color: base),
        SizedBox(width: widget.dotSpacing),
        _Dot(anim: _dot3, size: widget.dotSize, color: base),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.anim, required this.size, required this.color});

  final Animation<double> anim;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        final scale = 0.7 + 0.3 * (1 - (anim.value - 0.5).abs() * 2);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        );
      },
    );
  }
}
