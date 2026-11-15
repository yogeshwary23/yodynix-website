import 'package:flutter/material.dart';

import '../../core/constants/site_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/utils/responsive.dart';
import '../../models/internship_program.dart';
import '../../models/pillar_page.dart' show PillarStep;
import '../../repositories/content/internship_content.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';
import '../../shared/widgets/site_dialog.dart';
import '../../shared/widgets/tinted_photo.dart';
import 'internship_application_form.dart';

/// Building blocks shared by the Internship landing page, the seven
/// programme pages and the homepage Internship section.

// ------------------------------------------------------------ Programme card

/// Photo card for one programme. Contains no LayoutBuilder, so it can sit
/// in a [ResponsiveGrid] row.
class InternshipProgramCard extends StatefulWidget {
  const InternshipProgramCard({super.key, required this.program, required this.onOpen, this.index});

  final InternshipProgram program;
  final VoidCallback onOpen;

  /// Shown as "PROGRAM 01" when given.
  final int? index;

  @override
  State<InternshipProgramCard> createState() => _InternshipProgramCardState();
}

class _InternshipProgramCardState extends State<InternshipProgramCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.program;
    const shown = 4;
    final more = p.skills.length - shown;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: HoverCard(
        padding: EdgeInsets.zero,
        semanticLabel: p.title,
        onTap: widget.onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TintedPhoto(basePath: p.image, semanticLabel: p.imageAlt, active: _hover, strength: 0.55),
                  Positioned(
                    left: 14,
                    bottom: 14,
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.deepNavy.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: AppColors.cardLine),
                      ),
                      child: Icon(p.icon, size: 18, color: AppColors.cardAccent),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.index != null) ...[
                      Text(
                        'PROGRAM ${(widget.index! + 1).toString().padLeft(2, '0')}',
                        style: AppTypography.body(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cardAccent,
                          letterSpacing: 1.4,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      p.title,
                      style: AppTypography.display(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: AppColors.cardHeading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(p.description, style: AppTypography.body(fontSize: 14.2, height: 1.6, color: AppColors.cardBody)),
                    const SizedBox(height: 14),
                    Text(
                      'KEY SKILLS',
                      style: AppTypography.body(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cardMuted,
                        letterSpacing: 1.2,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final s in p.skills.take(shown)) TagChip(s),
                        if (more > 0) TagChip('+$more more', color: AppColors.cardAccent, filled: true),
                      ],
                    ),
                    const Spacer(),
                    const SizedBox(height: 18),
                    ArrowLink(label: 'Explore Program', color: AppColors.cardAccent, onPressed: widget.onOpen),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Eighth grid tile beside the seven programmes: flexible duration and
/// free / paid opportunities at a glance.
class InternshipAtAGlanceCard extends StatelessWidget {
  const InternshipAtAGlanceCard({
    super.key,
    required this.onApply,
    this.title = 'Programmes at a Glance',
    this.fill = true,
    this.terms = const ProgramTerms(),
  });

  final VoidCallback onApply;
  final String title;

  /// Pushes the button to the bottom; only valid inside a bounded height
  /// such as a [ResponsiveGrid] row.
  final bool fill;
  final ProgramTerms terms;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (Icons.schedule_rounded, 'Duration', terms.duration ?? InternshipConfig.duration),
      if (InternshipConfig.offersFreeOpportunities) (Icons.volunteer_activism_outlined, 'Free', 'When available'),
      if (InternshipConfig.offersPaidOpportunities) (Icons.payments_outlined, 'Paid', 'When available'),
      (Icons.event_available_outlined, 'Applications', terms.availability ?? InternshipConfig.availability ?? toBeAnnounced),
      (Icons.location_on_outlined, 'Office', ContactConfig.locality),
    ];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: CardStyle.decoration(radius: AppRadius.lg),
      child: SurfaceTone(
        colors: SurfaceColors.inCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IconBadge(icon: Icons.event_note_outlined, color: AppColors.cardAccent, size: 48),
            const SizedBox(height: 18),
            Text(
              title,
              style: AppTypography.display(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.cardHeading),
            ),
            const SizedBox(height: 8),
            Text(
              'Terms depend on each specific opportunity and are confirmed with you before it begins.',
              style: AppTypography.body(fontSize: 14, height: 1.6, color: AppColors.cardBody),
            ),
            const SizedBox(height: 18),
            for (final (icon, label, value) in rows) _TermRow(icon: icon, label: label, value: value),
            if (fill) const Spacer(),
            const SizedBox(height: 16),
            PrimaryButton(
              label: InternshipConfig.applicationsOpen ? 'Apply Now' : 'Register Interest',
              size: ButtonSize.small,
              onPressed: onApply,
            ),
          ],
        ),
      ),
    );
  }
}

