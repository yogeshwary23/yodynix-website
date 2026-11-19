import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../models/site_section.dart';
import '../../repositories/content/industries_content.dart';
import '../../repositories/content/services_content.dart';
import '../../shared/layouts/navigation_actions.dart';
import '../../shared/layouts/subpage_scaffold.dart';
import '../../shared/three/scene3d.dart';
import '../../shared/three/scene_widgets.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/motion_effects.dart';
import '../../shared/widgets/parallax_photo.dart';
import '../../shared/widgets/premium.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';

/// `/industries`: a hero with the eight sectors linked in 3D, then one
/// editorial section per sector: a photograph of the sector with its own 3D
/// arrangement set into it, the solutions that fit it and links to the
/// relevant services.
class IndustriesPage extends StatefulWidget {
  const IndustriesPage({super.key});

  @override
  State<IndustriesPage> createState() => _IndustriesPageState();
}

class _IndustriesPageState extends State<IndustriesPage> {
  final _sectionKeys = [for (final i in IndustriesContent.industries) GlobalKey(debugLabel: i.id)];

  void _jumpTo(int index) {
    final ctx = _sectionKeys[index].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: prefersReducedMotion(context) ? Duration.zero : const Duration(milliseconds: 900),
      curve: Curves.easeInOutCubic,
      alignment: 0.02,
    );
  }

  @override
  Widget build(BuildContext context) {
    const industries = IndustriesContent.industries;
    return SubpageScaffold(
      title: 'Industries',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionShell(
            background: AppColors.pearlWhite,
            topPadding: context.responsive(mobile: 36.0, desktop: 72.0),
            bottomPadding: context.responsive(mobile: 48.0, desktop: 88.0),
            child: _Hero(onSelect: _jumpTo),
          ),
          for (final (index, industry) in industries.indexed)
            KeyedSubtree(
              key: _sectionKeys[index],
              child: SectionShell(
                background: index.isEven ? AppColors.surface : AppColors.pearlWhite,
                topPadding: context.responsive(mobile: 56.0, desktop: 104.0),
                bottomPadding: context.responsive(mobile: 64.0, desktop: 104.0),
                decoration: const _SectionSeam(),
                child: _IndustrySection(
                  index: index,
                  industry: industry,
                  photoFirst: index.isEven,
                  // Matches the still renders (see tool/render_scenes).
                  panelColor: index.isEven ? AppColors.surface : AppColors.pearlWhite,
                ),
              ),
            ),
          SectionShell(
            background: industries.length.isEven ? AppColors.surface : AppColors.pearlWhite,
            decoration: const _SectionSeam(),
            child: Column(
              children: [
                const SectionHeader(
                  eyebrow: 'Your Sector',
                  title: "Don't See Your Industry?",
                  lead: 'Tell us about your business and what you want to achieve. We will reply with clear next steps.',
                  centered: true,
                ),
                const SizedBox(height: 28),
                PrimaryButton(label: 'Start a Conversation', onPressed: () => goToSection(context, SiteSection.contact)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _number(int index) => (index + 1).toString().padLeft(2, '0');

/// Copy and sector index beside the interconnected-industries scene.
class _Hero extends StatelessWidget {
  const _Hero({required this.onSelect});

  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktop;
    return PointerField(
      builder: (context, pointer) {
        final copy = Column(
          crossAxisAlignment: desktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            const Reveal(child: RuleEyebrow(IndustriesContent.eyebrow)),
            const SizedBox(height: 22),
            Reveal(
              delay: const Duration(milliseconds: 80),
              child: GoldHighlightHeading(
                heading: IndustriesContent.heading,
                highlight: IndustriesContent.headingHighlight,
                textAlign: desktop ? TextAlign.start : TextAlign.center,
                style: AppTypography.display(fontSize: context.responsive(mobile: 34.0, tablet: 44.0, desktop: 54.0)),
              ),
            ),
            const SizedBox(height: 24),
            Reveal(
              delay: const Duration(milliseconds: 160),
              child: desktop
                  ? GoldBarLead(
                      text: IndustriesContent.lead,
                      style: AppTypography.body(fontSize: 18, height: 1.75, color: AppColors.body),
                    )
                  : Text(
                      IndustriesContent.lead,
                      textAlign: TextAlign.center,
                      style: AppTypography.body(fontSize: 16, height: 1.7, color: AppColors.body),
                    ),
            ),
            const SizedBox(height: 32),
            Reveal(
              delay: const Duration(milliseconds: 240),
              child: Wrap(
                alignment: desktop ? WrapAlignment.start : WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (i, industry) in IndustriesContent.industries.indexed)
                    _IndexChip(number: _number(i), label: industry.name, onTap: () => onSelect(i)),
                ],
              ),
            ),
          ],
        );
        final scene = Reveal(
          offset: 40,
          child: AspectRatio(
            aspectRatio: 1.3,
            child: Section3DScene(
              scene: Scene3D.industries,
              variant: 'network',
              pointer: pointer,
              background: AppColors.pearlWhite,
              semanticLabel: IndustriesContent.networkSceneLabel,
              fallback: const Center(child: GoldIconTile(icon: Icons.hub_outlined, size: 96)),
            ),
          ),
        );
        if (!desktop) {
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [copy, const SizedBox(height: 28), scene]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 10, child: copy),
            const SizedBox(width: 48),
            Expanded(flex: 11, child: scene),
          ],
        );
      },
    );
  }
}

