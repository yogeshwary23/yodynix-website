import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/utils/responsive.dart';
import '../three/scroll_animation_controller.dart';
import 'particle_network.dart';

/// The curve families a [GoldFlowLayer] can draw. Each section gets a
/// different one, so the lines never read as a repeated pattern.
enum GoldFlowPattern {
  /// Long, slowly breathing waves across the section.
  waves,

  /// Wide arcs sweeping out of a corner.
  arcs,

  /// Fine contour lines flowing down one side.
  contours,

  /// A metallic ribbon that twists as it travels.
  ribbon,
}

/// Thin champagne-gold lines flowing behind a section's content: curves that
/// slowly change shape, a soft metallic glow, and a point of light that
/// travels along each one.
///
/// Like [GoldDust] it is drawn in Flutter (no WebGL), steps about 30 times a
/// second, on the same frames as the particles, only while on screen, and holds a still frame when the visitor
/// prefers reduced motion. The curves stay near the section's edges and fade
/// behind the central content column on wide screens; they shift with the
/// scroll and the pointer at different depths, for parallax. It never takes
/// part in hit testing.
class GoldFlowLayer extends StatefulWidget {
  const GoldFlowLayer({super.key, this.pattern, this.intensity = 1, this.band, this.bottom, this.right});

  /// Null picks the next pattern in turn, so neighbouring sections differ.
  final GoldFlowPattern? pattern;

  /// Scales the lines' opacity.
  final double intensity;

  /// Depth of the strip along the top or bottom edge that the waves, arcs
  /// and ribbon keep to; defaults to the section's empty padding, so the
  /// curves pass between content rather than across text.
  final double? band;

  /// Whether they gather at the bottom edge, and on the right; null
  /// alternates by section.
  final bool? bottom;
  final bool? right;

  @override
  State<GoldFlowLayer> createState() => _GoldFlowLayerState();
}

class _GoldFlowLayerState extends State<GoldFlowLayer> with SingleTickerProviderStateMixin {
  /// Hands out patterns in page order: sections mount top to bottom.
  static int _issued = 0;

  late final Ticker _ticker = createTicker(_tick);
  late final ScrollAnimationController _scroll = ScrollAnimationController(onChanged: _onScroll);
  late final int _variant = _issued++;
  final ValueNotifier<double> _time = ValueNotifier(0);
  final ValueNotifier<double> _progress = ValueNotifier(0.5);
  Duration _last = Duration.zero;
  double _sinceStep = 0;
  final AmbientClock _clock = AmbientClock();
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
    if (!_reduced) _progress.value = placement.progress;
    _sync();
  }

  void _sync() {
    final run = _visible && !_reduced;
    if (run && !_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    } else if (!run && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _tick(Duration elapsed) {
    // Long gaps (a hidden tab) resume smoothly rather than jumping ahead.
    final dt = _last == Duration.zero ? 0.0 : math.min(0.1, (elapsed - _last).inMicroseconds / 1e6);
    _last = elapsed;
    _sinceStep += dt;
    // In step with the particles, about 30 times a second.
    if (!_clock.due()) return;
    _time.value += _sinceStep;
    _sinceStep = 0;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scroll.dispose();
    _time.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pattern = widget.pattern ?? GoldFlowPattern.values[_variant % GoldFlowPattern.values.length];
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _FlowPainter(
            pattern: pattern,
            // Alternate the side and edge the curves gather at.
            mirror: widget.right ?? (_variant ~/ 2).isOdd,
            bottom: widget.bottom ?? _variant.isOdd,
            band: widget.band ?? context.sectionPadding,
            // The free margin beside the content column, for the contours.
            room: math.max(context.gutter, (MediaQuery.sizeOf(context).width - Breakpoints.maxContentWidth) / 2),
            seed: _variant * 1.7,
            dark: context.tone.isDark,
            wide: context.isDesktop,
            intensity: widget.intensity,
            time: _time,
            progress: _progress,
          ),
        ),
      ),
    );
  }
}

class _FlowPainter extends CustomPainter {
  _FlowPainter({
    required this.pattern,
    required this.mirror,
    required this.bottom,
    required this.band,
    required this.room,
    required this.seed,
    required this.dark,
    required this.wide,
    required this.intensity,
    required this.time,
    required this.progress,
  }) : super(repaint: Listenable.merge([time, progress]));

  final GoldFlowPattern pattern;
  final bool mirror, bottom, dark, wide;
  final double band, room, seed, intensity;
  final ValueNotifier<double> time;
  final ValueNotifier<double> progress;

