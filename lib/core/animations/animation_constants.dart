import 'package:flutter/animation.dart';

class AnimationConstants {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration staggeredStep = Duration(milliseconds: 80);

  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve entranceCurve = Curves.decelerate;
}
