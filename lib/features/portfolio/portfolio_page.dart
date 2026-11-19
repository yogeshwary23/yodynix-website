import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../models/content_models.dart';
import '../../models/service_page.dart';
import '../../models/site_section.dart';
import '../../repositories/content/portfolio_content.dart';
import '../../repositories/content/service_pages_content.dart';
import '../../repositories/content/services_content.dart';
import '../../services/asset_registry.dart';
import '../../shared/layouts/navigation_actions.dart';
import '../../shared/layouts/subpage_scaffold.dart';
import '../../shared/three/interactive_3d_object.dart';
import '../../shared/three/scene3d.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/premium.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';
import '../../shared/widgets/smart_image.dart';
import 'portfolio_widgets.dart';

/// A sample project with the service it belongs to.
typedef _Entry = ({SampleProject project, ServiceOffering service});

/// Which projects the gallery shows by status.
enum _Status { all, demo, concept }

/// `/portfolio`: every demonstration project from the service pages, each on
/// its own 3D device, filtered by area and status. Each card opens the
/// project's page (`/portfolio/<slug>`). Nothing here is presented as client
/// work.
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

  int _filter = 0; // index into PortfolioContent.filters
  _Status _status = _Status.all;

  List<_Entry> get _visible {
    final services = PortfolioContent.filters[_filter].$2;
    return [
      for (final e in _entries)
        if ((services.isEmpty || services.contains(e.service.id)) &&
            (_status == _Status.all || (_status == _Status.demo) == e.project.hasDemo))
          e,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final demos = _entries.where((e) => e.project.hasDemo).length;
    final areas = {for (final e in _entries) e.service.id}.length;
    final visible = _visible;
    return SubpageScaffold(
      title: 'Portfolio',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Hero(
            demos: demos,
            concepts: _entries.length - demos,
            areas: areas,
            showcase: [
              for (final id in const ['lumen_dental', 'fitslot', 'weave_and_co'])
                _entries.firstWhere((e) => e.project.id == id).project,
            ],
          ),
          SectionShell(
            background: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(
                  eyebrow: 'Explore the Collection',
                  title: 'Every Demonstration Project',
                  lead: 'Choose an area, then open any project to see its objective, challenge, proposed solution and key features.',
                  centered: true,
                ),
                const SizedBox(height: 32),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (i, (label, _)) in PortfolioContent.filters.indexed)
                      _Pill(label: label, selected: _filter == i, onTap: () => setState(() => _filter = i)),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: _StatusToggle(value: _status, onChanged: (s) => setState(() => _status = s)),
                ),
                const SizedBox(height: 14),
                Text(
                  '${visible.length} ${visible.length == 1 ? 'project' : 'projects'}',
                  textAlign: TextAlign.center,
                  style: AppTypography.body(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.muted),
                ),
                const SizedBox(height: 28),
                AnimatedSwitcher(
                  duration: AppMotion.lift,
                  child: visible.isEmpty
                      ? Padding(
                          key: const ValueKey('empty'),
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            'No projects match these filters yet.',
                            textAlign: TextAlign.center,
                            style: AppTypography.body(fontSize: 15, color: AppColors.muted),
                          ),
                        )
                      : ResponsiveGrid(
                          key: ValueKey('$_filter-$_status'),
                          minItemWidth: 300,
                          maxColumns: 3,
                          spacing: 24,
                          children: [
                            for (final (i, e) in visible.indexed)
                              Reveal(
                                delay: Duration(milliseconds: 70 * (i % 3)),
                                child: ProjectCard(project: e.project),
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
                  eyebrow: 'Start a Project',
                  title: PortfolioContent.closingHeading,
                  lead: PortfolioContent.closingBody,
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

/// Headline, disclosure and counted figures beside a laptop, phone and
/// tablet floating in studio light, each showing a real demo screenshot.
class _Hero extends StatelessWidget {
  const _Hero({required this.demos, required this.concepts, required this.areas, required this.showcase});

  final int demos;
  final int concepts;
  final int areas;

  /// Laptop, phone and tablet, in that order.
  final List<SampleProject> showcase;

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktop;
    final copy = Column(
      crossAxisAlignment: desktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        const Reveal(child: RuleEyebrow(PortfolioContent.eyebrow)),
        const SizedBox(height: 22),
        Reveal(
          delay: const Duration(milliseconds: 80),
          child: GoldHighlightHeading(
            heading: PortfolioContent.heading,
            highlight: PortfolioContent.headingHighlight,
            textAlign: desktop ? TextAlign.start : TextAlign.center,
            style: AppTypography.display(fontSize: context.responsive(mobile: 34.0, tablet: 46.0, desktop: 58.0), height: 1.08),
          ),
        ),
        const SizedBox(height: 22),
        Reveal(
          delay: const Duration(milliseconds: 160),
          child: Text(
            PortfolioContent.lead,
            textAlign: desktop ? TextAlign.start : TextAlign.center,
            style: AppTypography.body(fontSize: context.responsive(mobile: 16.0, desktop: 18.5), height: 1.75, color: AppColors.body),
          ),
        ),
        const SizedBox(height: 26),
        Reveal(delay: const Duration(milliseconds: 220), child: _Stats(demos: demos, concepts: concepts, areas: areas, centered: !desktop)),
        const SizedBox(height: 26),
        const Reveal(delay: Duration(milliseconds: 280), child: _Disclosure()),
      ],
    );
    final specs = [for (final p in showcase) p.screenSpec ?? ''];
    final visual = Reveal(
      delay: const Duration(milliseconds: 120),
      child: AspectRatio(
        aspectRatio: 1.4,
        child: Interactive3DObject(
          scene: Scene3D.device,
          variant: 'hero',
          image: specs.join('|'),
          background: null,
          semanticLabel: 'Three YODYNIX working demos, ${showcase.map((p) => p.name).join(', ')}, shown on a laptop, a phone and a tablet.',
          fallback: switch (AssetRegistry.instance.resolve(AssetPaths.render('device_hero'))) {
            final still? => LazyAssetImage(
              path: still,
              semanticLabel: 'YODYNIX working demos shown on a laptop, a phone and a tablet.',
              fit: BoxFit.contain,
            ),
            null => const SizedBox.shrink(),
          },
        ),
      ),
    );
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.pearlWhite, Color(0xFFF6F0E5), Color(0xFFEFE5D4)],
        ),
      ),
      child: Stack(
        children: [
          // Key light falling across the devices.
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.55, -0.35),
                    radius: 0.9,
                    colors: [Color(0xCCFFFFFF), Color(0x00FFFFFF)],
                  ),
                ),
              ),
            ),
          ),
          SectionShell(
            background: Colors.transparent,
            topPadding: context.responsive(mobile: 32.0, desktop: 64.0),
            bottomPadding: context.responsive(mobile: 40.0, desktop: 72.0),
            child: desktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 10, child: copy),
                      const SizedBox(width: 40),
                      Expanded(flex: 11, child: visual),
                    ],
                  )
                : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [copy, const SizedBox(height: 28), visual]),
          ),
        ],
      ),
    );
  }
}

