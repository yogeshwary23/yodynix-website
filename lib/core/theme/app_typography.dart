import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Sora (geometric display) for headings, Inter for body copy.
class AppTypography {
  AppTypography._();

  static TextStyle display({
    double fontSize = 48,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.ink,
    double height = 1.12,
    double? letterSpacing,
  }) {
    return GoogleFonts.sora(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing ?? -fontSize * 0.025,
    );
  }

  static TextStyle body({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.body,
    double height = 1.65,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextTheme textTheme() {
    return TextTheme(
      displayLarge: display(fontSize: 64, height: 1.06),
      displayMedium: display(fontSize: 48),
      displaySmall: display(fontSize: 36),
      headlineMedium: display(fontSize: 28, fontWeight: FontWeight.w600),
      headlineSmall: display(fontSize: 22, fontWeight: FontWeight.w600),
      titleLarge: display(fontSize: 19, fontWeight: FontWeight.w600, height: 1.3),
      titleMedium: body(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink, height: 1.4),
      titleSmall: body(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink, height: 1.4),
      bodyLarge: body(fontSize: 18, height: 1.7),
      bodyMedium: body(fontSize: 15.5),
      bodySmall: body(fontSize: 13.5, color: AppColors.muted, height: 1.55),
      labelLarge: body(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink, height: 1.2),
      labelMedium: body(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink, height: 1.2),
      labelSmall: body(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary, height: 1.2, letterSpacing: 1.4),
    );
  }
}
