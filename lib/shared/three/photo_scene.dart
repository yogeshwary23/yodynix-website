import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../widgets/parallax_photo.dart';
import '../widgets/reveal.dart';
import 'interactive_3d_object.dart';
import 'scene3d.dart';

/// A photograph framed in a warm setting with a 3D composition built
/// around and in front of it. The scene's canvas is transparent and places
/// each piece against the frame's position here (see `about` and
/// `aboutPage` in web/three/yodynix3d.js), so the two read as one picture.
/// The photo drifts with scroll and pointer behind the 3D, which separates
/// them in depth. Phones get the scene's transparent still over the photo.
class PhotoScene extends StatelessWidget {
  const PhotoScene({
    super.key,
    required this.photo,
    required this.photoAlt,
    required this.photoFallback,
    required this.scene,
    this.variant,
    required this.sceneLabel,
    required this.pointer,
  });

  /// Extension-less photo path, resolved by `AssetRegistry`.
  final String photo;
  final String photoAlt;
  final Widget photoFallback;
  final Scene3D scene;
  final String? variant;

  /// Describes the 3D for screen readers.
  final String sceneLabel;
  final ValueListenable<Offset> pointer;

  /// The photo's frame, as fractions of the visual. Must match the scenes,
  /// which place the 3D around it.
  static const _frame = Rect.fromLTWH(0.09, 0.08, 0.82, 0.72);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1188 / 1100,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final radius = BorderRadius.circular(context.responsive(mobile: 22.0, desktop: 30.0));
          return Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned(
                left: -40,
                right: -40,
                top: -30,
                bottom: -20,
                child: IgnorePointer(child: RepaintBoundary(child: CustomPaint(painter: _SettingPainter()))),
              ),
              Positioned(
                left: w * _frame.left,
                top: h * _frame.top,
                width: w * _frame.width,
                height: h * _frame.height,
                child: Reveal(
                  offset: 18,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      boxShadow: const [
                        BoxShadow(color: Color(0x1F4A3B28), blurRadius: 70, spreadRadius: -12, offset: Offset(0, 34)),
                        BoxShadow(color: Color(0x264A3B28), blurRadius: 26, spreadRadius: -10, offset: Offset(0, 14)),
                        BoxShadow(color: Color(0x1A4A3B28), blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: radius,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ParallaxPhoto(
                            basePath: photo,
                            semanticLabel: photoAlt,
                            pointer: pointer,
                            depth: 16,
                            fallback: photoFallback,
                          ),
                          // Soft daylight blooming from above and behind, the
                          // direction the 3D is lit from, and the faintest
                          // shade at the floor to seat the plinth.
                          const IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: Alignment(0.2, -1.1),
                                  radius: 1.1,
                                  colors: [Color(0x2EFFF8EC), Color(0x00FFF8EC)],
                                ),
                              ),
                            ),
                          ),
                          const IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Color(0x142E2418), Color(0x002E2418)],
                                  stops: [0, 0.3],
                                ),
                              ),
                            ),
                          ),
                          IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: radius,
                                border: Border.all(color: AppColors.white.withValues(alpha: 0.5)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Interactive3DObject(
                  scene: scene,
                  variant: variant,
                  semanticLabel: sceneLabel,
                  background: null,
                  pointer: pointer,
                  fallback: const SizedBox.shrink(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The setting behind the photograph: a warm pool of light and the faint
/// outlines of receding arches, as in the hero. Static, so it paints once.
class _SettingPainter extends CustomPainter {
  const _SettingPainter();

  static const _light = Color(0xFFFFFCF6);
  static const _sun = Color(0xFFFFF0D6);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Warm light pooling behind the composition, falling off gently.
    final centre = Offset(w * 0.52, h * 0.44);
    final radius = w * 0.62;
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _light.withValues(alpha: 0.85),
            _sun.withValues(alpha: 0.5),
            AppColors.softChampagne.withValues(alpha: 0.16),
            AppColors.softChampagne.withValues(alpha: 0.05),
            AppColors.softChampagne.withValues(alpha: 0),
          ],
          stops: const [0, 0.28, 0.56, 0.8, 1],
        ).createShader(Rect.fromCircle(center: centre, radius: radius)),
    );

    // Receding arch outlines, fading towards the floor.
    final base = h * 0.84;
    for (final (i, width) in [0.66, 0.82, 0.98].indexed) {
      final r = w * width / 2;
      final top = h * (0.12 - i * 0.06);
      final spring = top + r;
      final path = Path()
        ..moveTo(w / 2 - r, base)
        ..lineTo(w / 2 - r, spring)
        ..arcToPoint(Offset(w / 2 + r, spring), radius: Radius.circular(r))
        ..lineTo(w / 2 + r, base);
      final bounds = Rect.fromLTRB(w / 2 - r, top, w / 2 + r, base);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.champagneGold.withValues(alpha: 0.3 - i * 0.07),
              AppColors.champagneGold.withValues(alpha: 0.12 - i * 0.03),
              AppColors.champagneGold.withValues(alpha: 0),
            ],
            stops: const [0, 0.55, 1],
          ).createShader(bounds),
      );
    }
  }

  @override
  bool shouldRepaint(_SettingPainter old) => false;
}
