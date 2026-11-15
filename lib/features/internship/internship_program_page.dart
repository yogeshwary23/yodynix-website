import 'package:flutter/material.dart';

import '../../core/constants/site_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/utils/responsive.dart';
import '../../models/internship_program.dart';
import '../../models/site_section.dart';
import '../../repositories/content/internship_content.dart';
import '../../shared/layouts/navigation_actions.dart';
import '../../shared/layouts/subpage_scaffold.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';
import '../../shared/widgets/site_dialog.dart';
import '../../shared/widgets/tinted_photo.dart';
import 'internship_widgets.dart';

/// Independent page for one internship programme: hero, introduction,
/// what you will learn, skills, methodology, roadmap, example projects,
/// who can apply, duration and opportunity types, FAQ and the form.
class InternshipProgramPage extends StatefulWidget {
  const InternshipProgramPage({super.key, required this.program});

  final InternshipProgram program;

  @override
  State<InternshipProgramPage> createState() => _InternshipProgramPageState();
}

class _InternshipProgramPageState extends State<InternshipProgramPage> {
  final _applyKey = GlobalKey(debugLabel: 'apply');
  final _roadmapKey = GlobalKey(debugLabel: 'roadmap');
  late final _selection = ValueNotifier<String?>(widget.program.slug);

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

  void _backToPrograms() => openInternshipPage(context);

