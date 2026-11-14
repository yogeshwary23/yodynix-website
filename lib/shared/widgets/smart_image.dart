import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/asset_registry.dart';
import 'viewport_trigger.dart';
import 'visuals/illustrated_visual.dart';
import 'visuals/visual_kind.dart';

/// Shows the real photo at [basePath] when one is bundled (any of .webp,
/// .jpg, .jpeg, .png), otherwise the topic-specific illustration for
/// [fallback]. Photos load lazily as they approach the viewport.
class SmartImage extends StatelessWidget {
  const SmartImage({
    super.key,
    required this.basePath,
    required this.semanticLabel,
    this.fallback,
    this.fallbackWidget,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  }) : assert(fallback != null || fallbackWidget != null);

  final String basePath;
  final String semanticLabel;
  final VisualKind? fallback;
  final Widget? fallbackWidget;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final path = AssetRegistry.instance.resolve(basePath);
    if (path == null) {
      return Semantics(
        label: semanticLabel,
        image: true,
        child: ExcludeSemantics(child: fallbackWidget ?? IllustratedVisual(fallback!)),
      );
    }
    return LazyAssetImage(path: path, semanticLabel: semanticLabel, fit: fit, alignment: alignment);
  }
}

class LazyAssetImage extends StatefulWidget {
  const LazyAssetImage({
    super.key,
    required this.path,
    required this.semanticLabel,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final String path;
  final String semanticLabel;
  final BoxFit fit;
  final Alignment alignment;

  @override
  State<LazyAssetImage> createState() => _LazyAssetImageState();
}

class _LazyAssetImageState extends State<LazyAssetImage> with ViewportTrigger<LazyAssetImage> {
  @override
  double get lookahead => 1.6;

  @override
  void onEnterViewport() => setState(() {});

  @override
  Widget build(BuildContext context) {
    if (!hasEnteredViewport) {
      return Semantics(
        label: widget.semanticLabel,
        image: true,
        child: const ColoredBox(color: AppColors.surface),
      );
    }
    return Image.asset(
      widget.path,
      fit: widget.fit,
      alignment: widget.alignment,
      semanticLabel: widget.semanticLabel,
      width: double.infinity,
      height: double.infinity,
      filterQuality: FilterQuality.medium,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(opacity: frame == null ? 0 : 1, duration: const Duration(milliseconds: 450), child: child);
      },
    );
  }
}
