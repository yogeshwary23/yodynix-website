import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'visual_primitives.dart';

/// Artwork for the three core pillar cards. Each one is unique to its pillar.
enum PillarArt { business, innovation, careers }

/// Scene for a pillar card on a 320×200 design canvas, scaled to cover its
/// box. [active] brightens the scene while the card is hovered or focused.
/// The top-right corner is kept clear for the card's index number.
class PillarVisual extends StatelessWidget {
  const PillarVisual({super.key, required this.art, this.active = false});

  final PillarArt art;
  final bool active;

  static const _size = Size(320, 200);

  @override
  Widget build(BuildContext context) {
    final glowAt = switch (art) {
      PillarArt.business => const Alignment(-0.6, -0.8),
      PillarArt.innovation => Alignment.center,
      PillarArt.careers => const Alignment(0.8, -0.9),
    };
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1C1A), AppColors.charcoal, Color(0xFF24221F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: active ? 1 : 0.7,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: glowAt,
                    radius: 0.9,
                    colors: [
                      AppColors.primaryTint.withValues(alpha: 0.22),
                      AppColors.primary.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                    stops: const [0, 0.5, 1],
                  ),
                ),
              ),
            ),
            CustomPaint(painter: GridPainter(color: AppColors.white.withValues(alpha: 0.035), step: 22)),
            ClipRect(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox.fromSize(
                  size: _size,
                  child: switch (art) {
                    PillarArt.business => const _BusinessScene(),
                    PillarArt.innovation => const _InnovationScene(),
                    PillarArt.careers => const _CareersScene(),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------- Shared

/// Charcoal glass surface used by every scene.
BoxDecoration _glass({double radius = 12, Color edge = AppColors.primary, double glow = 0.18}) => BoxDecoration(
  gradient: LinearGradient(
    colors: [const Color(0xFF36332F).withValues(alpha: 0.95), const Color(0xFF2A2826).withValues(alpha: 0.95)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: edge.withValues(alpha: 0.38)),
  boxShadow: [
    BoxShadow(color: edge.withValues(alpha: glow), blurRadius: 22, spreadRadius: -6),
    const BoxShadow(color: Color(0x990C0A08), blurRadius: 18, offset: Offset(0, 10)),
  ],
);

Widget _iconTile(IconData icon, {Color color = AppColors.primaryTint, double size = 34}) => Container(
  width: size,
  height: size,
  decoration: _glass(radius: size * 0.3, edge: color, glow: 0.3),
  child: Icon(icon, size: size * 0.52, color: color),
);

Widget _tag(String text, {IconData? icon, Color color = AppColors.primaryTint}) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
  decoration: _glass(radius: 99, edge: color, glow: 0.12),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (icon != null) ...[Icon(icon, size: 11, color: color), const SizedBox(width: 4)],
      Text(
        text,
        maxLines: 1,
        style: AppTypography.body(fontSize: 9.5, fontWeight: FontWeight.w600, color: VizColors.text, height: 1.1),
      ),
    ],
  ),
);

/// Shared animation clock for the scenes that move. Static when the platform
/// asks for reduced motion.
mixin _SceneClock<T extends StatefulWidget> on State<T>, SingleTickerProviderStateMixin<T> {
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 6));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      clock.stop();
    } else if (!clock.isAnimating) {
      clock.repeat();
    }
  }

  @override
  void dispose() {
    clock.dispose();
    super.dispose();
  }
}

// ---------------------------------------------------------------- Business

