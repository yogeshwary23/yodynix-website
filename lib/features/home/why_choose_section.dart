import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../models/content_models.dart';
import '../../repositories/content/company_content.dart';
import '../../services/asset_registry.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';

class WhyChooseSection extends StatelessWidget {
  const WhyChooseSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionShell(
      background: AppColors.surface,
      glowAt: const Alignment(1.1, 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            eyebrow: 'Why Choose Yodynix',
            eyebrowColor: AppColors.cyan,
            title: CompanyContent.whyChooseHeading,
            lead:
                'What working with us feels like — a partner that cares about the outcome, '
                'not just the deliverable.',
            centered: true,
          ),
          const SizedBox(height: 64),
          ResponsiveGrid(
            minItemWidth: 300,
            maxColumns: 3,
            spacing: 28,
            children: [
              for (final (i, point) in CompanyContent.whyChoose.indexed)
                Reveal(
                  delay: Duration(milliseconds: 70 * (i % 3)),
                  child: _PhotoCard(point: point),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Photo-led card: the photograph fills the top band and zooms in on hover
/// while the card lifts and its border glows cyan.
class _PhotoCard extends StatefulWidget {
  const _PhotoCard({required this.point});

  final FeaturePoint point;

  @override
  State<_PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<_PhotoCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final point = widget.point;
    final radius = BorderRadius.circular(AppRadius.lg);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: AppMotion.lift,
        curve: AppMotion.ease,
        transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
        decoration: BoxDecoration(
          gradient: AppColors.glassGradient,
          borderRadius: radius,
          border: Border.all(
            color: _hover ? AppColors.cyan.withValues(alpha: 0.7) : AppColors.electricBlue.withValues(alpha: 0.24),
          ),
          boxShadow: _hover
              ? [...AppColors.glowShadow(1.1), ...AppColors.softShadow(0.8)]
              : AppColors.softShadow(0.6),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ~2:1 keeps the photo at roughly 40–45% of the card height.
              AspectRatio(
                aspectRatio: 2,
                child: _CardPhoto(basePath: point.image ?? '', semanticLabel: point.imageAlt ?? point.title, active: _hover),
              ),
              Container(height: 1, color: AppColors.electricBlue.withValues(alpha: 0.22)),
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 24, 26, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: AppMotion.lift,
                      curve: AppMotion.ease,
                      width: _hover ? 44 : 28,
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(point.title, style: AppTypography.display(fontSize: 19, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Text(point.description, style: AppTypography.body(fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardPhoto extends StatelessWidget {
  const _CardPhoto({required this.basePath, required this.semanticLabel, required this.active});

  final String basePath;
  final String semanticLabel;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final path = AssetRegistry.instance.resolve(basePath);
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedScale(
          duration: const Duration(milliseconds: 450),
          curve: AppMotion.ease,
          scale: active ? 1.07 : 1,
          child: path == null
              ? const _PhotoFallback()
              : Image.asset(
                  path,
                  fit: BoxFit.cover,
                  semanticLabel: semanticLabel,
                  filterQuality: FilterQuality.medium,
                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                    if (wasSynchronouslyLoaded) return child;
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 450),
                      child: child,
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const _PhotoFallback(),
                ),
        ),
        // Navy grade so the photos sit within the palette; lifts on hover.
        IgnorePointer(
          child: AnimatedOpacity(
            duration: AppMotion.lift,
            opacity: active ? 0.5 : 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.midnightNavy.withValues(alpha: 0.08),
                    AppColors.deepNavy.withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.glassGradient),
      child: Center(child: Icon(Icons.image_outlined, size: 40, color: AppColors.muted.withValues(alpha: 0.6))),
    );
  }
}
