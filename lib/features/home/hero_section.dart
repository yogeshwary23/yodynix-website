import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/utils/responsive.dart';
import '../../models/site_section.dart';
import '../../providers/section_navigator.dart';
import '../../repositories/content/company_content.dart';
import '../../shared/layouts/navigation_actions.dart';
import '../../shared/three/scene_widgets.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';
import '../../shared/widgets/smart_image.dart';
import '../../shared/widgets/visuals/visual_kind.dart';
import 'hero_backdrop.dart';
import 'hero_stats_bar.dart';

/// Light, cinematic hero: the headline on the left and the signature 3D
/// sculpture on the right, inside the architectural [HeroBackdrop]. The statistics card straddles the backdrop's lower
/// edge. The sculpture and the backdrop both answer the pointer anywhere in
/// the hero, and the sculpture transforms as the page scrolls.
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
    // How far the backdrop stops short of the section's foot: the lower part
    // of the statistics card sits on the plain page surface below it.
    final overlap = context.responsive(mobile: 96.0, tablet: 110.0, desktop: 128.0);
    // The card rises into the empty space in front of the plinth.
    final cardLift = desktop ? 10.0 : 0.0;

    final sculpture = Reveal(
      delay: const Duration(milliseconds: 200),
      offset: 30,
      child: AspectRatio(
        aspectRatio: desktop ? 1.38 : 1.2,
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
        child: SurfaceTone(
          colors: SurfaceColors.light,
          child: ColoredBox(
            color: AppColors.background,
            child: Stack(
              children: [
                Positioned(left: 0, right: 0, top: 0, bottom: overlap, child: HeroBackdrop(pointer: _pointer)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: context.responsive(mobile: 36.0, tablet: 48.0, desktop: 16.0)),
                    MaxWidth(
                      maxWidth: Breakpoints.heroMaxWidth,
                      child: desktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Expanded(flex: 9, child: _HeroCopy()),
                                const SizedBox(width: 8),
                                Expanded(flex: 11, child: sculpture),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _HeroCopy(),
                                const SizedBox(height: 12),
                                Center(
                                  child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 620), child: sculpture),
                                ),
                              ],
                            ),
                    ),
                    SizedBox(height: context.responsive(mobile: 8.0, tablet: 16.0, desktop: 0.0)),
                    Transform.translate(
                      offset: Offset(0, -cardLift),
                      child: const MaxWidth(
                        maxWidth: Breakpoints.heroMaxWidth,
                        child: Reveal(delay: Duration(milliseconds: 380), child: HeroStatsBar()),
                      ),
                    ),
                    SizedBox(height: context.responsive(mobile: 40.0, tablet: 56.0, desktop: 64.0) - cardLift),
                  ],
                ),
              ],
            ),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        // Sized from the column so "Intelligent Digital" always holds its line.
        final size = (constraints.maxWidth * 0.11).clamp(34.0, 72.0);
        final style = AppTypography.display(
          fontSize: size,
          height: 1.06,
          fontWeight: FontWeight.w800,
          color: tone.ink,
          letterSpacing: -size * 0.022,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Reveal(child: RuleEyebrow(CompanyContent.heroEyebrow)),
            SizedBox(height: size * 0.36),
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
                        child: GradientText(CompanyContent.heroHeadlineAccent, style: style, gradient: AppColors.metallicGoldText),
                      ),
                      const TextSpan(text: CompanyContent.heroHeadlineTail),
                    ],
                  ),
                  style: style,
                ),
              ),
            ),
            SizedBox(height: size * 0.4),
            Reveal(
              delay: const Duration(milliseconds: 160),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Text(
                  CompanyContent.heroDescription,
                  style: AppTypography.body(
                    fontSize: context.responsive(mobile: 16.5, tablet: 18.0, desktop: 20.0),
                    height: 1.6,
                    color: tone.body,
                  ),
                ),
              ),
            ),
            SizedBox(height: context.responsive(mobile: 30.0, desktop: 38.0)),
            Reveal(
              delay: const Duration(milliseconds: 240),
              child: Wrap(
                spacing: 24,
                runSpacing: 14,
                children: [
                  PrimaryButton(
                    label: 'Explore Our Expertise',
                    size: ButtonSize.large,
                    onPressed: () => goToSection(context, SiteSection.expertise),
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
      },
    );
  }
}
