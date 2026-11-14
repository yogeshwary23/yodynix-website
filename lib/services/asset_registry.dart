import 'package:flutter/services.dart';

/// Knows which image assets are bundled so sections can swap their
/// illustrated placeholder for a real photo simply by adding the file —
/// without triggering 404 requests for images that do not exist yet.
class AssetRegistry {
  AssetRegistry._();

  static final AssetRegistry instance = AssetRegistry._();

  static const List<String> _extensions = ['webp', 'jpg', 'jpeg', 'png'];

  Set<String> _assets = const {};

  Future<void> init() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      _assets = manifest.listAssets().toSet();
    } catch (_) {
      _assets = const {};
    }
  }

  bool has(String path) => _assets.contains(path);

  /// Resolves an extension-less base path to the first bundled match.
  String? resolve(String basePath) {
    for (final ext in _extensions) {
      final candidate = '$basePath.$ext';
      if (_assets.contains(candidate)) return candidate;
    }
    return null;
  }
}
