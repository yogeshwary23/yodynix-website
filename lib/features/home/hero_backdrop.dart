import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../shared/three/scroll_animation_controller.dart';

/// The hero's environment: a pearl-and-ivory architectural space of curved
/// walls catching champagne light, set in the large curved shell of a room
/// lit by warm daylight from the upper right, with a golden glow behind the
/// sculpture, light flowing along the walls' edges and slow gold and
/// platinum motes.
///
/// Two layers keep it cheap. The architecture repaints only when the pointer
/// or the scroll moves it; the atmosphere (glow, streaks, motes) animates on
/// one ticker that stops whenever the hero is off screen, and never starts
/// when the visitor prefers reduced motion. Layers sit at different depths,
/// so the pointer and the scroll separate them with parallax. The copy side
/// stays calm: no glow or streaks behind it, and only faint motes.
class HeroBackdrop extends StatefulWidget {
  const HeroBackdrop({super.key, required this.pointer});

  /// Pointer position over the hero, each axis -1 to 1.
  final ValueListenable<Offset> pointer;

  @override
  State<HeroBackdrop> createState() => _HeroBackdropState();
}

class _HeroBackdropState extends State<HeroBackdrop> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  late final ScrollAnimationController _scroll = ScrollAnimationController(onChanged: _onScroll);

  final ValueNotifier<double> _time = ValueNotifier(0);

  /// The pointer, eased so layers glide rather than jump.
  final ValueNotifier<Offset> _parallax = ValueNotifier(Offset.zero);

  /// 0 with the hero at rest, 1 once it has scrolled a full height away.
  final ValueNotifier<double> _scrolled = ValueNotifier(0);

  Duration _last = Duration.zero;
  bool _visible = true;
  bool _reduced = false;
  bool? _wide;
  List<_Mote> _motes = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.disableAnimationsOf(context);
    final wide = context.isDesktop;
    if (wide != _wide) {
      _wide = wide;
      _motes = _Mote.scatter(wide ? 54 : 26, wide: wide);
    }
    _scroll.attach(context);
    _sync();
  }

  void _onScroll(ScrollPlacement placement) {
    _visible = placement.visible;
    // The hero opens the page, so the scroll offset measures how far it has gone.
    final pixels = Scrollable.maybeOf(context)?.position.pixels ?? 0;
    _scrolled.value = (pixels / math.max(1.0, context.size?.height ?? 800)).clamp(0.0, 1.0);
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
    final dt = math.min((elapsed - _last).inMicroseconds / 1e6, 0.05);
    _last = elapsed;
    _time.value += dt;
    final target = widget.pointer.value;
    final current = _parallax.value;
    final next = Offset.lerp(current, target, 1 - math.exp(-3.5 * dt))!;
    // Settle exactly, so a still pointer stops repainting the architecture.
    if ((next - target).distanceSquared < 1e-6) {
      if (current != target) _parallax.value = target;
    } else {
      _parallax.value = next;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scroll.dispose();
    _time.dispose();
    _parallax.dispose();
    _scrolled.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = _wide ?? true;
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: CustomPaint(painter: _ArchitecturePainter(parallax: _parallax, scrolled: _scrolled, wide: wide)),
          ),
          RepaintBoundary(
            child: CustomPaint(
              painter: _AtmospherePainter(
                time: _time,
                parallax: _parallax,
                scrolled: _scrolled,
                motes: _motes,
                wide: wide,
                reduced: _reduced,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Palette ──────────────────────────────────────────────────────────────────
// Pearl and ivory tones with champagne and platinum accents only.

const _ivory = Color(0xFFF2E9DB);
const _pearl = Color(0xFFFAF7F1);
const _warm = Color(0xFFEDDFC8);
const _light = Color(0xFFFFFCF6);
const _shade = Color(0xFFDCC9AC); // shaded side of a curved wall
const _shadow = Color(0xFF8A7458); // warm cast shadow, used at low alpha
const _platinumMote = Color(0xFFBDB8AF);
const _sun = Color(0xFFFFF0D6); // warm daylight

/// A large shell of the room: its lit lip (a cubic from [a] to [b]) and
/// [inset], the offset from the lip to the shell's far, shaded side. All in
/// normalised coordinates.
typedef _Shell = ({Offset a, Offset c1, Offset c2, Offset b, Offset inset});

/// Wide layouts: a grand arch rising behind the sculpture and over the
/// room, and a long curved step in the floor. Stacked layouts keep both
/// below the copy.
List<_Shell> _shells(bool wide) => wide
    ? const [
        (a: Offset(0.16, 1.1), c1: Offset(0.3, 0.32), c2: Offset(0.62, -0.04), b: Offset(1.1, -0.02), inset: Offset(0.1, 0.11)),
        (a: Offset(-0.05, 0.86), c1: Offset(0.35, 0.77), c2: Offset(0.7, 0.8), b: Offset(1.05, 0.69), inset: Offset(0, 0.07)),
      ]
    : const [
        (a: Offset(-0.1, 0.78), c1: Offset(0.25, 0.47), c2: Offset(0.7, 0.43), b: Offset(1.1, 0.56), inset: Offset(0, 0.08)),
        (a: Offset(-0.05, 0.95), c1: Offset(0.4, 0.86), c2: Offset(0.7, 0.88), b: Offset(1.05, 0.82), inset: Offset(0, 0.05)),
      ];

/// Paints a [_Shell]: lit at its lip, turning through clear ivory into a
/// faint shade that dissolves before its far side, so it has no hard edge.
/// Gradients only, no blur, so it stays cheap to repaint.
void _paintShell(Canvas canvas, Size size, _Shell shell) {
  Offset at(Offset p) => Offset(p.dx * size.width, p.dy * size.height);
  final inset = at(shell.inset);
  final lip = Path()
    ..moveTo(at(shell.a).dx, at(shell.a).dy)
    ..cubicTo(at(shell.c1).dx, at(shell.c1).dy, at(shell.c2).dx, at(shell.c2).dy, at(shell.b).dx, at(shell.b).dy);
  final body = Path()
    ..addPath(lip, Offset.zero)
    ..extendWithPath(_ArchitecturePainter._reverse(lip.shift(inset)), Offset.zero)
    ..close();
  final mid = lip.computeMetrics().first;
  final from = mid.getTangentForOffset(mid.length / 2)!.position;
  canvas.drawPath(
    body,
    Paint()
      ..shader = ui.Gradient.linear(
        from,
        from + inset,
        [_light.withValues(alpha: 0.55), _light.withValues(alpha: 0), _shadow.withValues(alpha: 0.06), _shadow.withValues(alpha: 0)],
        const [0, 0.35, 0.72, 1],
      ),
  );
  // The lip itself: a hairline of champagne, fading out at both ends.
  final bounds = lip.getBounds().inflate(1);
  canvas.drawPath(
    lip,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        colors: [
          AppColors.softChampagne.withValues(alpha: 0),
          AppColors.softChampagne.withValues(alpha: 0.38),
          AppColors.softChampagne.withValues(alpha: 0.3),
          AppColors.softChampagne.withValues(alpha: 0),
        ],
        stops: const [0, 0.45, 0.75, 1],
      ).createShader(bounds),
  );
}

/// A curved wall: its lit edge (a cubic from [a] to [b]), its thickness as a
/// fraction of the width, how strongly the edge catches gold, and its depth
/// (0 far … 1 near) for parallax.
typedef _Wall = ({Offset a, Offset c1, Offset c2, Offset b, double width, double glow, double depth});

/// The walls, in normalised coordinates. On wide layouts they sweep up
/// behind the sculpture on the right; stacked layouts curve them under the
/// sculpture below the copy.
List<_Wall> _walls(bool wide) => wide
    ? const [
        (a: Offset(0.47, 1.08), c1: Offset(0.58, 0.62), c2: Offset(0.74, 0.08), b: Offset(1.04, -0.06), width: 0.075, glow: 1.0, depth: 0.55),
        (a: Offset(0.6, 1.08), c1: Offset(0.78, 0.74), c2: Offset(0.86, 0.3), b: Offset(1.06, 0.12), width: 0.055, glow: 0.8, depth: 0.7),
        (a: Offset(0.8, -0.06), c1: Offset(0.95, 0.2), c2: Offset(0.99, 0.5), b: Offset(1.06, 0.66), width: 0.045, glow: 0.7, depth: 0.85),
        (a: Offset(-0.06, 0.58), c1: Offset(0.12, 0.5), c2: Offset(0.26, 0.78), b: Offset(0.44, 1.08), width: 0.06, glow: 0.4, depth: 0.45),
      ]
    : const [
        (a: Offset(0.1, 1.06), c1: Offset(0.4, 0.6), c2: Offset(0.7, 0.36), b: Offset(1.06, 0.3), width: 0.08, glow: 0.8, depth: 0.55),
        (a: Offset(0.5, 1.06), c1: Offset(0.74, 0.74), c2: Offset(0.9, 0.5), b: Offset(1.06, 0.46), width: 0.06, glow: 0.6, depth: 0.75),
        (a: Offset(-0.06, 0.22), c1: Offset(0.2, 0.18), c2: Offset(0.4, 0.34), b: Offset(0.62, 0.62), width: 0.05, glow: 0.35, depth: 0.4),
      ];

/// Where the light pools: behind the sculpture.
Offset _focus(Size size, bool wide) => wide ? Offset(size.width * 0.7, size.height * 0.42) : Offset(size.width * 0.5, size.height * 0.72);

/// Layer shift for a [depth]: nearer layers move further with the pointer,
/// and rise faster as the page scrolls.
Offset _shift(Offset parallax, double scrolled, double depth, Size size) =>
    Offset(-parallax.dx * 16 * depth, -parallax.dy * 10 * depth - scrolled * size.height * 0.14 * depth);

Path _edgePath(_Wall wall, Size size, [double dx = 0]) {
  Offset at(Offset p) => Offset(p.dx * size.width + dx, p.dy * size.height);
  final a = at(wall.a), c1 = at(wall.c1), c2 = at(wall.c2), b = at(wall.b);
  return Path()
    ..moveTo(a.dx, a.dy)
    ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, b.dx, b.dy);
}

// ── Architecture ─────────────────────────────────────────────────────────────

class _ArchitecturePainter extends CustomPainter {
  _ArchitecturePainter({required this.parallax, required this.scrolled, required this.wide})
    : super(repaint: Listenable.merge([parallax, scrolled]));

  final ValueListenable<Offset> parallax;
  final ValueListenable<double> scrolled;
  final bool wide;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;
    final p = parallax.value;
    final s = scrolled.value;

    // Atmosphere: ivory at the edges, pearl where the light falls.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_ivory, _pearl, _warm],
          stops: [0, 0.45, 1],
        ).createShader(rect),
    );

    // Natural light: a broad, warm daylight wash entering from the upper
    // right, as through a tall window out of frame. Long, eased falloff so
    // it never shows an edge.
    final window = wide ? Offset(w * 1.05, -h * 0.15) : Offset(w * 0.95, -h * 0.1);
    final windowRadius = math.max(w, h) * (wide ? 1.05 : 1.2);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _sun.withValues(alpha: 0.5),
            _sun.withValues(alpha: 0.26),
            _sun.withValues(alpha: 0.08),
            _sun.withValues(alpha: 0),
          ],
          stops: const [0, 0.32, 0.62, 1],
        ).createShader(Rect.fromCircle(center: window, radius: windowRadius)),
    );

    // Far: the shell of the room, two very large, low-contrast curved
    // surfaces sweeping behind everything. Each is shaded across its width
    // with a soft lit lip, so it reads as form rather than line.
    canvas.save();
    final shell = _shift(p, s, 0.12, size);
    canvas.translate(shell.dx, shell.dy);
    for (final curve in _shells(wide)) {
      _paintShell(canvas, size, curve);
    }
    canvas.restore();

    // Far: architectural ribs, faint concentric arcs of a vault rising
    // behind the sculpture. They barely move, which reads as distance.
    canvas.save();
    canvas.translate(_shift(p, s, 0.2, size).dx, _shift(p, s, 0.2, size).dy);
    final ribCentre = wide ? Offset(w * 0.74, h * 1.32) : Offset(w * 0.5, h * 1.25);
    for (var i = 0; i < 5; i++) {
      final r = (wide ? w * 0.42 : w * 0.7) + i * (wide ? w * 0.09 : w * 0.16);
      final ribRect = Rect.fromCircle(center: ribCentre, radius: r);
      canvas.drawArc(
        ribRect,
        math.pi * 1.08,
        math.pi * 0.84,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..shader = RadialGradient(
            colors: [
              _platinumMote.withValues(alpha: 0.0),
              _platinumMote.withValues(alpha: 0.42 - i * 0.05),
              _platinumMote.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.92, 1.0],
          ).createShader(ribRect),
      );
    }
    canvas.restore();

    // Floor: the wall meets a softly shaded floor where the plinth stands.
    if (wide) {
      final floor = Rect.fromLTWH(0, h * 0.74, w, h * 0.26);
      canvas.drawRect(
        floor,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_warm.withValues(alpha: 0), _warm.withValues(alpha: 0.75), _ivory.withValues(alpha: 0.3)],
            stops: const [0, 0.45, 1],
          ).createShader(floor),
      );
      // Ambient occlusion where the wall meets the floor: a faint, soft
      // band of shade that grounds the room.
      final junction = Rect.fromLTWH(0, h * 0.68, w, h * 0.12);
      canvas.drawRect(
        junction,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_shadow.withValues(alpha: 0), _shadow.withValues(alpha: 0.045), _shadow.withValues(alpha: 0)],
            stops: const [0, 0.55, 1],
          ).createShader(junction),
      );
    }

    // Mid: the curved walls, each with a cast shadow, a shaded body and a
    // lit face, so they read as solid surfaces with depth.
    for (final wall in _walls(wide)) {
      final shift = _shift(p, s, wall.depth, size);
      canvas.save();
      canvas.translate(shift.dx, shift.dy);
      final thickness = wall.width * w;
      final edge = _edgePath(wall, size);
      final back = _edgePath(wall, size, thickness);
      final sheet = Path()
        ..addPath(edge, Offset.zero)
        ..extendWithPath(_reverse(back), Offset.zero)
        ..close();
      final bounds = sheet.getBounds();

      // Cast shadow, offset away from the light (top right).
      canvas.drawPath(
        sheet.shift(Offset(-thickness * 0.35, thickness * 0.3)),
        Paint()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30)
          ..color = _shadow.withValues(alpha: 0.1 + wall.depth * 0.07),
      );
      // Body: lit at the edge, turning into shade across its width.
      canvas.drawPath(
        sheet,
        Paint()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
          ..shader = LinearGradient(
            colors: [_light, _light.withValues(alpha: 0.4), _shade.withValues(alpha: 0.7)],
            stops: const [0, 0.45, 1],
          ).createShader(bounds),
      );
      // The gold edge catching the light, brightest midway along.
      final edgeBounds = edge.getBounds().inflate(1);
      Shader gold(double alpha) => LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          AppColors.champagneGold.withValues(alpha: 0),
          AppColors.softChampagne.withValues(alpha: alpha * wall.glow),
          AppColors.champagneGold.withValues(alpha: alpha * 0.8 * wall.glow),
          AppColors.champagneGold.withValues(alpha: 0),
        ],
        stops: const [0, 0.4, 0.62, 1],
      ).createShader(edgeBounds);
      canvas.drawPath(
        edge,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14)
          ..shader = gold(0.55),
      );
      canvas.drawPath(
        edge,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..shader = gold(0.8),
      );
      canvas.restore();
    }

    // Near: large out-of-focus swoops at the frame's edges, the nearest
    // layer, framing the scene like a lens close to the architecture.
    final near = _shift(p, s, 1.3, size);
    canvas.save();
    canvas.translate(near.dx, near.dy);
    final swoops = wide
        ? [
            Path()
              ..moveTo(-w * 0.05, h * 0.82)
              ..quadraticBezierTo(w * 0.18, h * 0.66, w * 0.36, h * 1.05),
            Path()
              ..moveTo(w * 0.9, -h * 0.05)
              ..quadraticBezierTo(w * 1.02, h * 0.3, w * 0.96, h * 0.78),
          ]
        : [
            Path()
              ..moveTo(-w * 0.05, h * 0.9)
              ..quadraticBezierTo(w * 0.3, h * 0.78, w * 0.55, h * 1.05),
          ];
    for (final swoop in swoops) {
      canvas.drawPath(
        swoop,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = wide ? 46 : 30
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22)
          ..color = _light.withValues(alpha: 0.7),
      );
      canvas.drawPath(
        swoop.shift(const Offset(8, 10)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
          ..color = AppColors.softChampagne.withValues(alpha: 0.28),
      );
    }
    canvas.restore();

    // Vignette: corners settle into warm shade, holding the eye in the middle.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: wide ? const Alignment(0.2, -0.1) : Alignment.center,
          radius: 1.05,
          colors: [_shadow.withValues(alpha: 0), _shadow.withValues(alpha: 0.035), _shadow.withValues(alpha: 0.09)],
          stops: const [0.55, 0.8, 1],
        ).createShader(rect),
    );

    // Scrolling away, the light lowers: a warm dusk rises from the floor.
    if (s > 0) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [_warm.withValues(alpha: 0.55 * s), _warm.withValues(alpha: 0)],
          ).createShader(rect),
      );
    }

    // Fade the foot into the page surface below.
    final foot = Rect.fromLTWH(0, h - 48, w, 48);
    canvas.drawRect(
      foot,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.background.withValues(alpha: 0), AppColors.background],
        ).createShader(foot),
    );
  }

  /// The same cubic, traced backwards (for closing a wall's outline).
  static Path _reverse(Path path) {
    final metric = path.computeMetrics().first;
    final reversed = Path();
    const steps = 48;
    for (var i = steps; i >= 0; i--) {
      final point = metric.getTangentForOffset(metric.length * i / steps)!.position;
      i == steps ? reversed.moveTo(point.dx, point.dy) : reversed.lineTo(point.dx, point.dy);
    }
    return reversed;
  }

  @override
  bool shouldRepaint(_ArchitecturePainter old) => old.wide != wide || old.parallax != parallax || old.scrolled != scrolled;
}

