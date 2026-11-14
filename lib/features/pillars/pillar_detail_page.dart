import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../models/content_models.dart';
import '../../models/pillar_page.dart';
import '../../models/site_section.dart';
import '../../repositories/content/company_content.dart';
import '../../repositories/content/pillar_pages_content.dart';
import '../../shared/layouts/navigation_actions.dart';
import '../../shared/layouts/subpage_scaffold.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';
import '../../shared/widgets/tinted_photo.dart';
import 'pillar_enquiry_form.dart';

/// Detail page for one of the three core pillars: hero, offerings with
/// photography, a process band, an enquiry / application form and links to
/// the other pillars.
class PillarDetailPage extends StatefulWidget {
  const PillarDetailPage({super.key, required this.content});

  final PillarPageContent content;

  @override
  State<PillarDetailPage> createState() => _PillarDetailPageState();
}

class _PillarDetailPageState extends State<PillarDetailPage> {
  late final List<GlobalKey> _offeringKeys = [for (final o in widget.content.offerings) GlobalKey(debugLabel: o.title)];
  final _offeringsKey = GlobalKey(debugLabel: 'offerings');
  final _formKey = GlobalKey(debugLabel: 'form');
  final _selection = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _selection.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final target = key.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(target, duration: const Duration(milliseconds: 750), curve: Curves.easeInOutCubic);
  }

  /// Pre-selects [option] in the form and scrolls to it.
  void _enquire([String? option]) {
    if (option != null) _selection.value = option;
    _scrollTo(_formKey);
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
    const formCta = 'Start an Enquiry';

    return SubpageScaffold(
      title: content.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Hero(
            content: content,
            primaryLabel: formCta,
            onPrimary: _enquire,
            onExplore: () => _scrollTo(_offeringsKey),
            onJump: (i) => _scrollTo(_offeringKeys[i]),
          ),
          KeyedSubtree(
            key: _offeringsKey,
            child: SectionShell(
              background: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(
                    eyebrow: content.offeringsEyebrow,
                    title: content.offeringsHeading,
                    lead: content.offeringsLead,
                    centered: true,
                  ),
                  SizedBox(height: context.responsive(mobile: 48.0, desktop: 72.0)),
                  for (final (i, offering) in content.offerings.indexed) ...[
                    if (i > 0) SizedBox(height: context.responsive(mobile: 56.0, tablet: 72.0, desktop: 96.0)),
                    KeyedSubtree(
                      key: _offeringKeys[i],
                      child: Reveal(
                        child: _OfferingRow(
                          index: i,
                          offering: offering,
                          content: content,
                          onEnquire: () => _enquire(offering.title),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          _StepsSection(content: content),
          KeyedSubtree(
            key: _formKey,
            child: _FormSection(content: content, selection: _selection),
          ),
          _RelatedPillars(current: content.route),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ Hero

class _Hero extends StatelessWidget {
  const _Hero({
    required this.content,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onExplore,
    required this.onJump,
  });

  final PillarPageContent content;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onExplore;
  final ValueChanged<int> onJump;

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktop;

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(content.eyebrow, color: AppColors.cyan),
        const SizedBox(height: 20),
        Semantics(
          header: true,
          child: Text(
            content.heroHeading,
            style: AppTypography.display(fontSize: context.responsive(mobile: 32.0, tablet: 42.0, desktop: 50.0)),
          ),
        ),
        const SizedBox(height: 18),
        Text(content.heroLead, style: AppTypography.body(fontSize: context.responsive(mobile: 16.0, desktop: 18.0), height: 1.7)),
        const SizedBox(height: 24),
        for (final (icon, label) in content.highlights)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cyan.withValues(alpha: 0.28)),
                  ),
                  child: Icon(icon, size: 17, color: AppColors.cyan),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.body(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            PrimaryButton(label: primaryLabel, onPressed: onPrimary),
            SecondaryButton(label: 'Explore ${content.offeringsEyebrow}', icon: Icons.south_rounded, onPressed: onExplore),
          ],
        ),
      ],
    );

    final image = Reveal(
      delay: const Duration(milliseconds: 120),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.22),
              blurRadius: 70,
              spreadRadius: -12,
              offset: const Offset(0, 24),
            ),
          ],
        ),
        child: MediaFrame(
          radius: AppRadius.xl,
          aspectRatio: desktop ? 5 / 4 : 16 / 10,
          child: TintedPhoto(basePath: content.heroImage, semanticLabel: content.heroImageAlt, strength: 0.6),
        ),
      ),
    );

    return SectionShell(
      topPadding: context.responsive(mobile: 28.0, desktop: 44.0),
      bottomPadding: context.responsive(mobile: 56.0, desktop: 88.0),
      gradient: const LinearGradient(
        colors: [AppColors.background, Color(0xFF0C1430), AppColors.surface],
        stops: [0, 0.6, 1],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      glowAt: const Alignment(0.8, -0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Breadcrumb(current: content.title),
          SizedBox(height: context.responsive(mobile: 24.0, desktop: 40.0)),
          if (desktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 11, child: Reveal(child: copy)),
                const SizedBox(width: 56),
                Expanded(flex: 10, child: image),
              ],
            )
          else ...[
            Reveal(child: copy),
            const SizedBox(height: 36),
            image,
          ],
          SizedBox(height: context.responsive(mobile: 36.0, desktop: 56.0)),
          Reveal(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final (i, offering) in content.offerings.indexed)
                  _JumpChip(icon: offering.icon, label: offering.title, onTap: () => onJump(i)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Home › Core Pillars › current page.
class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.current});

  final String current;

  @override
  Widget build(BuildContext context) {
    Widget link(String label, VoidCallback onTap, {IconData? icon}) => TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon ?? Icons.chevron_left_rounded, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.body,
        textStyle: AppTypography.body(fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        minimumSize: const Size(0, 36),
      ),
    );
    const separator = Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.muted);

    return Semantics(
      container: true,
      label: 'Breadcrumb',
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2,
        runSpacing: 4,
        children: [
          link('Home', () => goToSection(context, SiteSection.home), icon: Icons.home_outlined),
          separator,
          link('Core Pillars', () => goToSection(context, SiteSection.intro), icon: Icons.grid_view_rounded),
          separator,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              current,
              style: AppTypography.body(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.cyan, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}

class _JumpChip extends StatefulWidget {
  const _JumpChip({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_JumpChip> createState() => _JumpChipState();
}

class _JumpChipState extends State<_JumpChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Jump to ${widget.label}',
      excludeSemantics: true,
      child: Material(
        color: _hover ? AppColors.primarySoft : AppColors.white.withValues(alpha: 0.04),
        shape: StadiumBorder(side: BorderSide(color: _hover ? AppColors.cyan.withValues(alpha: 0.6) : AppColors.border)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onHover: (v) => setState(() => _hover = v),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 16, color: AppColors.cyan),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: _hover ? AppColors.white : AppColors.body,
                      height: 1.2,
                    ),
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

// -------------------------------------------------------------- Offerings

/// Photo and detail side by side on desktop (alternating sides), stacked on
/// smaller screens.
class _OfferingRow extends StatelessWidget {
  const _OfferingRow({required this.index, required this.offering, required this.content, required this.onEnquire});

  final int index;
  final PillarOffering offering;
  final PillarPageContent content;
  final VoidCallback onEnquire;

  @override
  Widget build(BuildContext context) {
    final image = _OfferingPhoto(offering: offering, number: (index + 1).toString().padLeft(2, '0'));
    final details = _OfferingDetails(offering: offering, content: content, onEnquire: onEnquire);

    if (!context.isDesktop) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [image, const SizedBox(height: 28), details]);
    }
    final imageFirst = index.isEven;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 5, child: imageFirst ? image : details),
        const SizedBox(width: 56),
        Expanded(flex: 6, child: imageFirst ? details : image),
      ],
    );
  }
}

