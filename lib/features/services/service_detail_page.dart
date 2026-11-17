import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/utils/responsive.dart';
import '../../models/content_models.dart';
import '../../models/pillar_page.dart' show PillarStep;
import '../../models/service_page.dart';
import '../../models/site_section.dart';
import '../../repositories/content/service_pages_content.dart';
import '../../repositories/content/services_content.dart';
import '../../shared/layouts/navigation_actions.dart';
import '../../shared/layouts/subpage_scaffold.dart';
import '../../services/asset_registry.dart';
import '../../shared/three/scene_widgets.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';
import '../../shared/widgets/site_dialog.dart';
import '../../shared/widgets/tinted_photo.dart';

/// Independent page for one service: hero, overview, offers, tools,
/// process, sample portfolio, featured project details and a project CTA.
class ServiceDetailPage extends StatefulWidget {
  const ServiceDetailPage({super.key, required this.service});

  final ServiceOffering service;

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  final _portfolioKey = GlobalKey(debugLabel: 'portfolio');

  void _toPortfolio() {
    final target = _portfolioKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(target, duration: const Duration(milliseconds: 750), curve: Curves.easeInOutCubic);
  }

  void _startProject() => goToSection(context, SiteSection.contact, enquiryService: widget.service.title);

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final content = ServicePagesContent.of(service);
    final gap = context.responsive(mobile: 48.0, desktop: 64.0);

    return SubpageScaffold(
      title: service.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Hero(service: service, content: content, onStart: _startProject, onPortfolio: _toPortfolio),
          SectionShell(
            background: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Overview(service: service, content: content),
                SizedBox(height: gap * 1.5),
                const SectionHeader(eyebrow: 'What We Offer', title: 'Everything This Service Covers', centered: true),
                SizedBox(height: gap),
                ResponsiveGrid(
                  minItemWidth: 280,
                  maxColumns: 3,
                  spacing: 20,
                  children: [
                    for (final (i, f) in content.offers.indexed)
                      Reveal(
                        delay: Duration(milliseconds: 60 * (i % 3)),
                        child: _OfferCard(feature: f, color: service.color),
                      ),
                  ],
                ),
              ],
            ),
          ),
          SectionShell(
            background: AppColors.surface,
            glowAt: const Alignment(-1.1, -0.4),
            glowStrength: 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Technologies(items: content.technologies, color: service.color),
                SizedBox(height: gap * 1.5),
                const SectionHeader(eyebrow: 'Our Process', title: 'How We Deliver It', centered: true),
                SizedBox(height: gap),
                ResponsiveGrid(
                  minItemWidth: 200,
                  maxColumns: content.process.length,
                  spacing: 16,
                  children: [
                    for (final (i, s) in content.process.indexed)
                      Reveal(
                        delay: Duration(milliseconds: 60 * i),
                        child: _ProcessCard(index: i, step: s),
                      ),
                  ],
                ),
              ],
            ),
          ),
          KeyedSubtree(
            key: _portfolioKey,
            child: SectionShell(
              background: AppColors.background,
              glowAt: const Alignment(1.1, -0.8),
              glowStrength: 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(
                    eyebrow: 'Sample Portfolio',
                    title: '${service.title} Samples',
                    lead:
                        'YODYNIX demo and concept projects that show how we approach this work. '
                        'Projects marked Live Demo open a working demo; concepts are design '
                        'studies without a live build.',
                    centered: true,
                  ),
                  SizedBox(height: gap),
                  ResponsiveGrid(
                    minItemWidth: 340,
                    maxColumns: 2,
                    spacing: 24,
                    children: [
                      for (final (i, p) in content.projects.indexed)
                        Reveal(
                          delay: Duration(milliseconds: 80 * (i % 2)),
                          child: _ProjectCard(project: p, service: service),
                        ),
                    ],
                  ),
                  SizedBox(height: gap * 1.5),
                  _FeaturedProject(project: content.featured, service: service),
                ],
              ),
            ),
          ),
          ServiceProjectCta(service: service, onStart: _startProject),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ Hero