// ── Atmosphere ───────────────────────────────────────────────────────────────

class _Mote {
  const _Mote(this.x, this.y, this.depth, this.size, this.speed, this.phase, this.gold);

  final double x, y;

  /// 0 far … 1 near: nearer motes are larger, brighter and move further.
  final double depth;
  final double size, speed, phase;
  final bool gold;

  /// Most motes gather on the sculpture's side, so the copy stays clear.
  static List<_Mote> scatter(int count, {required bool wide}) {
    final rand = math.Random(11);
    return [
      for (var i = 0; i < count; i++)
        () {
          final depth = rand.nextDouble();
          final x = wide && rand.nextDouble() < 0.7 ? 0.48 + rand.nextDouble() * 0.52 : rand.nextDouble();
          final y = !wide && rand.nextDouble() < 0.7 ? 0.45 + rand.nextDouble() * 0.55 : rand.nextDouble();
          return _Mote(x, y, depth, 0.8 + depth * 2.4, 0.004 + rand.nextDouble() * 0.01, rand.nextDouble() * math.pi * 2, rand.nextDouble() < 0.62);
        }(),
    ];
  }
}

class _AtmospherePainter extends CustomPainter {
  _AtmospherePainter({
    required this.time,
    required this.parallax,
    required this.scrolled,
    required this.motes,
    required this.wide,
    required this.reduced,
  }) : super(repaint: Listenable.merge([time, parallax, scrolled]));

