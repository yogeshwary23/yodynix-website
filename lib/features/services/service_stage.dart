import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../models/content_models.dart';
import '../../repositories/content/services_content.dart';
import '../../shared/layouts/navigation_actions.dart';
import '../../shared/three/scene_widgets.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/smart_image.dart';
import '../../shared/widgets/visuals/visual_kind.dart';
import '../../core/constants/asset_paths.dart';

/// A single live 3D stage for the six core service concepts. Choosing a
/// concept cross-fades the stage to its scene; the description stays in
/// plain text beside it so the visual supports, never replaces, the copy.
class ServiceStage extends StatefulWidget {
  const ServiceStage({super.key});

  /// One service per visual concept, in display order.
  static const conceptIds = [
    'website_development',
    'mobile_app_development',
    'ai_solutions_chatbots',
    'custom_software_development',
    'business_automation',
    'digital_marketing',
  ];

  @override
  State<ServiceStage> createState() => _ServiceStageState();
}

class _ServiceStageState extends State<ServiceStage> {
  late final List<ServiceOffering> _concepts = [
    for (final id in ServiceStage.conceptIds) ServicesContent.services.firstWhere((s) => s.id == id),
  ];
  int _selected = 0;
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final service = _concepts[_selected];
    final desktop = context.isDesktop;

    final stage = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppColors.softShadow(),
        ),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: desktop ? 1.4 : 1.5,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            switchInCurve: Curves.easeOut,
            child: Service3DVisual(
              key: ValueKey(service.id),
              serviceId: service.id,
              focus: _hover ? 1 : 0,
              fallback: SmartImage(basePath: AssetPaths.service(service.id), semanticLabel: service.imageAlt, fallback: VisualKind.hero),
            ),
          ),
        ),
      ),
    );

    final selector = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, s) in _concepts.indexed)
          _ConceptTile(
            service: s,
            selected: i == _selected,
            onTap: () => setState(() => _selected = i),
          ),
      ],
    );

    if (!desktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (i, s) in _concepts.indexed)
                ChoiceChip(
                  label: Text(s.title),
                  selected: i == _selected,
                  onSelected: (_) => setState(() => _selected = i),
                ),
            ],
          ),
          const SizedBox(height: 20),
          stage,
          const SizedBox(height: 20),
          Text(service.description, style: AppTypography.body(fontSize: 15.5, color: AppColors.body)),
          const SizedBox(height: 12),
          ArrowLink(label: 'Explore ${service.title}', onPressed: () => openServicePage(context, service)),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 5, child: selector),
        const SizedBox(width: 40),
        Expanded(flex: 8, child: stage),
      ],
    );
  }
}

class _ConceptTile extends StatelessWidget {
  const _ConceptTile({required this.service, required this.selected, required this.onTap});

  final ServiceOffering service;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: AppMotion.hover,
          curve: AppMotion.ease,
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: selected ? AppColors.cardBorder : Colors.transparent),
            boxShadow: selected ? AppColors.softShadow(0.6) : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: AppMotion.hover,
                width: 3,
                height: selected ? 64 : 22,
                margin: const EdgeInsets.only(right: 16, top: 2),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.stone,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: AppTypography.display(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: selected ? AppColors.ink : AppColors.muted,
                        height: 1.3,
                      ),
                    ),
                    AnimatedSize(
                      duration: AppMotion.lift,
                      curve: AppMotion.ease,
                      alignment: Alignment.topLeft,
                      child: selected
                          ? Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(service.summary, style: AppTypography.body(fontSize: 14.5, color: AppColors.body)),
                                  const SizedBox(height: 8),
                                  ArrowLink(label: 'Explore service', onPressed: () => openServicePage(context, service)),
                                ],
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
