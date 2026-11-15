import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import 'demo_kit.dart';

/// Business Automation demo: FlowRunner simulates what happens to a new
/// website enquiry when an automated workflow is switched on. Steps can be
/// toggled; "Run" plays the workflow and writes a log. Nothing is sent.
class EnquiryAutomationDemo extends StatefulWidget {
  const EnquiryAutomationDemo({super.key});

  @override
  State<EnquiryAutomationDemo> createState() => _EnquiryAutomationDemoState();
}

class _Step {
  _Step(this.icon, this.title, this.detail, this.log);

  final IconData icon;
  final String title;
  final String detail;
  final String log;
  bool enabled = true;
}

class _EnquiryAutomationDemoState extends State<EnquiryAutomationDemo> {
  final List<_Step> _steps = [
    _Step(Icons.save_alt_rounded, 'Save to CRM', 'Create a lead with the form details', 'Lead "Neha Patil" saved to CRM'),
    _Step(
      Icons.mark_email_read_outlined,
      'Send acknowledgement',
      'Email the customer within a minute',
      'Acknowledgement email queued to neha@example.com',
    ),
    _Step(
      Icons.notifications_active_outlined,
      'Notify sales team',
      'Post a message to the team channel',
      'Sales team notified: new website enquiry',
    ),
    _Step(
      Icons.assignment_ind_outlined,
      'Assign owner',
      'Round-robin to the next salesperson',
      'Assigned to Rohan (next in rotation)',
    ),
    _Step(
      Icons.event_repeat_outlined,
      'Schedule follow-up',
      'Reminder if no reply in 2 days',
      'Follow-up reminder set for +2 days',
    ),
  ];

  final List<String> _log = [];
  final List<Timer> _timers = [];
  int _active = -1;
  bool _running = false;

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  void _run() {
    final enabled = [
      for (var i = 0; i < _steps.length; i++)
        if (_steps[i].enabled) i,
    ];
    setState(() {
      _running = true;
      _active = -1;
      _log
        ..clear()
        ..add('00.0s  New enquiry received from website form');
    });
    for (var n = 0; n < enabled.length; n++) {
      final i = enabled[n];
      _timers.add(
        Timer(Duration(milliseconds: 700 * (n + 1)), () {
          if (!mounted) return;
          setState(() {
            _active = i;
            _log.add('${(0.7 * (n + 1)).toStringAsFixed(1).padLeft(4, '0')}s  ${_steps[i].log}');
          });
        }),
      );
    }
    _timers.add(
      Timer(Duration(milliseconds: 700 * (enabled.length + 1)), () {
        if (!mounted) return;
        setState(() {
          _running = false;
          _active = -1;
          _log.add('Done · ${enabled.length} step${enabled.length == 1 ? '' : 's'} completed automatically (simulation)');
        });
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saved = _steps.where((s) => s.enabled).length * 3;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final steps = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Workflow: New website enquiry',
              style: AppTypography.display(fontSize: 18, color: AppColors.white, height: 1.3),
            ),
            const SizedBox(height: 4),
            Text(
              'Toggle steps, then run the simulation.',
              style: AppTypography.body(fontSize: 13, color: AppColors.blueGrey, height: 1.4),
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < _steps.length; i++) _stepTile(i),
          ],
        );
        final log = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.deepNavy,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Run log',
                      style: AppTypography.body(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white, height: 1.2),
                    ),
                  ),
                  DemoButton(
                    label: _running ? 'Running…' : 'Run workflow',
                    icon: Icons.play_arrow_rounded,
                    onPressed: _running ? null : _run,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_log.isEmpty)
                Text('No runs yet.', style: AppTypography.body(fontSize: 13, color: AppColors.blueGrey))
              else
                for (final line in _log)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      line,
                      style: AppTypography.body(
                        fontSize: 12.5,
                        color: AppColors.electricBlueTint,
                        height: 1.45,
                      ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                    ),
                  ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.electricBlueSoft, borderRadius: BorderRadius.circular(AppRadius.sm)),
                child: Text(
                  'Estimated manual time avoided: about $saved minutes per enquiry (illustrative).',
                  style: AppTypography.body(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.white, height: 1.45),
                ),
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
                    Expanded(child: steps),
                    const SizedBox(width: 24),
                    Expanded(child: log),
                  ],
                )
              : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [steps, const SizedBox(height: 20), log]),
        );
      },
    );
  }

  Widget _stepTile(int i) {
    final s = _steps[i];
    final active = i == _active;
    return AnimatedContainer(
      duration: AppMotion.hover,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: active ? AppColors.electricBlue.withValues(alpha: 0.16) : AppColors.surfaceNavy,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: active ? AppColors.electricBlue : AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Icon(s.icon, color: s.enabled ? AppColors.electricBlue : AppColors.blueGrey, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.title,
                  style: AppTypography.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: s.enabled ? AppColors.white : AppColors.blueGrey,
                    height: 1.3,
                  ),
                ),
                Text(s.detail, style: AppTypography.body(fontSize: 12.5, color: AppColors.blueGrey, height: 1.35)),
              ],
            ),
          ),
          Switch(
            value: s.enabled,
            activeTrackColor: AppColors.electricBlue,
            onChanged: _running ? null : (v) => setState(() => s.enabled = v),
          ),
        ],
      ),
    );
  }
}
