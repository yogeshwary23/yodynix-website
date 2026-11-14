import 'package:flutter/animation.dart';

/// Corner radii used across cards, buttons and media.
class AppRadius {
  AppRadius._();

  static const double sm = 12;
  static const double md = 18;
  static const double lg = 22;
  static const double xl = 28;
  static const double pill = 999;
}

/// Spacing scale (logical pixels).
class AppSpacing {
  AppSpacing._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 20;
  static const double lg = 28;
  static const double xl = 40;
  static const double xxl = 56;
}

/// Motion durations and curves for hover, reveal and page transitions.
class AppMotion {
  AppMotion._();

  static const Duration hover = Duration(milliseconds: 220);
  static const Duration lift = Duration(milliseconds: 260);
  static const Duration reveal = Duration(milliseconds: 700);
  static const Duration page = Duration(milliseconds: 320);
  static const Curve ease = Curves.easeOutCubic;
}
