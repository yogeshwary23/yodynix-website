import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/utils/responsive.dart';
import '../../models/site_section.dart';
import '../../providers/section_navigator.dart';
import '../../repositories/content/company_content.dart';
import '../../shared/three/scene_widgets.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';
import '../../shared/widgets/smart_image.dart';
import '../../shared/widgets/visuals/visual_kind.dart';
import 'hero_stats_bar.dart';

/// Light, cinematic hero: the headline on the left and the signature 3D
/// sculpture on the right, reacting to the pointer anywhere in the hero and
/// transforming as the page scrolls.
class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final ValueNotifier<Offset> _pointer = ValueNotifier(Offset.zero);

  @override
  void dispose() {
    _pointer.dispose();
    super.dispose();
  }

  void _track(PointerEvent event, Size size) {
    _pointer.value = Offset(
      (event.localPosition.dx / size.width * 2 - 1).clamp(-1.0, 1.0),
      (event.localPosition.dy / size.height * 2 - 1).clamp(-1.0, 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktop;
    final sculpture = Reveal(
      delay: const Duration(milliseconds: 200),
      offset: 30,
      child: AspectRatio(
        aspectRatio: desktop ? 1.02 : 1.25,
        child: Hero3DScene(
          pointer: _pointer,
          fallback: SmartImage(
            basePath: AssetPaths.hero,
            fallback: VisualKind.hero,
            fit: BoxFit.contain,
            semanticLabel: 'An abstract sculpture representing connected digital intelligence.',
          ),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) => MouseRegion(
        onHover: (e) => _track(e, Size(constraints.maxWidth, context.size?.height ?? 800)),
        onExit: (_) => _pointer.value = Offset.zero,
        child: SectionShell(
          topPadding: context.responsive(mobile: 32.0, tablet: 48.0, desktop: 40.0),
          bottomPadding: context.responsive(mobile: 56.0, tablet: 72.0, desktop: 88.0),
          tone: SurfaceColors.light,
          background: AppColors.pearlWhite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (desktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(flex: 10, child: _HeroCopy()),
                    const SizedBox(width: 24),
                    // Sized so the sculpture never dominates the viewport.
                    Expanded(
                      flex: 11,
                      child: ConstrainedBox(constraints: const BoxConstraints(maxHeight: 600), child: sculpture),
                    ),
                  ],
                )
              else ...[
                const _HeroCopy(),
                const SizedBox(height: 16),
                Center(
                  child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: sculpture),
                ),
              ],
              SizedBox(height: context.responsive(mobile: 24.0, desktop: 40.0)),
              const Reveal(delay: Duration(milliseconds: 380), child: HeroStatsBar()),
            ],
          ),
        ),
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
    final size = context.responsive(mobile: 40.0, tablet: 54.0, desktop: 60.0);
    final style = AppTypography.display(fontSize: size, height: 1.06, fontWeight: FontWeight.w800, color: tone.ink, letterSpacing: -1.2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Reveal(child: Eyebrow(CompanyContent.heroEyebrow)),
        const SizedBox(height: 26),
        Reveal(
          delay: const Duration(milliseconds: 80),
          child: Semantics(
            header: true,
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: CompanyContent.heroHeadlineLead),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GradientText(
                      CompanyContent.heroHeadlineAccent,
                      style: style,
                      gradient: const LinearGradient(colors: [AppColors.antiqueGold, AppColors.champagneGold, Color(0xFFD9BC82)]),
                    ),
                  ),
                  const TextSpan(text: CompanyContent.heroHeadlineTail),
                ],
              ),
              style: style,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Reveal(
          delay: const Duration(milliseconds: 160),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              CompanyContent.heroDescription,
              style: AppTypography.body(fontSize: context.responsive(mobile: 16.5, desktop: 18.5), height: 1.65, color: tone.body),
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
                label: 'Explore Our Expertise',
                size: ButtonSize.large,
                onPressed: () => nav.scrollTo(SiteSection.expertise),
              ),
              SecondaryButton(
                label: 'Start Your Project',
                size: ButtonSize.large,
                icon: Icons.arrow_forward_rounded,
                onPressed: () => nav.startEnquiry(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