/// A sector in the hero's index; jumps to its section.
class _IndexChip extends StatefulWidget {
  const _IndexChip({required this.number, required this.label, required this.onTap});

  final String number;
  final String label;
  final VoidCallback onTap;

  @override
  State<_IndexChip> createState() => _IndexChipState();
}

class _IndexChipState extends State<_IndexChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Go to ${widget.label}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: AppMotion.hover,
            curve: AppMotion.ease,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
            decoration: BoxDecoration(
              color: _hover ? AppColors.goldWash : AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: _hover ? AppColors.champagneGold : AppColors.cardBorder),
              boxShadow: _hover ? AppColors.glowShadow() : AppColors.softShadow(0.5),
            ),
            child: ExcludeSemantics(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GradientText(
                    widget.number,
                    style: AppTypography.display(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.6, height: 1),
                    gradient: AppColors.metallicGoldText,
                  ),
                  const SizedBox(width: 8),
                  Text(widget.label, style: AppTypography.body(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.ink, height: 1.2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A fine champagne seam across the top of a section, so consecutive
/// bands read as a sequence rather than hard colour changes.
class _SectionSeam extends StatelessWidget {
  const _SectionSeam();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: FractionallySizedBox(
          widthFactor: 0.6,
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.champagneGold.withValues(alpha: 0),
                  AppColors.champagneGold.withValues(alpha: 0.55),
                  AppColors.champagneGold.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IndustrySection extends StatelessWidget {
  const _IndustrySection({required this.index, required this.industry, required this.photoFirst, required this.panelColor});

  final int index;
  final IndustryProfile industry;
  final bool photoFirst;
  final Color panelColor;

  @override
  Widget build(BuildContext context) {
    final visual = Reveal(
      offset: 36,
      child: _IndustryVisual(industry: industry, panelColor: panelColor, panelRight: photoFirst),
    );
    final copy = Reveal(
      delay: const Duration(milliseconds: 120),
      child: _IndustryCopy(number: _number(index), industry: industry),
    );
    if (!context.isDesktop) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [visual, const SizedBox(height: 36), copy]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 6, child: photoFirst ? visual : copy),
        const SizedBox(width: 72),
        Expanded(flex: 5, child: photoFirst ? copy : visual),
      ],
    );
  }
}

/// The sector's photograph, drifting with scroll and pointer, with its 3D
/// arrangement on a raised pearl panel set into the lower corner.
class _IndustryVisual extends StatefulWidget {
  const _IndustryVisual({required this.industry, required this.panelColor, required this.panelRight});

  final IndustryProfile industry;
  final Color panelColor;

  /// Which lower corner the 3D panel sits in.
  final bool panelRight;

  @override
  State<_IndustryVisual> createState() => _IndustryVisualState();
}

class _IndustryVisualState extends State<_IndustryVisual> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final industry = widget.industry;
    final mobile = context.isMobile;
    final radius = BorderRadius.circular(mobile ? AppRadius.lg : AppRadius.xl);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: PointerField(
        builder: (context, pointer) => LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final panelWidth = width * (mobile ? 0.5 : 0.44);
            final panelHeight = panelWidth / 1.22;
            final overlap = panelHeight * 0.38;
            // On desktop the panel reaches a little past the photo's edge,
            // into the gutter; on phones it stays inside the page.
            final outset = context.isDesktop ? -28.0 : 12.0;
            return Padding(
              padding: EdgeInsets.only(bottom: overlap),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: AppMotion.lift,
                    curve: AppMotion.ease,
                    decoration: BoxDecoration(borderRadius: radius, boxShadow: premiumCardShadow(lifted: _hover)),
                    child: ClipRRect(
                      borderRadius: radius,
                      child: AspectRatio(
                        aspectRatio: mobile ? 4 / 3.4 : 4 / 3.2,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ParallaxPhoto(
                              basePath: industry.photo,
                              semanticLabel: industry.photoAlt,
                              pointer: pointer,
                              depth: 20,
                              zoom: _hover ? 1.04 : 1,
                              fallback: _PhotoFallback(icon: industry.icon),
                            ),
                            // Cinematic falloff: light from above, depth at the foot.
                            const IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0x14FFF8EC), Color(0x00000000), Color(0x8C1E1C1A)],
                                    stops: [0, 0.45, 1],
                                  ),
                                ),
                              ),
                            ),
                            IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: radius,
                                  border: Border.all(color: AppColors.white.withValues(alpha: 0.45)),
                                ),
                              ),
                            ),
                            Positioned(
                              left: widget.panelRight ? 22 : null,
                              right: widget.panelRight ? null : 22,
                              top: 20,
                              child: _PhotoTag(icon: industry.icon, label: industry.name),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: widget.panelRight ? outset : null,
                    left: widget.panelRight ? null : outset,
                    bottom: -overlap,
                    width: panelWidth,
                    height: panelHeight,
                    child: AnimatedSlide(
                      duration: AppMotion.lift,
                      curve: AppMotion.ease,
                      offset: Offset(0, _hover ? -0.03 : 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.panelColor,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: _hover ? AppColors.goldLine : AppColors.white, width: 1.5),
                          boxShadow: premiumCardShadow(lifted: true),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.lg - 1.5),
                          child: Section3DScene(
                            scene: Scene3D.industries,
                            variant: industry.id,
                            background: widget.panelColor,
                            pointer: pointer,
                            focus: _hover ? 1 : 0,
                            semanticLabel: industry.sceneLabel,
                            fallback: Center(child: GoldIconTile(icon: industry.icon, size: 64)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Frosted label naming the sector on its photograph.
class _PhotoTag extends StatelessWidget {
  const _PhotoTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 7, 14, 7),
        decoration: BoxDecoration(
          color: AppColors.deepCharcoal.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.softChampagne.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.goldTint),
            const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
              style: AppTypography.body(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.3, color: AppColors.white, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.warmBeige, AppColors.ivoryLight, AppColors.platinum],
        ),
      ),
      child: Center(child: GoldIconTile(icon: icon, size: 72)),
    );
  }
}

