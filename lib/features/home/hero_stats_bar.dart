import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/site_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../shared/widgets/viewport_trigger.dart';

/// Single-row statistics bar at the foot of the hero. Values come from
/// [HeroStatsConfig] and count up once when the bar first becomes visible,
/// each figure starting a beat after the one before.
class HeroStatsBar extends StatefulWidget {
  const HeroStatsBar({super.key});

  @override
  State<HeroStatsBar> createState() => _HeroStatsBarState();
}

class _HeroStatsBarState extends State<HeroStatsBar> with SingleTickerProviderStateMixin, ViewportTrigger<HeroStatsBar> {
  late final AnimationController _count = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));

  final _built = DateTime.now();
  Timer? _start;

  @override
  void onEnterViewport() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _count.value = 1;
      return;
    }
    // On desktop the bar is in view on the very first frame, while the
    // splash screen is still fading out; hold the count until it has gone.
    final initialLoad = DateTime.now().difference(_built) < const Duration(seconds: 1);
    _start = Timer(Duration(milliseconds: initialLoad ? 900 : 150), () {
      if (mounted) _count.forward();
    });
  }

  @override
  void dispose() {
    _start?.cancel();
    _count.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const stats = HeroStatsConfig.stats;
    final mobile = context.isMobile;
    final tablet = context.isTablet;
    final numberSize = context.responsive(mobile: 28.0, tablet: 34.0, desktop: 42.0);
    final labelSize = context.responsive(mobile: 12.0, tablet: 13.0, desktop: 14.5);

    // Each figure gets its own window of the shared controller: a staggered
    // cascade rather than five counters ticking in lockstep.
    Animation<double> progressFor(int index) {
      final start = index * 0.09;
      return CurvedAnimation(
        parent: _count,
        curve: Interval(start, (start + 0.64).clamp(0, 1), curve: Curves.easeOutCubic),
      );
    }

    Widget item(int index, (int, String, String) stat) =>
        _StatItem(stat: stat, progress: progressFor(index), numberSize: numberSize, labelSize: labelSize);

    Widget row(List<(int, String, String)> items, {int offset = 0}) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, stat) in items.indexed) ...[
            if (i > 0) const _VerticalDivider(),
            Expanded(child: item(offset + i, stat)),
          ],
        ],
      ),
    );

    return Semantics(
      container: true,
      label: 'Key figures',
      child: Container(
        padding: EdgeInsets.symmetric(vertical: mobile ? 18 : (tablet ? 22 : 28), horizontal: mobile ? 8 : 12),
        decoration: BoxDecoration(
          gradient: AppColors.glassGradient,
          borderRadius: BorderRadius.circular(mobile ? 20 : 24),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppColors.softShadow(),
        ),
        // One straight row from tablet up; on phones 3 + 2 rows so labels
        // stay readable without horizontal scrolling.
        child: mobile
            ? Column(
                children: [
                  row(stats.sublist(0, 3)),
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.stone.withValues(alpha: 0), AppColors.stone, AppColors.stone.withValues(alpha: 0)],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Spacer(),
                      Expanded(flex: 4, child: row(stats.sublist(3), offset: 3)),
                      const Spacer(),
                    ],
                  ),
                ],
              )
            : row(stats),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.stat, required this.progress, required this.numberSize, required this.labelSize});

  final (int, String, String) stat;
  final Animation<double> progress;
  final double numberSize;
  final double labelSize;

  @override
  Widget build(BuildContext context) {
    final (value, suffix, label) = stat;
    // Tabular figures keep the digits from jittering while they count.
    final style = AppTypography.display(
      fontSize: numberSize,
      fontWeight: FontWeight.w800,
      height: 1.1,
      color: AppColors.charcoal,
    ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    return Semantics(
      label: '$value$suffix $label',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        // Top-aligned so figures stay level when one label wraps to two lines.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: progress,
              builder: (context, _) {
                final t = progress.value;
                // Charcoal numerals with only the suffix in gold; each figure
                // rises and fades in as it starts counting.
                final count = '${(value * t).round()}';
                return Opacity(
                  opacity: (t * 2.5).clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, (1 - (t * 2).clamp(0.0, 1.0)) * 10),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text.rich(
                        TextSpan(
                          text: count,
                          children: [
                            TextSpan(
                              text: suffix,
                              style: style.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                        style: style,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: numberSize * 0.14),
            // A short gold rule draws in as the figure lands.
            AnimatedBuilder(
              animation: progress,
              builder: (context, _) => Container(
                width: 22 * Curves.easeOut.transform(((progress.value - 0.6) / 0.4).clamp(0.0, 1.0)),
                height: 2,
                decoration: BoxDecoration(gradient: AppColors.liquidGold, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            SizedBox(height: numberSize * 0.14),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.body(fontSize: labelSize, color: AppColors.muted, fontWeight: FontWeight.w500, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.stone.withValues(alpha: 0.0), AppColors.stone, AppColors.stone.withValues(alpha: 0.0)],
        ),
      ),
    );
  }
}
