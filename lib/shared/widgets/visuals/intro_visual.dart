import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'visual_primitives.dart';

/// Isometric "technology stack": three floating glass platforms joined by a
/// beam of light, with rising data particles and four orbiting capability
/// chips (business, innovation, learning, careers). Laid out on a 560×520
/// design canvas and scaled to fit.
class IntroVisual extends StatefulWidget {
  const IntroVisual({super.key});

  @override
  State<IntroVisual> createState() => _IntroVisualState();
}

class _IntroVisualState extends State<IntroVisual> with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this, duration: const Duration(seconds: 12));

  static const _size = Size(560, 520);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _clock.stop();
    } else if (!_clock.isAnimating) {
      _clock.repeat();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox.fromSize(
          size: _size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: RepaintBoundary(child: CustomPaint(painter: _StackPainter(_clock))),
              ),
              const Positioned(
                left: 18,
                top: 92,
                child: _Chip(icon: Icons.storefront_rounded, color: AppColors.primary, phase: 0),
              ),
              const Positioned(
                right: 22,
                top: 58,
                child: _Chip(icon: Icons.auto_awesome_rounded, color: AppColors.primaryTint, phase: 0.25),
              ),
              const Positioned(
                left: 40,
                bottom: 96,
                child: _Chip(icon: Icons.school_rounded, color: AppColors.primaryTint, phase: 0.5),
              ),
              const Positioned(
                right: 34,
                bottom: 120,
                child: _Chip(icon: Icons.rocket_launch_rounded, color: AppColors.primary, phase: 0.75),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small floating glass tile carrying a single icon.
class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.color, required this.phase});

  final IconData icon;
  final Color color;
  final double phase;

  @override
  Widget build(BuildContext context) {
    return Floating(
      amplitude: 7,
      periodMs: 5200,
      phase: phase,
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF2A3243).withValues(alpha: 0.92), AppColors.deepNavy.withValues(alpha: 0.92)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.45)),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.22), blurRadius: 26, spreadRadius: -4),
            const BoxShadow(color: Color(0x8005070C), blurRadius: 20, offset: Offset(0, 12)),
          ],
        ),
        child: Icon(icon, size: 28, color: color),
      ),
    );
  }
}

class _StackPainter extends CustomPainter {
  _StackPainter(this.clock) : super(repaint: clock);

  final Animation<double> clock;

  static const _cos = 0.8660254; // cos 30°
  static const _sin = 0.5; // sin 30°

  late Offset _origin;

  /// Projects a 3D point (x, y on the floor plane, z up) to screen space.
  Offset _p(double x, double y, double z) => _origin + Offset((x - y) * _cos, (x + y) * _sin - z);

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value;
    _origin = Offset(size.width / 2, size.height * 0.66);

    double bob(double phase) => math.sin((t * 3 + phase) * 2 * math.pi) * 5;

    final levels = [
      (half: 150.0, z: 0.0 + bob(0), thick: 16.0),
      (half: 120.0, z: 92.0 + bob(0.33), thick: 14.0),
      (half: 88.0, z: 180.0 + bob(0.66), thick: 12.0),
    ];

    _paintFloorGlow(canvas);
    _paintOrbit(canvas, t, back: true);

    for (final (i, level) in levels.indexed) {
      _paintSlab(canvas, level.half, level.z, level.thick, i);
      switch (i) {
        case 0:
          _paintCircuits(canvas, level.half, level.z, t);
        case 1:
          _paintModules(canvas, level.half, level.z);
        case 2:
          _paintCore(canvas, level.z, t);
      }
      if (i < levels.length - 1) _paintBeam(canvas, level.z, levels[i + 1].z - levels[i + 1].thick, t);
    }