class _Hero extends StatelessWidget {
  const _Hero({required this.service, required this.content, required this.onStart, required this.onPortfolio});

  final ServiceOffering service;
  final ServicePageContent content;
  final VoidCallback onStart;
  final VoidCallback onPortfolio;

  @override
  Widget build(BuildContext context) {
    const tone = SurfaceColors.light;
    final desktop = context.isDesktop;
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(service.title, color: tone.accent),
        const SizedBox(height: 20),
        Semantics(
          header: true,
          child: Text(
            content.heroHeading,
            style: AppTypography.display(
              fontSize: context.responsive(mobile: 32.0, tablet: 42.0, desktop: 50.0),
              color: tone.ink,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          content.heroLead,
          style: AppTypography.body(fontSize: context.responsive(mobile: 16.0, desktop: 18.0), height: 1.7, color: tone.body),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in service.capabilities.take(4)) TagChip(c, color: tone.accent, icon: Icons.check_rounded, filled: true),
          ],
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            PrimaryButton(label: 'Start Your Project', onPressed: onStart),
            SecondaryButton(label: 'View Sample Portfolio', icon: Icons.south_rounded, onPressed: onPortfolio),
          ],
        ),
      ],
    );

    // The service's 3D concept, live, on the same pearl surface as the copy.
    final image = Reveal(
      delay: const Duration(milliseconds: 120),
      child: AspectRatio(
        aspectRatio: desktop ? 5 / 4 : 16 / 11,
        child: Service3DVisual(
          serviceId: service.id,
          background: AppColors.pearlWhite,
          fallback: MediaFrame(
            radius: AppRadius.xl,
            aspectRatio: desktop ? 5 / 4 : 16 / 11,
            child: TintedPhoto(basePath: AssetPaths.service(service.id), semanticLabel: service.imageAlt, strength: 0.5),
          ),
        ),
      ),
    );

    return SectionShell(
      topPadding: context.responsive(mobile: 28.0, desktop: 44.0),
      bottomPadding: context.responsive(mobile: 56.0, desktop: 88.0),
      tone: tone,
      background: AppColors.pearlWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ServiceBreadcrumb(current: service.title),
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
        ],
      ),
    );
  }
}

/// Home › Services › current service, or Home › Services › [service] ›
/// current when a [service] is given (used by demo pages).
class ServiceBreadcrumb extends StatelessWidget {
  const ServiceBreadcrumb({super.key, required this.current, this.service});

  final String current;
  final ServiceOffering? service;

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
            link('Home', Icons.home_outlined, () => goToSection(context, SiteSection.home)),
            separator,
            link('Services', Icons.grid_view_rounded, () => goToSection(context, SiteSection.services)),
            separator,
            if (service case final s?) ...[
              link(s.title, s.icon, () => Navigator.of(context).pushReplacementNamed(s.route)),
              separator,
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                current,
                style: AppTypography.body(fontSize: 13.5, fontWeight: FontWeight.w600, color: context.tone.accent, height: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------- Overview

class _Overview extends StatelessWidget {
  const _Overview({required this.service, required this.content});

  final ServiceOffering service;
  final ServicePageContent content;

  @override
  Widget build(BuildContext context) {
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Service Overview'),
        const SizedBox(height: 18),
        Semantics(
          header: true,
          child: Text(
            service.summary,
            style: AppTypography.display(fontSize: context.responsive(mobile: 24.0, desktop: 30.0), height: 1.3),
          ),
        ),
        const SizedBox(height: 20),
        for (final (i, p) in content.overview.indexed) ...[
          if (i > 0) const SizedBox(height: 14),
          Text(p, style: AppTypography.body(fontSize: 16, height: 1.75)),
        ],
      ],
    );

    final idealFor = Container(
      padding: const EdgeInsets.all(28),
      decoration: CardStyle.decoration(radius: AppRadius.lg),
      child: SurfaceTone(
        colors: SurfaceColors.inCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBadge(icon: service.icon, color: AppColors.accent, size: 44),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Ideal For',
                    style: AppTypography.display(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cardHeading,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CheckList(items: content.idealFor, color: AppColors.accent),
          ],
        ),
      ),
    );

    if (!context.isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(child: text),
          const SizedBox(height: 32),
          Reveal(child: idealFor),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: Reveal(child: text)),
        const SizedBox(width: 56),
        Expanded(
          flex: 5,
          child: Reveal(delay: const Duration(milliseconds: 120), child: idealFor),
        ),
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.feature, required this.color});

  final ServiceFeature feature;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: feature.icon, color: color, size: 46),
          const SizedBox(height: 18),
          Text(
            feature.title,
            style: AppTypography.display(fontSize: 17.5, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.cardHeading),
          ),
          const SizedBox(height: 8),
          Text(feature.description, style: AppTypography.body(fontSize: 14.5, height: 1.6, color: AppColors.cardBody)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------- Technologies

class _Technologies extends StatelessWidget {
  const _Technologies({required this.items, required this.color});

  final List<String> items;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(
          eyebrow: 'Technologies & Tools',
          title: 'The Toolkit Behind The Work',
          lead: 'Proven, well-supported tools chosen for each project’s needs.',
          centered: true,
        ),
        const SizedBox(height: 36),
        Reveal(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [for (final t in items) _ToolPill(label: t)],
          ),
        ),
      ],
    );
  }
}

