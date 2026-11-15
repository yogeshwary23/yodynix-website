import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../models/content_models.dart';
import '../../repositories/content/company_content.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';
import '../../shared/widgets/tinted_photo.dart';
import '../../shared/widgets/visuals/intro_visual.dart';
import '../../shared/widgets/visuals/pillar_visuals.dart';

class IntroSection extends StatelessWidget {
  const IntroSection({super.key});

  @override
  Widget build(BuildContext context) {
    const visual = Reveal(
      delay: Duration(milliseconds: 120),
      child: AspectRatio(aspectRatio: 560 / 520, child: IntroVisual()),
    );

    return SectionShell(
      background: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (context.isDesktop)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 11, child: _IntroCopy()),
                SizedBox(width: 56),
                Expanded(flex: 10, child: visual),
              ],
            )
          else ...[
            const _IntroCopy(),
            const SizedBox(height: 32),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: context.isMobile ? 420 : 520),
                child: visual,
              ),
            ),
          ],
          SizedBox(height: context.responsive(mobile: 40.0, desktop: 64.0)),
          const _BeliefsCard(),
          SizedBox(height: context.responsive(mobile: 48.0, desktop: 72.0)),
          const _PillarGrid(),
        ],
      ),
    );
  }
}

class _IntroCopy extends StatelessWidget {
  const _IntroCopy();

