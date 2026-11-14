import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import 'demo_kit.dart';

/// Digital Marketing demo: a campaign planner that turns a budget and a few
/// assumptions into an estimated funnel and return on ad spend. All numbers
/// are illustrative estimates, which the UI states.
class CampaignPlannerDemo extends StatefulWidget {
  const CampaignPlannerDemo({super.key});

  @override
  State<CampaignPlannerDemo> createState() => _CampaignPlannerDemoState();
}

class _Preset {
  const _Preset(this.name, this.cpc, this.conversion, this.orderValue);

  final String name;
  final double cpc;
  final double conversion;
  final double orderValue;
}

class _CampaignPlannerDemoState extends State<CampaignPlannerDemo> {
  static const _presets = [
    _Preset('Local café', 8, 4, 450),
    _Preset('Online store', 14, 2.5, 1800),
    _Preset('Clinic leads', 22, 6, 2500),
  ];

  int _preset = 1;
  double _budget = 30000;
  late double _cpc = _presets[1].cpc;
  late double _conversion = _presets[1].conversion;
  late double _orderValue = _presets[1].orderValue;

  void _apply(int i) {
    final p = _presets[i];
    setState(() {
      _preset = i;
      _cpc = p.cpc;
      _conversion = p.conversion;
      _orderValue = p.orderValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final clicks = _budget / _cpc;
    final conversions = clicks * _conversion / 100;
    final revenue = conversions * _orderValue;
    final roas = revenue / _budget;
    final cpa = conversions == 0 ? 0 : _budget / conversions;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final controls = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Campaign ROI Planner', style: AppTypography.display(fontSize: 22, color: DemoColors.ink, height: 1.2)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < _presets.length; i++)
                  DemoChip(label: _presets[i].name, selected: i == _preset, onTap: () => _apply(i)),
              ],
            ),
            const SizedBox(height: 18),
            _slider('Monthly ad budget', rupees(_budget), _budget, 5000, 200000, 39, (v) => _budget = v),
            _slider('Cost per click', rupees(_cpc), _cpc, 2, 60, 58, (v) => _cpc = v.roundToDouble()),
            _slider(
              'Conversion rate',
              '${_conversion.toStringAsFixed(1)}%',
              _conversion,
              0.5,
              12,
              23,
              (v) => _conversion = (v * 2).round() / 2,
            ),
            _slider('Average order / deal value', rupees(_orderValue), _orderValue, 200, 10000, 49, (v) => _orderValue = v),
          ],
        );
        final results = Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.midnightNavy, AppColors.surfaceNavy],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ESTIMATED MONTHLY FUNNEL',
                style: AppTypography.body(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cyan,
                  letterSpacing: 1.3,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              _FunnelBar(label: 'Clicks', value: clicks.round().toString(), fraction: 1),
              _FunnelBar(
                label: 'Conversions',
                value: conversions.round().toString(),
                fraction: (_conversion / 12).clamp(0.08, 1.0),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _Metric(label: 'Est. revenue', value: rupees(revenue)),
                  ),
                  Expanded(
                    child: _Metric(label: 'ROAS', value: '${roas.toStringAsFixed(1)}×'),
                  ),
                  Expanded(
                    child: _Metric(label: 'Cost / conversion', value: rupees(cpa)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Illustrative estimates only. Real results depend on the market, creative, targeting and season.',
                style: AppTypography.body(fontSize: 12, color: AppColors.blueGrey, height: 1.5),
              ),
            ],
          ),
        );
        return Padding(
          padding: EdgeInsets.all(wide ? 28 : 16),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: controls),
                    const SizedBox(width: 28),
                    Expanded(child: results),
                  ],
                )
              : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [controls, const SizedBox(height: 20), results]),
        );
      },
    );
  }

  Widget _slider(String label, String display, double value, double min, double max, int divisions, ValueChanged<double> set) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.body(fontSize: 13.5, fontWeight: FontWeight.w600, color: DemoColors.text, height: 1.3),
                ),
              ),
              Text(
                display,
                style: AppTypography.body(fontSize: 14, fontWeight: FontWeight.w700, color: DemoColors.ink, height: 1.3),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.electricBlue,
              inactiveTrackColor: DemoColors.line,
              thumbColor: AppColors.electricBlue,
              overlayColor: AppColors.electricBlue.withValues(alpha: 0.12),
              trackHeight: 4,
              tickMarkShape: SliderTickMarkShape.noTickMark,
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              semanticFormatterCallback: (_) => display,
              onChanged: (v) => setState(() => set(v)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FunnelBar extends StatelessWidget {
  const _FunnelBar({required this.label, required this.value, required this.fraction});

  final String label;
  final String value;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: AppTypography.body(fontSize: 13, color: AppColors.lightGrey, height: 1.3)),
              ),
              Text(
                value,
                style: AppTypography.body(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white, height: 1.3),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 10,
              backgroundColor: AppColors.deepNavy,
              valueColor: const AlwaysStoppedAnimation(AppColors.cyan),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          // Inter, not Sora: the bundled Sora has no ₹ glyph.
          child: Text(
            value,
            style: AppTypography.body(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.white, height: 1.2),
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.body(fontSize: 12, color: AppColors.blueGrey, height: 1.3)),
      ],
    );
  }
}
