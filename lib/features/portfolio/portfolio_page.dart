import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../models/content_models.dart';
import '../../models/service_page.dart';
import '../../models/site_section.dart';
import '../../repositories/content/industries_content.dart';
import '../../repositories/content/service_pages_content.dart';
import '../../repositories/content/services_content.dart';
import '../../services/asset_registry.dart';
import '../../shared/layouts/navigation_actions.dart';
import '../../shared/layouts/subpage_scaffold.dart';
import '../../shared/three/scene_widgets.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';
import '../../shared/widgets/tinted_photo.dart';
import '../industries/industries_page.dart' show PlaceholderNotice;

/// A sample project with the service it belongs to.
typedef _Entry = ({SampleProject project, ServiceOffering service});

/// `/portfolio`: every demonstration project from the service pages, with a
/// category filter and an interactive 3D presentation of the selected one.
/// Nothing here is presented as client work.
class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  static final List<_Entry> _entries = [
    for (final service in ServicesContent.services)
      for (final project in ServicePagesContent.of(service).projects) (project: project, service: service),
  ];

  String? _filter; // service id; null shows all
  late _Entry _selected = _entries.firstWhere((e) => e.project.hasDemo, orElse: () => _entries.first);
  final _viewerKey = GlobalKey();

  List<_Entry> get _visible => _filter == null ? _entries : _entries.where((e) => e.service.id == _filter).toList();

  void _select(_Entry entry) {
    setState(() => _selected = entry);
    final ctx = _viewerKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: AppMotion.reveal, curve: Curves.easeInOutCubic, alignment: 0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = [
      for (final s in ServicesContent.services)
        if (_entries.any((e) => e.service.id == s.id)) s,
    ];
    return SubpageScaffold(
      title: 'Portfolio',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionShell(
            background: AppColors.pearlWhite,
            topPadding: context.responsive(mobile: 36.0, desktop: 64.0),
            bottomPadding: context.responsive(mobile: 32.0, desktop: 48.0),
            glowAt: const Alignment(-0.6, -0.6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(
                  eyebrow: 'Portfolio',
                  title: PortfolioContent.heading,
                  lead: PortfolioContent.lead,
                  centered: true,
                ),
                const SizedBox(height: 20),
                const Center(child: _DemoNotice()),
                if (PortfolioContent.isPlaceholder) ...[const SizedBox(height: 10), const Center(child: PlaceholderNotice())],
                const SizedBox(height: 40),
                KeyedSubtree(
                  key: _viewerKey,
                  child: _Viewer(entry: _selected),
                ),
              ],
            ),
          ),
          SectionShell(
            background: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChip(label: 'All', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                    for (final s in services)
                      _FilterChip(label: s.title, selected: _filter == s.id, onTap: () => setState(() => _filter = s.id)),
                  ],
                ),
                const SizedBox(height: 32),
                AnimatedSwitcher(
                  duration: AppMotion.lift,
                  child: ResponsiveGrid(
                    key: ValueKey(_filter),
                    minItemWidth: 280,
                    maxColumns: 3,
                    spacing: 20,
                    children: [
                      for (final (i, e) in _visible.indexed)
                        Reveal(
                          delay: Duration(milliseconds: 50 * (i % 3)),
                          child: _ProjectCard(entry: e, selected: identical(e, _selected), onTap: () => _select(e)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SectionShell(
            background: AppColors.pearlWhite,
            child: Column(
              children: [
                const SectionHeader(
                  eyebrow: 'Client Work',
                  title: PortfolioContent.clientWorkHeading,
                  lead: PortfolioContent.clientWorkBody,
                  centered: true,
                ),
                const SizedBox(height: 28),
                PrimaryButton(label: 'Start Your Project', onPressed: () => goToSection(context, SiteSection.contact)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The states every visitor must see: these are demonstrations, not clients.
class _DemoNotice extends StatelessWidget {
  const _DemoNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.accent),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'All projects shown are demonstration projects built by YODYNIX, not client work.',
              style: AppTypography.body(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// Selected project: on a 3D laptop when it has a working demo, as a flat
/// image when it is a concept.
class _Viewer extends StatelessWidget {
  const _Viewer({required this.entry});

  final _Entry entry;

  @override
  Widget build(BuildContext context) {
    final project = entry.project;
    final screenshot = AssetRegistry.instance.resolve(project.image);
    final visual = project.hasDemo && screenshot != null
        ? AspectRatio(
            aspectRatio: 16 / 11,
            child: Portfolio3DPreview(
              imageAsset: screenshot,
              background: AppColors.pearlWhite,
              semanticLabel: '${project.imageAlt} Shown on a laptop screen.',
            ),
          )
        : MediaFrame(
            radius: AppRadius.xl,
            aspectRatio: 16 / 10,
            child: TintedPhoto(basePath: project.image, semanticLabel: project.imageAlt, strength: 0.3),
          );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Badge(project.hasDemo ? 'Working demo' : 'Concept'),
        const SizedBox(height: 14),
        Text(
          project.category.toUpperCase(),
          style: AppTypography.body(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
          ).copyWith(letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text(
            project.name,
            style: AppTypography.display(fontSize: context.responsive(mobile: 26.0, desktop: 34.0), color: AppColors.ink),
          ),
        ),
        const SizedBox(height: 14),
        Text(project.overview, style: AppTypography.body(fontSize: 15.5, height: 1.7, color: AppColors.body)),
        const SizedBox(height: 18),
        for (final f in project.features.take(4))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Icon(Icons.check_rounded, size: 16, color: AppColors.accent),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(f, style: AppTypography.body(fontSize: 14.5, color: AppColors.ink)),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Wrap(spacing: 6, runSpacing: 6, children: [for (final t in project.technologies) _Badge(t, quiet: true)]),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (project.demoRoute != null)
              PrimaryButton(label: 'Open Live Demo', onPressed: () => Navigator.of(context).pushNamed(project.demoRoute!)),
            SecondaryButton(
              label: entry.service.title,
              icon: Icons.arrow_forward_rounded,
              onPressed: () => openServicePage(context, entry.service),
            ),
          ],
        ),
      ],
    );

    return AnimatedSwitcher(
      duration: AppMotion.lift,
      child: Container(
        key: ValueKey(project.id),
        padding: EdgeInsets.all(context.responsive(mobile: 20.0, desktop: 36.0)),
        decoration: CardStyle.decoration(radius: AppRadius.xl),
        child: context.isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 11, child: visual),
                  const SizedBox(width: 40),
                  Expanded(flex: 9, child: details),
                ],
              )
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [visual, const SizedBox(height: 24), details]),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.entry, required this.selected, required this.onTap});

  final _Entry entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = entry.project;
    return HoverCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      semanticLabel: 'View ${p.name}, a demonstration ${p.category.toLowerCase()}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              MediaFrame(
                radius: AppRadius.md,
                aspectRatio: 16 / 10,
                child: TintedPhoto(
                  basePath: p.image,
                  semanticLabel: p.imageAlt,
                  strength: p.hasDemo ? 0.1 : 0.35,
                  alignment: Alignment.topCenter,
                ),
              ),
              Positioned(left: 10, top: 10, child: _Badge(p.hasDemo ? 'Working demo' : 'Concept')),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            p.category,
            style: AppTypography.body(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.accent),
          ),
          const SizedBox(height: 4),
          Text(
            p.name,
            style: AppTypography.display(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
          const SizedBox(height: 8),
          Text(
            p.summary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body(fontSize: 14, color: AppColors.body),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                selected ? 'Showing above' : 'View project',
                style: AppTypography.body(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.accent),
              ),
              const SizedBox(width: 6),
              Icon(selected ? Icons.visibility_outlined : Icons.north_rounded, size: 16, color: AppColors.accent),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: AppColors.champagneGold,
      backgroundColor: AppColors.white,
      labelStyle: AppTypography.body(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: selected ? AppColors.onPrimary : AppColors.ink,
      ),
      side: BorderSide(color: selected ? AppColors.champagneGold : AppColors.cardBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text, {this.quiet = false});

  final String text;
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: quiet ? AppColors.cardField : AppColors.goldWash,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: quiet ? AppColors.cardBorder : AppColors.goldLine),
      ),
      child: Text(
        text,
        style: AppTypography.body(fontSize: 12, fontWeight: FontWeight.w600, color: quiet ? AppColors.body : AppColors.accent),
      ),
    );
  }
}
