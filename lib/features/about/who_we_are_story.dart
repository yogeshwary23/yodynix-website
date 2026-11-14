import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../repositories/content/company_content.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/tinted_photo.dart';
import '../../shared/widgets/visuals/illustrated_visual.dart';
import '../../shared/widgets/visuals/visual_kind.dart';

/// "Who We Are": the studio photo beside our story, vision, mission and
/// approach; stacked below desktop widths.
class WhoWeAreStory extends StatelessWidget {
  const WhoWeAreStory({super.key});

  @override
  Widget build(BuildContext context) {
    final visual = Reveal(
      child: MediaFrame(
        aspectRatio: 560 / 480,
        radius: 28,
        child: TintedPhoto(
          basePath: AssetPaths.about,
          fallback: IllustratedVisual(VisualKind.about),
          strength: 0.7,
          semanticLabel: 'A technology team at work on their computers in a bright, open office.',
        ),
      ),
    );

    final story = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final paragraph in CompanyContent.aboutStory)
          Reveal(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(paragraph, style: AppTypography.body(fontSize: 16.5)),
            ),
          ),
        const SizedBox(height: 12),
        const Reveal(
          child: _StatementCard(
            icon: Icons.visibility_outlined,
            title: 'Our Vision',
            text: CompanyContent.vision,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        const Reveal(
          child: _StatementCard(
            icon: Icons.flag_outlined,
            title: 'Our Mission',
            text: CompanyContent.mission,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 16),
        const Reveal(
          child: _StatementCard(
            icon: Icons.route_outlined,
            title: 'Our Approach',
            text: CompanyContent.approach,
            color: AppColors.iceBlue,
          ),
        ),
      ],
    );

    if (!context.isDesktop) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [visual, const SizedBox(height: 40), story]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: visual),
        const SizedBox(width: 64),
        Expanded(flex: 6, child: story),
      ],
    );
  }
}

class _StatementCard extends StatelessWidget {
  const _StatementCard({required this.icon, required this.title, required this.text, required this.color});

  final IconData icon;
  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.glassGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow(0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Accent strip along the leading edge.
              Container(width: 4, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconBadge(icon: icon, color: color, size: 44),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AppTypography.display(fontSize: 18, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Text(text, style: AppTypography.body(fontSize: 15.5, color: AppColors.ink)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
