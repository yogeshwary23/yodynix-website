import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/utils/responsive.dart';
import '../../models/site_section.dart';
import '../../providers/section_navigator.dart';
import '../../repositories/content/company_content.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';
import '../../shared/widgets/smart_image.dart';
import '../../shared/widgets/visuals/visual_kind.dart';
import '../../shared/widgets/visuals/visual_primitives.dart';
import 'hero_stats_bar.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktop;
    final visual = Reveal(
      delay: const Duration(milliseconds: 250),
      offset: 40,
      child: AspectRatio(
        aspectRatio: 640 / 600,
        child: SmartImage(
          basePath: AssetPaths.hero,
          fallback: VisualKind.hero,
          fit: BoxFit.contain,
          semanticLabel:
              'A glowing blue innovation core connected to an AI assistant, a website, '
              'a mobile app and an automation workflow.',
        ),
      ),
    );

    return SectionShell(
      topPadding: context.responsive(mobile: 40.0, tablet: 64.0, desktop: 64.0),
      bottomPadding: context.responsive(mobile: 56.0, tablet: 72.0, desktop: 88.0),
      tone: SurfaceColors.dark,
      decoration: const _HeroBackdrop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (desktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(flex: 10, child: _HeroCopy()),
                // Asymmetric: the visual is larger and bleeds towards the edge.
                Expanded(
                  flex: 12,
                  child: Transform.translate(
                    offset: const Offset(36, 0),
                    child: Transform.scale(scale: 1.08, child: visual),
                  ),
                ),
              ],
            )
          else ...[
            const _HeroCopy(),
            const SizedBox(height: 32),
            Center(
              child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600), child: visual),
            ),
          ],
          SizedBox(height: context.responsive(mobile: 40.0, desktop: 56.0)),
          const Reveal(delay: Duration(milliseconds: 380), child: HeroStatsBar()),
        ],
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy();

  @override
  Widget build(BuildContext context) {
    final nav = SectionNavigatorScope.read(context);
    final tone = context.tone;
    final size = context.responsive(mobile: 40.0, tablet: 56.0, desktop: 58.0);
    final style = AppTypography.display(fontSize: size, height: 1.04, fontWeight: FontWeight.w800, color: tone.ink);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Reveal(
          child: Eyebrow(CompanyContent.heroEyebrow, color: AppColors.softChampagne, ornament: AppColors.steelBlue),
        ),
        const SizedBox(height: 26),
        Reveal(
          delay: const Duration(milliseconds: 80),
          child: Semantics(
            header: true,
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Turning Ideas Into\n'),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: _GlowText('Powerful Digital', style: style),
                  ),
                  const TextSpan(text: '\nExperiences.'),
                ],
              ),
              style: style,
            ),
          ),
        ),
        const SizedBox(height: 26),
        Reveal(
          delay: const Duration(milliseconds: 160),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              CompanyContent.heroDescription,
              style: AppTypography.body(fontSize: context.responsive(mobile: 16.5, desktop: 18.0), height: 1.7, color: tone.body),
            ),
          ),
        ),
        const SizedBox(height: 36),
        Reveal(
          delay: const Duration(milliseconds: 240),
          child: Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              PrimaryButton(
                label: 'Start Your Project',
                size: ButtonSize.large,
                fill: AppColors.softChampagne,
                onPressed: () => nav.startEnquiry(),
              ),
              SecondaryButton(
                label: 'Explore Our Services',
                size: ButtonSize.large,
                icon: Icons.south_east_rounded,
                onPressed: () => nav.scrollTo(SiteSection.services),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Accent-gradient text with a soft light bloom behind it.
class _GlowText extends StatelessWidget {
  const _GlowText(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: style.copyWith(
            color: AppColors.champagneGold.withValues(alpha: 0.0),
            shadows: [Shadow(color: AppColors.champagneGold.withValues(alpha: 0.12), blurRadius: 24)],
          ),
        ),
        GradientText(
          text,
          style: style,
          gradient: const LinearGradient(colors: [AppColors.champagneGold, AppColors.softChampagne]),
        ),
      ],
    );
  }
}

class _HeroBackdrop extends StatelessWidget {
  const _HeroBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => const RadialGradient(
                center: Alignment(0.5, -0.1),
                radius: 1.0,
                colors: [Colors.black, Colors.transparent],
              ).createShader(rect),
              child: CustomPaint(painter: GridPainter(color: AppColors.white.withValues(alpha: 0.045), step: 56)),
            ),
          ),
          // Main light behind the visual.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.glow(center: const Alignment(0.75, -0.2), radius: 0.9)),
            ),
          ),
          // Low bounce light on the left.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.glow(center: const Alignment(-1.1, 1.1), radius: 0.8, strength: 0.6)),
            ),
          ),
          // Settle into solid charcoal at the bottom edge.
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 120,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.deepCharcoal],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
