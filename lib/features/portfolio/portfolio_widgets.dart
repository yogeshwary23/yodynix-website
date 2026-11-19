import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../models/service_page.dart';
import '../../repositories/content/portfolio_content.dart';
import '../../services/asset_registry.dart';
import '../../shared/layouts/navigation_actions.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/motion_effects.dart';
import '../../shared/widgets/premium.dart';
import '../../shared/widgets/smart_image.dart';
import '../../shared/widgets/tinted_photo.dart';
import '../../shared/widgets/viewport_trigger.dart';

/// Shared pieces of the Portfolio page and the project pages.
extension ProjectPresentation on SampleProject {
  ProjectCaseStudy? get study => PortfolioContent.of(id);

  String get route => AppRoutes.project(slug);

  /// The project's 3D device still (`assets/images/project_devices/`).
  String get deviceStill => AssetPaths.projectDevice(id);

  /// The image spec for its screen in the live device scene: the bundled
  /// image's URL with the crop, alignment and grade the stills use (see
  /// `screenImage` in web/three/yodynix3d.js). Null if the image is missing.
  String? get screenSpec {
    final asset = AssetRegistry.instance.resolve(image);
    if (asset == null) return null;
    final fragment = [
      ?study?.screenCrop,
      // Screenshots keep their top and are never graded; concept
      // photographs stay centred and are toned towards the palette.
      if (!hasDemo) 'align=center&grade=warm',
    ].join('&');
    final url = Uri.base.resolve('assets/$asset').toString();
    return fragment.isEmpty ? url : '$url#$fragment';
  }
}

/// A warm studio backdrop for a device still: a pool of light falling on a
/// pearl-to-beige sweep, with a fine gold rim.
class DeviceStage extends StatelessWidget {
  const DeviceStage({super.key, required this.child, this.radius = AppRadius.md});

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFBF8F2), Color(0xFFF1E8D9), Color(0xFFE6D8C1)],
            stops: [0, 0.62, 1],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.55),
                    radius: 0.85,
                    colors: [Color(0xB3FFFFFF), Color(0x00FFFFFF)],
                  ),
                ),
              ),
            ),
            child,
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: AppColors.goldLine.withValues(alpha: 0.7)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The project on its 3D device, on a studio stage. Falls back to the plain
/// project image when no still is bundled.
class ProjectDeviceImage extends StatelessWidget {
  const ProjectDeviceImage({super.key, required this.project, this.active = false});

  final SampleProject project;

  /// Hover: the device lifts and comes slightly closer.
  final bool active;

  @override
  Widget build(BuildContext context) {
    final still = AssetRegistry.instance.resolve(project.deviceStill);
    final reduced = prefersReducedMotion(context);
    return DeviceStage(
      child: still == null
          ? TintedPhoto(basePath: project.image, semanticLabel: project.imageAlt, strength: 0.25, active: active)
          : AnimatedSlide(
              duration: AppMotion.lift,
              curve: AppMotion.ease,
              offset: Offset(0, active && !reduced ? -0.025 : 0),
              child: AnimatedScale(
                duration: AppMotion.lift,
                curve: AppMotion.ease,
                scale: active && !reduced ? 1.045 : 1,
                child: LazyAssetImage(path: still, semanticLabel: project.deviceLabel, fit: BoxFit.contain),
              ),
            ),
    );
  }
}

extension on SampleProject {
  String get deviceLabel {
    final device = study?.device.name ?? 'device';
    return hasDemo
        ? 'A screenshot of the $name working demo shown on a $device.'
        : 'Concept visual for $name: an illustrative photograph shown on a $device, not a product screenshot.';
  }
}

/// A project tile: its device still on a studio stage, status, category and
/// a one-line objective. Lifts, tilts towards the cursor and brings the
/// device forward on hover; opens the project's page.
class ProjectCard extends StatefulWidget {
  const ProjectCard({super.key, required this.project});

