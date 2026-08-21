import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedPressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const AnimatedPressScale({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<AnimatedPressScale> createState() => _AnimatedPressScaleState();
}

class _AnimatedPressScaleState extends State<AnimatedPressScale> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class AnimatedPulseBadge extends StatelessWidget {
  final Widget child;
  final bool isUrgent;

  const AnimatedPulseBadge({
    super.key,
    required this.child,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isUrgent) return child;
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.04, 1.04),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOut,
        );
  }
}