class _ToolPill extends StatelessWidget {
  const _ToolPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(gradient: AppColors.brandGradient, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppTypography.body(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.ink, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _ProcessCard extends StatelessWidget {
  const _ProcessCard({required this.index, required this.step});

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

// ------------------------------------------------------------- Portfolio

/// "LIVE DEMO" for projects with a working demo, "CONCEPT" otherwise.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.live});

  final bool live;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        // Opaque enough to stay legible over light demo screenshots.
        color: AppColors.deepCharcoal.withValues(alpha: live ? 0.9 : 0.78),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.white.withValues(alpha: live ? 0.24 : 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            live ? Icons.play_circle_outline_rounded : Icons.lightbulb_outline_rounded,
            size: 14,
            color: live ? AppColors.primaryTint : AppColors.cardLine,
          ),
          const SizedBox(width: 6),
          Text(
            live ? 'LIVE DEMO' : 'CONCEPT',
            style: AppTypography.body(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: live ? AppColors.primaryTint : AppColors.cardLine,
              letterSpacing: 1.2,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  const _ProjectCard({required this.project, required this.service});

  final SampleProject project;
  final ServiceOffering service;

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: HoverCard(
        padding: EdgeInsets.zero,
        semanticLabel: p.name,
        onTap: () => showProjectDetails(context, p),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TintedPhoto(
                    basePath: p.image,
                    semanticLabel: p.imageAlt,
                    active: _hover,
                    strength: p.hasDemo ? 0.15 : 0.5,
                    alignment: p.hasDemo ? Alignment.topCenter : Alignment.center,
                  ),
                  Positioned(top: 14, left: 14, child: _StatusBadge(live: p.hasDemo)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.category.toUpperCase(),
                      style: AppTypography.body(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cardAccent,
                        letterSpacing: 1.3,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.name,
                      style: AppTypography.display(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: AppColors.cardHeading,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(p.summary, style: AppTypography.body(fontSize: 14.8, height: 1.6, color: AppColors.cardBody)),
                    const SizedBox(height: 16),
                    Wrap(spacing: 8, runSpacing: 8, children: [for (final t in p.technologies) TagChip(t)]),
                    const Spacer(),
                    const SizedBox(height: 20),
                    _ProjectActions(project: p, compact: true),
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

/// "View Live Demo" (working demos only) and "Project Details". Concepts say
/// plainly that no live demo exists rather than showing a dead link.
class _ProjectActions extends StatelessWidget {
  const _ProjectActions({required this.project, this.compact = false, this.showDetails = true});

  final SampleProject project;
  final bool compact;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    final size = compact ? ButtonSize.small : ButtonSize.medium;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (project.hasDemo)
          PrimaryButton(
            label: 'View Live Demo',
            icon: Icons.open_in_new_rounded,
            size: size,
            onPressed: () => Navigator.of(context).pushNamed(project.demoRoute!),
          ),
        if (showDetails)
          SecondaryButton(
            label: 'View Project Details',
            icon: Icons.article_outlined,
            size: size,
            onPressed: () => showProjectDetails(context, project),
          ),
        if (!project.hasDemo)
          Text(
            'Concept · no live demo yet',
            style: AppTypography.body(fontSize: 12.5, fontWeight: FontWeight.w600, color: context.tone.muted, height: 1.3),
          ),
      ],
    );
  }
}

/// Full details of a sample project in a dialog.
void showProjectDetails(BuildContext context, SampleProject project) {
  showSiteDialog<void>(
    context,
    maxWidth: 760,
    builder: (dialogContext) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 16 / 8,
          child: Stack(
            fit: StackFit.expand,
            children: [
              TintedPhoto(
                basePath: project.image,
                semanticLabel: project.imageAlt,
                strength: project.hasDemo ? 0.1 : 0.4,
                alignment: project.hasDemo ? Alignment.topCenter : Alignment.center,
              ),
              Positioned(left: 20, bottom: 18, child: _StatusBadge(live: project.hasDemo)),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(dialogContext.responsive(mobile: 22.0, desktop: 32.0)),
          child: _ProjectDetailsBody(project: project, inDialog: true),
        ),
      ],
    ),
  );
}

class _ProjectDetailsBody extends StatelessWidget {
  const _ProjectDetailsBody({required this.project, this.inDialog = false});

  final SampleProject project;
  final bool inDialog;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project.category.toUpperCase(),
          style: AppTypography.body(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: context.tone.accent,
            letterSpacing: 1.3,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Semantics(
          header: true,
          child: Text(
            project.name,
            style: AppTypography.display(
              fontSize: inDialog ? 26 : context.responsive(mobile: 26.0, desktop: 32.0),
              color: context.tone.ink,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(project.overview, style: AppTypography.body(fontSize: 15.5, height: 1.7, color: context.tone.body)),
        const SizedBox(height: 22),
        Text(
          'Key Features',
          style: AppTypography.body(fontSize: 14, fontWeight: FontWeight.w700, color: context.tone.ink, height: 1.3),
        ),
        const SizedBox(height: 12),
        CheckList(items: project.features, color: context.tone.accent, columns: context.isMobile ? 1 : 2),
        const SizedBox(height: 22),
        Text(
          'Technologies',
          style: AppTypography.body(fontSize: 14, fontWeight: FontWeight.w700, color: context.tone.ink, height: 1.3),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final t in project.technologies) TagChip(t, color: context.tone.accent, filled: true)],
        ),
        const SizedBox(height: 22),
        _SampleNotice(project: project),
        if (project.hasDemo) ...[const SizedBox(height: 22), _ProjectActions(project: project, showDetails: false)],
      ],
    );
  }
}

class _SampleNotice extends StatelessWidget {
  const _SampleNotice({required this.project});

  final SampleProject project;

  @override
  Widget build(BuildContext context) {
    final text = project.hasDemo
        ? 'A YODYNIX sample project with a working demo built for this site. It is not client work, '
              'and demo data stays in your browser.'
        : 'A YODYNIX concept project used to illustrate our approach. It is not client work and does '
              'not have a live demo yet.';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: context.tone.ink),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: AppTypography.body(fontSize: 13.5, color: context.tone.body, height: 1.55)),
          ),
        ],
      ),
    );
  }
}

