import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final textTheme = AppTypography.textTheme();
    final colorScheme = ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.light).copyWith(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.charcoalNavy,
      onSecondary: AppColors.white,
      surface: AppColors.card,
      onSurface: AppColors.ink,
      error: AppColors.error,
      outline: AppColors.border,
    );

    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      dividerColor: AppColors.divider,
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1, space: 1),
      iconTheme: const IconThemeData(color: AppColors.ink),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.white,
        surfaceTintColor: Colors.transparent,
        textStyle: textTheme.bodyMedium?.copyWith(color: AppColors.ink),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primary),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary.withValues(alpha: 0.3),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        errorStyle: textTheme.bodySmall?.copyWith(color: AppColors.error),
        border: border(AppColors.softGrey.withValues(alpha: 0.6)),
        enabledBorder: border(AppColors.softGrey.withValues(alpha: 0.6)),
        focusedBorder: border(AppColors.primary, 1.6),
        errorBorder: border(AppColors.error),
        focusedErrorBorder: border(AppColors.error, 1.6),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.white,
        selectedColor: AppColors.primarySoft,
        side: const BorderSide(color: AppColors.border),
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.white, surfaceTintColor: Colors.transparent),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: AppColors.charcoalNavy, borderRadius: BorderRadius.circular(8)),
        textStyle: textTheme.bodySmall?.copyWith(color: AppColors.white),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(AppColors.softGrey.withValues(alpha: 0.7)),
        thickness: const WidgetStatePropertyAll(6),
        radius: const Radius.circular(8),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.charcoalNavy,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// [base] adapted for forms sitting inside a charcoal card: dark fields,
  /// light text and champagne focus.
  static ThemeData onCard(ThemeData base) {
    final textTheme = base.textTheme.apply(bodyColor: AppColors.cardHeading, displayColor: AppColors.cardHeading);
    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
    return base.copyWith(
      brightness: Brightness.dark,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        surface: AppColors.cardField,
        onSurface: AppColors.cardHeading,
        onSurfaceVariant: AppColors.cardMuted,
        error: AppColors.errorOnCard,
      ),
      canvasColor: AppColors.cardField, // dropdown menus
      textTheme: textTheme,
      iconTheme: const IconThemeData(color: AppColors.cardAccent),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        fillColor: AppColors.cardField,
        labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.cardMuted),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.cardAccent, fontWeight: FontWeight.w600),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.cardMuted),
        helperStyle: textTheme.bodySmall?.copyWith(color: AppColors.cardMuted),
        counterStyle: textTheme.bodySmall?.copyWith(color: AppColors.cardMuted),
        errorStyle: textTheme.bodySmall?.copyWith(color: AppColors.errorOnCard),
        prefixIconColor: AppColors.cardMuted,
        suffixIconColor: AppColors.cardMuted,
        border: border(AppColors.cardLine),
        enabledBorder: border(AppColors.cardLine),
        focusedBorder: border(AppColors.cardBorder, 1.6),
        errorBorder: border(AppColors.errorOnCard),
        focusedErrorBorder: border(AppColors.errorOnCard, 1.6),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.cardField,
        selectedColor: AppColors.cardTile,
        side: const BorderSide(color: AppColors.cardLine),
        labelStyle: textTheme.labelMedium?.copyWith(color: AppColors.cardHeading),
        checkmarkColor: AppColors.cardAccent,
      ),
      checkboxTheme: CheckboxThemeData(
        side: const BorderSide(color: AppColors.cardMuted, width: 1.4),
        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.cardAccent : null),
        checkColor: const WidgetStatePropertyAll(AppColors.onPrimary),
      ),
    );
  }
}