class _TermRow extends StatelessWidget {
  const _TermRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final pending = value == toBeAnnounced;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.cardAccent),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppTypography.body(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.cardHeading, height: 1.3),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.body(
                fontSize: 13.5,
                color: pending ? AppColors.cardMuted : AppColors.cardHeading,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ Benefits

class InternshipBenefits extends StatelessWidget {
  const InternshipBenefits({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveGrid(
      minItemWidth: 240,
      maxColumns: 4,
      spacing: 20,
      children: [
        for (final (i, (icon, title, text)) in InternshipContent.benefits.indexed)
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

// ------------------------------------------------------- Learning model

/// One of the two learning approaches, with its photograph. [focus] adds
/// programme-specific points on detail pages.
class LearningModelCard extends StatelessWidget {
  const LearningModelCard({
    super.key,
    required this.label,
    required this.title,
    required this.summary,
    required this.points,
    required this.image,
    required this.imageAlt,
    this.focusHeading,
    this.focus = const [],
  });

  final String label;
  final String title;
  final String summary;
  final List<String> points;
  final String image;
  final String imageAlt;
  final String? focusHeading;
  final List<String> focus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: CardStyle.decoration(radius: AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: SurfaceTone(
        colors: SurfaceColors.inCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: TintedPhoto(basePath: image, semanticLabel: imageAlt, strength: 0.45),
            ),
            Padding(
              padding: EdgeInsets.all(context.responsive(mobile: 22.0, desktop: 30.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: AppTypography.body(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cardAccent,
                      letterSpacing: 1.4,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: AppTypography.display(
                      fontSize: context.responsive(mobile: 21.0, desktop: 24.0),
                      height: 1.25,
                      color: AppColors.cardHeading,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(summary, style: AppTypography.body(fontSize: 15, height: 1.65, color: AppColors.cardBody)),
                  const SizedBox(height: 18),
                  CheckList(items: points, color: AppColors.cardAccent),
                  if (focus.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.cardTile,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            focusHeading ?? 'In this programme',
                            style: AppTypography.body(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cardHeading,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          CheckList(items: focus, color: AppColors.charcoalNavy),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mentor-guided and project-based learning side by side (stacked on
/// narrow screens).
class LearningModelPair extends StatelessWidget {
  const LearningModelPair({super.key, this.program});

  /// Adds programme-specific focus points when given.
  final InternshipProgram? program;

  @override
  Widget build(BuildContext context) {
    final p = program;
    final mentor = LearningModelCard(
      label: 'Learning Method A',
      title: InternshipContent.mentorTitle,
      summary: InternshipContent.mentorSummary,
      points: InternshipContent.mentorPoints,
      image: InternshipContent.mentorImage,
      imageAlt: InternshipContent.mentorImageAlt,
      focusHeading: p == null ? null : 'Mentor guidance in ${p.shortTitle}',
      focus: p?.mentorFocus ?? const [],
    );
    final project = LearningModelCard(
      label: 'Learning Method B',
      title: InternshipContent.projectTitle,
      summary: InternshipContent.projectSummary,
      points: InternshipContent.projectPoints,
      image: InternshipContent.projectImage,
      imageAlt: InternshipContent.projectImageAlt,
      focusHeading: p == null ? null : 'Project work in ${p.shortTitle}',
      focus: p?.projectFocus ?? const [],
    );
    if (context.screenWidth < 900) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(child: mentor),
          const SizedBox(height: 24),
          Reveal(child: project),
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: Reveal(child: mentor)),
          const SizedBox(width: 24),
          Expanded(
            child: Reveal(delay: const Duration(milliseconds: 100), child: project),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------- Opportunity types

/// Flexible duration plus free and paid opportunities, then the editable
/// terms for [terms] (shared defaults when omitted).
class OpportunityTypes extends StatelessWidget {
  const OpportunityTypes({super.key, this.terms = const ProgramTerms()});

  final ProgramTerms terms;

  @override
  Widget build(BuildContext context) {
    final cards = [
      (Icons.schedule_rounded, InternshipContent.durationTitle, InternshipContent.durationText, 'Flexible'),
      if (InternshipConfig.offersFreeOpportunities)
        (Icons.volunteer_activism_outlined, InternshipContent.freeTitle, InternshipContent.freeText, 'When available'),
      if (InternshipConfig.offersPaidOpportunities)
        (Icons.payments_outlined, InternshipContent.paidTitle, InternshipContent.paidText, 'When available'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResponsiveGrid(
          minItemWidth: 280,
          maxColumns: 3,
          spacing: 20,
          children: [
            for (final (i, (icon, title, text, tag)) in cards.indexed)
              Reveal(
                delay: Duration(milliseconds: 70 * i),
                child: HoverCard(
                  padding: const EdgeInsets.all(26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconBadge(icon: icon, color: AppColors.cardAccent, size: 46, gradient: i == 0),
                          const Spacer(),
                          TagChip(tag, color: AppColors.cardAccent, filled: true),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        title,
                        style: AppTypography.display(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: AppColors.cardHeading,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(text, style: AppTypography.body(fontSize: 14.5, height: 1.65, color: AppColors.cardBody)),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Reveal(child: ProgramTermsPanel(terms: terms)),
      ],
    );
  }
}

/// Editable programme terms; unconfirmed values read "To Be Announced".
class ProgramTermsPanel extends StatelessWidget {
  const ProgramTermsPanel({super.key, this.terms = const ProgramTerms()});

  final ProgramTerms terms;

  @override
  Widget build(BuildContext context) {
    final wide = context.screenWidth >= 860;
    final rows = terms.resolved();
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Programme Details',
          style: AppTypography.display(fontSize: 21, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.cardHeading),
        ),
        const SizedBox(height: 10),
        Text(
          InternshipContent.opportunityNote,
          style: AppTypography.body(fontSize: 14.5, height: 1.65, color: AppColors.cardBody),
        ),
        const SizedBox(height: 10),
        Text(InternshipContent.disclaimer, style: AppTypography.body(fontSize: 13.5, color: AppColors.cardMuted, height: 1.6)),
      ],
    );
    final list = Column(
      children: [
        for (final (i, (icon, label, value)) in rows.indexed)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              border: i == 0 ? null : const Border(top: BorderSide(color: AppColors.cardLine)),
            ),
            child: _TermRow(icon: icon, label: label, value: value),
          ),
      ],
    );
    return Container(
      padding: EdgeInsets.all(wide ? 32 : 22),
      decoration: CardStyle.decoration(radius: AppRadius.lg),
      child: SurfaceTone(
        colors: SurfaceColors.inCard,
        child: wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: heading),
                  const SizedBox(width: 40),
                  Expanded(flex: 6, child: list),
                ],
              )
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [heading, const SizedBox(height: 18), list]),
      ),
    );
  }
}

// ------------------------------------------------------------- Roadmap

/// The six-stage learning journey. [focus] adds one programme-specific line
/// per stage on detail pages.
class LearningRoadmap extends StatelessWidget {
  const LearningRoadmap({super.key, this.focus});

  final List<String>? focus;

  @override
  Widget build(BuildContext context) {
    const stages = InternshipContent.roadmap;
    return ResponsiveGrid(
      minItemWidth: 300,
      maxColumns: 3,
      spacing: 20,
      children: [
        for (final (i, stage) in stages.indexed)
          Reveal(
            delay: Duration(milliseconds: 60 * (i % 3)),
            child: _StageCard(index: i, stage: stage, focus: focus?[i]),
          ),
      ],
    );
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({required this.index, required this.stage, this.focus});

  final int index;
  final PillarStep stage;
  final String? focus;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(12)),
                child: Text('${index + 1}', style: AppTypography.display(fontSize: 18, color: AppColors.white, height: 1)),
              ),
              const SizedBox(width: 12),
              Text(
                'STAGE ${index + 1}',
                style: AppTypography.body(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cardAccent,
                  letterSpacing: 1.4,
                  height: 1.2,
                ),
              ),
              const Spacer(),
              Icon(stage.icon, size: 22, color: AppColors.cardMuted),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            stage.title,
            style: AppTypography.display(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.cardHeading),
          ),
          const SizedBox(height: 8),
          Text(stage.description, style: AppTypography.body(fontSize: 14.3, height: 1.6, color: AppColors.cardBody)),
          if (focus != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: AppColors.cardTile,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border(left: BorderSide(color: AppColors.cardAccent.withValues(alpha: 0.8), width: 3)),
              ),
              child: Text(focus!, style: AppTypography.body(fontSize: 13.5, color: AppColors.cardHeading, height: 1.55)),
            ),
          ],
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------- FAQ

/// Accessible accordion of questions; one answer open at a time.
class FaqList extends StatefulWidget {
  const FaqList({super.key, required this.faqs});

  final List<Faq> faqs;

  @override
  State<FaqList> createState() => _FaqListState();
}

class _FaqListState extends State<FaqList> {
  int? _open = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, faq) in widget.faqs.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _FaqTile(faq: faq, open: _open == i, onToggle: () => setState(() => _open = _open == i ? null : i)),
          ),
      ],
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq, required this.open, required this.onToggle});

  final Faq faq;
  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.hover,
      decoration: CardStyle.decoration(radius: AppRadius.md, hover: open),
      child: SurfaceTone(
        colors: SurfaceColors.inCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              button: true,
              expanded: open,
              child: InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          faq.question,
                          style: AppTypography.body(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cardHeading,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedRotation(
                        turns: open ? 0.5 : 0,
                        duration: AppMotion.hover,
                        child: Icon(Icons.expand_more_rounded, color: open ? AppColors.cardAccent : AppColors.cardMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedSize(
              duration: AppMotion.lift,
              curve: AppMotion.ease,
              alignment: Alignment.topCenter,
              child: open
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Text(faq.answer, style: AppTypography.body(fontSize: 14.8, height: 1.7, color: AppColors.cardBody)),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------- Apply section

/// Photo, reassurance points and the application form.
class InternshipApplySection extends StatelessWidget {
  const InternshipApplySection({super.key, required this.selection, this.program});

  final ValueNotifier<String?> selection;

  /// Tailors the heading on a programme page.
  final InternshipProgram? program;

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktop;
    final open = InternshipConfig.applicationsOpen;
    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(open ? 'Apply Now' : 'Register Interest', color: AppColors.accent),
        const SizedBox(height: 18),
        Semantics(
          header: true,
          child: Text(
            program == null ? 'Ready to Start Learning?' : 'Interested in ${program!.shortTitle}?',
            style: AppTypography.display(fontSize: context.responsive(mobile: 28.0, tablet: 34.0, desktop: 38.0)),
          ),
        ),
        const SizedBox(height: 14),
        Text(InternshipContent.applicationLead, style: AppTypography.body(fontSize: 16, height: 1.7)),
        const SizedBox(height: 24),
        const CheckList(
          items: [
            'Choose the programme that interests you most',
            'Tell us whether you prefer a free or paid opportunity',
            'We share confirmed terms before anything begins',
          ],
          color: AppColors.accent,
        ),
        if (desktop) ...[
          const SizedBox(height: 20),
          MediaFrame(
            radius: AppRadius.lg,
            aspectRatio: 4 / 3,
            child: TintedPhoto(
              basePath: InternshipContent.applicationImage,
              semanticLabel: InternshipContent.applicationImageAlt,
              strength: 0.4,
            ),
          ),
        ],
      ],
    );
    final form = FormCard(
      padding: EdgeInsets.all(context.responsive(mobile: 20.0, desktop: 36.0)),
      child: InternshipApplicationForm(selection: selection),
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

/// Home › Internship, or Home › Internship › [current] on a programme page.
class InternshipBreadcrumb extends StatelessWidget {
  const InternshipBreadcrumb({super.key, this.current, required this.onHome, this.onInternship});

  final String? current;
  final VoidCallback onHome;
  final VoidCallback? onInternship;

  @override
  Widget build(BuildContext context) {
    Widget link(String label, IconData icon, VoidCallback onTap) => TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: context.tone.body,
        textStyle: AppTypography.body(fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        minimumSize: const Size(0, 36),
      ),
    );
    Widget here(String label) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        label,
        style: AppTypography.body(fontSize: 13.5, fontWeight: FontWeight.w600, color: context.tone.accent, height: 1.2),
      ),
    );
    final separator = Icon(Icons.chevron_right_rounded, size: 16, color: context.tone.muted);

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
            link('Home', Icons.home_outlined, onHome),
            separator,
            if (current case final c?) ...[
              link('Internship', Icons.school_outlined, onInternship ?? onHome),
              separator,
              here(c),
            ] else
              here('Internship'),
          ],
        ),
      ),
    );
  }
}

/// "Back to Internship Programs" link shown on programme pages.
class BackToProgramsLink extends StatelessWidget {
  const BackToProgramsLink({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_back_rounded, size: 18),
        label: const Text('Back to Internship Programs'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: AppTypography.body(fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
      ),
    );
  }
}
