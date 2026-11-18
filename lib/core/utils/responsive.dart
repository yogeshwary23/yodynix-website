import 'package:flutter/widgets.dart';

class Breakpoints {
  Breakpoints._();

  static const double mobile = 640;
  static const double tablet = 1024;

  /// Below this width the navbar collapses into the mobile drawer.
  static const double navCollapse = 1280;

  static const double maxContentWidth = 1240;

  /// The two-level header spans wider than the page content.
  static const double headerMaxWidth = 1500;

  /// The hero and its statistics card sit between the two.
  static const double heroMaxWidth = 1420;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  bool get isMobile => screenWidth < Breakpoints.mobile;
  bool get isTablet => screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.tablet;
  bool get isDesktop => screenWidth >= Breakpoints.tablet;
  bool get useCompactNav => screenWidth < Breakpoints.navCollapse;

  T responsive<T>({required T mobile, T? tablet, required T desktop}) {
    if (isMobile) return mobile;
    if (isTablet) return tablet ?? desktop;
    return desktop;
  }

  /// Horizontal page gutter.
  double get gutter => responsive(mobile: 20.0, tablet: 32.0, desktop: 48.0);

  /// Vertical padding applied to each homepage section.
  double get sectionPadding => responsive(mobile: 72.0, tablet: 96.0, desktop: 120.0);

  /// Number of columns for a card grid given a minimum card width.
  int gridColumns({required double available, double minItemWidth = 280, int max = 4}) {
    final count = (available / minItemWidth).floor();
    return count.clamp(1, max);
  }
}
