import 'dart:ui' show Color;

/// The procedural 3D scenes defined in `web/three/yodynix3d.js`.
enum Scene3D {
  /// Signature hero sculpture: liquid-gold and platinum ribbons around a
  /// morphing glass core, with floating rings, spheres, cubes and gold dust.
  hero,

  /// Aluminium laptop with a live browser preview.
  web,

  /// Two titanium-framed phones with app screens.
  mobile,

  /// Compact network of glass neurons.
  ai,


  /// Exploded stack of glass architecture layers.
  software,

  /// Meshing machined gears with a glass data conduit.
  automation,

  /// Channels orbiting a chrome hub above a rising chart.
  marketing,

  /// Homepage "Who We Are": 3D around a photograph laid out by Flutter.
  about,

  /// About page heroes, likewise around a photograph; the variant names the
  /// page (who, team, philosophy, process).
  aboutPage,

  /// Laptop whose screen shows a real project image.
  preview,

  /// Portfolio device mock-ups: a project image on a laptop, desktop,
  /// tablet or phone (the variant), or all three floating together (`hero`).
  device,

  /// Rotating metallic ecosystem of interconnected components (technology).
  ecosystem,

  /// Connected delivery workflow whose stages rise in on scroll (process).
  workflow,


  /// One arrangement per sector; the variant names the industry.
  industries,
}

/// Render resolution and effect density for a mounted scene.
enum SceneQuality { high, medium, low }

/// Options passed to the engine when a scene is mounted.
class SceneOptions {
  const SceneOptions({
    required this.quality,
    required this.reducedMotion,
    this.background,
    this.image,
    this.variant,
    this.lean = 0,
  });

  final SceneQuality quality;

  /// Renders a still frame that only updates on scroll or resize.
  final bool reducedMotion;

  /// Opaque backdrop matching the host surface, so glass refracts it.
  final Color? background;

  /// Absolute URL of an image shown on a device screen ([Scene3D.preview]).
  final String? image;

  /// Scene-specific variation, e.g. `shop` for the web scene.
  final String? variant;

  /// Horizontal composition bias, -1 (left) to 1 (right).
  final double lean;
}

/// Asset base name of a scene's still render, e.g. `web_shop`.
String renderName(Scene3D scene, String? variant) => variant == null ? scene.name : '${scene.name}_$variant';

/// A mounted scene in the shared WebGL engine.
abstract interface class SceneHandle {
  /// Whether the scene is on screen. Off-screen scenes never render.
  void setActive(bool active);

  /// Scroll progress through the viewport: 0 entering at the bottom, 1 leaving at the top.
  void setProgress(double progress);

  /// Pointer position for parallax, each axis -1 to 1.
  void setPointer(double x, double y);

  /// Hover / emphasis, 0 to 1.
  void setFocus(double focus);

  /// Frees the scene's GPU resources and listeners.
  void dispose();
}
