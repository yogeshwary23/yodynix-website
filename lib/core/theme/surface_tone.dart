import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The text, line and card colours for one kind of section surface.
///
/// Light sections use [light]; the premium charcoal bands (hero, footer,
/// call-to-action panels) use [dark]. Shared widgets read the nearest
/// [SurfaceTone] so the same `SectionHeader` or `HoverCard` reads correctly on
/// either.
@immutable
class SurfaceColors {
  const SurfaceColors({
    required this.isDark,
    required this.background,
    required this.card,
    required this.cardGradient,
    required this.ink,
    required this.body,
    required this.muted,
    required this.border,
    required this.accent,
    required this.ornament,
    required this.glowCore,
    required this.glowTail,
    required this.shadowColor,
    required this.shadowAlpha,
    required this.badgeTint,
    required this.ghostFill,
    required this.ghostBorder,
    required this.ghostHoverFill,
  });

  final bool isDark;
  final Color background;
  final Color card;
  final Gradient? cardGradient;
  final Color ink;
  final Color body;
  final Color muted;
  final Color border;

  /// Accent for text and icons; lighter on dark surfaces for contrast.
  final Color accent;

  /// Fine decorative details: label dots, label outlines, short rules.
  final Color ornament;

  final Color glowCore;
  final Color glowTail;
  final Color shadowColor;
  final double shadowAlpha;

  /// Colour the gradient icon badge lifts towards.
  final Color badgeTint;

  // Outlined (secondary) button.
  final Color ghostFill;
  final Color ghostBorder;
  final Color ghostHoverFill;

  static const SurfaceColors light = SurfaceColors(
    isDark: false,
    background: AppColors.background,
    card: AppColors.card,
    cardGradient: null,
    ink: AppColors.ink,
    body: AppColors.body,
    muted: AppColors.muted,
    border: AppColors.border,
    accent: AppColors.accent,
    ornament: AppColors.champagneGold,
    glowCore: Color(0x00C6A46A),
    glowTail: Color(0x00C6A46A),
    shadowColor: AppColors.charcoalNavy,
    shadowAlpha: 0.06,
    badgeTint: AppColors.goldTint,
    ghostFill: AppColors.softWhite,
    ghostBorder: AppColors.goldLine,
    ghostHoverFill: AppColors.goldWash,
  );

  static const SurfaceColors dark = SurfaceColors(
    isDark: true,
    background: AppColors.deepCharcoal,
    card: AppColors.charcoalNavy,
    cardGradient: AppColors.darkGlassGradient,
    ink: AppColors.onDark,
    body: AppColors.onDarkBody,
    muted: AppColors.onDarkMuted,
    border: AppColors.darkBorder,
    accent: AppColors.champagneGold,
    ornament: AppColors.champagneGold,
    glowCore: Color(0x14C6A46A),
    glowTail: Color(0x00C6A46A),
    shadowColor: Color(0xFF05070C),
    shadowAlpha: 0.45,
    badgeTint: AppColors.goldTint,
    ghostFill: Color(0x0AFFFFFF),
    ghostBorder: Color(0x38FFFFFF),
    ghostHoverFill: Color(0x14FFFFFF),
  );

  /// Inside a content card (see `CardStyle`): charcoal with champagne details.
  static const SurfaceColors inCard = SurfaceColors(
    isDark: true,
    background: AppColors.cardSurface,
    card: AppColors.charcoalNavy,
    cardGradient: null,
    ink: AppColors.cardHeading,
    body: AppColors.cardBody,
    muted: AppColors.cardMuted,
    border: AppColors.cardLine,
    accent: AppColors.cardAccent,
    ornament: AppColors.cardAccent,
    glowCore: Color(0x00C6A46A),
    glowTail: Color(0x00C6A46A),
    shadowColor: Color(0xFF05070C),
    shadowAlpha: 0.3,
    badgeTint: AppColors.goldTint,
    ghostFill: Color(0x0AFFFFFF),
    ghostBorder: Color(0x66C6A46A),
    ghostHoverFill: Color(0x14FFFFFF),
  );

  /// Light pooling from [center], tuned per surface.
  RadialGradient glow({Alignment center = Alignment.center, double radius = 0.8, double strength = 1}) {
    return RadialGradient(
      center: center,
      radius: radius,
      colors: [
        glowCore.withValues(alpha: glowCore.a * strength),
        glowTail,
      ],
    );
  }

  List<BoxShadow> shadow([double strength = 1]) => [
    BoxShadow(
      color: shadowColor.withValues(alpha: shadowAlpha * strength.clamp(0, 1.5)),
      blurRadius: 28 * strength,
      offset: Offset(0, 12 * strength),
    ),
  ];
}

/// Provides [SurfaceColors] to everything below it.
class SurfaceTone extends InheritedWidget {
  const SurfaceTone({super.key, required this.colors, required super.child});

  final SurfaceColors colors;

  static SurfaceColors of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SurfaceTone>()?.colors ?? SurfaceColors.light;

  @override
  bool updateShouldNotify(SurfaceTone oldWidget) => colors != oldWidget.colors;
}

extension SurfaceToneContext on BuildContext {
  /// Colours for the surface this widget sits on.
  SurfaceColors get tone => SurfaceTone.of(this);

  /// [color] adjusted for this surface: the light-surface gold
  /// ([AppColors.accent]) becomes the surface's own readable gold.
  Color readable(Color color) => color == AppColors.accent ? tone.accent : color;
}
