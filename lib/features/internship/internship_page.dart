import 'package:flutter/material.dart';

import '../../core/constants/site_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/utils/responsive.dart';
import '../../models/site_section.dart';
import '../../repositories/content/internship_content.dart';
import '../../shared/layouts/navigation_actions.dart';
import '../../shared/layouts/subpage_scaffold.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';
import '../../shared/widgets/tinted_photo.dart';
import 'internship_widgets.dart';

/// Internship landing page: hero, benefits, the seven programmes, how
/// learning works, free and paid opportunities, roadmap, FAQ and the
/// application form.
class InternshipPage extends StatefulWidget {
  const InternshipPage({super.key, this.scrollToApply = false});

  /// Opens with the application form in view (e.g. "Register Interest").
  final bool scrollToApply;

  @override
  State<InternshipPage> createState() => _InternshipPageState();
}

class _InternshipPageState extends State<InternshipPage> {
  final _programsKey = GlobalKey(debugLabel: 'programs');
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

  void _openProgram(String slug) => openInternshipPage(context, slug: slug);

  @override
  Widget build(BuildContext context) {
    final gap = context.responsive(mobile: 40.0, desktop: 56.0);
    const programs = InternshipContent.programs;

    return SubpageScaffold(
      title: 'Internship Programs',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Hero
          _Hero(onExplore: () => _scrollTo(_programsKey), onApply: () => _scrollTo(_applyKey)),

          // 2. Learning benefits
          SectionShell(
            background: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(
                  eyebrow: 'Why Intern With YODYNIX',
                  title: 'Learning That Builds Real Skills',
                  lead:
                      'Every programme focuses on doing the work: practical tasks, guidance when you need it and '
                      'honest feedback on what you build.',
                  centered: true,
                  eyebrowColor: AppColors.accent,
                ),
                SizedBox(height: gap),
                const InternshipBenefits(),
              ],
            ),
          ),

          // 3. Seven programmes
          KeyedSubtree(
            key: _programsKey,
            child: SectionShell(
              background: AppColors.surface,
              glowAt: const Alignment(1.1, -0.7),
              glowStrength: 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                    eyebrow: 'Internship Programs',
                    title: 'Choose Your Learning Path',
                    lead:
                        'Seven programmes across development, design, marketing and automation. Open any programme '
                        'to see what you will learn, the tools involved and example practice projects.',
                    centered: true,
                    eyebrowColor: AppColors.accent,
                  ),
                  SizedBox(height: gap),
                  ResponsiveGrid(
                    minItemWidth: 270,
                    maxColumns: 4,
                    spacing: 20,
                    children: [
                      for (final (i, p) in programs.indexed)
                        Reveal(
                          delay: Duration(milliseconds: 60 * (i % 4)),
                          child: InternshipProgramCard(program: p, index: i, onOpen: () => _openProgram(p.slug)),
                        ),
                      Reveal(
                        delay: const Duration(milliseconds: 180),
                        child: InternshipAtAGlanceCard(onApply: () => _scrollTo(_applyKey)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 4. How internship learning works
          SectionShell(
            background: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(
                  eyebrow: 'How Internship Learning Works',
                  title: 'Two Ways You Learn With Us',
                  lead: InternshipContent.learningModelLead,
                  centered: true,
                  eyebrowColor: AppColors.accent,
                ),
                SizedBox(height: gap),
                const LearningModelPair(),
              ],
            ),
          ),

          // 5. Free and paid opportunities
          SectionShell(
            background: AppColors.surface,
            glowAt: const Alignment(-1.1, -0.4),
            glowStrength: 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(
                  eyebrow: 'Duration & Opportunity Types',
                  title: 'Flexible, With Free and Paid Opportunities',
                  lead:
                      'There is no fixed length or single format. Each opportunity is described clearly before it '
                      'begins, so you know exactly what to expect.',
                  centered: true,
                  eyebrowColor: AppColors.accent,
                ),
                SizedBox(height: gap),
                const OpportunityTypes(),
              ],
            ),
          ),

          // 6. Roadmap
          SectionShell(
            background: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(
                  eyebrow: 'Learning Roadmap',
                  title: 'Your Internship Journey',
                  lead:
                      'Six stages take you from orientation to a reviewed, finished piece of work. The pace of each '
                      'stage depends on the programme and your progress.',
                  centered: true,
                  eyebrowColor: AppColors.accent,
                ),
                SizedBox(height: gap),
                const LearningRoadmap(),
              ],
            ),
          ),

          // 7. FAQ
          SectionShell(
            background: AppColors.surface,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 880),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader(
                      eyebrow: 'FAQ',
                      title: 'Frequently Asked Questions',
                      centered: true,
                      eyebrowColor: AppColors.accent,
                    ),
                    SizedBox(height: gap * 0.8),
                    const FaqList(faqs: InternshipContent.faqs),
                  ],
                ),
              ),
            ),
          ),

          // 8. Apply / register interest
          KeyedSubtree(
            key: _applyKey,
            child: SectionShell(
              background: AppColors.background,
              glowAt: const Alignment(-1.1, 0.6),
              glowStrength: 0.6,
              child: InternshipApplySection(selection: _selection),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onExplore, required this.onApply});

  final VoidCallback onExplore;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    const tone = SurfaceColors.dark;
    final desktop = context.isDesktop;
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(InternshipContent.badge, color: tone.accent),
        const SizedBox(height: 20),
        Semantics(
          header: true,
          child: Text(
            InternshipContent.heading,
            style: AppTypography.display(
              fontSize: context.responsive(mobile: 32.0, tablet: 42.0, desktop: 50.0),
              color: tone.ink,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          InternshipContent.description,
          style: AppTypography.body(fontSize: context.responsive(mobile: 16.0, desktop: 18.0), height: 1.7, color: tone.body),
        ),
        const SizedBox(height: 24),
        for (final (icon, label) in InternshipContent.highlights)
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
            PrimaryButton(label: 'Explore Internship Opportunities', icon: Icons.south_rounded, onPressed: onExplore),
            SecondaryButton(label: InternshipConfig.applicationsOpen ? 'Apply Now' : 'Register Interest', onPressed: onApply),
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
          child: TintedPhoto(basePath: InternshipContent.heroImage, semanticLabel: InternshipContent.heroImageAlt, strength: 0.5),
        ),
      ),
    );

    return SectionShell(
      topPadding: context.responsive(mobile: 28.0, desktop: 44.0),
      bottomPadding: context.responsive(mobile: 56.0, desktop: 88.0),
      tone: tone,
      gradient: AppColors.darkBandGradient,
      glowAt: const Alignment(0.8, -0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InternshipBreadcrumb(onHome: () => goToSection(context, SiteSection.home)),
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
