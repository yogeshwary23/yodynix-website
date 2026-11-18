import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import 'cards.dart';

// The homepage's finishing language, shared by the "Who We Are" section and
// the About pages: white glass lit from the upper right, warm layered
// shadows, metallic gold accents.

/// Warm umber, the tone of every soft shadow on a light surface.
const Color warmShadowTone = Color(0xFF4A3B28);

/// Warm, layered card shadows: a broad ambient pool, a key shadow and a
/// tight contact edge, deepening as the card lifts.
List<BoxShadow> premiumCardShadow({required bool lifted}) => [
  BoxShadow(
    color: warmShadowTone.withValues(alpha: lifted ? 0.1 : 0.06),
    blurRadius: lifted ? 64 : 48,
    spreadRadius: -14,
    offset: Offset(0, lifted ? 34 : 24),
  ),
  BoxShadow(
    color: warmShadowTone.withValues(alpha: lifted ? 0.08 : 0.06),
    blurRadius: lifted ? 26 : 20,
    spreadRadius: -6,
    offset: Offset(0, lifted ? 14 : 10),
  ),
  BoxShadow(color: warmShadowTone.withValues(alpha: 0.05), blurRadius: 3, offset: const Offset(0, 1)),
];

/// White glass: a pale gradient lit from the upper right, with a fine rim
/// that turns gold as the card lifts.
BoxDecoration premiumGlassCard({required bool lifted, double radius = AppRadius.xl}) => BoxDecoration(
  gradient: const LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [AppColors.white, Color(0xFFFEFCF8), Color(0xFFFAF6EE)],
    stops: [0, 0.5, 1],
  ),
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: lifted ? AppColors.goldLine : const Color(0xFFEFE8DC)),
  boxShadow: premiumCardShadow(lifted: lifted),
);

/// A pearl tile holding a metallic-gold icon.
class GoldIconTile extends StatelessWidget {
  const GoldIconTile({super.key, required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.white, AppColors.goldWash],
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: AppColors.goldLine),
        boxShadow: [BoxShadow(color: AppColors.champagneGold.withValues(alpha: 0.18), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: AppColors.metallicGoldText.createShader,
        child: Icon(icon, size: size * 0.48, color: AppColors.white),
      ),
    );
  }
}

/// A number on a frosted pearl pill with a gold rim, for laying over photos.
class GoldNumberBadge extends StatelessWidget {
  const GoldNumberBadge({super.key, required this.number, this.active = false});

  final String number;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.lift,
      curve: AppMotion.ease,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: active ? 0.92 : 0.78),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: active ? AppColors.champagneGold : AppColors.goldLine),
        boxShadow: [BoxShadow(color: warmShadowTone.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: GradientText(
        number,
        style: AppTypography.display(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.2, height: 1),
        gradient: AppColors.metallicGoldText,
      ),
    );
  }
}

/// The vertical champagne rule beside a lead paragraph, fading at its foot.
class GoldBar extends StatelessWidget {
  const GoldBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.antiqueGold, AppColors.champagneGold, AppColors.softChampagne.withValues(alpha: 0.2)],
          stops: const [0, 0.55, 1],
        ),
      ),
    );
  }
}

/// A lead paragraph set beside a [GoldBar].
class GoldBarLead extends StatelessWidget {
  const GoldBarLead({super.key, required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const GoldBar(),
          const SizedBox(width: 22),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}

/// A display headline whose closing words, [highlight], are set in metallic
/// gold, as in the hero. Read as one heading by screen readers.
class GoldHighlightHeading extends StatelessWidget {
  const GoldHighlightHeading({super.key, required this.heading, required this.highlight, required this.style, this.textAlign});

  final String heading;

  /// The heading's ending to set in gold; ignored when it doesn't match.
  final String highlight;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final split = heading.endsWith(highlight) ? heading.length - highlight.length : heading.length;
    return Semantics(
      header: true,
      label: heading,
      child: ExcludeSemantics(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: heading.substring(0, split)),
              if (split < heading.length)
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GradientText(heading.substring(split), style: style, gradient: AppColors.metallicGoldText),
                ),
            ],
          ),
          style: style,
          textAlign: textAlign,
        ),
      ),
    );
  }
}

/// Tracks a hovering mouse over [builder]'s child as an offset (each axis
/// -1 to 1, zero when the pointer leaves), for parallax across a larger
/// area than the moving element itself.
class PointerField extends StatefulWidget {
  const PointerField({super.key, required this.builder});

  final Widget Function(BuildContext context, ValueNotifier<Offset> pointer) builder;

  @override
  State<PointerField> createState() => _PointerFieldState();
}

class _PointerFieldState extends State<PointerField> {
  final ValueNotifier<Offset> _pointer = ValueNotifier(Offset.zero);

  @override
  void dispose() {
    _pointer.dispose();
    super.dispose();
  }

  void _track(PointerEvent event) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    _pointer.value = Offset(
      (event.localPosition.dx / box.size.width * 2 - 1).clamp(-1.0, 1.0),
      (event.localPosition.dy / box.size.height * 2 - 1).clamp(-1.0, 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _track,
      onExit: (_) => _pointer.value = Offset.zero,
      child: widget.builder(context, _pointer),
    );
  }
}
