import 'package:flutter/widgets.dart';

/// Where a widget sits relative to the viewport of its nearest vertical
/// scrollable.
@immutable
class ScrollPlacement {
  const ScrollPlacement({required this.progress, required this.visible, required this.distance});

  /// 0 when the widget's top enters at the bottom of the viewport, 1 when its
  /// bottom leaves at the top.
  final double progress;

  /// Whether any part of the widget is inside the viewport.
  final bool visible;

  /// Distance from the viewport, in viewport heights (0 when visible).
  final double distance;

  static const ScrollPlacement onScreen = ScrollPlacement(progress: 0.5, visible: true, distance: 0);

  @override
  bool operator ==(Object other) =>
      other is ScrollPlacement && other.progress == progress && other.visible == visible && other.distance == distance;

  @override
  int get hashCode => Object.hash(progress, visible, distance);
}

/// Tracks a widget's [ScrollPlacement] as the page scrolls, without taking
/// over scrolling: normal browser and Flutter scroll physics are untouched.
///
/// Call [attach] from `didChangeDependencies` and [dispose] with the owning
/// state. [onChanged] fires only when the placement actually changes.
class ScrollAnimationController {
  ScrollAnimationController({required this.onChanged});

  final ValueChanged<ScrollPlacement> onChanged;

  BuildContext? _context;
  ScrollPosition? _position;
  ScrollPlacement? _last;
  bool _scheduled = false;

  ScrollPlacement get placement => _last ?? ScrollPlacement.onScreen;

  void attach(BuildContext context) {
    _context = context;
    final position = Scrollable.maybeOf(context, axis: Axis.vertical)?.position;
    if (position != _position) {
      _position?.removeListener(_update);
      _position = position?..addListener(_update);
    }
    schedule();
  }

  /// Recomputes after the next layout, e.g. when the widget resizes.
  void schedule() {
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      _update();
    });
  }

  void _update() {
    final context = _context;
    if (context == null || !context.mounted) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return;

    final position = _position;
    final ScrollPlacement next;
    if (position == null || !position.hasViewportDimension) {
      next = ScrollPlacement.onScreen;
    } else {
      final viewportBox = Scrollable.maybeOf(context, axis: Axis.vertical)?.context.findRenderObject();
      if (viewportBox is! RenderBox) return;
      final top = box.localToGlobal(Offset.zero, ancestor: viewportBox).dy;
      final height = box.size.height;
      final viewport = position.viewportDimension;
      final bottom = top + height;
      final travelled = (viewport - top) / (viewport + height);
      final gap = top > viewport ? top - viewport : (bottom < 0 ? -bottom : 0.0);
      next = ScrollPlacement(
        // Rounded so tiny sub-pixel jitter doesn't flood the engine with updates.
        progress: (travelled.clamp(0.0, 1.0) * 1000).round() / 1000,
        visible: bottom > 0 && top < viewport,
        distance: ((gap / viewport) * 100).round() / 100,
      );
    }
    if (next == _last) return;
    _last = next;
    onChanged(next);
  }

  void dispose() {
    _position?.removeListener(_update);
    _position = null;
    _context = null;
  }
}
