import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/constants/site_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/surface_tone.dart';

/// The official Yodynix logo (square, with its transparent background),
/// optionally followed by the brand name in text. The mark's geometry is
/// never altered; only its colourway follows the surface: charcoal and gold
/// on light surfaces, platinum and gold on charcoal bands.
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
    final tone = context.tone;
    final logo = Image.asset(
      tone.isDark ? AssetPaths.logoOnDark : AssetPaths.logo,
      height: height,
      width: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: 'YODYNIX logo',
    );
    if (!showWordmark) return logo;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        SizedBox(width: height * 0.2),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              SiteConfig.brandName,
              style: AppTypography.display(
                fontSize: height * 0.5,
                fontWeight: FontWeight.w800,
                letterSpacing: height * 0.045,
                height: 1.05,
                color: tone.isDark ? tone.ink : AppColors.logoCharcoal,
              ),
            ),
            if (showCategory) ...[
              SizedBox(height: height * 0.06),
              Text(
                'DIGITAL TECHNOLOGY COMPANY',
                style: AppTypography.body(
                  fontSize: height * 0.145,
                  fontWeight: FontWeight.w600,
                  letterSpacing: height * 0.05,
                  height: 1.2,
                  color: tone.isDark ? tone.muted : AppColors.logoCharcoal.withValues(alpha: 0.82),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
