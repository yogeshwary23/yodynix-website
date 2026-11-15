import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../models/content_models.dart';
import '../../repositories/content/services_content.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';
import '../../shared/layouts/navigation_actions.dart';
import '../../shared/widgets/tinted_photo.dart';

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  static const _spacing = 24.0;
  static const _minCard = 330.0;

  @override
  Widget build(BuildContext context) {
    const services = ServicesContent.services;
    return SectionShell(
      background: AppColors.background,
      glowAt: const Alignment(1.1, -0.9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            eyebrow: 'Our Services',
            title: ServicesContent.heading,
            lead: ServicesContent.lead,
            centered: true,
          ),
          const SizedBox(height: 56),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = ((constraints.maxWidth + _spacing) / (_minCard + _spacing)).floor().clamp(1, 3);
              // Balance ten services across the grid: wide feature cards absorb
              // the remainder so no row is left with a lone card.
              final List<ServiceOffering> wideTop;
              final List<ServiceOffering> grid;
              final List<ServiceOffering> wideBottom;
              if (columns == 3) {
                wideTop = const [];
                grid = services.sublist(0, 9);
                wideBottom = [services[9]];
              } else if (columns == 2) {
                wideTop = [services[0]];
                grid = services.sublist(1, 9);
                wideBottom = [services[9]];
              } else {
                wideTop = const [];
                grid = services;
                wideBottom = const [];
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final s in wideTop) ...[Reveal(child: _WideServiceCard(service: s)), const SizedBox(height: _spacing)],
                  ResponsiveGrid(
                    minItemWidth: _minCard,
                    maxColumns: 3,
                    spacing: _spacing,
                    children: [
                      for (final (i, s) in grid.indexed)
                        Reveal(
                          delay: Duration(milliseconds: 70 * (i % columns)),
                          child: _ServiceCard(service: s),
                        ),
                    ],
                  ),
                  for (final s in wideBottom) ...[const SizedBox(height: _spacing), Reveal(child: _WideServiceCard(service: s))],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Tracks hover for a service card so its photograph can respond.
class _HoverScope extends StatefulWidget {
  const _HoverScope({required this.builder});

  final Widget Function(bool hover) builder;

  @override
  State<_HoverScope> createState() => _HoverScopeState();
}

class _HoverScopeState extends State<_HoverScope> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: widget.builder(_hover),
    );
  }
}

/// The service's photograph with its icon badge in the corner.
class _ServicePhoto extends StatelessWidget {
  const _ServicePhoto({required this.service, required this.active});

  final ServiceOffering service;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        TintedPhoto(basePath: AssetPaths.service(service.id), semanticLabel: service.imageAlt, active: active, strength: 0.7),
        Positioned(
          left: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.deepNavy.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.cardLine),
            ),
            child: Icon(service.icon, size: 20, color: AppColors.cardAccent),
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});

  final ServiceOffering service;

  @override
  Widget build(BuildContext context) {
    return _HoverScope(
      builder: (hover) => HoverCard(
        padding: EdgeInsets.zero,
        semanticLabel: service.title,
        onTap: () => openServicePage(context, service),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 3 / 2,
              child: _ServicePhoto(service: service, active: hover),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
                child: _ServiceCardBody(service: service),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WideServiceCard extends StatelessWidget {
  const _WideServiceCard({required this.service});

  final ServiceOffering service;

  @override
  Widget build(BuildContext context) {
    return _HoverScope(
      builder: (hover) => HoverCard(
        padding: EdgeInsets.zero,
        semanticLabel: service.title,
        onTap: () => openServicePage(context, service),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: AspectRatio(
                  aspectRatio: 3 / 2,
                  child: _ServicePhoto(service: service, active: hover),
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: EdgeInsets.all(context.responsive(mobile: 24.0, desktop: 40.0)),
                  child: _ServiceCardBody(service: service, wide: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCardBody extends StatelessWidget {
  const _ServiceCardBody({required this.service, this.wide = false});

  final ServiceOffering service;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final shown = wide ? service.capabilities.length : 3;
    final remaining = service.capabilities.length - shown;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          service.title,
          style: AppTypography.display(
            fontSize: wide ? 22 : 18.5,
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: AppColors.cardHeading,
          ),
        ),
        const SizedBox(height: 14),
        Text(wide ? service.description : service.summary, style: AppTypography.body(fontSize: 14.8, color: AppColors.cardBody)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in service.capabilities.take(shown)) TagChip(c),
            if (remaining > 0) TagChip('+$remaining more', color: AppColors.cardAccent, filled: true),
          ],
        ),
        if (!wide) const Spacer(),
        const SizedBox(height: 18),
        ArrowLink(label: 'Explore service', color: AppColors.cardAccent, onPressed: () => openServicePage(context, service)),
      ],
    );
  }
}
