import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import 'smart_image.dart';

/// A bundled photograph graded towards the midnight-navy palette so photos
/// from different sources sit together consistently. The grade lifts and the
/// photo zooms slightly while [active] (hover / focus).
class TintedPhoto extends StatelessWidget {
  const TintedPhoto({
    super.key,
    required this.basePath,
    required this.semanticLabel,
    this.active = false,
    this.fallback,
    this.alignment = Alignment.center,
    this.strength = 1,
  });

  /// Extension-less asset path, resolved by `AssetRegistry`.
  final String basePath;
  final String semanticLabel;
  final bool active;

  /// Shown when the photo is not bundled; defaults to a branded navy panel.
  final Widget? fallback;
  final Alignment alignment;

  /// Scales the navy grade; 0 shows the untouched photo.
  final double strength;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedScale(
          duration: AppMotion.lift,
          curve: AppMotion.ease,
          scale: active ? 1.05 : 1,
          child: SmartImage(
            basePath: basePath,
            semanticLabel: semanticLabel,
            alignment: alignment,
            fallbackWidget: fallback ?? const _PhotoFallback(),
          ),
        ),
        IgnorePointer(
          child: AnimatedOpacity(
            duration: AppMotion.lift,
            opacity: active ? 0.55 : 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.midnightNavy.withValues(alpha: 0.10 * strength),
                    AppColors.deepNavy.withValues(alpha: 0.42 * strength),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.glassGradient),
      child: Center(child: Icon(Icons.image_outlined, size: 40, color: AppColors.muted.withValues(alpha: 0.6))),
    );
  }
}
