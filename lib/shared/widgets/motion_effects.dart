import 'dart:math' as math;

import 'package:flutter/gestures.dart' show PointerHoverEvent;
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Whether the visitor asked the system for reduced motion.
bool prefersReducedMotion(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Pulls [child] a few pixels towards a hovering mouse pointer and springs
/// back when it leaves, for buttons that respond to the cursor. Touch input
/// and reduced motion leave the child still.
class Magnetic extends StatefulWidget {
  const Magnetic({super.key, required this.child, this.strength = 6});

  final Widget child;

  /// Largest offset in logical pixels, reached at the child's edge.
  final double strength;

  @override
  State<Magnetic> createState() => _MagneticState();
}

class _MagneticState extends State<Magnetic> {
  Offset _offset = Offset.zero;

  void _hover(PointerHoverEvent event) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final size = box.size;
    final dx = (event.localPosition.dx / size.width - 0.5) * 2;
    final dy = (event.localPosition.dy / size.height - 0.5) * 2;
    setState(() => _offset = Offset(dx.clamp(-1, 1) * widget.strength, dy.clamp(-1, 1) * widget.strength * 0.6));
  }

  @override
  Widget build(BuildContext context) {
    if (prefersReducedMotion(context)) return widget.child;
    return MouseRegion(
      onHover: _hover,
      onExit: (_) => setState(() => _offset = Offset.zero),
      child: TweenAnimationBuilder<Offset>(
        tween: Tween(end: _offset),
        duration: Duration(milliseconds: _offset == Offset.zero ? 420 : 140),
        curve: _offset == Offset.zero ? Curves.elasticOut : Curves.easeOut,
        builder: (_, offset, child) => Transform.translate(offset: offset, child: child),
        child: widget.child,
      ),
    );
  }
}

/// Tilts [child] in perspective towards a hovering mouse pointer, with a
/// soft champagne sheen that follows it like light across glass. Touch
/// input and reduced motion leave the child flat.
class Tilt3D extends StatefulWidget {
  const Tilt3D({super.key, required this.child, this.maxAngle = 5, this.radius = 0, this.sheen = true});

  final Widget child;

  /// Largest tilt in degrees.
  final double maxAngle;

  /// Corner radius of the sheen, matching the child's shape.
  final double radius;
  final bool sheen;

  @override
  State<Tilt3D> createState() => _Tilt3DState();
}

class _Tilt3DState extends State<Tilt3D> {
  Offset _pointer = Offset.zero; // -1..1 on each axis
  bool _inside = false;

  void _hover(PointerHoverEvent event) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final size = box.size;
    setState(() {
      _inside = true;
      _pointer = Offset(
        (event.localPosition.dx / size.width * 2 - 1).clamp(-1, 1),
        (event.localPosition.dy / size.height * 2 - 1).clamp(-1, 1),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (prefersReducedMotion(context)) return widget.child;
    final target = _inside ? _pointer : Offset.zero;
    return MouseRegion(
      onHover: _hover,
      onExit: (_) => setState(() => _inside = false),
      child: TweenAnimationBuilder<Offset>(
        tween: Tween(end: target),
        duration: Duration(milliseconds: _inside ? 120 : 500),
        curve: Curves.easeOutCubic,
        builder: (_, p, child) {
          final angle = widget.maxAngle * math.pi / 180;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateX(-p.dy * angle)
            ..rotateY(p.dx * angle);
          final strength = p.distance.clamp(0.0, 1.0);
          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: !widget.sheen
                ? child
                : Stack(
                    children: [
                      child!,
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: _inside ? 1 : strength,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(widget.radius),
                                gradient: RadialGradient(
                                  center: Alignment(p.dx, p.dy),
                                  radius: 0.9,
                                  colors: [
                                    AppColors.white.withValues(alpha: 0.32),
                                    AppColors.softChampagne.withValues(alpha: 0.08),
                                    AppColors.softChampagne.withValues(alpha: 0),
                                  ],
                                  stops: const [0, 0.45, 1],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
