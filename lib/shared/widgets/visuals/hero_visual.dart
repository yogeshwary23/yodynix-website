import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'visual_primitives.dart';

/// Cinematic hero composition: a glowing "innovation core" inside tilted
/// orbital rings, linked to an AI assistant, a website, a mobile app and an
/// automation workflow. Laid out on a 640×600 design canvas.
class HeroVisual extends StatefulWidget {
  const HeroVisual({super.key});

  @override
  State<HeroVisual> createState() => _HeroVisualState();
}

class _HeroVisualState extends State<HeroVisual> with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(vsync: this, duration: const Duration(seconds: 14));

  static const _size = Size(640, 600);
  static const _core = Offset(320, 300);

  /// Where each connector meets its tile, in design pixels.
  static const _anchors = [Offset(200, 120), Offset(470, 150), Offset(470, 400), Offset(190, 470)];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _spin.stop();
    } else if (!_spin.isAnimating) {
      _spin.repeat();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox.fromSize(
        size: _size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Light pooling behind the core.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: AppColors.glow(center: const Alignment(0, 0), radius: 0.62, strength: 1.4)),
              ),
            ),
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _spin,
                  builder: (context, _) => CustomPaint(
                    painter: _OrbitPainter(t: _spin.value, center: _core, anchors: _anchors),
                  ),
                ),
              ),
            ),
            Positioned(left: _core.dx - 95, top: _core.dy - 95, child: const _Core(size: 190)),
            const Positioned(left: 24, top: 56, child: Floating(child: _AiTile())),
            const Positioned(left: 400, top: 34, child: Floating(phase: 0.3, amplitude: 7, child: _WebTile())),
            const Positioned(left: 458, top: 300, child: Floating(phase: 0.6, amplitude: 9, child: _MobileTile())),
            const Positioned(left: 30, top: 430, child: Floating(phase: 0.85, child: _AutomationTile())),
          ],
        ),
      ),
    );
  }
}

class _Core extends StatelessWidget {
  const _Core({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.35),
          radius: 0.95,
          colors: [AppColors.iceBlue, AppColors.cyan, AppColors.electricBlue, Color(0xFF14308F), Color(0xFF060B1C)],
          stops: [0, 0.22, 0.45, 0.8, 1],
        ),
        boxShadow: [
          BoxShadow(color: AppColors.electricBlue.withValues(alpha: 0.65), blurRadius: 70, spreadRadius: 6),
          BoxShadow(color: AppColors.cyan.withValues(alpha: 0.35), blurRadius: 140, spreadRadius: 30),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.52,
          height: size * 0.52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.deepNavy.withValues(alpha: 0.55),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.35), width: 1.4),
          ),
          child: const Icon(Icons.auto_awesome_rounded, color: AppColors.white, size: 46),
        ),
      ),
    );
  }
}

/// Navy glass tile with a faint electric-blue edge.
class _GlassTile extends StatelessWidget {
  const _GlassTile({required this.child, this.width});

  final Widget child;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [const Color(0xFF1A2850).withValues(alpha: 0.92), const Color(0xFF0D1631).withValues(alpha: 0.92)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.electricBlue.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 30, offset: const Offset(0, 16)),
          BoxShadow(color: AppColors.electricBlue.withValues(alpha: 0.16), blurRadius: 36, spreadRadius: -6),
        ],
      ),
      child: child,
    );
  }
}

Widget _tileHeader(IconData icon, String title, String caption) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: AppColors.brandGradient,
          boxShadow: [BoxShadow(color: AppColors.electricBlue.withValues(alpha: 0.5), blurRadius: 14)],
        ),
        child: Icon(icon, size: 19, color: AppColors.white),
      ),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          vLabel(title, size: 12.5, weight: FontWeight.w700),
          const SizedBox(height: 2),
          vLabel(caption, size: 9.5, color: AppColors.muted),
        ],
      ),
    ],
  );
}

class _AiTile extends StatelessWidget {
  const _AiTile();

