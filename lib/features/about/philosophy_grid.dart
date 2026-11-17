import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../models/content_models.dart';
import '../../repositories/content/company_content.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';
import '../../shared/widgets/tinted_photo.dart';

/// "Our Philosophy": the six principles as photographic cards.
class PhilosophyGrid extends StatelessWidget {
  const PhilosophyGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Three columns (3 + 3) on desktop, two on tablets and a single
    // column on phones.
    final columns = context.responsive(mobile: 1, tablet: 2, desktop: 3);
    final density = switch (columns) {
      3 => _Density.wide,
      2 => _Density.regular,
      _ => _Density.photo,
    };

    // Multi-column cards all share the tallest card's height; the single
    // column keeps a fixed aspect ratio.
    return ResponsiveGrid(
      minItemWidth: 0,
      maxColumns: columns,
      spacing: 20,
      equalHeight: columns > 1,
      children: [
        for (final (i, item) in CompanyContent.philosophy.indexed)
          Reveal(
            delay: Duration(milliseconds: 60 * (i % columns)),
            child: _PhilosophyCard(index: i, item: item, density: density),
          ),
      ],
    );
  }
}

/// Card sizing per layout. [photo] is the original fixed-aspect card; the
/// other two size to their copy so equal-height rows never clip text.
enum _Density {
  wide(padding: 22, icon: 40, number: 34, title: 19, body: 14.5, photoSpace: 180),
  regular(padding: 20, icon: 40, number: 32, title: 18, body: 14, photoSpace: 150),
  photo(padding: 22, icon: 40, number: 34, title: 19, body: 14.5, photoSpace: 0);

  const _Density({
    required this.padding,
    required this.icon,
    required this.number,
    required this.title,
    required this.body,
    required this.photoSpace,
  });

  final double padding;
  final double icon;
  final double number;
  final double title;
  final double body;

  /// Clear photo shown above the copy in the content-sized layouts.
  final double photoSpace;
}

/// Photographic principle card: full-bleed photo under a dark gradient, with
/// the number, title and description set over the lower portion. Lifts, zooms
/// and gains a gold edge on hover.
class _PhilosophyCard extends StatefulWidget {
  const _PhilosophyCard({required this.index, required this.item, required this.density});

  final int index;
  final FeaturePoint item;
  final _Density density;

  @override
  State<_PhilosophyCard> createState() => _PhilosophyCardState();
}

class _PhilosophyCardState extends State<_PhilosophyCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final d = widget.density;
    final fixedAspect = d == _Density.photo;
    final number = (widget.index + 1).toString().padLeft(2, '0');

    Widget copyOf(FeaturePoint item) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: AppMotion.lift,
          width: d.icon,
          height: d.icon,
          decoration: BoxDecoration(
            color: _hover ? AppColors.primary : AppColors.cardTile,
            borderRadius: BorderRadius.circular(d.icon * 0.3),
            border: Border.all(color: _hover ? AppColors.primary : AppColors.cardLine),
          ),
          child: Icon(item.icon, size: d.icon / 2, color: _hover ? AppColors.onPrimary : AppColors.cardAccent),
        ),
        SizedBox(height: d.padding * 0.64),
        Text(
          item.title,
          style: AppTypography.display(
            fontSize: d.title,
            fontWeight: FontWeight.w700,
            height: 1.25,
            color: AppColors.cardHeading,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.description,
          style: AppTypography.body(fontSize: d.body, height: 1.55, color: AppColors.cardBody),
        ),
      ],
    );
    final copy = copyOf(item);

    final layers = <Widget>[
      if (item.image != null)
        TintedPhoto(basePath: item.image!, semanticLabel: item.imageAlt ?? item.title, active: _hover, strength: 0.6)
      else
        const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.darkGlassGradient)),
      // Readability scrim: clear at the top, deep charcoal behind the copy.
      DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: const [Color(0x001E1C1A), Color(0x991E1C1A), Color(0xF21E1C1A)],
            stops: fixedAspect ? const [0.15, 0.5, 0.82] : const [0.12, 0.4, 0.62],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      Positioned(
        top: 16,
        right: d.padding - 4,
        child: Text(
          number,
          style: AppTypography.display(fontSize: d.number, fontWeight: FontWeight.w800, height: 1).copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2
              ..color = _hover ? AppColors.accent : AppColors.white.withValues(alpha: 0.55),
          ),
        ),
      ),
    ];

    final body = fixedAspect
        ? AspectRatio(
            aspectRatio: 4 / 3.5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ...layers,
                Positioned(left: d.padding, right: d.padding, bottom: d.padding, child: copy),
              ],
            ),
          )
        // Sized by the copy: photo and scrim fill whatever height the row
        // gives, and the copy sits at the bottom below a clear photo band.
        : Stack(
            fit: StackFit.expand,
            children: [
              for (final layer in layers) layer is Positioned ? layer : Positioned.fill(child: layer),
              Padding(
                padding: EdgeInsets.all(d.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: d.photoSpace),
                    const Spacer(),
                    // Invisible copies of every card's text make each card
                    // as tall as the longest one, so all six match in height
                    // across rows, not just within a row.
                    Stack(
                      alignment: AlignmentDirectional.bottomStart,
                      children: [
                        for (final other in CompanyContent.philosophy)
                          if (other != item)
                            Visibility(
                              visible: false,
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              child: copyOf(other),
                            ),
                        copy,
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );

    return Semantics(
      container: true,
      label: '${item.title}. ${item.description}',
      excludeSemantics: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedContainer(
          duration: AppMotion.lift,
          curve: AppMotion.ease,
          transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
          decoration: CardStyle.decoration(radius: AppRadius.lg, hover: _hover),
          child: ClipRRect(borderRadius: BorderRadius.circular(AppRadius.lg - 1), child: body),
        ),
      ),
    );
  }
}