/// The statement every visitor must see: these are demonstrations, not
/// client engagements.
class _Disclosure extends StatelessWidget {
  const _Disclosure();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 620),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.goldLine),
        boxShadow: AppColors.softShadow(0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.info_outline_rounded, size: 17, color: AppColors.accent),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              PortfolioContent.disclosure,
              style: AppTypography.body(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.ink, height: 1.55),
            ),
          ),
        ],
      ),
    );
  }
}

/// Counts taken from the project data itself, counted up on first view.
class _Stats extends StatelessWidget {
  const _Stats({required this.demos, required this.concepts, required this.areas, required this.centered});

  final int demos;
  final int concepts;
  final int areas;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final items = [(demos, 'Working demos'), (concepts, 'Concept projects'), (areas, 'Service areas')];
    return Wrap(
      alignment: centered ? WrapAlignment.center : WrapAlignment.start,
      spacing: context.responsive(mobile: 28.0, desktop: 48.0),
      runSpacing: 16,
      children: [
        for (final (value, label) in items)
          Semantics(
            label: '$value $label',
            child: ExcludeSemantics(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                children: [
                  CountUp(
                    value: value,
                    style: AppTypography.display(fontSize: context.responsive(mobile: 32.0, desktop: 44.0), fontWeight: FontWeight.w800, height: 1),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label.toUpperCase(),
                    style: AppTypography.body(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// A category filter.
class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: AppMotion.hover,
            curve: AppMotion.ease,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              gradient: selected ? AppColors.buttonGold : null,
              color: selected ? null : AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: selected ? AppColors.champagneGold : AppColors.cardBorder),
              boxShadow: selected ? AppColors.glowShadow() : null,
            ),
            child: Text(
              label,
              style: AppTypography.body(fontSize: 14, fontWeight: FontWeight.w700, color: selected ? AppColors.onPrimary : AppColors.ink, height: 1.2),
            ),
          ),
        ),
      ),
    );
  }
}

/// All / Working demos / Concepts, as a quiet segmented control.
class _StatusToggle extends StatelessWidget {
  const _StatusToggle({required this.value, required this.onChanged});

  final _Status value;
  final ValueChanged<_Status> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (status, label) in const [
            (_Status.all, 'All projects'),
            (_Status.demo, 'Working demos'),
            (_Status.concept, 'Concepts'),
          ])
            Semantics(
              button: true,
              selected: value == status,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onChanged(status),
                  child: AnimatedContainer(
                    duration: AppMotion.hover,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: value == status ? AppColors.goldWash : null,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: value == status ? AppColors.goldLine : Colors.transparent),
                    ),
                    child: Text(
                      label,
                      style: AppTypography.body(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: value == status ? AppColors.accentDeep : AppColors.slate,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
