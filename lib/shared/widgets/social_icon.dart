import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/social_link.dart';

/// A social platform's icon, in one colour. LinkedIn has no Material icon,
/// so its "in" mark is drawn in code; every other platform uses
/// [SocialPlatform.icon].
class SocialIcon extends StatelessWidget {
  const SocialIcon(this.platform, {super.key, required this.size, required this.color});

  final SocialPlatform platform;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (platform != SocialPlatform.linkedin) return Icon(platform.icon, size: size, color: color);
    // Centred at [size] inside a larger box, as an Icon is.
    return Center(
      widthFactor: 1,
      heightFactor: 1,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: LinkedInGlyphPainter(color)),
      ),
    );
  }
}

/// LinkedIn's mark: a rounded square with "in" cut out of it, so whatever
/// is behind shows through the letters.
class LinkedInGlyphPainter extends CustomPainter {
  const LinkedInGlyphPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final bounds = Offset.zero & Size.square(s);
    final clear = Paint()..blendMode = BlendMode.clear;
    canvas.saveLayer(bounds, Paint());
    canvas.drawRRect(RRect.fromRectAndRadius(bounds, Radius.circular(s * 0.18)), Paint()..color = color);
    // "i": dot and stem.
    canvas.drawCircle(Offset(s * 0.27, s * 0.26), s * 0.085, clear);
    canvas.drawRect(Rect.fromLTWH(s * 0.19, s * 0.4, s * 0.16, s * 0.42), clear);
    // "n": stem, arch and right leg.
    canvas.drawRect(Rect.fromLTWH(s * 0.42, s * 0.4, s * 0.15, s * 0.42), clear);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(s * 0.625, s * 0.58), radius: s * 0.115),
      math.pi,
      math.pi,
      false,
      Paint()
        ..blendMode = BlendMode.clear
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.15,
    );
    canvas.drawRect(Rect.fromLTWH(s * 0.665, s * 0.57, s * 0.15, s * 0.25), clear);
    canvas.restore();
  }

  @override
  bool shouldRepaint(LinkedInGlyphPainter oldDelegate) => oldDelegate.color != color;
}
