import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../models/site_section.dart';
import '../../repositories/content/our_work_content.dart';
import '../../services/link_service.dart';
import '../../shared/layouts/navigation_actions.dart';
import '../../shared/layouts/subpage_scaffold.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/section_widgets.dart';

/// `/our-work`: websites and software built for clients, each with a
/// screenshot, a badge saying how it is presented (live, client preview,
/// private client software, or a YODYNIX demo) and a link to open it.
class OurWorkPage extends StatefulWidget {
  const OurWorkPage({super.key});

  @override
  State<OurWorkPage> createState() => _OurWorkPageState();
}

class _OurWorkPageState extends State<OurWorkPage> {
  String _area = OurWorkContent.areas.first;

  List<ClientWork> get _visible => [
    for (final p in OurWorkContent.projects)
      if (_area == OurWorkContent.areas.first || p.area == _area) p,
  ];

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return SubpageScaffold(
      title: 'Our Work',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionShell(
            background: AppColors.pearlWhite,
            topPadding: context.responsive(mobile: 36.0, desktop: 64.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(
                  eyebrow: OurWorkContent.eyebrow,
                  title: OurWorkContent.heading,
                  lead: OurWorkContent.lead,
                  centered: true,
                ),
                const SizedBox(height: 32),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final area in OurWorkContent.areas)
                      _FilterPill(label: area, selected: _area == area, onTap: () => setState(() => _area = area)),
                  ],
                ),
                const SizedBox(height: 28),
                AnimatedSwitcher(
                  duration: AppMotion.lift,
                  child: ResponsiveGrid(
                    key: ValueKey(_area),
                    minItemWidth: 320,
                    maxColumns: 3,
                    spacing: 24,
                    // No per-card Reveal: a filter change swaps in a new grid
                    // that must show at once, and the switcher fades it in.
                    children: [for (final p in visible) _WorkCard(project: p)],
                  ),
                ),
                const SizedBox(height: 48),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Want your business on this page next?',
                        textAlign: TextAlign.center,
                        style: AppTypography.display(fontSize: context.responsive(mobile: 22.0, desktop: 28.0)),
                      ),
                      const SizedBox(height: 18),
                      PrimaryButton(
                        label: 'Start Your Project',
                        onPressed: () => goToSection(context, SiteSection.contact),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkCard extends StatelessWidget {
  const _WorkCard({required this.project});

  final ClientWork project;

  void _open(BuildContext context) {
    final url = project.url;
    final route = project.route;
    if (url != null) {
      LinkService.open(url);
    } else if (route != null) {
      openRoute(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = project;
    final opens = p.url != null || p.route != null;
    final image = p.image;
    final meta = [p.industry, ?p.location].join('  ·  ').toUpperCase();
    final (String ctaLabel, IconData ctaIcon) = p.url != null
        ? ('Visit Website', Icons.open_in_new_rounded)
        : p.route != null
        ? ('Try Live Demo', Icons.arrow_forward_rounded)
        : ('Private software · sign-in required', Icons.lock_outline_rounded);

    return HoverCard(
      padding: EdgeInsets.zero,
      onTap: opens ? () => _open(context) : null,
      semanticLabel: '${p.name}, ${p.type}. ${p.badge.label}.${opens ? ' $ctaLabel.' : ''}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (image != null)
                  Image.asset(
                    image,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    cacheWidth: 800,
                    semanticLabel: 'Screenshot of ${p.name}',
                  )
                else
                  _Placeholder(icon: p.icon),
                Positioned(left: 14, top: 14, child: _Badge(badge: p.badge)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meta,
                  style: AppTypography.body(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cardAccent,
                    letterSpacing: 1.2,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(p.name, style: AppTypography.display(fontSize: 21, color: AppColors.cardHeading, height: 1.25)),
                const SizedBox(height: 4),
                Text(
                  p.type,
                  style: AppTypography.body(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.cardMuted, height: 1.3),
                ),
                const SizedBox(height: 12),
                Text(p.summary, style: AppTypography.body(fontSize: 14.5, color: AppColors.cardBody, height: 1.65)),
                const SizedBox(height: 14),
                Wrap(spacing: 6, runSpacing: 6, children: [for (final f in p.features) TagChip(f)]),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        ctaLabel,
                        style: AppTypography.body(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: opens ? AppColors.cardAccent : AppColors.cardMuted,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(ctaIcon, size: 16, color: opens ? AppColors.cardAccent : AppColors.cardMuted),
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

class _Badge extends StatelessWidget {
  const _Badge({required this.badge});

  final WorkBadge badge;

  @override
  Widget build(BuildContext context) {
    final (Color fill, Color ink) = switch (badge) {
      WorkBadge.live => (const Color(0xFF2E6B3F), AppColors.white),
      WorkBadge.preview => (AppColors.champagneGold, AppColors.onPrimary),
      WorkBadge.private => (AppColors.charcoal, AppColors.white),
      WorkBadge.ourDemo => (AppColors.white, AppColors.goldInk),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: badge == WorkBadge.ourDemo ? Border.all(color: AppColors.goldLine) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge == WorkBadge.live) ...[
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(color: Color(0xFF9BE3A9), shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            badge.label.toUpperCase(),
            style: AppTypography.body(fontSize: 10.5, fontWeight: FontWeight.w700, color: ink, letterSpacing: 1, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.goldWash,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: AppColors.goldInk),
          const SizedBox(height: 10),
          Text(
            'Screens shared on request',
            style: AppTypography.body(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.goldInk, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, required this.selected, required this.onTap});

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
            ),
            child: Text(
              label,
              style: AppTypography.body(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.onPrimary : AppColors.ink,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
