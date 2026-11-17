import 'package:flutter/widgets.dart';

import '../../core/constants/asset_paths.dart';
import '../../services/asset_registry.dart';
import '../widgets/smart_image.dart';
import 'scene3d.dart';

/// The polished stand-in for a 3D scene: a still render of the same scene
/// (from `assets/images/renders/`, produced with the live engine) on phones,
/// low-power devices, browsers without WebGL and before a scene loads. When
/// no render is bundled it shows [fallback].
class Mobile3DFallback extends StatelessWidget {
  const Mobile3DFallback({super.key, required this.scene, required this.fallback, this.variant});

  final Scene3D scene;
  final String? variant;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    final path = AssetRegistry.instance.resolve(AssetPaths.render(renderName(scene, variant)));
    if (path == null) return fallback;
    return LazyAssetImage(path: path, semanticLabel: '', fit: BoxFit.contain);
  }
}
