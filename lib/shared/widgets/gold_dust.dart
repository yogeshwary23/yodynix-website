import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../three/scroll_animation_controller.dart';
import 'gold_flow.dart';
import 'particle_network.dart';

/// Slowly rising champagne-gold motes behind [child] — the footer's ambient
/// detail. Drawn in Flutter (no WebGL), it only ticks while on screen and
/// holds a still scatter when the visitor prefers reduced motion.
class GoldDust extends StatefulWidget {
  const GoldDust({super.key, required this.child, this.count = 46, this.opacity = 1, this.flow});

  final Widget child;
  final int count;
  final double opacity;

  /// Also draws flowing gold lines in this pattern behind the motes.
  final GoldFlowPattern? flow;

  @override
  State<GoldDust> createState() => _GoldDustState();
}

class _GoldDustState extends State<GoldDust> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  late final ScrollAnimationController _scroll = ScrollAnimationController(onChanged: _onScroll);
  late final List<_Mote> _motes = _Mote.scatter(widget.count);
  final ValueNotifier<double> _time = ValueNotifier(0);
  bool _visible = false;
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = ambientStill(context);
    _scroll.attach(context);
    _sync();
  }

  void _onScroll(ScrollPlacement placement) {
    _visible = placement.visible;
    _sync();
  }

  void _sync() {
    final run = _visible && !_reduced;
    if (run && !_ticker.isActive) {
      _ticker.start();
    } else if (!run && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _tick(Duration elapsed) => _time.value = elapsed.inMicroseconds / 1e6;

  @override
  void dispose() {
    _ticker.dispose();
    _scroll.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.flow case final flow?)
          Positioned.fill(
            // Along the top, in the space above the footer's columns.
            child: GoldFlowLayer(pattern: flow, intensity: 0.7, bottom: false, band: context.responsive(mobile: 50.0, desktop: 74.0)),
          ),
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(child: CustomPaint(painter: _DustPainter(_motes, _time, widget.opacity))),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Mote {
  _Mote(this.x, this.y, this.size, this.speed, this.phase, this.alpha);

  final double x, y, size, speed, phase, alpha;

  static List<_Mote> scatter(int count) {
    final rand = math.Random(7);
    return [
      for (var i = 0; i < count; i++)
        _Mote(
          rand.nextDouble(),
          rand.nextDouble(),
          0.6 + rand.nextDouble() * 1.8,
          0.006 + rand.nextDouble() * 0.014,
          rand.nextDouble() * math.pi * 2,
          0.15 + rand.nextDouble() * 0.45,
        ),
    ];
  }
}

class _DustPainter extends CustomPainter {
  _DustPainter(this.motes, this.time, this.opacity) : super(repaint: time);

  final List<_Mote> motes;
  final ValueNotifier<double> time;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final t = time.value;
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
    for (final m in motes) {
      // Rise slowly, wrapping at the top; sway sideways on a gentle sine.
      final y = (m.y - t * m.speed) % 1.0;
      final x = m.x + math.sin(t * 0.4 + m.phase) * 0.008;
      // Fade in at the bottom edge and out towards the top.
      final edge = math.min(1.0, math.min(y, 1 - y) * 6);
      final twinkle = 0.75 + 0.25 * math.sin(t * 1.6 + m.phase * 3);
      paint.color = AppColors.softChampagne.withValues(alpha: m.alpha * edge * twinkle * opacity);
      canvas.drawCircle(Offset(x * size.width, y * size.height), m.size, paint);
    }
  }

  @override
  bool shouldRepaint(_DustPainter old) => old.motes != motes || old.opacity != opacity;
}