  final ValueListenable<double> time;
  final ValueListenable<Offset> parallax;
  final ValueListenable<double> scrolled;
  final List<_Mote> motes;
  final bool wide;
  final bool reduced;

  @override
  void paint(Canvas canvas, Size size) {
    final t = time.value;
    final p = parallax.value;
    final s = scrolled.value;
    // The light swells in as the page opens.
    final intro = reduced ? 1.0 : Curves.easeOutCubic.transform((t / 1.8).clamp(0.0, 1.0));

    _ambient(canvas, size, t, s, intro);
    _rays(canvas, size, t, intro);
    if (!reduced) _streaks(canvas, size, t, p, s, intro);
    _motes(canvas, size, t, p, s, intro);
  }

  /// Golden light behind the sculpture, breathing slowly. As the page
  /// scrolls it rises with the sculpture and warms before fading.
  void _ambient(Canvas canvas, Size size, double t, double s, double intro) {
    final breath = 0.5 + 0.5 * math.sin(t * 0.7);
    final focus = _focus(size, wide) + Offset(0, -s * size.height * 0.12);
    final radius = math.max(size.width, size.height) * (wide ? 0.34 : 0.42);
    final strength = intro * (1 + math.sin(s * math.pi) * 0.35) * (1 - s * 0.5);
    final glow = (0.17 + breath * 0.05) * strength;
    // A slightly wider pool with an eased, many-step falloff: gentler at
    // the centre and with no visible ring where it meets the room.
    canvas.drawCircle(
      focus,
      radius * 1.12,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _light.withValues(alpha: 0.42 * strength),
            _light.withValues(alpha: 0.26 * strength),
            AppColors.softChampagne.withValues(alpha: glow),
            AppColors.softChampagne.withValues(alpha: glow * 0.45),
            AppColors.softChampagne.withValues(alpha: glow * 0.12),
            AppColors.softChampagne.withValues(alpha: 0),
          ],
          stops: const [0, 0.2, 0.42, 0.62, 0.82, 1],
        ).createShader(Rect.fromCircle(center: focus, radius: radius * 1.12)),
    );
  }

  /// Faint shafts of light falling from the upper right onto the sculpture.
  void _rays(Canvas canvas, Size size, double t, double intro) {
    if (!wide) return;
    final origin = Offset(size.width * 1.02, -size.height * 0.08);
    final reach = size.width * 0.62;
    for (var i = 0; i < 3; i++) {
      final angle = math.pi * (0.66 + i * 0.07) + math.sin(t * 0.12 + i * 1.7) * 0.015;
      final spread = 0.035 + i * 0.008;
      final a = origin + Offset(math.cos(angle - spread), math.sin(angle - spread)) * reach;
      final b = origin + Offset(math.cos(angle + spread), math.sin(angle + spread)) * reach;
      final ray = Path()
        ..moveTo(origin.dx, origin.dy)
        ..lineTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..close();
      canvas.drawPath(
        ray,
        Paint()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24)
          ..shader = RadialGradient(
            center: Alignment.topRight,
            radius: 1.2,
            colors: [_sun.withValues(alpha: 0.36 * intro), _sun.withValues(alpha: 0.12 * intro), _sun.withValues(alpha: 0)],
            stops: const [0, 0.5, 1],
          ).createShader(ray.getBounds()),
      );
    }
  }

  /// Champagne light flowing along the walls' gold edges, like a highlight
  /// travelling across polished metal.
  void _streaks(Canvas canvas, Size size, double t, Offset p, double s, double intro) {
    final walls = _walls(wide);
    for (var i = 0; i < walls.length; i++) {
      final wall = walls[i];
      final shift = _shift(p, s, wall.depth, size);
      final ui.PathMetric metric = _edgePath(wall, size).shift(shift).computeMetrics().first;
      final length = metric.length;
      final span = length * 0.24;
      // Each streak glides along its edge, then rests before the next pass.
      final cycle = (t * (0.06 + i * 0.012) + i * 0.37) % 1.0;
      final head = (cycle * 1.6 - 0.2) * length;
      if (head < 0 || head - span > length) continue;
      final start = (head - span).clamp(0.0, length);
      final end = head.clamp(0.0, length);
      if (end - start < 2) continue;
      final segment = metric.extractPath(start, end);
      final from = metric.getTangentForOffset(start)!.position;
      final to = metric.getTangentForOffset(end)!.position;
      final alpha = wall.glow * intro;
      // Transparent at the tail, brightest at the head.
      Shader along(Color color, double a) =>
          ui.Gradient.linear(from, to, [color.withValues(alpha: 0), color.withValues(alpha: a)]);
      canvas.drawPath(
        segment,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 7
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7)
          ..shader = along(AppColors.softChampagne, 0.55 * alpha),
      );
      canvas.drawPath(
        segment,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 1.6
          ..shader = along(_light, 0.95 * alpha),
      );
    }
  }

  /// Gold and platinum motes drifting upwards, swaying gently, each layer
  /// shifting with the pointer according to its depth.
  void _motes(Canvas canvas, Size size, double t, Offset p, double s, double intro) {
    final w = size.width;
    final h = size.height;
    final core = Paint();
    final halo = Paint();
    for (final m in motes) {
      final y = (m.y - t * m.speed * (0.4 + m.depth * 0.6) - s * 0.25 * m.depth) % 1.0;
      final x = m.x + math.sin(t * 0.35 + m.phase) * 0.01 * (0.5 + m.depth);
      final offset = Offset(x * w - p.dx * 26 * m.depth, y * h - p.dy * 16 * m.depth);
      // Fade near the top and bottom edges; quieter behind the copy.
      final edge = math.min(1.0, math.min(y, 1 - y) * 6);
      final behindCopy = wide ? x < 0.46 : y < 0.45;
      final twinkle = 0.7 + 0.3 * math.sin(t * 1.3 + m.phase * 3);
      final alpha = (0.3 + m.depth * 0.55) * edge * twinkle * intro * (behindCopy ? 0.4 : 1);
      if (alpha <= 0.01) continue;
      final colour = m.gold ? AppColors.champagneGold : _platinumMote;
      halo.color = colour.withValues(alpha: alpha * 0.16);
      canvas.drawCircle(offset, m.size * 2.6, halo);
      core.color = colour.withValues(alpha: alpha);
      canvas.drawCircle(offset, m.size, core);
      // A pinpoint highlight on the nearest motes, like light on metal.
      if (m.depth > 0.7) {
        core.color = _light.withValues(alpha: alpha * 0.9);
        canvas.drawCircle(offset + Offset(-m.size * 0.3, -m.size * 0.3), m.size * 0.35, core);
      }
    }
  }

  @override
  bool shouldRepaint(_AtmospherePainter old) =>
      old.motes != motes || old.wide != wide || old.reduced != reduced || old.time != time;
}
