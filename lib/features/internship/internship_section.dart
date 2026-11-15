import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/constants/site_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/utils/responsive.dart';
import '../../repositories/content/internship_content.dart';
import '../../shared/layouts/navigation_actions.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';
import '../../shared/widgets/smart_image.dart';
import '../../shared/widgets/visuals/visual_kind.dart';
import '../../shared/widgets/visuals/visual_primitives.dart';
import 'internship_widgets.dart';

/// Homepage Internship section: a banner leading to the Internship page and
/// the seven programme cards, each opening its own programme page.
class InternshipSection extends StatelessWidget {
  const InternshipSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionShell(
      background: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(
            child: _InternshipBanner(
              onExplore: () => openInternshipPage(context),
              onApply: () => openInternshipPage(context, apply: true),
            ),
          ),
          SizedBox(height: context.responsive(mobile: 56.0, desktop: 80.0)),
          const SectionHeader(
            eyebrow: 'Internship Programs',
            eyebrowColor: AppColors.accent,
            title: 'Choose Your Learning Path',
            lead:
                'Seven programmes, each focused on practical skills and project-based learning. '
                'Open a programme to see what you will learn.',
            centered: true,
          ),
          const SizedBox(height: 48),
          ResponsiveGrid(
            minItemWidth: 270,
            maxColumns: 4,
            spacing: 20,
            children: [
              for (final (i, p) in InternshipContent.programs.indexed)
                Reveal(
                  delay: Duration(milliseconds: 60 * (i % 4)),
                  child: InternshipProgramCard(
                    program: p,
                    onOpen: () => openInternshipPage(context, slug: p.slug),
                  ),
                ),
              Reveal(
                delay: const Duration(milliseconds: 180),
                child: InternshipAtAGlanceCard(onApply: () => openInternshipPage(context, apply: true)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InternshipBanner extends StatelessWidget {
  const _InternshipBanner({required this.onExplore, required this.onApply});

  final VoidCallback onExplore;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktop;
    final mobile = context.isMobile;

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow(InternshipContent.badge, color: AppColors.primaryTint),
        const SizedBox(height: 20),
        Semantics(
          header: true,
          child: Text(
            InternshipContent.heading,
            style: AppTypography.display(
              fontSize: context.responsive(mobile: 30.0, tablet: 40.0, desktop: 46.0),
              color: AppColors.white,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          InternshipContent.description,
          style: AppTypography.body(fontSize: mobile ? 16 : 18, color: AppColors.onDarkBody),
        ),
        const SizedBox(height: 26),
        for (final (icon, label) in InternshipContent.highlights)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.primaryTint),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.body(fontSize: 15.5, fontWeight: FontWeight.w600, color: AppColors.white, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SecondaryButton(
              label: 'Explore Internship Opportunities',
              size: ButtonSize.large,
              icon: Icons.arrow_forward_rounded,
              onPressed: onExplore,
            ),
            TextButton(
              onPressed: onApply,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.white,
                textStyle: AppTypography.body(fontSize: 15, fontWeight: FontWeight.w700, height: 1.2),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              ),
              child: Text(InternshipConfig.applicationsOpen ? 'Apply Now' : 'Register Interest'),
            ),
          ],
        ),
      ],
    );

    final visual = AspectRatio(
      aspectRatio: 560 / 420,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SmartImage(
          basePath: AssetPaths.internship,
          fallback: VisualKind.internship,
          fit: BoxFit.cover,
          semanticLabel: InternshipContent.bannerImageAlt,
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.charcoalNavy, AppColors.deepCharcoal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(mobile ? 26 : 36),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoalNavy.withValues(alpha: 0.22),
            blurRadius: 60,
            offset: const Offset(0, 24),
            spreadRadius: -12,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(mobile ? 26 : 36),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: GridPainter(color: AppColors.white.withValues(alpha: 0.04), step: 36)),
            ),
            Positioned(
              right: -120,
              top: -160,
              child: Container(
                width: 460,
                height: 460,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppColors.accent.withValues(alpha: 0.18), AppColors.accent.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(context.responsive(mobile: 26.0, tablet: 44.0, desktop: 64.0)),
              child: SurfaceTone(
                colors: SurfaceColors.dark,
                child: desktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 6, child: copy),
                          const SizedBox(width: 48),
                          Expanded(flex: 5, child: visual),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [copy, const SizedBox(height: 36), visual],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