  final SampleProject project;

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final study = p.study;
    return Semantics(
      button: true,
      label: 'Open ${p.name}, a ${p.hasDemo ? 'working demo' : 'concept'}: ${p.category.toLowerCase()}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: () => openRoute(context, p.route),
          child: Tilt3D(
            maxAngle: 3,
            radius: AppRadius.xl,
            child: AnimatedContainer(
              duration: AppMotion.lift,
              curve: AppMotion.ease,
              transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
              padding: const EdgeInsets.all(10),
              decoration: premiumGlassCard(lifted: _hover),
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 2,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ProjectDeviceImage(project: p, active: _hover),
                          Positioned(left: 12, top: 12, child: ProjectStatusBadge(demo: p.hasDemo, compact: true)),
                          if (!p.hasDemo) const Positioned(right: 12, bottom: 10, child: ConceptVisualNote()),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 18, 10, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            [p.category, ?study?.industry].join('  ·  ').toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: AppColors.accent),
                          ),
                          const SizedBox(height: 6),
                          Text(p.name, style: AppTypography.display(fontSize: 21, fontWeight: FontWeight.w700, color: AppColors.ink)),
                          const SizedBox(height: 8),
                          Text(
                            study?.objective ?? p.summary,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body(fontSize: 14, color: AppColors.body),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
                      child: Row(
                        children: [
                          Text(
                            'View Project',
                            style: AppTypography.body(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.accent),
                          ),
                          const SizedBox(width: 6),
                          AnimatedSlide(
                            duration: AppMotion.hover,
                            offset: Offset(_hover ? 0.25 : 0, 0),
                            child: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.accent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small frosted note marking an illustrative concept image.
class ConceptVisualNote extends StatelessWidget {
  const ConceptVisualNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.platinumDeep),
      ),
      child: Text('Concept visual', style: AppTypography.body(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.slate, height: 1.2)),
    );
  }
}

class ProjectStatusBadge extends StatelessWidget {
  const ProjectStatusBadge({super.key, required this.demo, this.compact = false});

  final bool demo;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 9 : 11, vertical: compact ? 4 : 5),
      decoration: BoxDecoration(
        gradient: demo ? AppColors.buttonGold : null,
        color: demo ? null : AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: demo ? AppColors.antiqueGold.withValues(alpha: 0.4) : AppColors.platinumDeep),
        boxShadow: [BoxShadow(color: warmShadowTone.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(demo ? Icons.play_circle_outline_rounded : Icons.draw_outlined, size: compact ? 12 : 14, color: demo ? AppColors.onPrimary : AppColors.slate),
          const SizedBox(width: 5),
          Text(
            demo ? 'Working Demo' : 'Concept',
            style: AppTypography.body(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: demo ? AppColors.onPrimary : AppColors.slate,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectTag extends StatelessWidget {
  const ProjectTag(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.goldWash,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.goldLine),
      ),
      child: Text(text, style: AppTypography.body(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent, height: 1.2)),
    );
  }
}

/// A technology name on a brushed-platinum chip.
class TechChip extends StatelessWidget {
  const TechChip(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.white, AppColors.platinum]),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.platinumDeep),
      ),
      child: Text(text, style: AppTypography.body(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.charcoal, height: 1.2)),
    );
  }
}

/// A screenshot in a desktop browser window with a brushed-platinum bezel.
class BrowserMockup extends StatelessWidget {
  const BrowserMockup({super.key, required this.image, required this.address, required this.semanticLabel});

  final String image;
  final String address;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF1EFEB), AppColors.platinumDeep]),
        boxShadow: premiumCardShadow(lifted: true),
      ),
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 34,
            child: Row(
              children: [
                const SizedBox(width: 14),
                for (final c in const [AppColors.champagneGold, AppColors.softGrey, AppColors.platinumDeep]) ...[
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
                  const SizedBox(width: 7),
                ],
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 20,
                    margin: const EdgeInsets.only(right: 60),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      'yodynix.com$address',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(fontSize: 11, color: AppColors.muted, height: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 1200 / 750,
              child: LazyAssetImage(path: image, semanticLabel: semanticLabel, alignment: Alignment.topCenter),
            ),
          ),
        ],
      ),
    );
  }
}

/// A figure that counts up from zero the first time it scrolls into view,
/// in metallic gold. Reduced motion shows the final value at once.
class CountUp extends StatefulWidget {
  const CountUp({super.key, required this.value, required this.style});

  final int value;
  final TextStyle style;

  @override
  State<CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<CountUp> with ViewportTrigger<CountUp> {
  bool _started = false;

  @override
  double get lookahead => 0.85;

  @override
  void onEnterViewport() => setState(() => _started = true);

  @override
  Widget build(BuildContext context) {
    if (prefersReducedMotion(context)) {
      return GradientText('${widget.value}', style: widget.style, gradient: AppColors.metallicGoldText);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _started ? widget.value.toDouble() : 0),
      duration: const Duration(milliseconds: 1600),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => GradientText('${v.round()}', style: widget.style, gradient: AppColors.metallicGoldText),
    );
  }
}
