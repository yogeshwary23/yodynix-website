import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../models/content_models.dart';
import '../../repositories/content/company_content.dart';
import '../../shared/three/photo_scene.dart';
import '../../shared/three/scene3d.dart';
import '../../shared/widgets/motion_effects.dart';
import '../../shared/widgets/parallax_photo.dart';
import '../../shared/widgets/premium.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';
import '../../shared/widgets/smart_image.dart';
import '../../shared/widgets/visuals/intro_visual.dart';
import '../../shared/widgets/visuals/pillar_visuals.dart';

/// "Who We Are": the headline and story beside a photograph set into a 3D
/// composition, then the six principles and the three core pillars, each
/// a photograph with its own 3D overlay. It
/// continues the hero's language: the same eyebrow, metallic gold
/// highlight, materials, warm light and layered shadows.
class IntroSection extends StatelessWidget {
  const IntroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionShell(
      background: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _IntroLead(),
          SizedBox(height: context.responsive(mobile: 48.0, desktop: 80.0)),
          const _Principles(),
          SizedBox(height: context.responsive(mobile: 48.0, desktop: 80.0)),
          const _PillarGrid(),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ Lead

/// Copy on the left, the photograph and its 3D on the right; stacked below
/// desktop widths. The pointer anywhere over the pair sways the scene.
class _IntroLead extends StatelessWidget {
  const _IntroLead();

  @override
  Widget build(BuildContext context) {
    return PointerField(
      builder: (context, pointer) {
        final visual = Reveal(
          delay: const Duration(milliseconds: 200),
          offset: 30,
          child: PhotoScene(
            photo: CompanyContent.whoWeArePhoto,
            photoAlt: CompanyContent.whoWeArePhotoAlt,
            photoFallback: const IntroVisual(),
            scene: Scene3D.about,
            sceneLabel:
                'A gold ribbon sweeping round the photograph, a glass globe banded in gold on a gold '
                'plinth, a glass panel of rising gold bars and a gold halo.',
            pointer: pointer,
          ),
        );
        if (context.isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(flex: 10, child: _IntroCopy()),
              const SizedBox(width: 48),
              Expanded(flex: 11, child: visual),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _IntroCopy(),
            const SizedBox(height: 28),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: context.isMobile ? 440 : 560),
                child: visual,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _IntroCopy extends StatelessWidget {
  const _IntroCopy();

  @override
  Widget build(BuildContext context) {
    final size = context.responsive<double>(mobile: 33, tablet: 44, desktop: 54);
    final style = AppTypography.display(
      fontSize: size,
      height: 1.08,
      fontWeight: FontWeight.w800,
      color: context.tone.ink,
      letterSpacing: -size * 0.022,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Reveal(child: RuleEyebrow('Who We Are')),
        SizedBox(height: size * 0.42),
        Reveal(
          delay: const Duration(milliseconds: 80),
          child: GoldHighlightHeading(heading: CompanyContent.introHeading, highlight: 'Into Progress.', style: style),
        ),
        SizedBox(height: size * 0.56),
        Reveal(
          delay: const Duration(milliseconds: 160),
          child: GoldBarLead(
            text: CompanyContent.introLead,
            style: AppTypography.body(
              fontSize: context.responsive(mobile: 17.0, desktop: 20.0),
              color: AppColors.ink,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
          ),
        ),
        SizedBox(height: context.responsive(mobile: 20.0, desktop: 26.0)),
        Reveal(
          delay: const Duration(milliseconds: 240),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Text(
              CompanyContent.introBody,
              style: AppTypography.body(fontSize: context.responsive(mobile: 15.5, desktop: 17.0), height: 1.85),
            ),
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------ Principles

/// Icons for [CompanyContent.introBeliefs], in the same order.
const _beliefIcons = [
  Icons.hearing_rounded,
  Icons.architecture_rounded,
  Icons.engineering_rounded,
  Icons.verified_rounded,
  Icons.school_rounded,
  Icons.lightbulb_rounded,
];

class _Principles extends StatelessWidget {
  const _Principles();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Reveal(
          child: Row(
            children: [
              Text(
                'Our principles',
                style: AppTypography.display(
                  fontSize: context.responsive(mobile: 24.0, desktop: 30.0),
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.champagneGold.withValues(alpha: 0.55), AppColors.champagneGold.withValues(alpha: 0)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.responsive(mobile: 22.0, desktop: 32.0)),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900 ? 3 : (constraints.maxWidth >= 560 ? 2 : 1);
            return ResponsiveGrid(
              minItemWidth: 1,
              maxColumns: columns,
              spacing: context.responsive(mobile: 14.0, desktop: 22.0),
              children: [
                for (final (i, belief) in CompanyContent.introBeliefs.indexed)
                  Reveal(
                    delay: Duration(milliseconds: 80 * (i % columns) + 40 * (i ~/ columns)),
                    child: _PrincipleCard(index: i, text: belief, icon: _beliefIcons[i % _beliefIcons.length]),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// One principle on a white glass card: a metallic gold icon, its number,
/// and a gold accent along the top that extends as the card lifts and
/// tilts towards the pointer.
class _PrincipleCard extends StatefulWidget {
  const _PrincipleCard({required this.index, required this.text, required this.icon});

  final int index;
  final String text;
  final IconData icon;

  @override
  State<_PrincipleCard> createState() => _PrincipleCardState();
}

class _PrincipleCardState extends State<_PrincipleCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final number = (widget.index + 1).toString().padLeft(2, '0');
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Tilt3D(
        radius: AppRadius.xl,
        maxAngle: 5,
        child: AnimatedContainer(
          duration: AppMotion.lift,
          curve: AppMotion.ease,
          transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
          decoration: premiumGlassCard(lifted: _hover),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 28,
                child: AnimatedContainer(
                  duration: AppMotion.lift,
                  curve: AppMotion.ease,
                  width: _hover ? 96 : 36,
                  height: 2,
                  decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(context.responsive(mobile: 20.0, desktop: 28.0)),
                child: context.isMobile ? _compact(number) : _stacked(number),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _number(String number) => Text(
    number,
    style: AppTypography.body(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.6,
      color: AppColors.goldInk.withValues(alpha: _hover ? 0.9 : 0.55),
      height: 1,
    ),
  );

  Widget _text(double fontSize) => Text(
    widget.text,
    style: AppTypography.body(fontSize: fontSize, color: AppColors.charcoal, fontWeight: FontWeight.w500, height: 1.55),
  );

  /// Icon and number above the text, on wider layouts.
  Widget _stacked(String number) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [GoldIconTile(icon: widget.icon, size: 52), const Spacer(), _number(number)]),
      const SizedBox(height: 20),
      _text(16.5),
    ],
  );

  /// Icon beside the text on phones, so six cards stay a short scroll.
  Widget _compact(String number) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GoldIconTile(icon: widget.icon, size: 44),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_number(number), const SizedBox(height: 8), _text(15.5)],
        ),
      ),
    ],
  );
}

// --------------------------------------------------------------- Pillars

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
          spacing: context.responsive(mobile: 16.0, desktop: 22.0),
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

/// Pillar card: 3D artwork in a lit ivory setting with a numbered glass
/// badge, then the category, headline, description and an explore action
/// that opens the pillar's detail page.
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
      child: Tilt3D(
        radius: AppRadius.xl,
        maxAngle: 3,
        child: AnimatedContainer(
          duration: AppMotion.lift,
          curve: AppMotion.ease,
          transform: Matrix4.translationValues(0, _active ? -8 : 0, 0),
          decoration: premiumGlassCard(lifted: _active),
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
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
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
                                          letterSpacing: 1.4,
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
                                    fontSize: context.responsive(mobile: 22.0, desktop: 24.0),
                                    fontWeight: FontWeight.w700,
                                    height: 1.25,
                                    letterSpacing: -0.3,
                                    color: AppColors.cardHeading,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  pillar.description,
                                  style: AppTypography.body(fontSize: 15, height: 1.65, color: AppColors.cardBody),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(padding: const EdgeInsets.only(top: 24), child: _action(pillar.actionLabel)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The pillar's photograph fading into lit ivory on one side, where its
  /// 3D overlay stands. On hover the photo eases in closer while the 3D
  /// lifts towards the viewer, so the two separate in depth.
  Widget _artwork(String number, CorePillar pillar) {
    final inner = BorderRadius.circular(AppRadius.md);
    final left = pillar.artworkOnLeft;
    final towards = left ? Alignment.centerLeft : Alignment.centerRight;
    return ClipRRect(
      borderRadius: inner,
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ParallaxPhoto(
              basePath: pillar.image,
              semanticLabel: pillar.imageAlt,
              depth: 10,
              zoom: _active ? 1.05 : 1,
              fallback: PillarVisual(art: pillar.art, active: _active),
            ),
            // The photo settles into ivory where the 3D stands, lit from
            // above it, so the objects sit in the room's light.
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: -towards,
                    end: towards,
                    colors: const [Color(0x00FAF5EC), Color(0x00FAF5EC), Color(0x99FAF5EC), Color(0xDBFAF5EC)],
                    // The careers photo's open wall is narrow, so its fade starts later.
                    stops: left ? const [0, 0.72, 0.86, 1] : const [0, 0.5, 0.72, 1],
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(left ? -0.64 : 0.6, -0.1),
                    radius: 0.75,
                    colors: const [Color(0x6BFFE8BE), Color(0x00FFE8BE)],
                  ),
                ),
              ),
            ),
            AnimatedSlide(
              duration: const Duration(milliseconds: 600),
              curve: AppMotion.ease,
              offset: Offset(0, _active ? -0.025 : 0),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 600),
                curve: AppMotion.ease,
                scale: _active ? 1.035 : 1,
                alignment: towards,
                child: SmartImage(
                  basePath: pillar.artwork,
                  semanticLabel: pillar.artworkAlt,
                  fallbackWidget: const SizedBox.shrink(),
                ),
              ),
            ),
            // Light catching the scene as the card lifts.
            IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                curve: AppMotion.ease,
                opacity: _active ? 1 : 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [AppColors.white.withValues(alpha: 0.26), AppColors.white.withValues(alpha: 0)],
                      stops: const [0, 0.55],
                    ),
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
            // The number sits opposite the 3D, over the photograph.
            Positioned(
              top: 14,
              left: left ? null : 14,
              right: left ? 14 : null,
              child: GoldNumberBadge(number: number, active: _active),
            ),
          ],
        ),
      ),
    );
  }

  Widget _action(String label) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 6, 6),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.cardLine)),
      ),
      child: Row(
        children: [
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: AppMotion.hover,
              style: AppTypography.body(
                fontSize: 14.5,
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _active ? AppColors.brandGradient : null,
              color: _active ? null : AppColors.cardTile,
              border: Border.all(color: _active ? AppColors.champagneGold : AppColors.cardLine),
              boxShadow: _active ? AppColors.glowShadow(0.8) : null,
            ),
            child: AnimatedSlide(
              duration: AppMotion.lift,
              curve: AppMotion.ease,
              offset: Offset(_active ? 0.08 : 0, 0),
              child: Icon(Icons.arrow_forward_rounded, size: 17, color: _active ? AppColors.white : AppColors.cardAccent),
            ),
          ),
        ],
      ),
    );
  }
}
