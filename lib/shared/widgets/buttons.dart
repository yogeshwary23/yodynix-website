import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/surface_tone.dart';
import 'motion_effects.dart';

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

/// Solid champagne-gold action with a soft lift on hover and an arrow that
/// nudges forward.
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
    this.fill,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonSize size;
  final bool expand;
  final bool loading;

  /// Uses the charcoal fill instead of gold, for a quieter action
  /// next to a primary one.
  final bool warm;

  /// Overrides the gold fill; hover deepens to antique gold.
  final Color? fill;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _hover = false;
  bool _pressed = false;

  /// Counts pointer arrivals; each one replays the light sweep.
  int _sweeps = 0;

  void _setHover(bool hover) {
    if (hover == _hover) return;
    setState(() {
      _hover = hover;
      if (hover) _sweeps++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.warm ? AppColors.charcoal : widget.fill ?? AppColors.primary;
    final hoverFill = widget.warm
        ? AppColors.deepCharcoal
        : widget.fill != null
        ? AppColors.primary
        : AppColors.primaryDeep;
    final foreground = widget.warm ? AppColors.white : AppColors.onPrimary;
    final enabled = widget.onPressed != null && !widget.loading;

    // Drawn a few pixels towards the cursor on hover (not on touch).
    return Magnetic(
      child: Semantics(
        button: true,
        enabled: enabled,
        label: widget.label,
        excludeSemantics: true,
        child: AnimatedScale(
          // A slight press on tap, for a tactile response.
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: AppMotion.hover,
            curve: AppMotion.ease,
            transform: Matrix4.translationValues(0, _hover && enabled ? -2 : 0, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              boxShadow: [
                BoxShadow(
                  color: AppColors.deepCharcoal.withValues(alpha: _hover && enabled ? 0.18 : 0.08),
                  blurRadius: _hover ? 22 : 14,
                  offset: const Offset(0, 6),
                ),
                // Warm gold halo on hover (gold buttons only).
                if (!widget.warm)
                  BoxShadow(
                    color: AppColors.champagneGold.withValues(alpha: _hover && enabled ? 0.38 : 0),
                    blurRadius: 26,
                    spreadRadius: -4,
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              clipBehavior: Clip.antiAlias,
              child: Ink(
                decoration: BoxDecoration(color: enabled ? (_hover ? hoverFill : base) : AppColors.softGrey),
                child: InkWell(
                  onTap: enabled ? widget.onPressed : null,
                  onHover: _setHover,
                  onHighlightChanged: (v) => setState(() => _pressed = v),
                  child: _LightSweep(
                    run: _sweeps,
                    enabled: enabled && !widget.warm,
                    child: Padding(
                      padding: _padding(widget.size),
                      child: Row(
                        mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.loading)
                            SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: foreground))
                          else
                            Flexible(
                              child: Text(
                                widget.label,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.body(
                                  fontSize: _fontSize(widget.size),
                                  fontWeight: FontWeight.w600,
                                  color: foreground,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          if (widget.icon != null && !widget.loading) ...[
                            AnimatedPadding(
                              duration: AppMotion.hover,
                              padding: EdgeInsets.only(left: _hover ? 12 : 8),
                              child: Icon(widget.icon, size: 18, color: foreground),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A polished highlight that glides once across a gold button each time
/// [run] changes, like light catching metal. Skipped under reduced motion.
class _LightSweep extends StatelessWidget {
  const _LightSweep({required this.run, required this.enabled, required this.child});

  final int run;
  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled || run == 0 || (MediaQuery.maybeDisableAnimationsOf(context) ?? false)) return child;
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: TweenAnimationBuilder<double>(
              key: ValueKey(run),
              tween: Tween(begin: -1.4, end: 1.4),
              duration: const Duration(milliseconds: 750),
              curve: Curves.easeInOutCubic,
              builder: (_, x, _) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(x - 0.6, -1),
                    end: Alignment(x + 0.6, 1),
                    colors: [
                      AppColors.white.withValues(alpha: 0),
                      AppColors.white.withValues(alpha: 0.42),
                      AppColors.white.withValues(alpha: 0),
                    ],
                    stops: const [0.3, 0.5, 0.7],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
    final tone = context.tone;
    final hoverText = tone.accent;
    // Drawn a few pixels towards the cursor on hover (not on touch).
    return Magnetic(
      child: Semantics(
        button: true,
        label: widget.label,
        excludeSemantics: true,
        child: Material(
          color: _hover ? tone.ghostHoverFill : tone.ghostFill,
          shape: StadiumBorder(
            side: BorderSide(color: _hover ? tone.accent.withValues(alpha: 0.7) : tone.ghostBorder, width: 1.2),
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
                        color: _hover ? hoverText : tone.ink,
                        height: 1.2,
                      ),
                    ),
                  ),
                  if (widget.icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(widget.icon, size: 18, color: _hover ? hoverText : tone.ink),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline text action with an arrow, e.g. "Learn more →".
class ArrowLink extends StatefulWidget {
  const ArrowLink({super.key, required this.label, required this.onPressed, this.color});

  final String label;
  final VoidCallback onPressed;

  /// Defaults to the surface's accent.
  final Color? color;

  @override
  State<ArrowLink> createState() => _ArrowLinkState();
}

class _ArrowLinkState extends State<ArrowLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final color = context.readable(widget.color ?? context.tone.accent);
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
                  style: AppTypography.body(fontSize: 14.5, fontWeight: FontWeight.w600, color: color, height: 1.2),
                ),
                AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.only(left: _hover ? 10 : 6),
                  child: Icon(Icons.arrow_forward_rounded, size: 17, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