  @override
  Widget build(BuildContext context) {
    return _GlassTile(
      width: 206,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tileHeader(Icons.smart_toy_rounded, 'AI Assistant', 'Ready to help'),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(9)),
              child: Skel(width: 86, height: 4, color: AppColors.white.withValues(alpha: 0.8)),
            ),
          ),
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.cardRaised, borderRadius: BorderRadius.circular(9)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skel(width: 150, height: 4, color: Color(0xFF3A4B75)),
                SizedBox(height: 5),
                Skel(width: 112, height: 4, color: Color(0xFF3A4B75)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < 3; i++)
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cyan.withValues(alpha: 1 - i * 0.28),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WebTile extends StatelessWidget {
  const _WebTile();

  @override
  Widget build(BuildContext context) {
    return BrowserFrame(
      width: 214,
      height: 150,
      child: ColoredBox(
        color: AppColors.card,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 54,
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(colors: [Color(0xFF132A6B), AppColors.electricBlue]),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    vLabel('Websites', size: 11, weight: FontWeight.w700, color: AppColors.white),
                    const SizedBox(height: 6),
                    Skel(width: 70, height: 4, color: AppColors.white.withValues(alpha: 0.6)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    Expanded(
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.cardRaised,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: i == 0 ? AppColors.electricBlue.withValues(alpha: 0.6) : AppColors.border),
                        ),
                      ),
                    ),
                    if (i < 2) const SizedBox(width: 6),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileTile extends StatelessWidget {
  const _MobileTile();

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      width: 132,
      height: 252,
      screenColor: const Color(0xFF0D1631),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            vLabel('Mobile Apps', size: 10.5, weight: FontWeight.w700),
            const SizedBox(height: 8),
            Container(
              height: 62,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), gradient: AppColors.warmGradient),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skel(width: 40, height: 4, color: AppColors.white.withValues(alpha: 0.7)),
                  const Spacer(),
                  vLabel('Your App', size: 13, weight: FontWeight.w700, color: AppColors.white),
                ],
              ),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < 3; i++)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.cardRaised, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == 0 ? AppColors.electricBlue : AppColors.skeleton,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Skel(width: 50.0 - i * 8, height: 4, color: const Color(0xFF3A4B75)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AutomationTile extends StatelessWidget {
  const _AutomationTile();

  static const _steps = [(Icons.bolt_rounded, 'Trigger'), (Icons.tune_rounded, 'Process'), (Icons.task_alt_rounded, 'Done')];

  @override
  Widget build(BuildContext context) {
    return _GlassTile(
      width: 226,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tileHeader(Icons.settings_suggest_rounded, 'Automation', 'Workflow running'),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final (i, (icon, label)) in _steps.indexed) ...[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        color: i == 2 ? null : AppColors.cardRaised,
                        gradient: i == 2 ? AppColors.brandGradient : null,
                        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.45)),
                      ),
                      child: Icon(icon, size: 16, color: i == 2 ? AppColors.white : AppColors.cyan),
                    ),
                    const SizedBox(height: 5),
                    vLabel(label, size: 8.5, color: AppColors.lightGrey),
                  ],
                ),
                if (i < _steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
                      decoration: const BoxDecoration(gradient: AppColors.brandGradient),
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Tilted orbital rings (drawn as ellipses for a 3D feel), travelling light
/// points and glowing connectors from the core to each tile.
class _OrbitPainter extends CustomPainter {
  const _OrbitPainter({required this.t, required this.center, required this.anchors});

  final double t;
  final Offset center;
  final List<Offset> anchors;

  @override
  void paint(Canvas canvas, Size size) {
    // Connectors.
    for (final (i, anchor) in anchors.indexed) {
      final shader = LinearGradient(
        colors: [AppColors.electricBlue.withValues(alpha: 0.7), AppColors.electricBlue.withValues(alpha: 0.05)],
      ).createShader(Rect.fromPoints(center, anchor));
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..quadraticBezierTo((center.dx + anchor.dx) / 2, center.dy, anchor.dx, anchor.dy);
      canvas.drawPath(
        path,
        Paint()
          ..shader = shader
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
      // A light pulse travelling outwards along each connector.
      final metric = path.computeMetrics().first;
      final progress = (t * 2 + i * 0.25) % 1;
      final tangent = metric.getTangentForOffset(metric.length * progress);
      if (tangent != null) _spark(canvas, tangent.position, 3.2, (1 - progress).clamp(0.2, 1));
    }

    // Rings: (radius x, squash, tilt, speed).
    const rings = [(250.0, 0.30, -0.18, 1.0), (205.0, 0.36, 0.22, -1.4), (150.0, 0.42, -0.05, 2.0)];
    for (final (i, (rx, squash, tilt, speed)) in rings.indexed) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(tilt);
      final rect = Rect.fromCenter(center: Offset.zero, width: rx * 2, height: rx * 2 * squash);
      canvas.drawOval(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = i == 0 ? 1.6 : 1.1
          ..shader = SweepGradient(
            transform: GradientRotation(t * 2 * math.pi * speed),
            colors: [
              AppColors.electricBlue.withValues(alpha: 0.05),
              AppColors.cyan.withValues(alpha: 0.85),
              AppColors.iceBlue.withValues(alpha: 0.25),
              AppColors.electricBlue.withValues(alpha: 0.05),
            ],
            stops: const [0, 0.3, 0.55, 1],
          ).createShader(rect),
      );
      // Orbiting light point; dimmer while "behind" the core.
      final angle = t * 2 * math.pi * speed + i * 2.1;
      final p = Offset(math.cos(angle) * rx, math.sin(angle) * rx * squash);
      _spark(canvas, p, i == 0 ? 4.5 : 3.5, math.sin(angle) < 0 ? 0.35 : 1);
      canvas.restore();
    }

    // Floor reflection under the core.
    canvas.drawOval(
      Rect.fromCenter(center: center.translate(0, 150), width: 260, height: 34),
      Paint()
        ..color = AppColors.electricBlue.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
  }

  void _spark(Canvas canvas, Offset p, double r, double opacity) {
    canvas.drawCircle(
      p,
      r * 3,
      Paint()
        ..color = AppColors.electricBlue.withValues(alpha: 0.35 * opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 1.6),
    );
    canvas.drawCircle(p, r, Paint()..color = Color.lerp(AppColors.iceBlue, AppColors.white, 0.4)!.withValues(alpha: opacity));
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) => oldDelegate.t != t;
}
