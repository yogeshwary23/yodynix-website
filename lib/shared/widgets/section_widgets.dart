import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
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

/// A full-width homepage section with consistent vertical rhythm.
class SectionShell extends StatelessWidget {
  const SectionShell({
    super.key,
    required this.child,
    this.background,
    this.gradient,
    this.topPadding,
    this.bottomPadding,
    this.decoration,
    this.glowAt,
    this.glowStrength = 1,
  });

  final Widget child;
  final Color? background;
  final Gradient? gradient;
  final double? topPadding;
  final double? bottomPadding;

  /// Optional decorative layer painted behind the content.
  final Widget? decoration;

  /// Paints a soft orange-red light pool at this position behind the content.
  final Alignment? glowAt;
  final double glowStrength;

  @override
  Widget build(BuildContext context) {
    final pad = context.sectionPadding;
    final layers = [
      if (glowAt != null)
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.glow(center: glowAt!, radius: 0.9, strength: 0.55 * glowStrength),
              ),
            ),
          ),
        ),
      if (decoration != null) Positioned.fill(child: decoration!),
    ];
    final content = Padding(
      padding: EdgeInsets.only(top: topPadding ?? pad, bottom: bottomPadding ?? pad),
      child: MaxWidth(child: child),
    );
    return DecoratedBox(
      decoration: BoxDecoration(color: background, gradient: gradient),
      child: layers.isEmpty ? content : Stack(children: [...layers, content]),
    );
  }
}

/// Small uppercase label shown above section headings.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color = AppColors.primary});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.8), blurRadius: 8)],
            ),
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
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.lead,
    this.centered = false,
    this.maxWidth = 760,
    this.eyebrowColor = AppColors.primary,
    this.titleSize,
  });

  final String eyebrow;
  final String title;
  final String? lead;
  final bool centered;
  final double maxWidth;
  final Color eyebrowColor;
  final double? titleSize;

  @override
  Widget build(BuildContext context) {
    final double size = titleSize ?? context.responsive<double>(mobile: 30, tablet: 38, desktop: 46);
    final align = centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.start;
    return Reveal(
      child: Align(
        alignment: centered ? Alignment.center : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: align,
            children: [
              Eyebrow(eyebrow, color: eyebrowColor),
              const SizedBox(height: 18),
              Semantics(
                header: true,
                child: Text(
                  title,
                  textAlign: textAlign,
                  style: AppTypography.display(fontSize: size),
                ),
              ),
              if (lead != null) ...[
                const SizedBox(height: 18),
                Text(
                  lead!,
                  textAlign: textAlign,
                  style: AppTypography.body(fontSize: context.responsive(mobile: 16.0, desktop: 18.0), height: 1.7),
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
