import 'package:flutter/material.dart';

import '../../core/constants/site_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../shared/widgets/viewport_trigger.dart';

/// Single-row statistics bar at the foot of the hero. Values come from
/// [HeroStatsConfig] and count up once when the bar first becomes visible.
class HeroStatsBar extends StatefulWidget {
  const HeroStatsBar({super.key});

  @override
  State<HeroStatsBar> createState() => _HeroStatsBarState();
}

class _HeroStatsBarState extends State<HeroStatsBar> with SingleTickerProviderStateMixin, ViewportTrigger<HeroStatsBar> {
  late final AnimationController _count = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
  late final Animation<double> _progress = CurvedAnimation(parent: _count, curve: Curves.easeOutCubic);

  @override
  void onEnterViewport() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _count.value = 1;
    } else {
      _count.forward();
    }
  }

  @override
  void dispose() {
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

    Widget item((int, String, String) stat) =>
        _StatItem(stat: stat, progress: _progress, numberSize: numberSize, labelSize: labelSize);

    Widget row(List<(int, String, String)> items) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, stat) in items.indexed) ...[if (i > 0) const _VerticalDivider(), Expanded(child: item(stat))],
        ],
      ),
    );

    return Semantics(
      container: true,
      label: 'Key figures',
      child: Container(
        padding: EdgeInsets.symmetric(vertical: mobile ? 18 : (tablet ? 22 : 28), horizontal: mobile ? 8 : 12),
        decoration: BoxDecoration(
          gradient: AppColors.darkGlassGradient,
          borderRadius: BorderRadius.circular(mobile ? 20 : 24),
          border: Border.all(color: AppColors.darkBorder),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 32, offset: const Offset(0, 14))],
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
                        colors: [
                          AppColors.darkBorder.withValues(alpha: 0),
                          AppColors.softGrey.withValues(alpha: 0.35),
                          AppColors.darkBorder.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Spacer(),
                      Expanded(flex: 4, child: row(stats.sublist(3))),
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
    final style = AppTypography.display(fontSize: numberSize, fontWeight: FontWeight.w800, height: 1.1, color: AppColors.onDark);
    return Semantics(
      label: '$value$suffix $label',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: progress,
              builder: (context, _) {
                // White numerals with only the suffix in accent blue.
                final count = '${(value * progress.value).round()}';
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text.rich(
                    TextSpan(
                      text: count,
                      children: [
                        TextSpan(
                          text: suffix,
                          style: style.copyWith(color: AppColors.primaryTint),
                        ),
                      ],
                    ),
                    style: style,
                  ),
                );
              },
            ),
            SizedBox(height: numberSize * 0.22),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                fontSize: labelSize,
                color: AppColors.onDarkMuted,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
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
          colors: [
            AppColors.softGrey.withValues(alpha: 0.0),
            AppColors.softGrey.withValues(alpha: 0.35),
            AppColors.softGrey.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}
