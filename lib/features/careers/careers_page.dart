import 'package:flutter/material.dart';

import '../../core/constants/site_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/utils/responsive.dart';
import '../../models/pillar_page.dart' show PillarStep;
import '../../models/site_section.dart';
import '../../repositories/contact_repository.dart';
import '../../repositories/content/careers_content.dart';
import '../../shared/layouts/navigation_actions.dart';
import '../../shared/layouts/subpage_scaffold.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';
import '../../shared/widgets/site_dialog.dart';
import '../../shared/widgets/tinted_photo.dart';
import 'careers_application_form.dart';

/// `/careers`: hero, the four open positions, why join, the hiring process
/// and the application form.
class CareersPage extends StatefulWidget {
  const CareersPage({super.key, this.scrollToApply = false, this.repository = const ApiContactRepository()});

  /// Opens with the application form in view (e.g. footer "Apply Now").
  final bool scrollToApply;
  final ContactRepository repository;

  @override
  State<CareersPage> createState() => _CareersPageState();
}

class _CareersPageState extends State<CareersPage> {
  final _openingsKey = GlobalKey(debugLabel: 'openings');
  final _applyKey = GlobalKey(debugLabel: 'apply');
  final _selection = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    if (widget.scrollToApply) {
      // After the page transition has laid the page out.
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollTo(_applyKey));
    }
  }

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

  /// Pre-selects [opening] in the form and brings the form into view.
  void _apply(JobOpening opening) {
    _selection.value = opening.id;
    _scrollTo(_applyKey);
  }

  @override
  Widget build(BuildContext context) {
    final gap = context.responsive(mobile: 40.0, desktop: 56.0);
    const openings = CareersContent.openings;

    return SubpageScaffold(
      title: 'Careers',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Hero
          _Hero(onExplore: () => _scrollTo(_openingsKey), onApply: () => _scrollTo(_applyKey)),

          // 2. Open positions
          KeyedSubtree(
            key: _openingsKey,
            child: SectionShell(
              background: AppColors.surface,
              glowAt: const Alignment(1.1, -0.7),
              glowStrength: 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                    eyebrow: 'Open Positions',
                    title: 'Current Job Openings',
                    lead: CareersContent.openingsLead,
                    centered: true,
                    eyebrowColor: AppColors.accent,
                  ),
                  SizedBox(height: gap),
                  ResponsiveGrid(
                    minItemWidth: 320,
                    maxColumns: 2,
                    spacing: 24,
                    children: [
                      for (final (i, o) in openings.indexed)
                        Reveal(
                          delay: Duration(milliseconds: 80 * (i % 2)),
                          child: JobOpeningCard(opening: o, index: i, onApply: () => _apply(o)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. Why join
          SectionShell(
            background: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(
                  eyebrow: 'Why Join YODYNIX',
                  title: 'A Place to Do Your Best Work',
                  lead: 'We value craftsmanship, ownership and clear communication in everything we build.',
                  centered: true,
                  eyebrowColor: AppColors.accent,
                ),
                SizedBox(height: gap),
                const _Benefits(),
              ],
            ),
          ),

          // 4. Hiring process
          SectionShell(
            background: AppColors.surface,
            glowAt: const Alignment(-1.1, -0.4),
            glowStrength: 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(
                  eyebrow: 'Hiring Process',
                  title: 'How We Hire',
                  lead: 'A clear, respectful process. We keep you informed at every stage.',
                  centered: true,
                  eyebrowColor: AppColors.accent,
                ),
                SizedBox(height: gap),
                ResponsiveGrid(
                  minItemWidth: 220,
                  maxColumns: CareersContent.hiringProcess.length,
                  spacing: 16,
                  children: [
                    for (final (i, s) in CareersContent.hiringProcess.indexed)
                      Reveal(
                        delay: Duration(milliseconds: 60 * i),
                        child: _StepCard(index: i, step: s),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // 5. Apply
          KeyedSubtree(
            key: _applyKey,
            child: SectionShell(
              background: AppColors.background,
              glowAt: const Alignment(-1.1, 0.6),
              glowStrength: 0.6,
              child: _ApplySection(selection: _selection, repository: widget.repository),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ Hero

class _Hero extends StatelessWidget {
  const _Hero({required this.onExplore, required this.onApply});

  final VoidCallback onExplore;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    const tone = SurfaceColors.light;
    final desktop = context.isDesktop;
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(CareersContent.badge, color: tone.accent),
        const SizedBox(height: 20),
        Semantics(
          header: true,
          child: Text(
            CareersContent.heading,
            style: AppTypography.display(
              fontSize: context.responsive(mobile: 32.0, tablet: 42.0, desktop: 50.0),
              color: tone.ink,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          CareersContent.description,
          style: AppTypography.body(fontSize: context.responsive(mobile: 16.0, desktop: 18.0), height: 1.7, color: tone.body),
        ),
        const SizedBox(height: 24),
        for (final (icon, label) in CareersContent.highlights)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: Icon(icon, size: 18, color: tone.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.body(fontSize: 15.5, fontWeight: FontWeight.w600, color: tone.ink, height: 1.4),
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
            PrimaryButton(label: 'View Open Positions', icon: Icons.south_rounded, onPressed: onExplore),
            SecondaryButton(label: 'Apply Now', onPressed: onApply),
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
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 70,
              spreadRadius: -12,
              offset: const Offset(0, 24),
            ),
          ],
        ),
        child: MediaFrame(
          radius: AppRadius.xl,
          aspectRatio: desktop ? 5 / 4 : 16 / 10,
          child: TintedPhoto(basePath: CareersContent.heroImage, semanticLabel: CareersContent.heroImageAlt, strength: 0.5),
        ),
      ),
    );

    return SectionShell(
      topPadding: context.responsive(mobile: 28.0, desktop: 44.0),
      bottomPadding: context.responsive(mobile: 56.0, desktop: 88.0),
      tone: tone,
      background: AppColors.pearlWhite,
      glowAt: const Alignment(0.8, -0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CareersBreadcrumb(onHome: () => goToSection(context, SiteSection.home)),
          SizedBox(height: context.responsive(mobile: 24.0, desktop: 40.0)),
          if (desktop)
            Row(
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
        ],
      ),
    );
  }
}

/// Home › Careers.
class CareersBreadcrumb extends StatelessWidget {
  const CareersBreadcrumb({super.key, required this.onHome});

  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Breadcrumb',
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 2,
          runSpacing: 4,
          children: [
            TextButton.icon(
              onPressed: onHome,
              icon: const Icon(Icons.home_outlined, size: 16),
              label: const Text('Home'),
              style: TextButton.styleFrom(
                foregroundColor: context.tone.body,
                textStyle: AppTypography.body(fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                minimumSize: const Size(0, 36),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 16, color: context.tone.muted),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Careers',
                style: AppTypography.body(fontSize: 13.5, fontWeight: FontWeight.w600, color: context.tone.accent, height: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------- Job card

/// One open position: title, summary, required skills and "Apply Now".
/// Contains no LayoutBuilder, so it can sit in a [ResponsiveGrid] row.
class JobOpeningCard extends StatelessWidget {
  const JobOpeningCard({super.key, required this.opening, required this.onApply, this.index});

  final JobOpening opening;
  final VoidCallback onApply;

  /// Shown as "POSITION 01" when given.
  final int? index;

  @override
  Widget build(BuildContext context) {
    final o = opening;
    return HoverCard(
      padding: const EdgeInsets.all(28),
      semanticLabel: o.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: o.icon, color: AppColors.cardAccent, size: 48),
              const Spacer(),
              if (index != null)
                Text(
                  'POSITION ${(index! + 1).toString().padLeft(2, '0')}',
                  style: AppTypography.body(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cardAccent,
                    letterSpacing: 1.4,
                    height: 1.2,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            o.title,
            style: AppTypography.display(fontSize: 22, fontWeight: FontWeight.w700, height: 1.25, color: AppColors.cardHeading),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TagChip(ContactConfig.city, icon: Icons.location_on_outlined, color: AppColors.cardAccent, filled: true),
            ],
          ),
          const SizedBox(height: 14),
          Text(o.summary, style: AppTypography.body(fontSize: 14.8, height: 1.6, color: AppColors.cardBody)),
          const SizedBox(height: 18),
          Text(
            'REQUIRED SKILLS',
            style: AppTypography.body(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.cardMuted,
              letterSpacing: 1.2,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [for (final s in o.skills) TagChip(s)]),
          const Spacer(),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Apply Now', size: ButtonSize.small, onPressed: onApply),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------- Benefits

class _Benefits extends StatelessWidget {
  const _Benefits();

  @override
  Widget build(BuildContext context) {
    return ResponsiveGrid(
      minItemWidth: 240,
      maxColumns: 4,
      spacing: 20,
      children: [
        for (final (i, (icon, title, text)) in CareersContent.benefits.indexed)
          Reveal(
            delay: Duration(milliseconds: 60 * i),
            child: HoverCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconBadge(icon: icon, color: AppColors.cardAccent, size: 46),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: AppTypography.display(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: AppColors.cardHeading,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(text, style: AppTypography.body(fontSize: 14.2, height: 1.6, color: AppColors.cardBody)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.index, required this.step});

  final int index;
  final PillarStep step;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: CardStyle.decoration(radius: AppRadius.lg),
      child: SurfaceTone(
        colors: SurfaceColors.inCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  (index + 1).toString().padLeft(2, '0'),
                  style: AppTypography.display(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.cardAccent),
                ),
                const Spacer(),
                Icon(step.icon, size: 22, color: AppColors.charcoal),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              step.title,
              style: AppTypography.display(fontSize: 17, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.cardHeading),
            ),
            const SizedBox(height: 8),
            Text(step.description, style: AppTypography.body(fontSize: 14, height: 1.55, color: AppColors.cardBody)),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ Apply section

/// Photo, reassurance points and the application form.
class _ApplySection extends StatelessWidget {
  const _ApplySection({required this.selection, required this.repository});

  final ValueNotifier<String?> selection;
  final ContactRepository repository;

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktop;
    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Apply Now', color: AppColors.accent),
        const SizedBox(height: 18),
        Semantics(
          header: true,
          child: Text(
            'Ready to Join Our Team?',
            style: AppTypography.display(fontSize: context.responsive(mobile: 28.0, tablet: 34.0, desktop: 38.0)),
          ),
        ),
        const SizedBox(height: 14),
        Text(CareersContent.applicationLead, style: AppTypography.body(fontSize: 16, height: 1.7)),
        const SizedBox(height: 24),
        const CheckList(
          items: [
            'Choose the position that matches your skills',
            'Share a link to your résumé, portfolio or GitHub',
            'Our hiring team replies by email with next steps',
          ],
          color: AppColors.accent,
        ),
        if (desktop) ...[
          const SizedBox(height: 20),
          MediaFrame(
            radius: AppRadius.lg,
            aspectRatio: 4 / 3,
            child: TintedPhoto(
              basePath: CareersContent.applicationImage,
              semanticLabel: CareersContent.applicationImageAlt,
              strength: 0.4,
            ),
          ),
        ],
      ],
    );
    final form = FormCard(
      padding: EdgeInsets.all(context.responsive(mobile: 20.0, desktop: 36.0)),
      child: CareersApplicationForm(selection: selection, repository: repository),
    );
    return desktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 4, child: Reveal(child: intro)),
              const SizedBox(width: 48),
              Expanded(flex: 6, child: form),
            ],
          )
        : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [intro, const SizedBox(height: 32), form]);
  }
}