  static const _samples = 56;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final t = time.value + seed * 10;
    // Edge curves need a strip of free space; contours use the side margin.
    if (pattern != GoldFlowPattern.contours && _band(size) < 32) {
      canvas.restore();
      return;
    }
    final curves = switch (pattern) {
      GoldFlowPattern.waves => _waves(size, t),
      GoldFlowPattern.arcs => _arcs(size, t),
      GoldFlowPattern.contours => _contours(size, t),
      GoldFlowPattern.ribbon => _ribbon(size, t),
    };
    final pointer = ParticleField.instance.pointer;
    for (var i = 0; i < curves.length; i++) {
      final c = curves[i];
      // Deeper curves move less: scroll and pointer parallax.
      final depth = 0.4 + 0.6 * (i + 1) / curves.length;
      // Vertical drift scales with the strip, so curves stay in the padding.
      final drift = pattern == GoldFlowPattern.contours ? 1.0 : (_band(size) / 120).clamp(0.3, 1.0);
      final shift = Offset(
        -pointer.dx * 10 * depth,
        ((progress.value - 0.5) * -24 - pointer.dy * 5) * depth * drift,
      );
      _drawCurve(canvas, size, c, shift, t, i);
    }
    canvas.restore();
  }

  // ------------------------------------------------------------ patterns

  double _band(Size size) => math.min(size.height / 2, band);

  double _edgeY(Size size, double y) => bottom ? size.height - y : y;

  List<_Curve> _waves(Size size, double t) {
    final band = _band(size);
    final n = wide ? 3 : 2;
    return [
      for (var i = 0; i < n; i++)
        _Curve.horizontal(
          [
            for (var s = 0; s <= _samples; s++)
              () {
                final u = s / _samples;
                final amp = band * (0.13 + 0.04 * math.sin(t * 0.11 + i));
                final y = band * (0.32 + 0.18 * i) +
                    amp * (0.62 * math.sin(u * math.pi * 2.2 + t * 0.23 + i * 0.8) + 0.38 * math.sin(u * math.pi * 4.6 - t * 0.17 + i * 1.9));
                return Offset(-20 + u * (size.width + 40), _edgeY(size, y));
              }(),
          ],
          tone: i,
        ),
    ];
  }

  List<_Curve> _arcs(Size size, double t) {
    final n = wide ? 3 : 2;
    final cx = mirror ? size.width * 1.02 : -size.width * 0.02;
    final low = bottom;
    final cy = low ? size.height + 20 : -20.0;
    final base = math.min(size.width * 0.3, _band(size) * 1.7);
    return [
      for (var i = 0; i < n; i++)
        _Curve.horizontal(
          [
            for (var s = 0; s <= _samples; s++)
              () {
                // A quarter turn out of the corner, into the section.
                final a = (s / _samples) * math.pi / 2;
                final r = base * (0.55 + 0.2 * i) * (1 + 0.035 * math.sin(t * 0.3 + i * 1.3) + 0.03 * math.sin(a * 5 + t * 0.4 + i));
                final dx = math.cos(a) * r * 1.35;
                final dy = math.sin(a) * r * 0.85;
                return Offset(cx + (mirror ? -dx : dx), cy + (low ? -dy : dy));
              }(),
          ],
          tone: i,
        ),
    ];
  }

  List<_Curve> _contours(Size size, double t) {
    final n = wide ? 3 : 2;
    final gap = room * (wide ? 0.2 : 0.18);
    final inset = room * 0.16;
    return [
      for (var i = 0; i < n; i++)
        _Curve.vertical(
          [
            for (var s = 0; s <= _samples; s++)
              () {
                final v = s / _samples;
                final sway = room * 0.1 * (0.7 * math.sin(v * math.pi * 3 + t * 0.21 + i * 0.6) + 0.3 * math.sin(v * math.pi * 7 - t * 0.15 + i));
                final x = inset + gap * i + sway;
                return Offset(mirror ? size.width - x : x, -10 + v * (size.height + 20));
              }(),
          ],
          tone: i,
        ),
    ];
  }

  List<_Curve> _ribbon(Size size, double t) {
    final band = _band(size);
    final centre = <Offset>[];
    final half = <double>[];
    for (var s = 0; s <= _samples; s++) {
      final u = s / _samples;
      final y = band * 0.45 + band * 0.16 * math.sin(u * math.pi * 1.8 + t * 0.19) + band * 0.05 * math.sin(u * math.pi * 5 - t * 0.27);
      centre.add(Offset(-20 + u * (size.width + 40), _edgeY(size, y)));
      // The ribbon's width swings through zero where it twists.
      half.add(band * 0.12 * math.sin(u * math.pi * 2.6 + t * 0.33));
    }
    final upper = [for (var s = 0; s <= _samples; s++) centre[s] - Offset(0, half[s])];
    final lower = [for (var s = 0; s <= _samples; s++) centre[s] + Offset(0, half[s])];
    return [
      _Curve.horizontal(upper, tone: 0, ribbonPartner: lower),
      _Curve.horizontal(lower, tone: 1),
      _Curve.horizontal([for (final p in centre) p + Offset(0, (bottom ? -1 : 1) * band * 0.3)], tone: 2),
    ];
  }

  // -------------------------------------------------------------- drawing

  static const _tones = [AppColors.champagneGold, AppColors.antiqueGold, AppColors.platinumDeep, AppColors.softChampagne];

  void _drawCurve(Canvas canvas, Size size, _Curve curve, Offset shift, double t, int index) {
    final base = _tones[curve.tone % _tones.length];
    final strength = (dark ? 0.62 : 0.68) * intensity * (wide ? 1 : 0.8);
    final shader = _fadeShader(size, curve.vertical, base, strength);
    final path = _smooth(curve.points, shift);

    if (curve.ribbonPartner case final partner?) {
      final fill = Path()..addPath(path, Offset.zero);
      final back = _smooth(partner.reversed.toList(), shift);
      fill.extendWithPath(back, Offset.zero);
      fill.close();
      canvas.drawPath(
        fill,
        Paint()
          ..shader = _fadeShader(size, false, AppColors.softChampagne, strength * 0.22)
          ..style = PaintingStyle.fill,
      );
    }

    // A soft metallic glow under a hairline: wide faint strokes, no blur
    // filter, so repainting stays cheap.
    final stroke = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, stroke..strokeWidth = 4..color = const Color(0x2E000000));
    canvas.drawPath(path, stroke..strokeWidth = index == 0 ? 1.4 : 1.0..color = const Color(0xFF000000));

    // A point of light travelling along the line, each at its own pace.
    final u = (t * (0.035 + 0.012 * index) + index * 0.37) % 1.0;
    final at = curve.points[(u * (curve.points.length - 1)).round()] + shift;
    final edge = math.min(1.0, math.min(u, 1 - u) * 8);
    final along = curve.vertical ? at.dy / size.height : at.dx / size.width;
    final alpha = (edge * _calm(along, curve.vertical) * strength * 1.4).clamp(0.0, 1.0);
    if (alpha < 0.02) return;
    final glow = wide ? 12.0 : 9.0;
    canvas.drawCircle(
      at,
      glow,
      Paint()
        ..shader = ui.Gradient.radial(at, glow, [
          AppColors.softChampagne.withValues(alpha: alpha * 0.6),
          AppColors.softChampagne.withValues(alpha: 0),
        ]),
    );
    canvas.drawCircle(at, 1.6, Paint()..color = AppColors.white.withValues(alpha: alpha));
  }

  /// A gradient along the line: faded at both ends and, on wide screens,
  /// faint behind the central content column.
  ui.Shader _fadeShader(Size size, bool vertical, Color color, double strength) {
    final stops = const [0.0, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0];
    return ui.Gradient.linear(
      Offset.zero,
      vertical ? Offset(0, size.height) : Offset(size.width, 0),
      [for (final s in stops) color.withValues(alpha: (strength * _calm(s, vertical)).clamp(0.0, 1.0))],
      stops,
    );
  }

  double _calm(double along, bool vertical) {
    final ends = math.min(1.0, math.min(along, 1 - along) * 10);
    // Contours already sit at the side; horizontal lines fade mid-page.
    if (vertical || !wide) return ends;
    final off = (along - 0.5).abs();
    final calm = 0.25 + 0.75 * _smoothstep((off - 0.12) / 0.22);
    return ends * calm;
  }

  static double _smoothstep(double t) {
    final c = t.clamp(0.0, 1.0);
    return c * c * (3 - 2 * c);
  }

  /// A smooth path through [points]: quadratic curves between midpoints.
  static Path _smooth(List<Offset> points, Offset shift) {
    final path = Path()..moveTo(points.first.dx + shift.dx, points.first.dy + shift.dy);
    for (var i = 1; i < points.length - 1; i++) {
      final p = points[i] + shift;
      final mid = Offset.lerp(points[i], points[i + 1], 0.5)! + shift;
      path.quadraticBezierTo(p.dx, p.dy, mid.dx, mid.dy);
    }
    path.lineTo(points.last.dx + shift.dx, points.last.dy + shift.dy);
    return path;
  }

  @override
  bool shouldRepaint(_FlowPainter old) =>
      old.pattern != pattern ||
      old.mirror != mirror ||
      old.bottom != bottom ||
      old.dark != dark ||
      old.wide != wide ||
      old.intensity != intensity ||
      old.time != time ||
      old.progress != progress;
}

class _Curve {
  _Curve.horizontal(this.points, {required this.tone, this.ribbonPartner}) : vertical = false;
  _Curve.vertical(this.points, {required this.tone}) : vertical = true, ribbonPartner = null;

  final List<Offset> points;
  final bool vertical;
  final int tone;

  /// The ribbon's other edge, filled between the two.
  final List<Offset>? ribbonPartner;
}
