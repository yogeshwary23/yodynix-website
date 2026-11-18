import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../core/utils/responsive.dart';
import 'mobile_3d_fallback.dart';
import 'scene3d.dart';
import 'scroll_animation_controller.dart';
import 'three_platform.dart';

/// Picks how much 3D a device gets: the full cinematic scene on desktop,
/// lighter scenes on tablets, and pre-rendered stills for supporting visuals
/// on phones and low-power hardware.
class SceneBudget {
  SceneBudget._();

  static SceneQuality quality(BuildContext context) {
    if (context.isMobile) return SceneQuality.low;
    if (context.isTablet) return SceneQuality.medium;
    return ThreePlatform.cpuCores <= 4 ? SceneQuality.medium : SceneQuality.high;
  }

  /// Supporting visuals use a still render instead of a live scene on
  /// phones and very low-power devices; [essential] scenes always run live.
  static bool preferStill(BuildContext context, {required bool essential}) =>
      !essential && (context.isMobile || ThreePlatform.cpuCores <= 2);
}

/// A live 3D scene from the shared WebGL engine, with everything a page
/// needs around it:
///
/// * **Lazy loading** — the engine module is fetched and the scene mounted
///   only as the widget approaches the viewport; the [fallback] (or a still
///   render) shows until then and wherever WebGL is unavailable.
/// * **Lifecycle** — off-screen scenes stop rendering; scenes far from the
///   viewport, or removed from the tree, are disposed with their GPU
///   resources and listeners.
/// * **Interaction** — scroll progress, pointer parallax and [focus] are
///   forwarded to the scene. Pointer events still reach Flutter, so scrolling
///   and clicking over the scene work normally.
/// * **Accessibility** — the scene is a single labelled image; with reduced
///   motion enabled it renders a still frame that changes only on scroll.
class Interactive3DObject extends StatefulWidget {
  const Interactive3DObject({
    super.key,
    required this.scene,
    required this.semanticLabel,
    required this.fallback,
    required this.background,
    this.focus = 0,
    this.pointer,
    this.essential = false,
    this.image,
    this.variant,
    this.lean = 0,
  });

  final Scene3D scene;
  final String semanticLabel;

  /// Shown before the scene loads and wherever 3D can't run.
  final Widget fallback;

  /// The surface colour behind the scene; glass refracts it. Null renders
  /// on a transparent canvas over whatever the page paints behind it.
  final Color? background;

  /// Hover / emphasis, 0 to 1.
  final double focus;

  /// Pointer position (each axis -1 to 1) from a larger hover area, such as
  /// a whole hero section. When null the widget tracks hover over itself.
  final ValueListenable<Offset>? pointer;

  /// Keeps the scene live on phones instead of using a still render.
  final bool essential;

  /// Absolute URL of an image for device screens ([Scene3D.preview]).
  final String? image;

  /// Scene-specific variation (see `SceneOptions.variant`).
  final String? variant;

  /// Horizontal composition bias, -1 to 1.
  final double lean;

  @override
  State<Interactive3DObject> createState() => _Interactive3DObjectState();
}

class _Interactive3DObjectState extends State<Interactive3DObject> {
  /// Mount when within this many viewport heights of the screen…
  static const double _mountAhead = 1.0;

  /// …and dispose once further away than this (hysteresis avoids churn).
  static const double _disposeBeyond = 2.5;

  late final ScrollAnimationController _scroll = ScrollAnimationController(onChanged: _onPlacement);
  SceneHandle? _handle;
  bool _wantMounted = false;
  bool? _supported = ThreePlatform.supportedSync;
  int _generation = 0;

  /// Set once the live scene has drawn, so the still underneath can go: the
  /// scene's feathered edges would otherwise reveal it.
  bool _liveReady = false;