class _OfferingPhoto extends StatefulWidget {
  const _OfferingPhoto({required this.offering, required this.number});

  final PillarOffering offering;
  final String number;

  @override
  State<_OfferingPhoto> createState() => _OfferingPhotoState();
}

class _OfferingPhotoState extends State<_OfferingPhoto> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: AppMotion.lift,
        curve: AppMotion.ease,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: _hover ? AppColors.cyan.withValues(alpha: 0.5) : AppColors.border),
          boxShadow: [
            if (_hover)
              BoxShadow(
                color: AppColors.cyan.withValues(alpha: 0.16),
                blurRadius: 48,
                spreadRadius: -6,
                offset: const Offset(0, 20),
              ),
            ...AppColors.softShadow(0.6),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl - 1),
          child: AspectRatio(
            aspectRatio: context.isMobile ? 16 / 10 : 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                TintedPhoto(basePath: widget.offering.image, semanticLabel: widget.offering.imageAlt, active: _hover),
                Positioned(
                  left: 18,
                  bottom: 18,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
                    decoration: BoxDecoration(
                      color: AppColors.deepNavy.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: AppColors.cyan.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.offering.icon, size: 16, color: AppColors.cyan),
                        const SizedBox(width: 8),
                        Text(
                          widget.number,
                          style: AppTypography.body(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                            height: 1.2,
                            letterSpacing: 1,
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
      ),
    );
  }
}

