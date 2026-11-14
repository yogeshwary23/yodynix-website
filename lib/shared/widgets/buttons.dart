import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';

enum ButtonSize { small, medium, large }

EdgeInsets _padding(ButtonSize size) => switch (size) {
  ButtonSize.small => const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
  ButtonSize.medium => const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
  ButtonSize.large => const EdgeInsets.symmetric(horizontal: 30, vertical: 19),
};

double _fontSize(ButtonSize size) => switch (size) {
  ButtonSize.small => 14,
  ButtonSize.medium => 15,
  ButtonSize.large => 16,
};

/// Gradient brand button with a hover glow and an arrow that nudges forward.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
    this.size = ButtonSize.medium,
    this.expand = false,
    this.loading = false,
    this.warm = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonSize size;
  final bool expand;
  final bool loading;

  /// Uses the orange accent gradient instead of the blue brand gradient.
  final bool warm;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final gradient = widget.warm
        ? const LinearGradient(colors: [AppColors.cyan, AppColors.iceBlue])
        : const LinearGradient(colors: [AppColors.electricBlue, AppColors.cyan]);
    final glow = widget.warm ? AppColors.cyan : AppColors.electricBlue;
    final enabled = widget.onPressed != null && !widget.loading;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: AppMotion.hover,
        curve: AppMotion.ease,
        transform: Matrix4.translationValues(0, _hover && enabled ? -2 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: [
            BoxShadow(
              color: glow.withValues(alpha: _hover && enabled ? 0.55 : 0.28),
              blurRadius: _hover ? 34 : 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              gradient: enabled ? gradient : null,
              color: enabled ? null : AppColors.muted.withValues(alpha: 0.4),
            ),
            child: InkWell(
              onTap: enabled ? widget.onPressed : null,
              onHover: (v) => setState(() => _hover = v),
              child: Padding(
                padding: _padding(widget.size),
                child: Row(
                  mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.loading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                      )
                    else
                      Flexible(
                        child: Text(
                          widget.label,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body(
                            fontSize: _fontSize(widget.size),
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                            height: 1.2,
                          ),
                        ),
                      ),
                    if (widget.icon != null && !widget.loading) ...[
                      AnimatedPadding(
                        duration: AppMotion.hover,
                        padding: EdgeInsets.only(left: _hover ? 12 : 8),
                        child: Icon(widget.icon, size: 18, color: AppColors.white),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined secondary action.
class SecondaryButton extends StatefulWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.size = ButtonSize.medium,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonSize size;
  final bool expand;

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      child: Material(
        color: _hover ? AppColors.primarySoft : AppColors.white.withValues(alpha: 0.04),
        shape: StadiumBorder(
          side: BorderSide(
            color: _hover ? AppColors.primary.withValues(alpha: 0.7) : AppColors.white.withValues(alpha: 0.22),
            width: 1.2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onPressed,
          onHover: (v) => setState(() => _hover = v),
          child: Padding(
            padding: _padding(widget.size),
            child: Row(
              mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(
                      fontSize: _fontSize(widget.size),
                      fontWeight: FontWeight.w600,
                      color: _hover ? AppColors.primary : AppColors.ink,
                      height: 1.2,
                    ),
                  ),
                ),
                if (widget.icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(widget.icon, size: 18, color: _hover ? AppColors.primary : AppColors.ink),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline text action with an arrow, e.g. "Learn more →".
class ArrowLink extends StatefulWidget {
  const ArrowLink({super.key, required this.label, required this.onPressed, this.color = AppColors.primary});

  final String label;
  final VoidCallback onPressed;
  final Color color;

  @override
  State<ArrowLink> createState() => _ArrowLinkState();
}

class _ArrowLinkState extends State<ArrowLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: AppTypography.body(fontSize: 14.5, fontWeight: FontWeight.w600, color: widget.color, height: 1.2),
                ),
                AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.only(left: _hover ? 10 : 6),
                  child: Icon(Icons.arrow_forward_rounded, size: 17, color: widget.color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