  /// The WebGL context was lost; stay on the still for this widget.
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    widget.pointer?.addListener(_onExternalPointer);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scroll.attach(context);
  }

  @override
  void didUpdateWidget(Interactive3DObject oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pointer != widget.pointer) {
      oldWidget.pointer?.removeListener(_onExternalPointer);
      widget.pointer?.addListener(_onExternalPointer);
    }
    if (oldWidget.focus != widget.focus) _handle?.setFocus(widget.focus);
    if (oldWidget.scene != widget.scene || oldWidget.image != widget.image || oldWidget.variant != widget.variant) {
      _unmount();
      if (_scroll.placement.distance <= _mountAhead) _requestMount();
    }
    _scroll.schedule();
  }

  void _onPlacement(ScrollPlacement placement) {
    final handle = _handle;
    if (handle != null) {
      handle.setActive(placement.visible);
      handle.setProgress(placement.progress);
    }
    if (!_wantMounted && placement.distance <= _mountAhead) {
      _requestMount();
    } else if (_wantMounted && placement.distance > _disposeBeyond) {
      _unmount();
    }
  }

  Future<void> _requestMount() async {
    if (_supported == false) return;
    _wantMounted = true;
    _supported ??= await ThreePlatform.ensureLoaded();
    if (!mounted) return;
    setState(() {});
  }

  void _onMounted(SceneHandle handle) {
    if (!mounted || !_wantMounted) {
      handle.dispose();
      return;
    }
    _handle?.dispose();
    _handle = handle;
    final placement = _scroll.placement;
    handle
      ..setProgress(placement.progress)
      ..setFocus(widget.focus)
      ..setActive(placement.visible);
    // The engine draws on its next animation frame; give it a moment.
    Future<void>.delayed(const Duration(milliseconds: 400), () {
      if (mounted && identical(_handle, handle) && !_liveReady) setState(() => _liveReady = true);
    });
  }

  void _unmount() {
    _handle?.dispose();
    _handle = null;
    _liveReady = false;
    if (!_wantMounted) return;
    _wantMounted = false;
    // A new key gives a fresh platform view on the next mount.
    _generation++;
    if (mounted) setState(() {});
  }

  void _onExternalPointer() {
    final p = widget.pointer!.value;
    _handle?.setPointer(p.dx, p.dy);
  }

  void _onHover(PointerEvent event) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final local = event.localPosition;
    _handle?.setPointer(
      (local.dx / box.size.width * 2 - 1).clamp(-1.0, 1.0),
      (local.dy / box.size.height * 2 - 1).clamp(-1.0, 1.0),
    );
  }

  @override
  void dispose() {
    widget.pointer?.removeListener(_onExternalPointer);
    _scroll.dispose();
    _handle?.dispose();
    _handle = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = SceneBudget.preferStill(context, essential: widget.essential);
    final fallback = Mobile3DFallback(scene: widget.scene, variant: widget.variant, fallback: widget.fallback);
    if (still || _supported == false || _failed) {
      return Semantics(label: widget.semanticLabel, image: true, child: ExcludeSemantics(child: fallback));
    }

    final live = _wantMounted && _supported == true;
    Widget child = Stack(
      fit: StackFit.expand,
      children: [
        if (!_liveReady) fallback,
        if (live)
          KeyedSubtree(
            key: ValueKey(_generation),
            child: ThreePlatform.buildHost(
              scene: widget.scene,
              options: SceneOptions(
                quality: SceneBudget.quality(context),
                reducedMotion: MediaQuery.disableAnimationsOf(context),
                background: widget.background,
                image: widget.image,
                variant: widget.variant,
                lean: widget.lean,
              ),
              onMounted: _onMounted,
              onLost: () {
                if (!mounted) return;
                _unmount();
                setState(() => _failed = true);
              },
            ),
          ),
      ],
    );
    if (widget.pointer == null) {
      child = MouseRegion(onHover: _onHover, onExit: (_) => _handle?.setPointer(0, 0), child: child);
    }
    return Semantics(
      label: widget.semanticLabel,
      image: true,
      child: ExcludeSemantics(
        child: NotificationListener<SizeChangedLayoutNotification>(
          onNotification: (_) {
            _scroll.schedule();
            return false;
          },
          child: SizeChangedLayoutNotifier(child: child),
        ),
      ),
    );
  }
}
