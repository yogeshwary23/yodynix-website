import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/utils/responsive.dart';
import 'gold_flow.dart';
import 'particle_network.dart';
import 'reveal.dart';

/// Centres content at the site's maximum width with responsive gutters.
class MaxWidth extends StatelessWidget {
  const MaxWidth({super.key, required this.child, this.maxWidth = Breakpoints.maxContentWidth});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth + context.gutter * 2),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.gutter),
          child: child,
        ),
      ),
    );
  }
}

/// A full-width homepage section with consistent vertical rhythm. [tone]
/// decides whether the content below reads as a light or a dark surface.
class SectionShell extends StatelessWidget {
  const SectionShell({
    super.key,
    required this.child,
    this.tone = SurfaceColors.light,
    this.background,
    this.gradient,
    this.topPadding,
    this.bottomPadding,
    this.decoration,
    this.glowAt,
    this.glowStrength = 1,
    this.particles = true,
    this.flow = true,
    this.flowPattern,
  });

  final Widget child;
  final SurfaceColors tone;
  final Color? background;
  final Gradient? gradient;
  final double? topPadding;
  final double? bottomPadding;

  /// Optional decorative layer painted behind the content.
  final Widget? decoration;

  /// Paints a soft light pool at this position behind the content. Dark
  /// surfaces only: light sections stay clean.
  final Alignment? glowAt;
  final double glowStrength;

  /// Paints the site-wide particle network between the background and the
  /// content (see [ParticleNetworkLayer]).
  final bool particles;

  /// Paints flowing gold lines behind the content (see [GoldFlowLayer]);
  /// [flowPattern] picks their shape, or null for the next in turn.
  final bool flow;
  final GoldFlowPattern? flowPattern;

  @override
  Widget build(BuildContext context) {
    final pad = context.sectionPadding;
    final layers = [
      if (glowAt != null && tone.isDark)
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: tone.glow(center: glowAt!, radius: 0.9, strength: 0.55 * glowStrength),
              ),
            ),
          ),
        ),
      if (flow)
        Positioned.fill(
          // The curves keep to the padding, whichever edge they gather at.
          child: GoldFlowLayer(pattern: flowPattern, band: math.min(topPadding ?? pad, bottomPadding ?? pad)),
        ),
      if (particles) const Positioned.fill(child: ParticleNetworkLayer()),
      if (decoration != null) Positioned.fill(child: decoration!),
    ];
    final content = Padding(
      padding: EdgeInsets.only(top: topPadding ?? pad, bottom: bottomPadding ?? pad),
      child: MaxWidth(child: child),
    );
    return SurfaceTone(
      colors: tone,
      child: DecoratedBox(
        decoration: BoxDecoration(color: background ?? tone.background, gradient: gradient),
        child: layers.isEmpty ? content : Stack(children: [...layers, content]),
      ),
    );
  }
}

/// Small uppercase label shown above section headings.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color, this.ornament});

  final String text;

  /// Defaults to the surface's accent.
  final Color? color;

  /// Dot and outline colour; defaults to the surface's ornament.
  final Color? ornament;

  @override
  Widget build(BuildContext context) {
    final tone = context.tone;
    final color = context.readable(this.color ?? tone.accent);
    final ornament = this.ornament ?? tone.ornament;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: ornament == color ? 0.10 : 0.08),
        borderRadius: BorderRadius.circular(99),
        // A gold outline stays fine-lined; when the label is already in the
        // ornament colour (dark bands) a lighter edge is enough.
        border: Border.all(color: ornament.withValues(alpha: ornament == color ? 0.32 : 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: ornament, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text.toUpperCase(),
              style: AppTypography.body(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 1.4,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Eyebrow + display heading + optional lead paragraph.
/// The hero's eyebrow: a short gold rule followed by a spaced, uppercase
/// brand line. Used where a section continues the hero's look.
class RuleEyebrow extends StatelessWidget {
  const RuleEyebrow(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: mobile ? 24 : 32,
          height: 2,
          decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(2)),
        ),
        SizedBox(width: mobile ? 10 : 14),
        Flexible(
          child: Text(
            text.toUpperCase(),
            style: AppTypography.body(
              fontSize: mobile ? 11 : 15,
              fontWeight: FontWeight.w700,
              letterSpacing: mobile ? 1.2 : 2.4,
              height: 1.3,
              color: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.lead,
    this.centered = false,
    this.maxWidth = 760,
    this.eyebrowColor,
    this.titleSize,
  });

  final String eyebrow;
  final String title;
  final String? lead;
  final bool centered;
  final double maxWidth;

  /// Defaults to the surface's accent.
  final Color? eyebrowColor;
  final double? titleSize;

  @override
  Widget build(BuildContext context) {
    final double size = titleSize ?? context.responsive<double>(mobile: 30, tablet: 38, desktop: 46);
    final align = centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.start;
    final tone = context.tone;
    return Reveal(
      child: Align(
        alignment: centered ? Alignment.center : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: align,
            children: [
              Eyebrow(eyebrow, color: eyebrowColor ?? tone.accent),
              const SizedBox(height: 18),
              Semantics(
                header: true,
                child: Text(
                  title,
                  textAlign: textAlign,
                  style: AppTypography.display(fontSize: size, color: tone.ink),
                ),
              ),
              if (lead != null) ...[
                const SizedBox(height: 18),
                Text(
                  lead!,
                  textAlign: textAlign,
                  style: AppTypography.body(
                    fontSize: context.responsive(mobile: 16.0, desktop: 18.0),
                    height: 1.7,
                    color: tone.body,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Rows of equal-width, equal-height cards that reflow by available width.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 280,
    this.maxColumns = 3,
    this.spacing = 24,
    this.runSpacing,
    this.equalHeight = true,
  });

  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;
  final double spacing;
  final double? runSpacing;
  final bool equalHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = ((constraints.maxWidth + spacing) / (minItemWidth + spacing)).floor().clamp(1, maxColumns);
        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += columns) {
          final rowChildren = <Widget>[];
          for (var c = 0; c < columns; c++) {
            final index = i + c;
            rowChildren.add(Expanded(child: index < children.length ? children[index] : const SizedBox.shrink()));
            if (c < columns - 1) rowChildren.add(SizedBox(width: spacing));
          }
          final row = Row(
            crossAxisAlignment: equalHeight ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
            children: rowChildren,
          );
          // IntrinsicHeight bounds the row so cards can use Spacer/Expanded,
          // and stretches every card in the row to the tallest one.
          rows.add(equalHeight ? IntrinsicHeight(child: row) : row);
          if (i + columns < children.length) rows.add(SizedBox(height: runSpacing ?? spacing));
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
      },
    );
  }
}