class _IndustryCopy extends StatelessWidget {
  const _IndustryCopy({required this.number, required this.industry});

  final String number;
  final IndustryProfile industry;

  @override
  Widget build(BuildContext context) {
    final services = [for (final id in industry.serviceIds) ...ServicesContent.services.where((s) => s.id == id)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ExcludeSemantics(
              child: GradientText(
                number,
                style: AppTypography.display(fontSize: context.responsive(mobile: 44.0, desktop: 60.0), fontWeight: FontWeight.w800, height: 1),
                gradient: AppColors.metallicGoldText,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.champagneGold, AppColors.champagneGold.withValues(alpha: 0)]),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Semantics(
          header: true,
          child: Text(
            industry.name,
            style: AppTypography.display(fontSize: context.responsive(mobile: 28.0, tablet: 34.0, desktop: 38.0), color: AppColors.ink),
          ),
        ),
        const SizedBox(height: 16),
        Text(industry.summary, style: AppTypography.body(fontSize: context.responsive(mobile: 16.0, desktop: 17.0), height: 1.75, color: AppColors.body)),
        const SizedBox(height: 26),
        Text(
          'SOLUTIONS WE BUILD',
          style: AppTypography.body(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 1.6, color: AppColors.accent),
        ),
        const SizedBox(height: 10),
        for (final (i, solution) in industry.solutions.indexed) _SolutionRow(text: solution, last: i == industry.solutions.length - 1),
        const SizedBox(height: 24),
        Text(
          'Related services',
          style: AppTypography.body(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.muted),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in services)
              ActionChip(
                label: Text(s.title),
                onPressed: () => openServicePage(context, s),
                backgroundColor: AppColors.white,
                side: const BorderSide(color: AppColors.goldLine),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
              ),
          ],
        ),
      ],
    );
  }
}

/// One solution, with a gold diamond that brightens on hover.
class _SolutionRow extends StatefulWidget {
  const _SolutionRow({required this.text, required this.last});

  final String text;
  final bool last;

  @override
  State<_SolutionRow> createState() => _SolutionRowState();
}

class _SolutionRowState extends State<_SolutionRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: AppMotion.hover,
        curve: AppMotion.ease,
        padding: EdgeInsets.fromLTRB(_hover ? 6 : 0, 12, 0, 12),
        decoration: BoxDecoration(
          border: widget.last ? null : const Border(bottom: BorderSide(color: AppColors.goldLine)),
        ),
        child: Row(
          children: [
            _Diamond(lit: _hover),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                widget.text,
                style: AppTypography.body(fontSize: 15.5, fontWeight: FontWeight.w600, color: AppColors.ink, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Diamond extends StatelessWidget {
  const _Diamond({required this.lit});

  final bool lit;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.785398,
      child: AnimatedContainer(
        duration: AppMotion.hover,
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          gradient: lit ? AppColors.buttonGold : AppColors.metallicGoldText,
          borderRadius: BorderRadius.circular(1.5),
          boxShadow: lit ? AppColors.glowShadow(1.4) : null,
        ),
      ),
    );
  }
}