class _OfferingDetails extends StatelessWidget {
  const _OfferingDetails({required this.offering, required this.content, required this.onEnquire});

  final PillarOffering offering;
  final PillarPageContent content;
  final VoidCallback onEnquire;

  @override
  Widget build(BuildContext context) {
    final lists = [
      _PointList(label: content.primaryLabel, items: offering.primaryPoints, icon: Icons.check_rounded, color: AppColors.cyan),
      _PointList(
        label: content.secondaryLabel,
        items: offering.secondaryPoints,
        icon: Icons.trending_up_rounded,
        color: AppColors.primary,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconBadge(icon: offering.icon, color: AppColors.primary, gradient: true, size: 46),
            const SizedBox(width: 14),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  offering.title,
                  style: AppTypography.display(fontSize: context.responsive(mobile: 24.0, desktop: 30.0), height: 1.2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          offering.tagline,
          style: AppTypography.body(fontSize: 16.5, fontWeight: FontWeight.w600, color: AppColors.iceBlue, height: 1.5),
        ),
        const SizedBox(height: 12),
        Text(offering.description, style: AppTypography.body(fontSize: 15.5, height: 1.75)),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth >= 520
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: lists[0]),
                    const SizedBox(width: 20),
                    Expanded(child: lists[1]),
                  ],
                )
              : Column(children: [lists[0], const SizedBox(height: 16), lists[1]]),
        ),
        if (offering.skills.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            content.skillsLabel.toUpperCase(),
            style: AppTypography.body(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
              letterSpacing: 1.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final s in offering.skills) TagChip(s, color: AppColors.cyan, filled: true)],
          ),
        ],
        const SizedBox(height: 26),
        PrimaryButton(label: '${content.ctaPrefix} ${offering.title}', onPressed: onEnquire),
      ],
    );
  }
}

class _PointList extends StatelessWidget {
  const _PointList({required this.label, required this.items, required this.icon, required this.color});