  @override
  Widget build(BuildContext context) {
    final titleSize = context.responsive<double>(mobile: 31, tablet: 40, desktop: 48);
    final titleStyle = AppTypography.display(fontSize: titleSize, height: 1.1);
    const highlight = 'Into Progress.';
    const heading = CompanyContent.introHeading;
    final split = heading.endsWith(highlight) ? heading.length - highlight.length : heading.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Reveal(child: Eyebrow('Who We Are')),
        const SizedBox(height: 20),
        Reveal(
          child: Semantics(
            header: true,
            label: heading,
            child: ExcludeSemantics(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: heading.substring(0, split)),
                    if (split < heading.length)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: AppColors.headlineGradientLight.createShader,
                          child: Text(heading.substring(split), style: titleStyle),
                        ),
                      ),
                  ],
                ),
                style: titleStyle,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Reveal(
          child: Container(
            padding: const EdgeInsets.only(left: 20),
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: AppColors.accent, width: 2)),
            ),
            child: Text(
              CompanyContent.introLead,
              style: AppTypography.body(
                fontSize: context.responsive(mobile: 17.0, desktop: 19.5),
                color: AppColors.ink,
                fontWeight: FontWeight.w500,
                height: 1.6,
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Reveal(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              CompanyContent.introBody,
              style: AppTypography.body(fontSize: context.responsive(mobile: 15.5, desktop: 16.5), height: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}

/// Icons for [CompanyContent.introBeliefs], in the same order.
const _beliefIcons = [
  Icons.hearing_rounded,
  Icons.architecture_rounded,
  Icons.engineering_rounded,
  Icons.verified_rounded,
  Icons.school_rounded,
  Icons.lightbulb_rounded,
];

class _BeliefsCard extends StatelessWidget {
  const _BeliefsCard();

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.xl);
    return Reveal(
      child: Container(
        decoration: CardStyle.decoration(radius: AppRadius.xl),
        child: SurfaceTone(
          colors: SurfaceColors.inCard,
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(context.responsive(mobile: 22.0, tablet: 32.0, desktop: 40.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const _AccentIcon(icon: Icons.favorite_rounded, size: 46),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Our principles',
                              style: AppTypography.display(
                                fontSize: context.responsive(mobile: 20.0, desktop: 24.0),
                                fontWeight: FontWeight.w700,
                                color: AppColors.cardHeading,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.softGrey.withValues(alpha: 0.7), AppColors.cardLine.withValues(alpha: 0)],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ResponsiveGrid(
                        minItemWidth: 280,
                        maxColumns: 3,
                        spacing: 28,
                        runSpacing: 22,
                        equalHeight: false,
                        children: [
                          for (final (i, belief) in CompanyContent.introBeliefs.indexed)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _AccentIcon(icon: _beliefIcons[i % _beliefIcons.length], size: 38),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 7),
                                    child: Text(
                                      belief,
                                      style: AppTypography.body(fontSize: 15.5, color: AppColors.cardHeading, height: 1.55),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Accent icon tile used consistently in the beliefs card.
class _AccentIcon extends StatelessWidget {
  const _AccentIcon({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: AppColors.cardTile, borderRadius: BorderRadius.circular(size * 0.3)),
      child: Icon(icon, size: size * 0.5, color: AppColors.cardAccent),
    );
  }
}

/// The three core pillars: three across on desktops and wide tablets, one
/// per row below that (two columns would leave an orphan card).
class _PillarGrid extends StatelessWidget {
  const _PillarGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = !context.isMobile && constraints.maxWidth >= 860 ? 3 : 1;
        return ResponsiveGrid(
          // Column count is decided above; the grid only distributes width.
          minItemWidth: 1,
          maxColumns: columns,
          spacing: context.responsive(mobile: 16.0, desktop: 20.0),
          children: [
            for (final (i, pillar) in CompanyContent.corePillars.indexed)
              Reveal(
                delay: Duration(milliseconds: 90 * (i % columns)),
                child: _PillarCard(index: i, pillar: pillar),
              ),
          ],
        );
      },
    );
  }
}

/// Editorial pillar card: photograph with an outlined index number,
/// category, headline, description and an explore action that opens the
/// pillar's detail page.
///
class _PillarCard extends StatefulWidget {
  const _PillarCard({required this.index, required this.pillar});

  final int index;
  final CorePillar pillar;

  @override
  State<_PillarCard> createState() => _PillarCardState();
}

class _PillarCardState extends State<_PillarCard> {
  bool _hover = false;
  bool _focus = false;

  bool get _active => _hover || _focus;

  void _open() => Navigator.of(context).pushNamed(widget.pillar.route);

  @override
  Widget build(BuildContext context) {
    final pillar = widget.pillar;
    final radius = BorderRadius.circular(AppRadius.xl);
    final number = (widget.index + 1).toString().padLeft(2, '0');

    return Semantics(
      button: true,
      link: true,
      label: '$number. ${pillar.title}. ${pillar.actionLabel}',
      child: AnimatedContainer(
        duration: AppMotion.lift,
        curve: AppMotion.ease,
        transform: Matrix4.translationValues(0, _active ? -8 : 0, 0),
        decoration: CardStyle.decoration(radius: AppRadius.xl, hover: _active),
        child: SurfaceTone(
          colors: SurfaceColors.inCard,
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _open,
              onHover: (v) => setState(() => _hover = v),
              onFocusChange: (v) => setState(() => _focus = v),
              borderRadius: radius,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              splashColor: AppColors.cardAccent.withValues(alpha: 0.06),
              highlightColor: AppColors.cardAccent.withValues(alpha: 0.03),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _artwork(number, pillar),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 22, 14, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 1),
                                    child: Icon(pillar.icon, size: 15, color: AppColors.cardAccent),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      pillar.title.toUpperCase(),
                                      style: AppTypography.body(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.cardAccent,
                                        letterSpacing: 1.3,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                pillar.headline,
                                style: AppTypography.display(
                                  fontSize: context.responsive(mobile: 22.0, desktop: 23.0),
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                  color: AppColors.cardHeading,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                pillar.description,
                                style: AppTypography.body(fontSize: 14.5, height: 1.65, color: AppColors.cardBody),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(padding: const EdgeInsets.only(top: 22), child: _action(pillar.actionLabel)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _artwork(String number, CorePillar pillar) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            TintedPhoto(
              basePath: pillar.image,
              semanticLabel: pillar.imageAlt,
              active: _active,
              fallback: PillarVisual(art: pillar.art, active: _active),
            ),
            // Fade the artwork into the card body.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Color(0x40151B26)],
                  stops: [0.6, 1],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.white.withValues(alpha: 0.06)),
              ),
            ),
            // Outlined index number.
            Positioned(
              top: 8,
              right: 14,
              child: Text(
                number,
                style: AppTypography.display(fontSize: 44, fontWeight: FontWeight.w800, height: 1, color: AppColors.cardHeading)
                    .copyWith(
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 1.2
                        ..color = _active
                            ? AppColors.cardAccent.withValues(alpha: 0.75)
                            : AppColors.white.withValues(alpha: 0.28),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _action(String label) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 6, 6),
      decoration: BoxDecoration(
        border: const Border(top: BorderSide(color: AppColors.cardLine)),
      ),
      child: Row(
        children: [
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: AppMotion.hover,
              style: AppTypography.body(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _active ? AppColors.cardAccent : AppColors.cardHeading,
                height: 1.3,
              ),
              child: Text(label),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedContainer(
            duration: AppMotion.lift,
            curve: AppMotion.ease,
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _active ? AppColors.primary : AppColors.cardTile,
              border: Border.all(color: _active ? AppColors.primary : AppColors.cardLine),
              boxShadow: _active ? AppColors.glowShadow(0.6) : null,
            ),
            child: AnimatedSlide(
              duration: AppMotion.lift,
              curve: AppMotion.ease,
              offset: Offset(_active ? 0.08 : 0, 0),
              child: Icon(Icons.arrow_forward_rounded, size: 17, color: _active ? AppColors.onPrimary : AppColors.cardAccent),
            ),
          ),
        ],
      ),
    );
  }
}
