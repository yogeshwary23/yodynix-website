import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';

/// Dark glass card that lifts and gains a glowing orange edge on hover.
class HoverCard extends StatefulWidget {
  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(28),
    this.radius = AppRadius.lg,
    this.color = AppColors.card,
    this.accent = AppColors.primary,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double radius;
  final Color color;
  final Color accent;
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
      child: AnimatedContainer(
        duration: AppMotion.lift,
        curve: AppMotion.ease,
        transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
        decoration: BoxDecoration(
          color: widget.color == AppColors.card ? null : widget.color,
          gradient: widget.color == AppColors.card ? AppColors.glassGradient : null,
          borderRadius: radius,
          border: Border.all(color: _hover ? widget.accent.withValues(alpha: 0.6) : AppColors.border),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: widget.accent.withValues(alpha: 0.22),
                    blurRadius: 44,
                    spreadRadius: -6,
                    offset: const Offset(0, 18),
                  ),
                ]
              : AppColors.softShadow(0.6),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: radius,
            hoverColor: Colors.transparent,
            splashColor: widget.accent.withValues(alpha: 0.06),
            highlightColor: widget.accent.withValues(alpha: 0.03),
            child: Padding(padding: widget.padding, child: widget.child),
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
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: gradient ? null : color.withValues(alpha: 0.12),
        border: gradient ? null : Border.all(color: color.withValues(alpha: 0.22)),
        gradient: gradient
            ? LinearGradient(
                colors: [color, Color.lerp(color, AppColors.iceBlue, 0.35)!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: gradient
            ? [BoxShadow(color: color.withValues(alpha: 0.28), blurRadius: 18, offset: const Offset(0, 8))]
            : null,
      ),
      child: Icon(icon, size: size * 0.48, color: gradient ? AppColors.white : color),
    );
  }
}

class TagChip extends StatelessWidget {
  const TagChip(this.label, {super.key, this.color = AppColors.primary, this.icon, this.filled = false});

  final String label;
  final Color color;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.12) : AppColors.card,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: filled ? color.withValues(alpha: 0.3) : AppColors.border),
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
                color: filled ? color : AppColors.body,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Clips [child] into the brand's orange-red gradient.
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
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.softShadow(),
        ),
        child: ClipRRect(borderRadius: BorderRadius.circular(radius), child: child),
      ),
    );
  }
}
