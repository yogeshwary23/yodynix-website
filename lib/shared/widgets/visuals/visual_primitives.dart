import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Building blocks for the illustrated compositions. Every composition is
/// laid out on a fixed design canvas and scaled with [VisualCanvas], so the
/// numbers below are design-space pixels.

class Skel extends StatelessWidget {
  const Skel({super.key, required this.width, this.height = 7, this.color = AppColors.skeleton, this.radius = 99});

  final double width;
  final double height;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radius)),
    );
  }
}

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    this.width,
    this.height,
    required this.child,
    this.radius = 14,
    this.color = AppColors.card,
    this.padding = const EdgeInsets.all(12),
    this.elevation = 1,
    this.gradient,
  });

  final double? width;
  final double? height;
  final Widget child;
  final double radius;
  final Color color;
  final EdgeInsets padding;
  final double elevation;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.09)),
        boxShadow: elevation == 0
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5 * elevation),
                  blurRadius: 30 * elevation,
                  offset: Offset(0, 14 * elevation),
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.07 * elevation),
                  blurRadius: 40 * elevation,
                  spreadRadius: -8,
                ),
              ],
      ),
      child: child,
    );
  }
}

class BrowserFrame extends StatelessWidget {
  const BrowserFrame({super.key, required this.width, required this.height, required this.child, this.elevation = 1});

  final double width;
  final double height;
  final Widget child;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Panel(
      width: width,
      height: height,
      padding: EdgeInsets.zero,
      radius: 12,
      elevation: elevation,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              color: AppColors.cardRaised,
              child: Row(
                children: [
                  for (final c in const [Color(0xFFFF6B6B), Color(0xFFFFC94D), Color(0xFF3DD68C)])
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 11,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class PhoneFrame extends StatelessWidget {
  const PhoneFrame({
    super.key,
    required this.width,
    required this.height,
    required this.child,
    this.screenColor = AppColors.card,
  });

  final double width;
  final double height;
  final Widget child;
  final Color screenColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2850),
        borderRadius: BorderRadius.circular(width * 0.17),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.22), blurRadius: 34, offset: const Offset(0, 12))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width * 0.14),
        child: ColoredBox(
          color: screenColor,
          child: Column(
            children: [
              const SizedBox(height: 6),
              Container(
                width: width * 0.3,
                height: 7,
                decoration: BoxDecoration(color: const Color(0xFF1A2850), borderRadius: BorderRadius.circular(8)),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class IconBubble extends StatelessWidget {
  const IconBubble({super.key, required this.icon, required this.color, this.size = 34, this.filled = false});

  final IconData icon;
  final Color color;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, size: size * 0.55, color: filled ? AppColors.white : color),
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.color, this.size = 26});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.6)]),
        border: Border.all(color: AppColors.card, width: 2),
      ),
      child: Icon(Icons.person_rounded, size: size * 0.6, color: AppColors.white),
    );
  }
}

/// Gently bobs its child up and down. Static when animations are disabled.
class Floating extends StatefulWidget {
  const Floating({super.key, required this.child, this.amplitude = 6, this.periodMs = 4200, this.phase = 0});

  final Widget child;
  final double amplitude;
  final int periodMs;
  final double phase;

  @override
  State<Floating> createState() => _FloatingState();
}

class _FloatingState extends State<Floating> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: widget.periodMs),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dy = math.sin((_controller.value + widget.phase) * 2 * math.pi) * widget.amplitude;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: widget.child,
    );
  }
}

/// Scales a fixed-size composition to fill any box while keeping proportions.
class VisualCanvas extends StatelessWidget {
  const VisualCanvas({
    super.key,
    required this.child,
    this.designSize = const Size(600, 400),
    this.tones = const [Color(0xFF0B1328), Color(0xFF0F1D3D)],
    this.blobs = const [AppColors.primary, AppColors.iceBlue],
    this.showGrid = true,
    this.fit = BoxFit.cover,
  });

  final Widget child;
  final Size designSize;
  final List<Color> tones;
  final List<Color> blobs;
  final bool showGrid;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: tones, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: ClipRect(
        child: FittedBox(
          fit: fit,
          child: SizedBox(
            width: designSize.width,
            height: designSize.height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (blobs.isNotEmpty)
                  Positioned(
                    left: -designSize.width * 0.15,
                    top: -designSize.height * 0.25,
                    child: _Blob(color: blobs.first, size: designSize.width * 0.6),
                  ),
                if (blobs.length > 1)
                  Positioned(
                    right: -designSize.width * 0.12,
                    bottom: -designSize.height * 0.3,
                    child: _Blob(color: blobs[1], size: designSize.width * 0.55),
                  ),
                if (showGrid)
                  Positioned.fill(
                    child: CustomPaint(painter: GridPainter(color: AppColors.white.withValues(alpha: 0.035))),
                  ),
                Positioned.fill(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)]),
      ),
    );
  }
}

// ------------------------------------------------------------------ Painters

class GridPainter extends CustomPainter {
  const GridPainter({required this.color, this.step = 28});

  final Color color;
  final double step;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) => oldDelegate.color != color;
}

class LineChartPainter extends CustomPainter {
  const LineChartPainter({required this.points, required this.color, this.fill = true, this.strokeWidth = 2.4});

