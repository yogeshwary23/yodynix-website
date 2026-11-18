import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../three/scroll_animation_controller.dart';
import 'motion_effects.dart';
import 'smart_image.dart';

/// Warms a photograph towards the champagne-and-ivory palette (a light
/// sepia, slightly desaturated and lifted), so stock photos from different
/// sources sit with the gold and pearl 3D renders.
const ColorFilter warmPhotoGrade = ColorFilter.matrix(<double>[
  0.806, 0.244, 0.047, 0, 0, //
  0.098, 0.930, 0.044, 0, 0, //
  0.085, 0.203, 0.738, 0, 0, //
  0, 0, 0, 1, 0,
]);

/// A warm-graded photograph that drifts against its frame as the page
/// scrolls past, and, given a [pointer] (each axis -1 to 1), leans away from
/// the mouse, so it reads as a window onto a deeper space. Clip it with the
/// frame. Reduced motion holds it still.
class ParallaxPhoto extends StatefulWidget {
  const ParallaxPhoto({
    super.key,
    required this.basePath,
    required this.semanticLabel,
    required this.fallback,
    this.pointer,
    this.depth = 18,
    this.zoom = 1,
    this.alignment = Alignment.center,
  });

  /// Extension-less asset path, resolved by `AssetRegistry`.
  final String basePath;
  final String semanticLabel;
  final Widget fallback;
  final ValueListenable<Offset>? pointer;

  /// Largest shift, in logical pixels, at the ends of the scroll.
  final double depth;

  /// Extra scale on top of the overscan the drift needs, e.g. for hover.
  final double zoom;
  final Alignment alignment;

  @override
  State<ParallaxPhoto> createState() => _ParallaxPhotoState();
}

class _ParallaxPhotoState extends State<ParallaxPhoto> {
  late final ScrollAnimationController _scroll = ScrollAnimationController(onChanged: _onScroll);

  /// -1 entering at the bottom of the viewport, 0 centred, 1 leaving the top.
  final ValueNotifier<double> _drift = ValueNotifier(0);
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = prefersReducedMotion(context);
    _scroll.attach(context);
  }

  void _onScroll(ScrollPlacement placement) {
    if (placement.visible) _drift.value = (placement.progress - 0.5) * 2;
  }

  @override
  void dispose() {
    _scroll.dispose();
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photo = ColorFiltered(
      colorFilter: warmPhotoGrade,
      child: SmartImage(
        basePath: widget.basePath,
        semanticLabel: widget.semanticLabel,
        alignment: widget.alignment,
        fallbackWidget: widget.fallback,
      ),
    );
    if (_reduced) return photo;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Overscan just enough that the drift never shows an edge.
        final overscan = 1 + 2.4 * widget.depth / constraints.maxHeight.clamp(1.0, double.infinity);
        return AnimatedScale(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          scale: widget.zoom,
          child: ValueListenableBuilder<Offset>(
            valueListenable: widget.pointer ?? const _Still(),
            builder: (context, pointer, child) => ValueListenableBuilder<double>(
              valueListenable: _drift,
              builder: (context, drift, child) => Transform(
                transform: Matrix4.translationValues(
                  -pointer.dx * widget.depth * 0.5,
                  drift * widget.depth - pointer.dy * widget.depth * 0.35,
                  0,
                )..scaleByDouble(overscan, overscan, 1, 1),
                alignment: Alignment.center,
                child: child,
              ),
              child: child,
            ),
            child: RepaintBoundary(child: photo),
          ),
        );
      },
    );
  }
}

class _Still implements ValueListenable<Offset> {
  const _Still();

  @override
  Offset get value => Offset.zero;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}
