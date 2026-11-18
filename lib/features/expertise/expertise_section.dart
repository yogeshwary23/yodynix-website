import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/surface_tone.dart';
import '../../models/content_models.dart';
import '../../models/site_section.dart';
import '../../repositories/content/expertise_content.dart';
import '../../shared/layouts/navigation_actions.dart';
import '../../core/utils/responsive.dart';
import '../../shared/three/interactive_3d_object.dart';
import '../../shared/three/scene3d.dart';
import '../../shared/three/scene_widgets.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';

class ExpertiseSection extends StatelessWidget {
  const ExpertiseSection({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = ExpertiseContent.categories;
    return SectionShell(
      background: AppColors.pearlWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            eyebrow: 'AI & Technology',
            title: ExpertiseContent.aiHeading,
            lead: ExpertiseContent.aiLead,
            centered: true,
          ),
          const SizedBox(height: 24),
          // The neural network: glass neurons with signals travelling between them.
          Reveal(
            child: AspectRatio(
              aspectRatio: context.responsive(mobile: 1.3, tablet: 1.8, desktop: 2.3),
              child: const Interactive3DObject(
                scene: Scene3D.neural,
                semanticLabel:
                    'A neural network of transparent glass and metal spheres, connected by fine lines '
                    'with points of golden light travelling between them.',
                background: AppColors.pearlWhite,
                fallback: SizedBox.shrink(),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const _TechnologyHeader(),
          const SizedBox(height: 48),
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

/// "Our Expertise" heading beside the technology ecosystem: metallic
/// components orbiting a gold hub, linked to it by fine lines.
class _TechnologyHeader extends StatelessWidget {
  const _TechnologyHeader();

  static const _header = SectionHeader(
    eyebrow: 'Our Expertise',
    title: ExpertiseContent.heading,
    lead: ExpertiseContent.lead,
  );

  static const _scene = Section3DScene(
    scene: Scene3D.ecosystem,
    semanticLabel:
        'A rotating ecosystem of metallic and glass components on gold and platinum orbits, '
        'each linked to a central gold hub.',
    fallback: SizedBox.shrink(),
  );

  @override
  Widget build(BuildContext context) {
    if (!context.isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header,
          const SizedBox(height: 16),
          Reveal(child: AspectRatio(aspectRatio: context.responsive(mobile: 1.2, tablet: 1.7, desktop: 1.7), child: _scene)),
        ],
      );
    }
    return Row(
      children: [
        const Expanded(flex: 5, child: _header),
        const SizedBox(width: 32),
        Expanded(flex: 6, child: Reveal(child: AspectRatio(aspectRatio: 1.45, child: _scene))),
      ],
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
                  style: AppTypography.display(fontSize: 19, fontWeight: FontWeight.w700, color: context.tone.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(category.description, style: AppTypography.body(fontSize: 14, color: context.tone.body)),
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
                      style: AppTypography.body(fontSize: 14.5, fontWeight: FontWeight.w600, color: context.tone.ink, height: 1.3),
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
    // A solid gold panel with white type and a light outlined button.
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.glowShadow(1.4),
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
                color: AppColors.white.withValues(alpha: 0.16),
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
              onPressed: () => goToSection(context, SiteSection.contact),
            ),
          ],
        ),
      ),
    );
  }
}
