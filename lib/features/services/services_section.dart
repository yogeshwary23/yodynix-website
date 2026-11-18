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
import '../../shared/three/mobile_3d_fallback.dart';
import '../../shared/three/scene_widgets.dart';
import '../../shared/widgets/tinted_photo.dart';
import 'service_stage.dart';

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
          const Reveal(child: ServiceStage()),
          SizedBox(height: context.responsive(mobile: 56.0, desktop: 88.0)),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = ((constraints.maxWidth + _spacing) / (_minCard + _spacing)).floor().clamp(1, 3);
              // Balance the services across the grid: a wide feature card
              // absorbs a remainder of one, so no row is left with a lone card
              // (nine services fill three columns exactly).
              final List<ServiceOffering> wideTop = columns > 1 && services.length % columns == 1 ? [services.first] : const [];
              final grid = services.sublist(wideTop.length);
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

/// The service's 3D concept (a still render from the engine) with its icon
/// badge in the corner. The image eases up slightly on hover.
class _ServicePhoto extends StatelessWidget {
  const _ServicePhoto({required this.service, required this.active});

  final ServiceOffering service;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: AppColors.white,
          child: Semantics(
            label: service.imageAlt,
            image: true,
            child: AnimatedScale(
              scale: active ? 1.05 : 1,
              duration: AppMotion.lift,
              curve: AppMotion.ease,
              child: Mobile3DFallback(
                scene: Service3DVisual.sceneFor(service.id),
                variant: Service3DVisual.variantFor(service.id),
                fallback: TintedPhoto(basePath: AssetPaths.service(service.id), semanticLabel: service.imageAlt, active: active, strength: 0.7),
              ),
            ),
          ),
        ),
        const Positioned(left: 0, right: 0, bottom: 0, child: Divider(height: 1, color: AppColors.cardLine)),
        Positioned(
          left: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.cardTile,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.goldLine),
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
