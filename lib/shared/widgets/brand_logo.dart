import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/constants/site_config.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/surface_tone.dart';

/// The official Yodynix logo, rendered exactly as supplied (square, with its
/// transparent background), optionally followed by the brand name in text.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.height = 44,
    this.showWordmark = SiteConfig.showWordmarkBesideLogo,
    this.showCategory = false,
  });

  final double height;
  final bool showWordmark;
  final bool showCategory;

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      AssetPaths.logo,
      height: height,
      width: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: 'YODYNIX logo',
    );
    if (!showWordmark) return logo;
    final tone = context.tone;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        SizedBox(width: height * 0.22),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              SiteConfig.brandName,
              style: AppTypography.display(
                fontSize: height * 0.44,
                fontWeight: FontWeight.w800,
                letterSpacing: height * 0.05,
                height: 1.05,
                color: tone.ink,
              ),
            ),
            if (showCategory)
              Text(
                'Digital Innovation Studio',
                style: AppTypography.body(fontSize: height * 0.22, color: tone.muted, height: 1.3),
              ),
          ],
        ),
      ],
    );
  }
}
