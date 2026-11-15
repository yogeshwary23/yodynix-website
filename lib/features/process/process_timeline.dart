import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../models/content_models.dart';
import '../../repositories/content/company_content.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/tinted_photo.dart';

/// The "How We Work" page body: the photographed delivery steps on a
/// connected timeline, followed by the ongoing support after launch.
class ProcessTimeline extends StatelessWidget {
  const ProcessTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    // Steps with a photograph form the timeline; the rest (post-launch
    // support) close the section as an ongoing commitment.
    final timeline = CompanyContent.processSteps.where((s) => s.image != null).toList();
    final ongoing = CompanyContent.processSteps.where((s) => s.image == null).toList();
    final wide = context.screenWidth >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, step) in timeline.indexed)
          Reveal(
            delay: const Duration(milliseconds: 60),
            child: wide
                ? _SpineRow(step: step, imageLeft: i.isEven, isFirst: i == 0, isLast: i == timeline.length - 1)
                : _RailRow(step: step, isLast: i == timeline.length - 1),
          ),
        for (final step in ongoing) ...[const SizedBox(height: 40), Reveal(child: _OngoingCard(step: step))],
      ],
    );
  }
}

/// Wide layout: photo and copy on opposite sides of a central spine.
class _SpineRow extends StatelessWidget {
  const _SpineRow({required this.step, required this.imageLeft, required this.isFirst, required this.isLast});

  final ProcessStep step;
  final bool imageLeft;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final photo = Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: _StepPhoto(step: step),
    );
    final copy = Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: _StepCopy(step: step, alignEnd: !imageLeft),
    );
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: Center(child: imageLeft ? photo : copy)),
          SizedBox(
            width: 96,
            child: Column(
              children: [
                Expanded(child: _Line(visible: !isFirst)),
                _Node(step: step),
                Expanded(child: _Line(visible: !isLast)),
              ],
            ),
          ),
          Expanded(child: Center(child: imageLeft ? copy : photo)),
        ],
      ),
    );
  }
}

/// Narrow layout: a rail with numbered nodes down the left, a card per step.
class _RailRow extends StatelessWidget {
  const _RailRow({required this.step, required this.isLast});

  final ProcessStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 56,
            child: Column(
              children: [
                _Node(step: step, size: 48),
                Expanded(child: _Line(visible: !isLast)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StepPhoto(step: step),
                  const SizedBox(height: 20),
                  _StepCopy(step: step, alignEnd: false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Center(
      child: Container(
        width: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.softGrey, AppColors.lightGrey],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({required this.step, this.size = 60});

  final ProcessStep step;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.charcoalNavy,
        border: Border.all(color: AppColors.background, width: 4),
        boxShadow: AppColors.softShadow(0.6),
      ),
      child: Text(
        step.number,
        style: AppTypography.display(fontSize: size * 0.3, fontWeight: FontWeight.w800, color: AppColors.white, height: 1),
      ),
    );
  }
}

class _StepPhoto extends StatefulWidget {
  const _StepPhoto({required this.step});

  final ProcessStep step;

  @override
  State<_StepPhoto> createState() => _StepPhotoState();
}

class _StepPhotoState extends State<_StepPhoto> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: AppMotion.lift,
        curve: AppMotion.ease,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: _hover ? AppColors.accent.withValues(alpha: 0.45) : AppColors.lightGrey),
          boxShadow: [
            if (_hover)
              BoxShadow(
                color: AppColors.charcoalNavy.withValues(alpha: 0.14),
                blurRadius: 44,
                spreadRadius: -6,
                offset: const Offset(0, 18),
              ),
            ...AppColors.softShadow(0.6),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl - 1),
          child: AspectRatio(
            aspectRatio: context.isMobile ? 16 / 10 : 3 / 2,
            child: Stack(
              fit: StackFit.expand,
              children: [
                TintedPhoto(basePath: step.image!, semanticLabel: step.imageAlt ?? step.title, active: _hover, strength: 0.8),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 7, 14, 7),
                    decoration: BoxDecoration(
                      color: AppColors.deepNavy.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: AppColors.white.withValues(alpha: 0.16)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(step.icon, size: 15, color: AppColors.primaryTint),
                        const SizedBox(width: 8),
                        Text(
                          'STEP ${step.number}',
                          style: AppTypography.body(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                            letterSpacing: 1.2,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
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

class _StepCopy extends StatelessWidget {
  const _StepCopy({required this.step, required this.alignEnd});

  final ProcessStep step;

  /// Right-aligns the copy when it sits left of the spine.
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final align = alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textAlign = alignEnd ? TextAlign.end : TextAlign.start;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: align,
      children: [
        Text(
          step.title,
          textAlign: textAlign,
          style: AppTypography.display(fontSize: context.responsive(mobile: 24.0, desktop: 30.0), height: 1.2),
        ),
        const SizedBox(height: 10),
        Text(step.description, textAlign: textAlign, style: AppTypography.body(fontSize: 16, height: 1.7)),
        const SizedBox(height: 16),
        Wrap(
          alignment: alignEnd ? WrapAlignment.end : WrapAlignment.start,
          spacing: 8,
          runSpacing: 8,
          children: [for (final a in step.activities) TagChip(a, color: AppColors.accent, filled: true)],
        ),
      ],
    );
  }
}

/// Post-launch commitment shown after the timeline.
class _OngoingCard extends StatelessWidget {
  const _OngoingCard({required this.step});

  final ProcessStep step;

  @override
  Widget build(BuildContext context) {
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AFTER LAUNCH · ${step.number}',
          style: AppTypography.body(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppColors.cardAccent,
            letterSpacing: 1.4,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          step.title,
          style: AppTypography.display(fontSize: 22, fontWeight: FontWeight.w700, height: 1.25, color: AppColors.cardHeading),
        ),
        const SizedBox(height: 6),
        Text(step.description, style: AppTypography.body(fontSize: 15.5, height: 1.6, color: AppColors.cardBody)),
      ],
    );
    final chips = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [for (final a in step.activities) TagChip(a, color: AppColors.cardAccent, filled: true)],
    );
    return Container(
      padding: EdgeInsets.all(context.responsive(mobile: 22.0, desktop: 28.0)),
      decoration: CardStyle.decoration(radius: AppRadius.lg),
      child: SurfaceTone(
        colors: SurfaceColors.inCard,
        child: context.screenWidth >= 900
            ? Row(
                children: [
                  IconBadge(icon: step.icon, color: AppColors.cardAccent, gradient: true, size: 56),
                  const SizedBox(width: 22),
                  Expanded(flex: 3, child: details),
                  const SizedBox(width: 28),
                  Expanded(flex: 2, child: chips),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconBadge(icon: step.icon, color: AppColors.cardAccent, gradient: true, size: 50),
                  const SizedBox(height: 16),
                  details,
                  const SizedBox(height: 16),
                  chips,
                ],
              ),
      ),
    );
  }
}
