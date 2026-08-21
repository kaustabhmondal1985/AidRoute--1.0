import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'animation_constants.dart';

class AnimatedFadeSlide extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;

  const AnimatedFadeSlide({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AnimationConstants.medium,
    this.offset = const Offset(0, 0.1),
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration, curve: AnimationConstants.defaultCurve)
        .slide(
          begin: offset,
          end: Offset.zero,
          duration: duration,
          curve: AnimationConstants.defaultCurve,
        );
  }
}

class AnimatedScaleIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const AnimatedScaleIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AnimationConstants.medium,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
          duration: duration,
          curve: AnimationConstants.defaultCurve,
        );
  }
}