    _paintBeam(canvas, levels.last.z, levels.last.z + 120, t, fadeOut: true);
    _paintOrbit(canvas, t, back: false);
  }

  void _paintFloorGlow(Canvas canvas) {
    final center = _p(0, 0, -40);
    final rect = Rect.fromCenter(center: center, width: 420, height: 170);
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [AppColors.primary.withValues(alpha: 0.35), AppColors.primaryTint.withValues(alpha: 0.06), Colors.transparent],
          stops: const [0, 0.55, 1],
        ).createShader(rect),
    );
  }

  void _paintSlab(Canvas canvas, double a, double z, double thick, int index) {
    final top = [_p(-a, -a, z), _p(a, -a, z), _p(a, a, z), _p(-a, a, z)];
    final bottom = [_p(-a, -a, z - thick), _p(a, -a, z - thick), _p(a, a, z - thick), _p(-a, a, z - thick)];

    // Visible sides: front-left (corner 3 → 2) and front-right (2 → 1).
    final leftFace = Path()..addPolygon([top[3], top[2], bottom[2], bottom[3]], true);
    final rightFace = Path()..addPolygon([top[2], top[1], bottom[1], bottom[2]], true);
    canvas.drawPath(leftFace, Paint()..color = const Color(0xFF262E3E));
    canvas.drawPath(rightFace, Paint()..color = const Color(0xFF1A202C));

    final topFace = Path()..addPolygon(top, true);
    final bounds = topFace.getBounds();
    canvas.drawPath(
      topFace,
      Paint()
        ..shader = LinearGradient(
          colors: [const Color(0xFF323B4E).withValues(alpha: 0.95), const Color(0xFF202735).withValues(alpha: 0.95)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bounds),
    );

    // Faint grid on the top surface.
    final grid = Paint()
      ..color = AppColors.primaryTint.withValues(alpha: 0.07)
      ..strokeWidth = 1;
    const divisions = 6;
    for (var k = 1; k < divisions; k++) {
      final f = -a + 2 * a * k / divisions;
      canvas.drawLine(_p(f, -a, z), _p(f, a, z), grid);
      canvas.drawLine(_p(-a, f, z), _p(a, f, z), grid);
    }

    // Edges: cyan on the leading corners, blue elsewhere.
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppColors.primary.withValues(alpha: 0.55);
    canvas.drawPath(topFace, edge);
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..shader = const LinearGradient(colors: [AppColors.primary, AppColors.primaryTint, AppColors.primary])
          .createShader(Rect.fromPoints(top[3], top[1]));
    canvas.drawPath(Path()..addPolygon([top[3], top[2], top[1]], false), rim);
    canvas.drawLine(
      bottom[3],
      bottom[2],
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.25)
        ..strokeWidth = 1,
    );
    canvas.drawLine(
      bottom[2],
      bottom[1],
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.25)
        ..strokeWidth = 1,
    );
    canvas.drawLine(
      top[2],
      bottom[2],
      Paint()
        ..color = AppColors.primaryTint.withValues(alpha: 0.5)
        ..strokeWidth = 1.2,
    );
  }

  /// Circuit traces radiating from the centre with light travelling outwards.
  void _paintCircuits(Canvas canvas, double a, double z, double t) {
    final trace = Paint()
      ..color = AppColors.primaryTint.withValues(alpha: 0.28)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final inner = a * 0.25;
    final outer = a * 0.88;
    const routes = [(1.0, 0.0), (0.0, 1.0), (-1.0, 0.0), (0.0, -1.0)];
    for (final (i, r) in routes.indexed) {
      final side = i.isEven ? 0.4 : -0.4;
      final path = Path()..moveTo(_p(r.$1 * inner, r.$2 * inner, z).dx, _p(r.$1 * inner, r.$2 * inner, z).dy);
      final mid = Offset(r.$1 * a * 0.55, r.$2 * a * 0.55);
      final bend = Offset(mid.dx + r.$2 * a * side, mid.dy + r.$1 * a * side);
      final end = Offset(bend.dx + r.$1 * (outer - a * 0.55), bend.dy + r.$2 * (outer - a * 0.55));
      for (final pt in [mid, bend, end]) {
        final s = _p(pt.dx, pt.dy, z);
        path.lineTo(s.dx, s.dy);
      }
      canvas.drawPath(path, trace);
      final endPt = _p(end.dx, end.dy, z);
      canvas.drawCircle(endPt, 3, Paint()..color = AppColors.primaryTint.withValues(alpha: 0.7));

      // Travelling pulse.
      final metric = path.computeMetrics().first;
      final pos = metric.getTangentForOffset(metric.length * ((t * 2 + i / 4) % 1))?.position;
      if (pos != null) {
        canvas.drawCircle(pos, 6, Paint()..color = AppColors.primaryTint.withValues(alpha: 0.18));
        canvas.drawCircle(pos, 2.4, Paint()..color = AppColors.primaryTint);
      }
    }
  }

  /// Raised module blocks on the middle platform.
  void _paintModules(Canvas canvas, double a, double z) {
    const cells = [(-0.55, -0.55), (0.15, -0.55), (-0.55, 0.15), (0.15, 0.15)];
    final size = a * 0.4;
    for (final (i, c) in cells.indexed) {
      final x0 = c.$1 * a;
      final y0 = c.$2 * a;
      final h = 8.0 + (i % 2) * 6;
      final topFace = [_p(x0, y0, z + h), _p(x0 + size, y0, z + h), _p(x0 + size, y0 + size, z + h), _p(x0, y0 + size, z + h)];
      final left = [topFace[3], topFace[2], _p(x0 + size, y0 + size, z), _p(x0, y0 + size, z)];
      final right = [topFace[2], topFace[1], _p(x0 + size, y0, z), _p(x0 + size, y0 + size, z)];
      final color = i == 1 || i == 2 ? AppColors.primaryTint : AppColors.primary;
      canvas.drawPath(Path()..addPolygon(left, true), Paint()..color = color.withValues(alpha: 0.22));
      canvas.drawPath(Path()..addPolygon(right, true), Paint()..color = color.withValues(alpha: 0.14));
      canvas.drawPath(Path()..addPolygon(topFace, true), Paint()..color = color.withValues(alpha: 0.32));
      canvas.drawPath(
        Path()..addPolygon(topFace, true),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = color.withValues(alpha: 0.8),
      );
    }
  }

  /// Glowing core on the top platform.
  void _paintCore(Canvas canvas, double z, double t) {
    final center = _p(0, 0, z);
    final pulse = 0.5 + 0.5 * math.sin(t * 6 * 2 * math.pi);
    for (final (r, alpha) in [(60.0, 0.10), (42.0, 0.18)]) {
      canvas.drawOval(
        Rect.fromCenter(center: center, width: r * 2 * _cos * 1.15, height: r * 1.15),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..color = AppColors.primaryTint.withValues(alpha: alpha + 0.12 * pulse),
      );
    }
    final orb = Rect.fromCircle(center: center.translate(0, -18), radius: 22);
    canvas.drawCircle(
      orb.center,
      40,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.primaryTint.withValues(alpha: 0.35 + 0.15 * pulse),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: orb.center, radius: 40)),
    );
    canvas.drawCircle(
      orb.center,
      18,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.35),
          colors: [AppColors.white, AppColors.primaryTint, AppColors.primary],
          stops: [0, 0.4, 1],
        ).createShader(orb),
    );
  }

  /// Vertical light beam with rising particles between two heights.
  void _paintBeam(Canvas canvas, double fromZ, double toZ, double t, {bool fadeOut = false}) {
    final a = _p(0, 0, fromZ);
    final b = _p(0, 0, toZ);
    final rect = Rect.fromPoints(a.translate(-8, 0), b.translate(8, 0));
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.primaryTint.withValues(alpha: 0.22),
            AppColors.primary.withValues(alpha: fadeOut ? 0 : 0.16),
          ],
        ).createShader(rect),
    );
    canvas.drawLine(
      a,
      b,
      Paint()
        ..strokeWidth = 1.4
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.primaryTint.withValues(alpha: 0.8),
            AppColors.primaryTint.withValues(alpha: fadeOut ? 0 : 0.5),
          ],
        ).createShader(rect),
    );
    for (var k = 0; k < 3; k++) {
      final p = (t * 4 + k / 3) % 1;
      final pos = Offset.lerp(a, b, p)!;
      final alpha = math.sin(p * math.pi);
      canvas.drawCircle(pos, 2.6, Paint()..color = AppColors.primaryTint.withValues(alpha: 0.9 * alpha));
    }
  }

  /// Tilted orbit around the stack, split so the back half sits behind it.
  void _paintOrbit(Canvas canvas, double t, {required bool back}) {
    final center = _p(0, 0, 96);
    final rect = Rect.fromCenter(center: center, width: 470, height: 150);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.primaryTint.withValues(alpha: back ? 0.12 : 0.22);
    canvas.drawArc(rect, back ? math.pi : 0, math.pi, false, paint);

    // A light point riding the orbit.
    final angle = t * 2 * math.pi;
    final onBack = math.sin(angle) < 0;
    if (onBack != back) return;
    final pos = Offset(center.dx + math.cos(angle) * rect.width / 2, center.dy + math.sin(angle) * rect.height / 2);
    canvas.drawCircle(pos, 8, Paint()..color = AppColors.primaryTint.withValues(alpha: back ? 0.08 : 0.2));
    canvas.drawCircle(pos, 3, Paint()..color = AppColors.primaryTint.withValues(alpha: back ? 0.5 : 1));
  }

  @override
  bool shouldRepaint(_StackPainter oldDelegate) => false;
}
