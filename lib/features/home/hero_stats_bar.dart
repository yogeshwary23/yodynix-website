import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/site_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/viewport_trigger.dart';

/// The "Our Impact" card at the foot of the hero: an introduction followed
/// by the figures from [HeroStatsConfig], separated by fine gold rules. The
/// figures count up once when the card first becomes visible, each starting
/// a beat after the one before.
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
    // On desktop the card is in view on the very first frame, while the
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
    final desktop = context.isDesktop;
    final metrics = _StatMetrics(
      number: context.responsive(mobile: 30.0, tablet: 36.0, desktop: 46.0),
      label: context.responsive(mobile: 13.0, tablet: 14.5, desktop: 17.0),
      icon: context.responsive(mobile: 24.0, tablet: 28.0, desktop: 32.0),
    );

    // Each figure gets its own window of the shared controller: a staggered
    // cascade rather than five counters ticking in lockstep.
    Animation<double> progressFor(int index) {
      final start = index * 0.09;
      return CurvedAnimation(
        parent: _count,
        curve: Interval(start, (start + 0.64).clamp(0, 1), curve: Curves.easeOutCubic),
      );
    }

    Widget row(List<(int, String, String)> items, {int offset = 0}) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, stat) in items.indexed) ...[
            if (i > 0) const _GoldRule(),
            Expanded(child: _StatItem(stat: stat, progress: progressFor(offset + i), metrics: metrics)),
          ],
        ],
      ),
    );

    final Widget content;
    if (desktop) {
      // The introduction and all five figures in one row.
      content = IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(flex: 13, child: _ImpactIntro()),
            const _GoldRule(),
            Expanded(flex: 50, child: row(stats)),
          ],
        ),
      );
    } else {
      // Introduction on top; the figures in one row on tablets, and 3 + 2 on
      // phones so labels stay readable without horizontal scrolling.
      content = Column(
        children: [
          const _ImpactIntro(),
          const _GoldRule(horizontal: true),
          if (mobile) ...[
            row(stats.sublist(0, 3)),
            const SizedBox(height: 22),
            Row(
              children: [
                const Spacer(),
                Expanded(flex: 4, child: row(stats.sublist(3), offset: 3)),
                const Spacer(),
              ],
            ),
          ] else
            row(stats),
        ],
      );
    }

    return Semantics(
      container: true,
      label: 'Our impact: key figures',
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: context.responsive(mobile: 24.0, tablet: 26.0, desktop: 24.0),
          horizontal: context.responsive(mobile: 12.0, tablet: 24.0, desktop: 40.0),
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.white, Color(0xFFFBF8F2)],
          ),
          borderRadius: BorderRadius.circular(mobile ? 22 : 28),
          border: Border.all(color: const Color(0xFFEFE8DC)),
          boxShadow: [
            BoxShadow(color: AppColors.charcoal.withValues(alpha: 0.08), blurRadius: 48, offset: const Offset(0, 22)),
            BoxShadow(color: AppColors.charcoal.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: content,
      ),
    );
  }
}

/// "Our Impact" beside a gold accent bar.
class _ImpactIntro extends StatelessWidget {
  const _ImpactIntro();

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktop;
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: desktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          'Our Impact',
          style: AppTypography.display(
            fontSize: context.responsive(mobile: 24.0, tablet: 28.0, desktop: 34.0),
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
            height: 1.15,
          ),
        ),
        SizedBox(height: desktop ? 12 : 6),
        Text(
          // Two lines beside the bar; one line when centred above the figures.
          desktop ? 'Delivering Real\nDigital Results' : 'Delivering Real Digital Results',
          textAlign: desktop ? TextAlign.start : TextAlign.center,
          style: AppTypography.body(
            fontSize: context.responsive(mobile: 14.5, tablet: 16.0, desktop: 19.0),
            color: AppColors.slate,
            height: 1.5,
          ),
        ),
      ],
    );
    if (!desktop) return text;
    // Stretched to the card row's height, so the bar spans it.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 3,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.antiqueGold, AppColors.champagneGold, AppColors.softChampagne.withValues(alpha: 0)],
              stops: const [0, 0.55, 1],
            ),
          ),
        ),
        const SizedBox(width: 30),
        Flexible(child: Align(alignment: Alignment.centerLeft, child: text)),
      ],
    );
  }
}

class _StatMetrics {
  const _StatMetrics({required this.number, required this.label, required this.icon});

  final double number;
  final double label;
  final double icon;
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.stat, required this.progress, required this.metrics});

  final (int, String, String) stat;
  final Animation<double> progress;
  final _StatMetrics metrics;

  static IconData _iconFor(String label) => switch (label) {
    'Websites Developed' => Icons.laptop_outlined,
    'Mobile Apps Developed' => Icons.phone_iphone_outlined,
    'Projects Completed' => Icons.layers_outlined,
    'Happy Clients' => Icons.groups_outlined,
    'Technology Solutions' => Icons.settings_outlined,
    _ => Icons.auto_awesome_outlined,
  };

  /// Breaks before the last word, so every label sits on two balanced lines.
  static String _twoLines(String label) {
    final i = label.lastIndexOf(' ');
    return i < 0 ? label : '${label.substring(0, i)}\n${label.substring(i + 1)}';
  }

  @override
  Widget build(BuildContext context) {
    final (value, suffix, label) = stat;
    // Tabular figures keep the digits from jittering while they count.
    final style = AppTypography.display(
      fontSize: metrics.number,
      fontWeight: FontWeight.w800,
      height: 1.1,
      color: AppColors.white,
    ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

    return Semantics(
      label: '$value$suffix $label',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        // Top-aligned so figures stay level whatever the label length.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(_iconFor(label), size: metrics.icon, color: AppColors.primary),
            SizedBox(height: metrics.number * 0.16),
            AnimatedBuilder(
              animation: progress,
              builder: (context, _) {
                final t = progress.value;
                // Each figure rises and fades in as it starts counting.
                return Opacity(
                  opacity: (t * 2.5).clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, (1 - (t * 2).clamp(0.0, 1.0)) * 10),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: GradientText('${(value * t).round()}$suffix', style: style, gradient: AppColors.metallicGoldText),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: metrics.number * 0.12),
            Text(
              _twoLines(label),
              textAlign: TextAlign.center,
              style: AppTypography.body(fontSize: metrics.label, color: AppColors.charcoal, fontWeight: FontWeight.w500, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}

/// A fine champagne separator that fades out at both ends.
class _GoldRule extends StatelessWidget {
  const _GoldRule({this.horizontal = false});

  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final fade = [AppColors.champagneGold.withValues(alpha: 0), AppColors.champagneGold.withValues(alpha: 0.55), AppColors.champagneGold.withValues(alpha: 0)];
    if (horizontal) {
      return Container(
        height: 1,
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(gradient: LinearGradient(colors: fade)),
      );
    }
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: fade),
      ),
    );
  }
}
