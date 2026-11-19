import 'package:flutter/widgets.dart';

/// Calls [onEnterViewport] once, the first time the widget scrolls within
/// [lookahead] × viewport height of the visible area. Used for reveal
/// animations and lazy image loading without extra packages.
mixin ViewportTrigger<T extends StatefulWidget> on State<T> {
  ScrollPosition? _position;
  RenderObject? _scrollableBox;
  bool _triggered = false;

  bool get hasEnteredViewport => _triggered;

  /// Fraction of the viewport height ahead of the fold at which to trigger.
  double get lookahead => 0.9;

  void onEnterViewport();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_triggered) return;
    final scrollable = Scrollable.maybeOf(context, axis: Axis.vertical);
    if (scrollable == null) {
      _trigger();
      return;
    }
    if (_position != scrollable.position) {
      _position?.removeListener(_check);
      _position = scrollable.position..addListener(_check);
    }
    _scrollableBox = scrollable.context.findRenderObject();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (_triggered || !mounted) return;
    final box = context.findRenderObject();
    final ancestor = _scrollableBox ??= Scrollable.maybeOf(context)?.context.findRenderObject();
    final position = _position;
    if (ancestor == null || position == null) return;
    if (box is! RenderBox || !box.attached || !box.hasSize) {
      // Not laid out yet, e.g. a page built beneath another route on a deep
      // link: look again after a later frame, once it is shown.
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
      return;
    }
    final top = box.localToGlobal(Offset.zero, ancestor: ancestor).dy;
    if (top < position.viewportDimension * lookahead) _trigger();
  }

  void _trigger() {
    if (_triggered) return;
    _triggered = true;
    _position?.removeListener(_check);
    _position = null;
    if (mounted) onEnterViewport();
  }

  @override
  void dispose() {
    _position?.removeListener(_check);
    super.dispose();
  }
}