  /// Values from 0 to 1, evenly spaced on the x-axis.
  final List<double> points;
  final Color color;
  final bool fill;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final dx = size.width / (points.length - 1);
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final p = Offset(i * dx, size.height * (1 - points[i]));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        final prev = Offset((i - 1) * dx, size.height * (1 - points[i - 1]));
        final cx = (prev.dx + p.dx) / 2;
        path.cubicTo(cx, prev.dy, cx, p.dy, p.dx, p.dy);
      }
    }
    if (fill) {
      final area = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Offset.zero & size),
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) => oldDelegate.points != points || oldDelegate.color != color;
}

class BarsPainter extends CustomPainter {
  const BarsPainter({required this.values, required this.color, this.highlight, this.highlightColor});

  final List<double> values;
  final Color color;
  final int? highlight;
  final Color? highlightColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gap = size.width / values.length;
    final barWidth = gap * 0.55;
    for (var i = 0; i < values.length; i++) {
      final h = size.height * values[i];
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(i * gap + (gap - barWidth) / 2, size.height - h, barWidth, h),
        Radius.circular(barWidth / 3),
      );
      canvas.drawRRect(rect, Paint()..color = i == highlight ? (highlightColor ?? color) : color.withValues(alpha: 0.28));
    }
  }

  @override
  bool shouldRepaint(covariant BarsPainter oldDelegate) => oldDelegate.values != values;
}

class DonutPainter extends CustomPainter {
  const DonutPainter({required this.fractions, required this.colors, this.stroke = 10});

  final List<double> fractions;
  final List<Color> colors;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = AppColors.skeleton
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    var start = -math.pi / 2;
    for (var i = 0; i < fractions.length; i++) {
      final sweep = fractions[i] * math.pi * 2;
      canvas.drawArc(
        rect,
        start,
        sweep - 0.08,
        false,
        Paint()
          ..color = colors[i % colors.length]
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = stroke,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant DonutPainter oldDelegate) => oldDelegate.fractions != fractions;
}

/// Nodes joined by soft links — used for "connected systems" visuals.
class NetworkPainter extends CustomPainter {
  const NetworkPainter({
    required this.nodes,
    required this.links,
    required this.color,
    this.accent = AppColors.accent,
    this.pulse = 0,
  });

  /// Node positions, normalised 0..1.
  final List<Offset> nodes;
  final List<(int, int)> links;
  final Color color;
  final Color accent;

  /// 0..1 animation progress for the travelling pulse dots.
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    Offset at(int i) => Offset(nodes[i].dx * size.width, nodes[i].dy * size.height);

    final linkPaint = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..strokeWidth = 1.3;
    for (final (a, b) in links) {
      canvas.drawLine(at(a), at(b), linkPaint);
    }
    for (var i = 0; i < links.length; i++) {
      final (a, b) = links[i];
      final t = (pulse + i * 0.17) % 1.0;
      final p = Offset.lerp(at(a), at(b), t)!;
      canvas.drawCircle(p, 2.4, Paint()..color = (i.isEven ? color : accent).withValues(alpha: 0.75));
    }
    for (var i = 0; i < nodes.length; i++) {
      final c = at(i);
      canvas.drawCircle(c, 9, Paint()..color = (i % 3 == 0 ? accent : color).withValues(alpha: 0.12));
      canvas.drawCircle(c, 4, Paint()..color = i % 3 == 0 ? accent : color);
    }
  }

  @override
  bool shouldRepaint(covariant NetworkPainter oldDelegate) => oldDelegate.pulse != pulse;
}

class RingsPainter extends CustomPainter {
  const RingsPainter({required this.color, this.count = 3, this.dashed = true});

  final Color color;
  final int count;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.shortestSide / 2;
    for (var i = 1; i <= count; i++) {
      final r = maxR * i / count;
      final paint = Paint()
        ..color = color.withValues(alpha: 0.10 + 0.05 * (count - i))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      if (!dashed) {
        canvas.drawCircle(center, r, paint);
        continue;
      }
      const segments = 72;
      for (var s = 0; s < segments; s += 2) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: r),
          s * 2 * math.pi / segments,
          2 * math.pi / segments,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant RingsPainter oldDelegate) => false;
}

/// Simple connector with an arrow head, used in flow diagrams.
class ArrowPainter extends CustomPainter {
  const ArrowPainter({required this.from, required this.to, required this.color, this.curve = 0});

  final Offset from;
  final Offset to;
  final Color color;
  final double curve;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2 + curve);
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, to.dx, to.dy);
    canvas.drawPath(path, paint);
    final angle = math.atan2(to.dy - mid.dy, to.dx - mid.dx);
    const len = 7.0;
    canvas.drawLine(to, to - Offset(math.cos(angle - 0.5), math.sin(angle - 0.5)) * len, paint);
    canvas.drawLine(to, to - Offset(math.cos(angle + 0.5), math.sin(angle + 0.5)) * len, paint);
  }

  @override
  bool shouldRepaint(covariant ArrowPainter oldDelegate) => false;
}

Text vLabel(String text, {double size = 11, Color color = AppColors.ink, FontWeight weight = FontWeight.w600}) {
  return Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.clip,
    style: AppTypography.body(fontSize: size, color: color, fontWeight: weight, height: 1.2),
  );
}

Widget chipCard(IconData icon, String label, Color color, {double iconSize = 24}) {
  return Panel(
    padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
    radius: 12,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconBubble(icon: icon, color: color, size: iconSize),
        const SizedBox(width: 8),
        vLabel(label),
      ],
    ),
  );
}
