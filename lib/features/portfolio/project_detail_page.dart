import 'package:flutter/material.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../models/service_page.dart';
import '../../models/site_section.dart';
import '../../repositories/content/portfolio_content.dart';
import '../../repositories/content/service_pages_content.dart';
import '../../services/asset_registry.dart';
import '../../shared/layouts/navigation_actions.dart';
import '../../shared/layouts/subpage_scaffold.dart';
import '../../shared/three/interactive_3d_object.dart';
import '../../shared/three/scene3d.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/premium.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';
import '../../shared/widgets/smart_image.dart';
import 'portfolio_widgets.dart';

/// `/portfolio/<slug>`: one demonstration project in full: overview,
/// objective, challenge, proposed solution and key features, with large
/// visuals. "Open Working Demo" appears only for projects with a real demo;
/// concept visuals are labelled as such. No clients or results are implied.
class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage({super.key, required this.project});

  final SampleProject project;

  @override
  Widget build(BuildContext context) {
    final study = project.study;
    final service = ServicePagesContent.serviceOf(project);
    return SubpageScaffold(
      title: project.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Hero(project: project, serviceTitle: service.title),
          SectionShell(
            background: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (study != null)
                  ResponsiveGrid(
                    minItemWidth: 300,
                    maxColumns: 3,
                    spacing: 24,
                    children: [
                      Reveal(child: _StoryCard(number: '01', label: 'Objective', icon: Icons.flag_outlined, text: study.objective)),
                      Reveal(
                        delay: const Duration(milliseconds: 80),
                        child: _StoryCard(number: '02', label: 'The Challenge', icon: Icons.help_outline_rounded, text: study.problem),
                      ),
                      Reveal(
                        delay: const Duration(milliseconds: 160),
                        child: _StoryCard(number: '03', label: 'Proposed Solution', icon: Icons.lightbulb_outline_rounded, text: study.solution),
                      ),
                    ],
                  ),
                SizedBox(height: context.responsive(mobile: 48.0, desktop: 72.0)),
                Reveal(child: _Features(project: project, technologies: study?.technologies ?? const [])),
              ],
            ),
          ),
          if (project.hasDemo)
            SectionShell(
              background: AppColors.pearlWhite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                    eyebrow: 'Previews',
                    title: 'See It on Screen',
                    lead: 'Screens captured from the working demo running on this site.',
                    centered: true,
                  ),
                  const SizedBox(height: 36),
                  Reveal(child: _Previews(project: project)),
                ],
              ),
            ),
          SectionShell(
            background: AppColors.surface,
            child: Column(
              children: [
                const SectionHeader(
                  eyebrow: 'Next Steps',
                  title: 'Want Something Like This?',
                  lead: 'Ask for a walkthrough of this demonstration, or tell us what your business needs and we will reply with clear next steps.',
                  centered: true,
                ),
                const SizedBox(height: 28),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    PrimaryButton(
                      label: 'Request Demo',
                      onPressed: () => goToSection(context, SiteSection.contact, enquiryService: service.title, showForm: true),
                    ),
                    SecondaryButton(
                      label: 'Back to Portfolio',
                      icon: Icons.grid_view_rounded,
                      onPressed: () => openRoute(context, AppRoutes.portfolio),
                    ),
                    SecondaryButton(label: service.title, icon: Icons.arrow_forward_rounded, onPressed: () => openServicePage(context, service)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.project, required this.serviceTitle});

  final SampleProject project;
  final String serviceTitle;

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktop;
    final study = project.study;
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Reveal(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ProjectStatusBadge(demo: project.hasDemo),
              ProjectTag(project.category),
              if (study != null) ProjectTag(study.industry),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Reveal(
          delay: const Duration(milliseconds: 80),
          child: Semantics(
            header: true,
            child: GradientText(
              project.name,
              style: AppTypography.display(fontSize: context.responsive(mobile: 38.0, tablet: 48.0, desktop: 60.0), fontWeight: FontWeight.w800, height: 1.05),
              gradient: AppColors.metallicGoldText,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Reveal(
          delay: const Duration(milliseconds: 140),
          child: Text(
            project.overview,
            style: AppTypography.body(fontSize: context.responsive(mobile: 16.0, desktop: 18.0), height: 1.75, color: AppColors.body),
          ),
        ),
        const SizedBox(height: 28),
        Reveal(
          delay: const Duration(milliseconds: 200),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (project.demoRoute != null)
                PrimaryButton(
                  label: 'Open Working Demo',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => openRoute(context, project.demoRoute!),
                ),
              (project.demoRoute != null ? SecondaryButton.new : PrimaryButton.new)(
                label: 'Request Demo',
                icon: Icons.mail_outline_rounded,
                onPressed: () => goToSection(context, SiteSection.contact, enquiryService: serviceTitle, showForm: true),
              ),
            ],
          ),
        ),
        if (!project.hasDemo) ...[
          const SizedBox(height: 18),
          Text(
            'Concept project: there is no working demo yet. Images are illustrative.',
            style: AppTypography.body(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.muted),
          ),
        ],
      ],
    );
    final still = project.deviceStill;
    final visual = Reveal(
      delay: const Duration(milliseconds: 120),
      child: Stack(
        children: [
          ProjectCover(
            project: project,
            radius: AppRadius.xl,
            device: still == null
                ? null
                : Interactive3DObject(
                    scene: Scene3D.device,
                    variant: project.deviceVariant,
                    image: project.screenSpec,
                    background: null,
                    semanticLabel: project.coverLabel,
                    fallback: LazyAssetImage(path: still, semanticLabel: project.coverLabel, fit: BoxFit.contain),
                  ),
          ),
          if (!project.hasDemo) const Positioned(right: 14, bottom: 12, child: ConceptVisualNote()),
        ],
      ),
    );
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.pearlWhite, Color(0xFFF4EDE1)],
        ),
      ),
      child: SectionShell(
        background: Colors.transparent,
        topPadding: context.responsive(mobile: 32.0, desktop: 64.0),
        bottomPadding: context.responsive(mobile: 40.0, desktop: 72.0),
        child: desktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 9, child: copy),
                  const SizedBox(width: 48),
                  Expanded(flex: 11, child: visual),
                ],
              )
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [copy, const SizedBox(height: 28), visual]),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.number, required this.label, required this.icon, required this.text});

  final String number;
  final String label;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: premiumGlassCard(lifted: false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GradientText(number, style: AppTypography.display(fontSize: 30, fontWeight: FontWeight.w800, height: 1), gradient: AppColors.metallicGoldText),
              const Spacer(),
              Icon(icon, size: 20, color: AppColors.accent),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            label.toUpperCase(),
            style: AppTypography.body(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: AppColors.accent, height: 1.2),
          ),
          const SizedBox(height: 10),
          Text(text, style: AppTypography.body(fontSize: 15, height: 1.7, color: AppColors.body)),
        ],
      ),
    );
  }
}

