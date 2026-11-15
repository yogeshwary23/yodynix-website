import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/surface_tone.dart';
import '../../models/content_models.dart';
import '../../models/site_section.dart';
import '../../providers/section_navigator.dart';
import '../../repositories/content/expertise_content.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';
import '../../shared/widgets/visuals/visual_primitives.dart';

class ExpertiseSection extends StatelessWidget {
  const ExpertiseSection({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = ExpertiseContent.categories;
    return SectionShell(
      tone: SurfaceColors.dark,
      glowAt: const Alignment(-1, -0.8),
      decoration: IgnorePointer(
        child: CustomPaint(painter: GridPainter(color: AppColors.white.withValues(alpha: 0.03), step: 40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            eyebrow: 'Our Expertise',
            title: ExpertiseContent.heading,
            lead: ExpertiseContent.lead,
            centered: true,
          ),
          const SizedBox(height: 56),
          ResponsiveGrid(
            minItemWidth: 260,
            maxColumns: 4,
            spacing: 20,
            children: [
              for (final (i, category) in categories.indexed)
                Reveal(
                  delay: Duration(milliseconds: 60 * (i % 4)),
                  child: _CategoryCard(category: category),
                ),
              const Reveal(delay: Duration(milliseconds: 180), child: _TalkCard()),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final TechCategory category;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: category.icon, color: AppColors.primary, size: 42, gradient: true),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  category.name,
                  style: AppTypography.display(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(category.description, style: AppTypography.body(fontSize: 14, color: AppColors.onDarkBody)),
          const SizedBox(height: 18),
          for (final item in category.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(color: item.color.withValues(alpha: 0.09), borderRadius: BorderRadius.circular(10)),
                    child: Icon(item.icon, size: 17, color: item.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.name,
                      style: AppTypography.body(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.white, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TalkCard extends StatelessWidget {
  const _TalkCard();

  @override
  Widget build(BuildContext context) {
    // A solid champagne panel; its outlined button reads as on a light surface.
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 30, offset: const Offset(0, 14))],
      ),
      child: SurfaceTone(
        colors: SurfaceColors.light,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.deepCharcoal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.forum_outlined, color: AppColors.onPrimary, size: 21),
            ),
            const SizedBox(height: 18),
            Text(
              'Have a specific technology in mind?',
              style: AppTypography.display(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.onPrimary, height: 1.3),
            ),
            const SizedBox(height: 10),
            Text(
              "Tell us about your existing systems and preferences, and we'll recommend the "
              'most practical approach for your project.',
              style: AppTypography.body(fontSize: 14, color: AppColors.onPrimary.withValues(alpha: 0.85)),
            ),
            const Spacer(),
            const SizedBox(height: 18),
            SecondaryButton(
              label: "Let's Talk",
              size: ButtonSize.small,
              icon: Icons.arrow_forward_rounded,
              onPressed: () => SectionNavigatorScope.read(context).scrollTo(SiteSection.contact),
            ),
          ],
        ),
      ),
    );
  }
}
