import 'package:flutter/material.dart';
import 'entrance_animations.dart';

extension WidgetAnimationExtensions on Widget {
  Widget animateFadeSlide({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 350),
    Offset offset = const Offset(0, 0.1),
  }) {
    return AnimatedFadeSlide(
      delay: delay,
      duration: duration,
      offset: offset,
      child: this,
    );
  }
}
