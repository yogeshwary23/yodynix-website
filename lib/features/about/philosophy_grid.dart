import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/utils/responsive.dart';
import '../../models/content_models.dart';
import '../../repositories/content/company_content.dart';
import '../../shared/widgets/motion_effects.dart';
import '../../shared/widgets/parallax_photo.dart';
import '../../shared/widgets/premium.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';
import '../../shared/widgets/visuals/illustrated_visual.dart';
import '../../shared/widgets/visuals/visual_kind.dart';

/// "Our Philosophy": the six principles as glass cards, each opening on a
/// warm photograph. Three columns on desktop, two on tablets, one on phones.
class PhilosophyGrid extends StatelessWidget {
  const PhilosophyGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final columns = context.responsive(mobile: 1, tablet: 2, desktop: 3);
    return ResponsiveGrid(
      minItemWidth: 0,
      maxColumns: columns,
      spacing: 24,
      equalHeight: columns > 1,
      children: [
        for (final (i, item) in CompanyContent.philosophy.indexed)
          Reveal(
            delay: Duration(milliseconds: 70 * (i % columns)),
            child: _PhilosophyCard(index: i, item: item),
          ),
      ],
    );
  }
}

/// White glass card: the principle's photograph with its number, a gold
/// icon overlapping the photo's edge, then the title and description. Tilts
/// towards the pointer, lifts, and eases the photo closer on hover.
class _PhilosophyCard extends StatefulWidget {
  const _PhilosophyCard({required this.index, required this.item});

  final int index;
  final FeaturePoint item;

  @override
  State<_PhilosophyCard> createState() => _PhilosophyCardState();
}

class _PhilosophyCardState extends State<_PhilosophyCard> {
  bool _hover = false;

  static const _iconSize = 52.0;

  Widget _copy(FeaturePoint item) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        item.title,
        style: AppTypography.display(fontSize: 19, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.cardHeading),
      ),
      const SizedBox(height: 10),
      Text(item.description, style: AppTypography.body(fontSize: 15, height: 1.65, color: AppColors.cardBody)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final number = (widget.index + 1).toString().padLeft(2, '0');
    final inner = BorderRadius.circular(AppRadius.md);

    return Semantics(
      container: true,
      label: '${item.title}. ${item.description}',
      excludeSemantics: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: Tilt3D(
          radius: AppRadius.xl,
          maxAngle: 4,
          child: AnimatedContainer(
            duration: AppMotion.lift,
            curve: AppMotion.ease,
            transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
            decoration: premiumGlassCard(lifted: _hover),
            child: SurfaceTone(
              colors: SurfaceColors.inCard,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // The icon tile sits half over the photo's lower edge.
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: inner,
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (item.image != null)
                                  ParallaxPhoto(
                                    basePath: item.image!,
                                    semanticLabel: item.imageAlt ?? item.title,
                                    depth: 8,
                                    zoom: _hover ? 1.06 : 1,
                                    fallback: const IllustratedVisual(VisualKind.about),
                                  )
                                else
                                  const IllustratedVisual(VisualKind.about),
                                // Warm light from the upper right, settling
                                // into ivory at the foot so the tile reads.
                                const IgnorePointer(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                        colors: [Color(0x40FFECC8), Color(0x00FFECC8)],
                                        stops: [0, 0.55],
                                      ),
                                    ),
                                  ),
                                ),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: inner,
                                    border: Border.all(color: AppColors.goldLine.withValues(alpha: 0.6)),
                                  ),
                                ),
                                Positioned(top: 12, left: 12, child: GoldNumberBadge(number: number, active: _hover)),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 18,
                          bottom: -_iconSize / 2,
                          child: GoldIconTile(icon: item.icon, size: _iconSize),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, _iconSize / 2 + 18, 18, 18),
                      // Invisible copies of every card's text make each card
                      // as tall as the longest, so all six match across rows.
                      child: Stack(
                        children: [
                          for (final other in CompanyContent.philosophy)
                            if (other != item)
                              Visibility(
                                visible: false,
                                maintainSize: true,
                                maintainAnimation: true,
                                maintainState: true,
                                child: _copy(other),
                              ),
                          _copy(item),
                        ],
                      ),
                    ),
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