  final String label;
  final List<String> items;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.glassGradient,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.body(fontSize: 11.5, fontWeight: FontWeight.w700, color: color, letterSpacing: 1.3, height: 1.2),
          ),
          const SizedBox(height: 14),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                    child: Icon(icon, size: 12, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item, style: AppTypography.body(fontSize: 14.2, color: AppColors.ink, height: 1.5)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ Steps

class _StepsSection extends StatelessWidget {
  const _StepsSection({required this.content});

  final PillarPageContent content;

  @override
  Widget build(BuildContext context) {
    final withImage = content.stepsImage != null && context.isDesktop;
    final grid = ResponsiveGrid(
      minItemWidth: 220,
      maxColumns: withImage ? 2 : 4,
      spacing: 18,
      children: [
        for (final (i, step) in content.steps.indexed)
          Reveal(
            delay: Duration(milliseconds: 70 * i),
            child: _StepCard(number: i + 1, step: step),
          ),
      ],
    );

    return SectionShell(
      background: AppColors.background,
      glowAt: const Alignment(-0.9, 0.2),
      glowStrength: 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(eyebrow: content.stepsEyebrow, title: content.stepsHeading, lead: content.stepsLead),
          const SizedBox(height: 44),
          if (withImage)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: Reveal(
                    child: MediaFrame(
                      radius: AppRadius.xl,
                      aspectRatio: 4 / 3,
                      child: TintedPhoto(basePath: content.stepsImage!, semanticLabel: content.stepsImageAlt ?? ''),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(flex: 7, child: grid),
              ],
            )
          else ...[
            if (content.stepsImage != null) ...[
              Reveal(
                child: MediaFrame(
                  radius: AppRadius.xl,
                  aspectRatio: 16 / 9,
                  child: TintedPhoto(basePath: content.stepsImage!, semanticLabel: content.stepsImageAlt ?? ''),
                ),
              ),
              const SizedBox(height: 28),
            ],
            grid,
          ],
          if (content.note != null) ...[
            const SizedBox(height: 32),
            Reveal(
              child: _Notice(icon: content.noteIcon ?? Icons.info_outline_rounded, text: content.note!),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.number, required this.step});

  final int number;
  final PillarStep step;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: step.icon, color: AppColors.cyan, size: 44),
              const Spacer(),
              Text(
                number.toString().padLeft(2, '0'),
                style: AppTypography.display(fontSize: 30, fontWeight: FontWeight.w800, height: 1).copyWith(
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 1.1
                    ..color = AppColors.white.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(step.title, style: AppTypography.display(fontSize: 19, fontWeight: FontWeight.w700, height: 1.3)),
          const SizedBox(height: 8),
          Text(step.description, style: AppTypography.body(fontSize: 14.5, height: 1.6)),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.cyan),
          const SizedBox(width: 14),
          Expanded(
            child: Text(text, style: AppTypography.body(fontSize: 15, color: AppColors.ink, height: 1.65)),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------- Form

class _FormSection extends StatelessWidget {
  const _FormSection({required this.content, required this.selection});

  final PillarPageContent content;
  final ValueNotifier<String?> selection;

  @override
  Widget build(BuildContext context) {
    final form = content.form;
    final desktop = context.isDesktop;

    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Get In Touch', color: AppColors.cyan),
        const SizedBox(height: 18),
        Semantics(
          header: true,
          child: Text(
            'Ready to Take the Next Step?',
            style: AppTypography.display(fontSize: context.responsive(mobile: 28.0, tablet: 34.0, desktop: 38.0)),
          ),
        ),
        const SizedBox(height: 14),
        Text(form.lead, style: AppTypography.body(fontSize: 16, height: 1.7)),
        const SizedBox(height: 28),
        MediaFrame(
          radius: AppRadius.xl,
          aspectRatio: desktop ? 4 / 3 : 16 / 9,
          child: TintedPhoto(basePath: form.image, semanticLabel: form.imageAlt),
        ),
      ],
    );

    final card = Container(
      padding: EdgeInsets.all(context.responsive(mobile: 22.0, desktop: 36.0)),
      decoration: BoxDecoration(
        gradient: AppColors.glassGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow(0.8),
      ),
      child: PillarEnquiryForm(
        config: form,
        options: [for (final o in content.offerings) o.title, PillarPagesContent.otherOption],
        selection: selection,
      ),
    );

    return SectionShell(
      background: AppColors.surface,
      child: desktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: Reveal(child: intro)),
                const SizedBox(width: 56),
                Expanded(
                  flex: 7,
                  child: Reveal(delay: const Duration(milliseconds: 100), child: card),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Reveal(child: intro),
                const SizedBox(height: 32),
                card,
              ],
            ),
    );
  }
}

// -------------------------------------------------------- Related pillars

class _RelatedPillars extends StatelessWidget {
  const _RelatedPillars({required this.current});

  final String current;

  @override
  Widget build(BuildContext context) {
    final others = CompanyContent.corePillars.where((p) => p.route != current).toList();
    return SectionShell(
      background: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            eyebrow: 'Explore More',
            title: 'Other Ways YODYNIX Can Help',
            lead: 'Discover the rest of our core pillars.',
            centered: true,
          ),
          const SizedBox(height: 44),
          ResponsiveGrid(
            minItemWidth: 260,
            maxColumns: 3,
            spacing: 20,
            children: [
              for (final (i, pillar) in others.indexed)
                Reveal(
                  delay: Duration(milliseconds: 80 * i),
                  child: _RelatedCard(pillar: pillar),
                ),
            ],
          ),
          const SizedBox(height: 48),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                SecondaryButton(
                  label: 'Back to Home',
                  icon: Icons.home_outlined,
                  onPressed: () => goToSection(context, SiteSection.home),
                ),
                SecondaryButton(
                  label: 'Back to About',
                  icon: Icons.info_outline_rounded,
                  onPressed: () => goToSection(context, SiteSection.about),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedCard extends StatefulWidget {
  const _RelatedCard({required this.pillar});

  final CorePillar pillar;

  @override
  State<_RelatedCard> createState() => _RelatedCardState();
}

class _RelatedCardState extends State<_RelatedCard> {
  bool _hover = false;

  // Replace rather than push so "back" always returns to the homepage.
  void _open() => Navigator.of(context).pushReplacementNamed(widget.pillar.route);

  @override
  Widget build(BuildContext context) {
    final pillar = widget.pillar;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: HoverCard(
        padding: const EdgeInsets.all(10),
        onTap: _open,
        accent: AppColors.cyan,
        semanticLabel: pillar.title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: TintedPhoto(basePath: pillar.image, semanticLabel: pillar.imageAlt, active: _hover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 18, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(pillar.icon, size: 16, color: AppColors.cyan),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pillar.title,
                          style: AppTypography.display(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(pillar.description, style: AppTypography.body(fontSize: 14, height: 1.6)),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
              child: ArrowLink(label: pillar.actionLabel, color: AppColors.cyan, onPressed: _open),
            ),
          ],
        ),
      ),
    );
  }
}
