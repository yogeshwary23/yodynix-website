import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../core/theme/app_colors.dart';
import '../widgets/smart_image.dart';
import 'interactive_3d_object.dart';
import 'scene3d.dart';

/// The homepage's signature sculpture. Always live (lighter on phones),
/// with parallax driven by the pointer anywhere over the hero.
class Hero3DScene extends StatelessWidget {
  const Hero3DScene({super.key, required this.fallback, this.pointer, this.background = AppColors.pearlWhite});

  final Widget fallback;
  final ValueListenable<Offset>? pointer;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Interactive3DObject(
      scene: Scene3D.hero,
      semanticLabel:
          'A liquid-gold and platinum ribbon sculpture woven around a morphing glass core, '
          'with floating metallic rings, chrome spheres and glass cubes in drifting gold dust.',
      fallback: fallback,
      background: background,
      pointer: pointer,
      essential: true,
    );
  }
}

/// The 3D concept for a service, in the shared chrome-and-glass language.
class Service3DVisual extends StatelessWidget {
  const Service3DVisual({super.key, required this.serviceId, required this.fallback, this.focus = 0, this.background = AppColors.white});

  final String serviceId;
  final Widget fallback;
  final double focus;
  final Color background;

  /// Scene for each service, by `ServiceOffering.id`.
  static Scene3D sceneFor(String serviceId) => switch (serviceId) {
    'website_development' || 'ecommerce_development' => Scene3D.web,
    'mobile_app_development' || 'flutter_development' => Scene3D.mobile,
    'ai_solutions_chatbots' => Scene3D.ai,
    'custom_software_development' || 'ui_ux_design' => Scene3D.software,
    'business_automation' => Scene3D.automation,
    _ => Scene3D.marketing,
  };

  /// Variation that keeps services sharing a scene visually distinct.
  static String? variantFor(String serviceId) => switch (serviceId) {
    'ecommerce_development' => 'shop',
    'flutter_development' => 'single',
    'ui_ux_design' => 'design',
    'branding_digital_presence' => 'brand',
    _ => null,
  };

  static String labelFor(Scene3D scene) => switch (scene) {
    Scene3D.web => 'An aluminium laptop showing a website, with a glass interface panel floating above it.',
    Scene3D.mobile => 'Two metal-framed smartphones floating side by side, showing app screens.',
    Scene3D.ai => 'A neural network of glass and metal spheres with signals travelling between them.',
    Scene3D.software => 'Stacked glass layers representing interface, logic, data and infrastructure.',
    Scene3D.automation => 'Interlocking chrome and gold gears beside a glass conduit carrying data.',
    Scene3D.marketing => 'Marketing channels orbiting a gold hub above a rising bar chart.',
    _ => 'A 3D illustration.',
  };

  @override
  Widget build(BuildContext context) {
    final scene = sceneFor(serviceId);
    return Interactive3DObject(
      scene: scene,
      semanticLabel: labelFor(scene),
      variant: variantFor(serviceId),
      fallback: fallback,
      background: background,
      focus: focus,
    );
  }
}

/// A demonstration project shown on a 3D laptop. [imageAsset] is a bundled
/// asset path; the still fallback shows the same image flat.
class Portfolio3DPreview extends StatelessWidget {
  const Portfolio3DPreview({super.key, required this.imageAsset, required this.semanticLabel, this.focus = 0, this.background = AppColors.white});

  final String imageAsset;
  final String semanticLabel;
  final double focus;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Interactive3DObject(
      scene: Scene3D.preview,
      semanticLabel: semanticLabel,
      fallback: LazyAssetImage(path: imageAsset, semanticLabel: semanticLabel),
      background: background,
      focus: focus,
      // Flutter web serves bundled assets under `assets/`.
      image: Uri.base.resolve('assets/$imageAsset').toString(),
    );
  }
}

/// A decorative scene for a page section (technology, process, contact,
/// industries). Not essential: phones show its still render instead.
class Section3DScene extends StatelessWidget {
  const Section3DScene({
    super.key,
    required this.scene,
    required this.semanticLabel,
    required this.fallback,
    this.variant,
    this.pointer,
    this.focus = 0,
    this.background = AppColors.pearlWhite,
  });

  final Scene3D scene;
  final String semanticLabel;
  final Widget fallback;
  final String? variant;
  final ValueListenable<Offset>? pointer;
  final double focus;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Interactive3DObject(
      scene: scene,
      variant: variant,
      semanticLabel: semanticLabel,
      fallback: fallback,
      background: background,
      pointer: pointer,
      focus: focus,
    );
  }
}