  @override
  Widget build(BuildContext context) {
    final p = widget.program;
    final gap = context.responsive(mobile: 40.0, desktop: 56.0);

    return SubpageScaffold(
      title: p.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Hero(
            program: p,
            onBack: _backToPrograms,
            onApply: () => _scrollTo(_applyKey),
            onRoadmap: () => _scrollTo(_roadmapKey),
          ),

          // Introduction + what you will learn
          SectionShell(
            background: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Introduction(program: p, onApply: () => _scrollTo(_applyKey)),
                SizedBox(height: gap * 1.4),
                SectionHeader(
                  eyebrow: 'What You Will Learn',
                  title: 'Inside the ${p.shortTitle} Programme',
                  centered: true,
                  eyebrowColor: AppColors.accent,
                ),
                SizedBox(height: gap),
                ResponsiveGrid(
                  minItemWidth: 280,
                  maxColumns: 3,
                  spacing: 20,
                  children: [
                    for (final (i, t) in p.learnTopics.indexed)
                      Reveal(
                        delay: Duration(milliseconds: 60 * (i % 3)),
                        child: _TopicCard(topic: t),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Skills & technologies + learning methodology
          SectionShell(
            background: AppColors.surface,
            glowAt: const Alignment(-1.1, -0.5),
            glowStrength: 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SkillsAndTechnologies(program: p),
                SizedBox(height: gap * 1.4),
                const SectionHeader(
                  eyebrow: 'Learning Methodology',
                  title: 'Mentor-Guided and Project-Based',
                  lead: InternshipContent.learningModelLead,
                  centered: true,
                  eyebrowColor: AppColors.accent,
                ),
                SizedBox(height: gap),
                LearningModelPair(program: p),
              ],
            ),
          ),

          // Project examples
          SectionShell(
            background: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  eyebrow: 'Project Examples',
                  title: 'What You Could Build',
                  lead:
                      'Illustrative practice projects used for learning in this programme. They are examples, '
                      'not client work, and the exact project depends on the opportunity and your progress.',
                  centered: true,
                  eyebrowColor: AppColors.accent,
                ),
                SizedBox(height: gap),
                ResponsiveGrid(
                  minItemWidth: 280,
                  maxColumns: 3,
                  spacing: 20,
                  children: [
                    for (final (i, project) in p.projects.indexed)
                      Reveal(
                        delay: Duration(milliseconds: 70 * i),
                        child: _ProjectCard(project: project),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Roadmap
          KeyedSubtree(
            key: _roadmapKey,
            child: SectionShell(
              background: AppColors.surface,
              glowAt: const Alignment(1.1, -0.6),
              glowStrength: 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(
                    eyebrow: 'Learning Roadmap',
                    title: 'Your ${p.shortTitle} Journey',
                    lead:
                        'Six stages, each with a focus specific to this programme. The pace depends on the '
                        'opportunity and your progress.',
                    centered: true,
                    eyebrowColor: AppColors.accent,
                  ),
                  SizedBox(height: gap),
                  LearningRoadmap(focus: p.roadmapFocus),
                ],
              ),
            ),
          ),

          // Who can apply + duration / free & paid
          SectionShell(
            background: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WhoCanApply(program: p),
                SizedBox(height: gap * 1.4),
                const SectionHeader(
                  eyebrow: 'Duration & Opportunity Types',
                  title: 'Flexible, With Free and Paid Opportunities',
                  lead:
                      'The duration is flexible, and opportunities may be free or paid depending on what is '
                      'available. Confirmed terms are always shared before anything begins.',
                  centered: true,
                  eyebrowColor: AppColors.accent,
                ),
                SizedBox(height: gap),
                OpportunityTypes(terms: p.terms),
              ],
            ),
          ),

          // FAQ
          SectionShell(
            background: AppColors.surface,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 880),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionHeader(
                      eyebrow: 'FAQ',
                      title: '${p.shortTitle} Questions',
                      centered: true,
                      eyebrowColor: AppColors.accent,
                    ),
                    SizedBox(height: gap * 0.8),
                    FaqList(faqs: [...p.faqs, ...InternshipContent.faqs]),
                  ],
                ),
              ),
            ),
          ),

          // Apply / register interest
          KeyedSubtree(
            key: _applyKey,
            child: SectionShell(
              background: AppColors.background,
              glowAt: const Alignment(-1.1, 0.6),
              glowStrength: 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InternshipApplySection(selection: _selection, program: p),
                  SizedBox(height: gap * 1.2),
                  _OtherPrograms(current: p),
                  const SizedBox(height: 16),
                  Center(child: BackToProgramsLink(onPressed: _backToPrograms)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ Hero

class _Hero extends StatelessWidget {
  const _Hero({required this.program, required this.onBack, required this.onApply, required this.onRoadmap});

  final InternshipProgram program;
  final VoidCallback onBack;
  final VoidCallback onApply;
  final VoidCallback onRoadmap;

  @override
  Widget build(BuildContext context) {
    const tone = SurfaceColors.dark;
    final desktop = context.isDesktop;
    final p = program;
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow('Internship Program', color: tone.accent),
        const SizedBox(height: 20),
        Semantics(
          header: true,
          child: Text(
            p.title,
            style: AppTypography.display(
              fontSize: context.responsive(mobile: 32.0, tablet: 42.0, desktop: 48.0),
              color: tone.ink,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          p.description,
          style: AppTypography.body(fontSize: context.responsive(mobile: 16.0, desktop: 18.0), height: 1.7, color: tone.body),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            TagChip(
              'Duration: ${p.terms.duration ?? InternshipConfig.duration}',
              color: tone.accent,
              icon: Icons.schedule_rounded,
              filled: true,
            ),
            if (InternshipConfig.offersFreeOpportunities && InternshipConfig.offersPaidOpportunities)
              TagChip('Free & Paid opportunities', color: tone.accent, icon: Icons.payments_outlined, filled: true),
            TagChip('Mentor-guided', color: tone.accent, icon: Icons.groups_2_outlined, filled: true),
          ],
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            PrimaryButton(label: InternshipConfig.applicationsOpen ? 'Apply Now' : 'Register Interest', onPressed: onApply),
            SecondaryButton(label: 'View Learning Roadmap', icon: Icons.south_rounded, onPressed: onRoadmap),
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
          aspectRatio: desktop ? 4 / 3 : 16 / 10,
          child: TintedPhoto(basePath: p.image, semanticLabel: p.imageAlt, strength: 0.5),
        ),
      ),
    );

    return SectionShell(
      topPadding: context.responsive(mobile: 20.0, desktop: 32.0),
      bottomPadding: context.responsive(mobile: 56.0, desktop: 88.0),
      tone: tone,
      gradient: AppColors.darkBandGradient,
      glowAt: const Alignment(0.8, -0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BackToProgramsLink(onPressed: onBack),
          InternshipBreadcrumb(current: p.shortTitle, onHome: () => goToSection(context, SiteSection.home), onInternship: onBack),
          SizedBox(height: context.responsive(mobile: 22.0, desktop: 36.0)),
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

// ---------------------------------------------------------- Introduction

class _Introduction extends StatelessWidget {
  const _Introduction({required this.program, required this.onApply});

  final InternshipProgram program;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final p = program;
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Introduction', color: AppColors.accent),
        const SizedBox(height: 18),
        Text(
          'About This Programme',
          style: AppTypography.display(fontSize: context.responsive(mobile: 26.0, tablet: 32.0, desktop: 36.0)),
        ),
        const SizedBox(height: 16),
        for (final para in p.introduction)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(para, style: AppTypography.body(fontSize: 16, height: 1.75)),
          ),
      ],
    );
    final glance = InternshipAtAGlanceCard(onApply: onApply, title: 'At a Glance', fill: false, terms: p.terms);
    if (!context.isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(child: text),
          const SizedBox(height: 20),
          Reveal(child: glance),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: Reveal(child: text)),
        const SizedBox(width: 48),
        Expanded(
          flex: 4,
          child: Reveal(delay: const Duration(milliseconds: 100), child: glance),
        ),
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic});

  final LearningTopic topic;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: topic.icon, color: AppColors.cardAccent, size: 46),
          const SizedBox(height: 16),
          Text(
            topic.title,
            style: AppTypography.display(fontSize: 17.5, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.cardHeading),
          ),
          const SizedBox(height: 8),
          Text(topic.description, style: AppTypography.body(fontSize: 14.3, height: 1.6, color: AppColors.cardBody)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------- Skills & technologies

class _SkillsAndTechnologies extends StatelessWidget {
  const _SkillsAndTechnologies({required this.program});

  final InternshipProgram program;

  @override
  Widget build(BuildContext context) {
    Widget group(String label, IconData icon, List<String> items, {bool filled = false}) => Container(
      padding: EdgeInsets.all(context.responsive(mobile: 22.0, desktop: 28.0)),
      decoration: CardStyle.decoration(radius: AppRadius.lg),
      child: SurfaceTone(
        colors: SurfaceColors.inCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.cardAccent),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: AppTypography.display(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: AppColors.cardHeading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in items)
                  TagChip(s, color: AppColors.cardAccent, icon: filled ? Icons.check_rounded : null, filled: filled),
              ],
            ),
          ],
        ),
      ),
    );

    final skills = group('Skills You Develop', Icons.psychology_outlined, program.skills, filled: true);
    final tools = group('Tools & Technologies', Icons.build_outlined, program.technologies);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          eyebrow: 'Skills & Technologies',
          title: 'Skills and Tools You Will Use',
          centered: true,
          eyebrowColor: AppColors.cardAccent,
        ),
        SizedBox(height: context.responsive(mobile: 32.0, desktop: 44.0)),
        if (context.screenWidth >= 860)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: Reveal(child: skills)),
                const SizedBox(width: 20),
                Expanded(
                  child: Reveal(delay: const Duration(milliseconds: 80), child: tools),
                ),
              ],
            ),
          )
        else ...[
          Reveal(child: skills),
          const SizedBox(height: 20),
          Reveal(child: tools),
        ],
      ],
    );
  }
}

