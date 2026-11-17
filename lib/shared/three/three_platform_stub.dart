import 'package:flutter/widgets.dart';

import 'scene3d.dart';

/// Non-web stand-in: 3D is never available, so callers use their fallback.
class ThreePlatform {
  ThreePlatform._();

  static bool? get supportedSync => false;

  static Future<bool> ensureLoaded() async => false;

  /// Number of logical CPU cores, used to pick a quality tier.
  static int get cpuCores => 8;

  static Widget buildHost({
    required Scene3D scene,
    required SceneOptions options,
    required ValueChanged<SceneHandle> onMounted,
    required VoidCallback onLost,
  }) =>
      const SizedBox.shrink();
}
