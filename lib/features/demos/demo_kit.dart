import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';

/// Shared building blocks for the in-site demos. Demos stay within the
/// YODYNIX palette; "client-style" demos use the light tokens (white, light
/// grey) with navy text so they read as a separate product.

/// Light demo surface colours, all from the brand palette.
class DemoColors {
  DemoColors._();

  static const Color page = AppColors.white;
  static const Color panel = Color(0xFFF5F6F8); // white tinted toward light grey
  static const Color line = AppColors.lightGrey;
  static const Color ink = AppColors.midnightNavy;
  static const Color text = AppColors.surfaceNavy;
  static const Color muted = AppColors.blueGrey;
  static const Color accent = AppColors.electricBlue;
}

/// A browser-style window around a demo, with a title bar and a "Sample"
/// tag so the demo is never mistaken for a real business site.
class DemoWindow extends StatelessWidget {
  const DemoWindow({super.key, required this.title, required this.child, this.light = true});

  final String title;
  final Widget child;

  /// Light body for client-style demos; dark for tool-style demos.
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.lightGrey),
        boxShadow: AppColors.softShadow(1.4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg - 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              color: AppColors.surfaceNavy,
              child: Row(
                children: [
                  for (final c in [AppColors.blueGrey, AppColors.electricBlueTint, AppColors.electricBlue]) ...[
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                  ],
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightGrey,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SampleTag(),
                ],
              ),
            ),
            ColoredBox(color: light ? DemoColors.page : AppColors.deepNavy, child: child),
          ],
        ),
      ),
    );
  }
}

class SampleTag extends StatelessWidget {
  const SampleTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.electricBlue.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.electricBlueTint.withValues(alpha: 0.5)),
      ),
      child: Text(
        'SAMPLE DEMO',
        style: AppTypography.body(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.electricBlueTint,
          letterSpacing: 1,
          height: 1.2,
        ),
      ),
    );
  }
}

/// A phone outline for mobile-app demos.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child, this.width = 340, this.height = 680});

  final Widget child;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(44),
        border: Border.all(color: AppColors.electricBlue.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricBlue.withValues(alpha: 0.16),
            blurRadius: 60,
            spreadRadius: -10,
            offset: const Offset(0, 24),
          ),
          ...AppColors.softShadow(0.8),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Stack(
          children: [
            Positioned.fill(child: child),
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 86,
                  height: 22,
                  decoration: BoxDecoration(color: AppColors.deepNavy, borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A labelled text field styled for light or dark demo surfaces.
class DemoField extends StatelessWidget {
  const DemoField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.light = true,
    this.keyboardType,
    this.hint,
    this.onSubmitted,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final bool light;
  final TextInputType? keyboardType;
  final String? hint;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final ink = light ? DemoColors.ink : AppColors.white;
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: BorderSide(color: c),
    );
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onFieldSubmitted: onSubmitted,
      style: AppTypography.body(fontSize: 14.5, color: ink, height: 1.4),
      cursorColor: AppColors.electricBlue,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: light ? DemoColors.panel : AppColors.surfaceNavy,
        labelStyle: AppTypography.body(fontSize: 14, color: light ? DemoColors.muted : AppColors.lightGrey, height: 1.2),
        hintStyle: AppTypography.body(fontSize: 14, color: DemoColors.muted, height: 1.2),
        floatingLabelStyle: AppTypography.body(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.electricBlue,
          height: 1.2,
        ),
        errorStyle: AppTypography.body(fontSize: 12, color: AppColors.electricBlue, fontWeight: FontWeight.w600, height: 1.2),
        border: border(light ? DemoColors.line : AppColors.darkBorder),
        enabledBorder: border(light ? DemoColors.line : AppColors.darkBorder),
        focusedBorder: border(AppColors.electricBlue),
        errorBorder: border(AppColors.electricBlue),
        focusedErrorBorder: border(AppColors.electricBlue),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

/// Small pill used for toggles and filters inside demos.
class DemoChip extends StatelessWidget {
  const DemoChip({super.key, required this.label, required this.selected, required this.onTap, this.light = true, this.icon});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool light;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final idle = light ? DemoColors.text : AppColors.lightGrey;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.electricBlue : (light ? DemoColors.panel : AppColors.surfaceNavy),
        shape: StadiumBorder(
          side: BorderSide(color: selected ? AppColors.electricBlue : (light ? DemoColors.line : AppColors.darkBorder)),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: 16, color: selected ? AppColors.white : idle), const SizedBox(width: 6)],
                Text(
                  label,
                  style: AppTypography.body(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.white : idle,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Primary demo action button (electric blue).
class DemoButton extends StatelessWidget {
  const DemoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm));
    final textStyle = AppTypography.body(fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.2);
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Flexible(child: Text(label)),
            ],
          );
    final button = outlined
        ? OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.electricBlue,
              side: const BorderSide(color: AppColors.electricBlue),
              padding: padding,
              shape: shape,
              textStyle: textStyle,
            ),
            child: child,
          )
        : FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.electricBlue,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.blueGrey,
              padding: padding,
              shape: shape,
              textStyle: textStyle,
            ),
            child: child,
          );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Formats whole rupees with Indian digit grouping, e.g. ₹1,25,000.
String rupees(num value) {
  final digits = value.round().abs().toString();
  String grouped;
  if (digits.length <= 3) {
    grouped = digits;
  } else {
    final last3 = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    grouped = '${parts.join(',')},$last3';
  }
  return '${value < 0 ? '-' : ''}₹$grouped';
}