// ------------------------------------------------------- Project examples

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final SampleLearningProject project;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconBadge(icon: project.icon, color: AppColors.cardAccent, size: 46, gradient: true),
              const Spacer(),
              const TagChip('Practice Project', color: AppColors.charcoalNavy),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            project.title,
            style: AppTypography.display(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.cardHeading),
          ),
          const SizedBox(height: 8),
          Text(project.description, style: AppTypography.body(fontSize: 14.3, height: 1.6, color: AppColors.cardBody)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------- Who can apply

class _WhoCanApply extends StatelessWidget {
  const _WhoCanApply({required this.program});

  final InternshipProgram program;

  @override
  Widget build(BuildContext context) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Who Can Apply', color: AppColors.cardAccent),
        const SizedBox(height: 18),
        Text(
          'Is This Programme Right for You?',
          style: AppTypography.display(
            fontSize: context.responsive(mobile: 26.0, tablet: 32.0, desktop: 36.0),
            color: AppColors.cardHeading,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'You do not need prior professional experience. Specific eligibility, if any, is confirmed with each '
          'opportunity.',
          style: AppTypography.body(fontSize: 16, height: 1.7, color: AppColors.cardBody),
        ),
      ],
    );
    final list = Container(
      padding: EdgeInsets.all(context.responsive(mobile: 22.0, desktop: 30.0)),
      decoration: CardStyle.decoration(radius: AppRadius.lg),
      child: SurfaceTone(
        colors: SurfaceColors.inCard,
        child: CheckList(items: program.whoCanApply, color: AppColors.cardAccent),
      ),
    );
    if (!context.isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(child: heading),
          const SizedBox(height: 24),
          Reveal(child: list),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 5, child: Reveal(child: heading)),
        const SizedBox(width: 48),
        Expanded(
          flex: 6,
          child: Reveal(delay: const Duration(milliseconds: 100), child: list),
        ),
      ],
    );
  }
}

// --------------------------------------------------------- Other programmes

class _OtherPrograms extends StatelessWidget {
  const _OtherPrograms({required this.current});

  final InternshipProgram current;

  @override
  Widget build(BuildContext context) {
    final others = InternshipContent.programs.where((p) => p.slug != current.slug);
    return Column(
      children: [
        Text(
          'EXPLORE OTHER PROGRAMS',
          textAlign: TextAlign.center,
          style: AppTypography.body(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
            letterSpacing: 1.6,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final p in others)
              ActionChip(
                avatar: Icon(p.icon, size: 16, color: AppColors.accent),
                label: Text(p.shortTitle),
                labelStyle: AppTypography.body(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.ink, height: 1.2),
                backgroundColor: AppColors.card,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                onPressed: () => openInternshipPage(context, slug: p.slug),
              ),
          ],
        ),
      ],
    );
  }
}