class _Features extends StatelessWidget {
  const _Features({required this.project, required this.technologies});

  final SampleProject project;
  final List<String> technologies;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.responsive(mobile: 22.0, desktop: 40.0)),
      decoration: premiumGlassCard(lifted: false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RuleEyebrow('Key Features'),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 760 ? 3 : (constraints.maxWidth > 440 ? 2 : 1);
              final width = (constraints.maxWidth - 20 * (columns - 1)) / columns;
              return Wrap(
                spacing: 20,
                runSpacing: 14,
                children: [
                  for (final f in project.features)
                    SizedBox(
                      width: width,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.only(top: 1),
                            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.buttonGold),
                            child: const Icon(Icons.check_rounded, size: 14, color: AppColors.onPrimary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(f, style: AppTypography.body(fontSize: 15, color: AppColors.ink, height: 1.5))),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          if (technologies.isNotEmpty) ...[
            const SizedBox(height: 28),
            Text(
              'BUILT WITH',
              style: AppTypography.body(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: AppColors.accent, height: 1.2),
            ),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [for (final t in technologies) TechChip(t)]),
          ],
        ],
      ),
    );
  }
}

/// Large visuals of a working demo: its screenshot as a desktop browser
/// window beside the project on its device (phone demos show the phone).
class _Previews extends StatelessWidget {
  const _Previews({required this.project});

  final SampleProject project;

  @override
  Widget build(BuildContext context) {
    final device = project.study?.device ?? ProjectDevice.laptop;
    final onDevice = ProjectCover(project: project, radius: AppRadius.xl);
    final phone = device == ProjectDevice.phone;
    final screenshot = AssetRegistry.instance.resolve(project.image);
    final desktopPreview = screenshot == null || phone
        ? null
        : BrowserMockup(image: screenshot, address: project.demoRoute ?? '', semanticLabel: project.imageAlt);
    final caption = phone ? 'Mobile preview' : 'Desktop preview';
    if (desktopPreview == null) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: _Captioned(caption: caption, child: onDevice),
        ),
      );
    }
    final deviceCaption = '${device.name[0].toUpperCase()}${device.name.substring(1)} view';
    return context.isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 3, child: _Captioned(caption: caption, child: desktopPreview)),
              const SizedBox(width: 32),
              Expanded(flex: 2, child: _Captioned(caption: deviceCaption, child: onDevice)),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Captioned(caption: caption, child: desktopPreview),
              const SizedBox(height: 28),
              _Captioned(caption: deviceCaption, child: onDevice),
            ],
          );
  }
}

class _Captioned extends StatelessWidget {
  const _Captioned({required this.caption, required this.child});

  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        child,
        const SizedBox(height: 12),
        Text(
          caption.toUpperCase(),
          textAlign: TextAlign.center,
          style: AppTypography.body(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: AppColors.muted),
        ),
      ],
    );
  }
}