/// Storefront website, a mobile shop screen and a growth chart.
class _BusinessScene extends StatelessWidget {
  const _BusinessScene();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Website window.
        Positioned(
          left: 26,
          top: 30,
          child: Container(
            width: 196,
            height: 136,
            decoration: _glass(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.white.withValues(alpha: 0.06))),
                  ),
                  child: Row(
                    children: [
                      for (final c in [AppColors.primary, AppColors.primaryTint, AppColors.primaryTint])
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(color: c.withValues(alpha: 0.8), shape: BoxShape.circle),
                        ),
                      const SizedBox(width: 8),
                      Skel(width: 70, height: 6, color: AppColors.white.withValues(alpha: 0.08)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Skel(width: 74, height: 8, color: AppColors.white),
                          const SizedBox(height: 6),
                          Skel(width: 58, height: 6, color: AppColors.white.withValues(alpha: 0.25)),
                          const SizedBox(height: 4),
                          Skel(width: 66, height: 6, color: AppColors.white.withValues(alpha: 0.25)),
                          const SizedBox(height: 10),
                          Container(
                            width: 46,
                            height: 14,
                            decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(99)),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        width: 70,
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [AppColors.primary.withValues(alpha: 0.5), AppColors.primaryTint.withValues(alpha: 0.25)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(Icons.shopping_bag_rounded, color: AppColors.white, size: 26),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        if (i > 0) const SizedBox(width: 6),
                        Expanded(
                          child: Container(
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.white.withValues(alpha: 0.06)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Mobile shop screen.
        Positioned(
          right: 34,
          top: 60,
          child: Floating(
            amplitude: 4,
            periodMs: 5000,
            child: Container(
              width: 74,
              height: 128,
              padding: const EdgeInsets.all(7),
              decoration: _glass(radius: 16, edge: AppColors.primaryTint, glow: 0.28),
              child: Column(
                children: [
                  Skel(width: 20, height: 4, color: AppColors.white.withValues(alpha: 0.15)),
                  const SizedBox(height: 8),
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [AppColors.primaryTint.withValues(alpha: 0.4), AppColors.primary.withValues(alpha: 0.3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(child: Icon(Icons.phone_iphone_rounded, size: 20, color: AppColors.white)),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Skel(width: 44, height: 5, color: AppColors.white.withValues(alpha: 0.5)),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Skel(width: 30, height: 5, color: AppColors.primaryTint.withValues(alpha: 0.7)),
                  ),
                  const Spacer(),
                  Container(
                    height: 16,
                    decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.add_shopping_cart_rounded, size: 10, color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Growth chip.
        Positioned(
          left: 150,
          bottom: 14,
          child: Floating(
            amplitude: 3,
            periodMs: 4400,
            phase: 0.4,
            child: Container(
              width: 92,
              height: 46,
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              decoration: _glass(radius: 10, edge: AppColors.primaryTint),
              child: Row(
                children: [
                  const Icon(Icons.trending_up_rounded, size: 16, color: AppColors.primaryTint),
                  const SizedBox(width: 6),
                  Expanded(
                    child: CustomPaint(
                      size: const Size.fromHeight(30),
                      painter: const LineChartPainter(
                        points: [0.15, 0.3, 0.25, 0.5, 0.45, 0.75, 0.9],
                        color: AppColors.primaryTint,
                        strokeWidth: 1.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------- Innovation

/// An AI core wired to Flutter, automation and engineering nodes.
class _InnovationScene extends StatefulWidget {
  const _InnovationScene();

  @override
  State<_InnovationScene> createState() => _InnovationSceneState();
}

class _InnovationSceneState extends State<_InnovationScene> with SingleTickerProviderStateMixin, _SceneClock<_InnovationScene> {
  static const _center = Offset(160, 100);

  /// Satellite positions, in design pixels.
  static const _satellites = [
    (Offset(56, 50), Icons.flutter_dash_rounded),
    (Offset(220, 42), Icons.bolt_rounded),
    (Offset(62, 154), Icons.hub_rounded),
    (Offset(258, 152), Icons.code_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: clock,
      builder: (context, _) {
        final t = clock.value;
        final pulse = 0.5 + 0.5 * math.sin(t * 2 * math.pi);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _CircuitPainter(t: t, center: _center, ends: [for (final s in _satellites) s.$1]),
              ),
            ),
            Positioned(
              left: _center.dx - 60,
              top: _center.dy - 60,
              child: SizedBox.square(
                dimension: 120,
                child: CustomPaint(painter: RingsPainter(color: AppColors.primaryTint, count: 2)),
              ),
            ),
            Positioned(
              left: _center.dx - 31,
              top: _center.dy - 31,
              child: Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryTint],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryTint.withValues(alpha: 0.3 + 0.25 * pulse),
                      blurRadius: 30 + 10 * pulse,
                    ),
                  ],
                ),
                child: const Icon(Icons.psychology_rounded, size: 34, color: AppColors.white),
              ),
            ),
            for (final (i, s) in _satellites.indexed)
              Positioned(
                left: s.$1.dx - 17,
                top: s.$1.dy - 17,
                child: _iconTile(s.$2, color: i.isEven ? AppColors.primaryTint : AppColors.primary),
              ),
            Positioned(left: 128, top: 160, child: _tag('AI', icon: Icons.auto_awesome_rounded)),
          ],
        );
      },
    );
  }
}

/// Right-angled traces from the core to each satellite with travelling light.
class _CircuitPainter extends CustomPainter {
  const _CircuitPainter({required this.t, required this.center, required this.ends});

  final double t;
  final Offset center;
  final List<Offset> ends;

  @override
  void paint(Canvas canvas, Size size) {
    final trace = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppColors.primary.withValues(alpha: 0.45);
    for (final (i, end) in ends.indexed) {
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(center.dx + (end.dx - center.dx) * 0.5, center.dy)
        ..lineTo(center.dx + (end.dx - center.dx) * 0.5, end.dy)
        ..lineTo(end.dx, end.dy);
      canvas.drawPath(path, trace);
      final metric = path.computeMetrics().first;
      final pos = metric.getTangentForOffset(metric.length * ((t * 2 + i * 0.25) % 1))?.position;
      if (pos != null) {
        canvas.drawCircle(pos, 5, Paint()..color = AppColors.primaryTint.withValues(alpha: 0.2));
        canvas.drawCircle(pos, 2.2, Paint()..color = AppColors.primaryTint);
      }
    }
  }

  @override
  bool shouldRepaint(_CircuitPainter oldDelegate) => oldDelegate.t != t;
}

// ----------------------------------------------------------------- Careers

/// A rising career path of milestones ending at a launch, with the tracks
/// on offer floating alongside.
class _CareersScene extends StatefulWidget {
  const _CareersScene();

  @override
  State<_CareersScene> createState() => _CareersSceneState();
}

class _CareersSceneState extends State<_CareersScene> with SingleTickerProviderStateMixin, _SceneClock<_CareersScene> {
  static const _milestones = [
    (Offset(36, 172), Icons.school_rounded),
    (Offset(96, 140), Icons.code_rounded),
    (Offset(156, 110), Icons.work_rounded),
  ];
  static const _launch = Offset(222, 72);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: clock,
            builder: (context, _) => CustomPaint(
              painter: _PathPainter(t: clock.value, points: [for (final m in _milestones) m.$1, _launch]),
            ),
          ),
        ),
        for (final (i, m) in _milestones.indexed)
          Positioned(
            left: m.$1.dx - 15,
            top: m.$1.dy - 15,
            child: _iconTile(m.$2, size: 30, color: i.isEven ? AppColors.primaryTint : AppColors.primary),
          ),
        Positioned(
          left: _launch.dx - 26,
          top: _launch.dy - 26,
          child: Floating(
            amplitude: 4,
            periodMs: 3800,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: AppColors.brandGradient,
                boxShadow: [BoxShadow(color: AppColors.primaryTint.withValues(alpha: 0.45), blurRadius: 28)],
              ),
              child: const Icon(Icons.rocket_launch_rounded, size: 26, color: AppColors.white),
            ),
          ),
        ),
        Positioned(
          left: 18,
          top: 22,
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _tag('Flutter', icon: Icons.flutter_dash_rounded),
              _tag('UI/UX', icon: Icons.palette_outlined, color: AppColors.primary),
            ],
          ),
        ),
        Positioned(
          left: 34,
          top: 56,
          child: Wrap(
            spacing: 6,
            children: [
              _tag('Python', icon: Icons.terminal_rounded, color: AppColors.primary),
              _tag('AI', icon: Icons.auto_awesome_rounded),
            ],
          ),
        ),
        Positioned(right: 18, bottom: 18, child: _tag('Web', icon: Icons.language_rounded)),
      ],
    );
  }
}

/// Dashed rising path through the milestones with a light travelling along.
class _PathPainter extends CustomPainter {
  const _PathPainter({required this.t, required this.points});

  final double t;
  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final a = points[i - 1];
      final b = points[i];
      path.cubicTo(a.dx + (b.dx - a.dx) * 0.5, a.dy, a.dx + (b.dx - a.dx) * 0.5, b.dy, b.dx, b.dy);
    }
    final metric = path.computeMetrics().first;
    final dash = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(colors: [AppColors.primary, AppColors.primaryTint])
          .createShader(Rect.fromPoints(points.first, points.last));
    for (var d = 0.0; d < metric.length; d += 9) {
      canvas.drawPath(metric.extractPath(d, d + 5), dash);
    }
    final pos = metric.getTangentForOffset(metric.length * t)?.position;
    if (pos != null) {
      canvas.drawCircle(pos, 6, Paint()..color = AppColors.primaryTint.withValues(alpha: 0.22));
      canvas.drawCircle(pos, 2.6, Paint()..color = AppColors.primaryTint);
    }
  }

  @override
  bool shouldRepaint(_PathPainter oldDelegate) => oldDelegate.t != t;
}