/// "Project Details" band featuring the service's working demo.
class _FeaturedProject extends StatelessWidget {
  const _FeaturedProject({required this.project, required this.service});

  final SampleProject project;
  final ServiceOffering service;

  @override
  Widget build(BuildContext context) {
    final screenshot = AssetRegistry.instance.resolve(project.image);
    // Working demos are shown on a 3D laptop using their real screenshot;
    // concepts keep a flat image so they never read as shipped products.
    final Widget image = project.hasDemo && screenshot != null
        ? AspectRatio(
            aspectRatio: 16 / 11,
            child: Portfolio3DPreview(
              imageAsset: screenshot,
              semanticLabel: '${project.imageAlt} Shown on a laptop screen.',
            ),
          )
        : MediaFrame(
            radius: AppRadius.xl,
            aspectRatio: 16 / 10,
            child: TintedPhoto(
              basePath: project.image,
              semanticLabel: project.imageAlt,
              strength: project.hasDemo ? 0.1 : 0.4,
              alignment: project.hasDemo ? Alignment.topCenter : Alignment.center,
            ),
          );
    final details = _ProjectDetailsBody(project: project);

    return Reveal(
      child: Container(
        padding: EdgeInsets.all(context.responsive(mobile: 20.0, desktop: 40.0)),
        decoration: CardStyle.decoration(radius: AppRadius.xl),
        child: SurfaceTone(
          colors: SurfaceColors.inCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(alignment: Alignment.centerLeft, child: Eyebrow('Project Details')),
              const SizedBox(height: 24),
              if (context.isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 11, child: image),
                    const SizedBox(width: 44),
                    Expanded(flex: 10, child: details),
                  ],
                )
              else ...[
                image,
                const SizedBox(height: 28),
                details,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------- CTA

/// "Start Your Project" band plus links to the other services.
class ServiceProjectCta extends StatelessWidget {
  const ServiceProjectCta({super.key, required this.service, required this.onStart});

  final ServiceOffering service;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final others = ServicesContent.services.where((s) => s.id != service.id).toList();
    return SectionShell(
      background: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(
            child: Container(
              padding: EdgeInsets.all(context.responsive(mobile: 28.0, desktop: 56.0)),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.charcoal, AppColors.deepCharcoal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.charcoal.withValues(alpha: 0.22),
                    blurRadius: 60,
                    spreadRadius: -12,
                    offset: const Offset(0, 24),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'START YOUR PROJECT',
                    textAlign: TextAlign.center,
                    style: AppTypography.body(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryTint,
                      letterSpacing: 1.6,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Ready to plan your ${service.title.toLowerCase()} project?',
                    textAlign: TextAlign.center,
                    style: AppTypography.display(
                      fontSize: context.responsive(mobile: 26.0, desktop: 38.0),
                      color: AppColors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Text(
                      'Tell us what you have in mind. We will reply with clear next steps, a suggested '
                      'approach and an honest estimate.',
                      textAlign: TextAlign.center,
                      style: AppTypography.body(fontSize: 16, color: AppColors.onDarkBody, height: 1.65),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _CtaButton(label: 'Start Your Project', onPressed: onStart),
                ],
              ),
            ),
          ),
          const SizedBox(height: 56),
          Text(
            'EXPLORE OTHER SERVICES',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
              letterSpacing: 1.6,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [for (final s in others) _ServiceLink(service: s)],
          ),
        ],
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  const _CtaButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      iconAlignment: IconAlignment.end,
      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        shape: const StadiumBorder(),
        textStyle: AppTypography.body(fontSize: 15.5, fontWeight: FontWeight.w700, height: 1.2),
      ),
    );
  }
}

class _ServiceLink extends StatefulWidget {
  const _ServiceLink({required this.service});

  final ServiceOffering service;

  @override
  State<_ServiceLink> createState() => _ServiceLinkState();
}

class _ServiceLinkState extends State<_ServiceLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    return Semantics(
      button: true,
      label: s.title,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: () => openServicePage(context, s),
          child: AnimatedContainer(
            duration: AppMotion.hover,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: _hover ? AppColors.primarySoft : AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.accent.withValues(alpha: _hover ? 0.6 : 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(s.icon, size: 17, color: _hover ? AppColors.accent : AppColors.charcoal),
                const SizedBox(width: 8),
                Text(
                  s.title,
                  style: AppTypography.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _hover ? AppColors.accent : AppColors.ink,
                    height: 1.2,
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
