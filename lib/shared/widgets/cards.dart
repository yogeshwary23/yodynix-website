import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/surface_tone.dart';
import 'motion_effects.dart';

/// The site-wide card look: a white tile with a fine silver edge and a soft,
/// cool shadow. Content inside reads its colours from
/// [SurfaceColors.inCard] (wrap it in [CardSurface] or use [HoverCard]).
class CardStyle {
  CardStyle._();

  static BoxDecoration decoration({double radius = AppRadius.lg, bool hover = false}) => BoxDecoration(
    color: AppColors.cardSurface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: hover ? AppColors.cardBorderHover : AppColors.cardBorder),
    boxShadow: shadow(hover: hover),
  );

  static List<BoxShadow> shadow({bool hover = false}) => [
    BoxShadow(
      color: AppColors.charcoal.withValues(alpha: hover ? 0.12 : 0.06),
      blurRadius: hover ? 32 : 22,
      offset: Offset(0, hover ? 16 : 10),
    ),
  ];
}

/// A static card: [CardStyle] decoration with card colours for its content.
class CardSurface extends StatelessWidget {
  const CardSurface({super.key, required this.child, this.padding, this.radius = AppRadius.lg, this.hover = false});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final bool hover;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.lift,
      curve: AppMotion.ease,
      padding: padding,
      decoration: CardStyle.decoration(radius: radius, hover: hover),
      child: SurfaceTone(colors: SurfaceColors.inCard, child: child),
    );
  }
}

/// A [CardSurface] holding a form: fields, chips and menus switch to their
/// platinum, gold-focused style.
class FormCard extends StatelessWidget {
  const FormCard({super.key, required this.child, this.padding, this.radius = AppRadius.xl});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.onCard(Theme.of(context)),
      child: CardSurface(padding: padding, radius: radius, child: child),
    );
  }
}

/// Card that lifts gently, tilts towards the cursor with a glass-like sheen
/// and tints its edge gold on hover.
class HoverCard extends StatefulWidget {
  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(28),
    this.radius = AppRadius.lg,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double radius;
  final String? semanticLabel;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.radius);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: Tilt3D(
        radius: widget.radius,
        maxAngle: 4,
        child: AnimatedContainer(
          duration: AppMotion.lift,
          curve: AppMotion.ease,
          transform: Matrix4.translationValues(0, _hover ? -4 : 0, 0),
          decoration: CardStyle.decoration(radius: widget.radius, hover: _hover),
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: radius,
              hoverColor: Colors.transparent,
              splashColor: AppColors.cardAccent.withValues(alpha: 0.06),
              highlightColor: AppColors.cardAccent.withValues(alpha: 0.03),
              child: SurfaceTone(
                colors: SurfaceColors.inCard,
                child: Padding(padding: widget.padding, child: widget.child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded square with a soft-tinted background and icon.
class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, required this.color, this.size = 52, this.gradient = false});

  final IconData icon;
  final Color color;
  final double size;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    if (identical(context.tone, SurfaceColors.inCard)) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.cardTile,
          border: Border.all(color: AppColors.cardLine),
          borderRadius: BorderRadius.circular(size * 0.3),
        ),
        child: Icon(icon, size: size * 0.48, color: AppColors.cardAccent),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: gradient ? null : color.withValues(alpha: 0.12),
        border: gradient ? null : Border.all(color: color.withValues(alpha: 0.22)),
        gradient: gradient
            ? LinearGradient(
                colors: [color, Color.lerp(color, context.tone.badgeTint, 0.35)!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: gradient
            ? [
                BoxShadow(
                  color: color.withValues(alpha: context.tone.isDark ? 0.28 : 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Icon(
        icon,
        size: size * 0.48,
        // Charcoal glyph on light fills, white on deep ones.
        color: gradient
            ? (ThemeData.estimateBrightnessForColor(color) == Brightness.light ? AppColors.charcoal : AppColors.white)
            : color,
      ),
    );
  }
}

class TagChip extends StatelessWidget {
  const TagChip(this.label, {super.key, this.color, this.icon, this.filled = false});

  final String label;

  /// Defaults to the surface's accent.
  final Color? color;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final tone = context.tone;
    final color = context.readable(this.color ?? tone.accent);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: tone.isDark ? 0.12 : 0.08) : tone.card,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: filled ? color.withValues(alpha: tone.isDark ? 0.3 : 0.22) : tone.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 6)],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: filled ? color : tone.body,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Clips [text] into the brand's headline gradient.
class GradientText extends StatelessWidget {
  const GradientText(this.text, {super.key, required this.style, this.gradient = AppColors.headlineGradient, this.textAlign});

  final String text;
  final TextStyle style;
  final Gradient gradient;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(Offset.zero & bounds.size),
      child: Text(text, style: style, textAlign: textAlign),
    );
  }
}

/// Framed media container with rounded corners and a soft shadow.
class MediaFrame extends StatelessWidget {
  const MediaFrame({super.key, required this.child, this.aspectRatio = 3 / 2, this.radius = 24});

  final Widget child;
  final double aspectRatio;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: context.tone.border),
          boxShadow: context.tone.shadow(),
        ),
        child: ClipRRect(borderRadius: BorderRadius.circular(radius), child: child),
      ),
    );
  }
}
