import 'package:flutter/material.dart';

/// YODYNIX design tokens — midnight navy foundation with electric blue
/// actions and cyan light. Every colour on the site resolves through here.
class AppColors {
  AppColors._();

  // ── Brand palette ────────────────────────────────────────────────────────
  static const Color midnightNavy = Color(0xFF101A35);
  static const Color deepNavy = Color(0xFF0A1022);
  static const Color electricBlue = Color(0xFF386BFF);
  static const Color cyan = Color(0xFF00D4FF);
  static const Color iceBlue = Color(0xFF8CCFFF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFD8E0EF);
  static const Color blueGrey = Color(0xFF9AA9C5);
  static const Color surfaceNavy = Color(0xFF182647);

  // ── Semantic roles ───────────────────────────────────────────────────────
  static const Color primary = electricBlue;
  static const Color primaryDeep = Color(0xFF2346C8);
  static const Color primarySoft = Color(0xFF16244D); // blue-tinted navy
  static const Color sky = cyan;
  static const Color skySoft = Color(0xFF0E2A44);

  static const Color accent = cyan;
  static const Color accentDeep = Color(0xFF00A8D6);
  static const Color accentSoft = Color(0xFF0F2540);
  static const Color sun = iceBlue;

  // Supporting tones — kept within the navy/blue family so accents vary
  // without breaking the palette.
  static const Color violet = Color(0xFF7C8CFF); // periwinkle
  static const Color mint = Color(0xFF3FE0D0); // aqua
  static const Color rose = Color(0xFF5AA9FF); // sky blue

  // ── Surfaces (darkest → lightest) ───────────────────────────────────────
  static const Color background = deepNavy;
  static const Color surface = Color(0xFF0D1530); // alternate section band
  static const Color surfaceBlue = Color(0xFF0C142B);
  static const Color card = Color(0xFF131E3D);
  static const Color cardRaised = surfaceNavy;
  static const Color skeleton = Color(0xFF263459);

  // ── Text & lines ────────────────────────────────────────────────────────
  static const Color ink = white; // headings, primary text
  static const Color body = lightGrey;
  static const Color muted = blueGrey;
  static const Color border = Color(0xFF223258);
  static const Color divider = Color(0xFF1A2749);

  static const Color success = Color(0xFF34D399);
  static const Color error = Color(0xFFFF6B7A);

  // ── Gradients ───────────────────────────────────────────────────────────
  static const LinearGradient brandGradient = LinearGradient(
    colors: [electricBlue, cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [primaryDeep, electricBlue, cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient signatureGradient = LinearGradient(
    colors: [primaryDeep, electricBlue, cyan],
    stops: [0, 0.5, 1],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Headline highlight: electric blue into cyan.
  static const LinearGradient headlineGradient = LinearGradient(
    colors: [electricBlue, Color(0xFF3E9BFF), cyan],
    stops: [0, 0.5, 1],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Glass card fill: faint light falloff over navy.
  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0xFF17244A), Color(0xFF0F1934)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Soft blue-cyan light pooling from [center].
  static RadialGradient glow({Alignment center = Alignment.center, double radius = 0.8, double strength = 1}) => RadialGradient(
    center: center,
    radius: radius,
    colors: [
      electricBlue.withValues(alpha: 0.26 * strength),
      cyan.withValues(alpha: 0.06 * strength),
      Colors.transparent,
    ],
    stops: const [0, 0.5, 1],
  );

  static List<BoxShadow> softShadow([double strength = 1]) => [
    BoxShadow(
      color: const Color(0xFF02050F).withValues(alpha: 0.5 * strength.clamp(0, 1.5)),
      blurRadius: 28 * strength,
      offset: Offset(0, 12 * strength),
    ),
  ];

  /// Cyan halo for focused or hovered elements.
  static List<BoxShadow> glowShadow([double strength = 1, Color color = cyan]) => [
    BoxShadow(
      color: color.withValues(alpha: 0.28 * strength),
      blurRadius: 32 * strength,
      spreadRadius: -4,
    ),
  ];
}
