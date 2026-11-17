import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import 'demo_kit.dart';

/// UI/UX demo: a clickable three-screen prototype for "Bookly", a salon
/// booking app. A toggle switches between the wireframe and the finished UI
/// so visitors can see how a design moves from structure to polish.
class AppPrototypeDemo extends StatefulWidget {
  const AppPrototypeDemo({super.key});

  @override
  State<AppPrototypeDemo> createState() => _AppPrototypeDemoState();
}

class _AppPrototypeDemoState extends State<AppPrototypeDemo> {
  static const _screens = ['Choose service', 'Pick a time', 'Confirmed'];
  static const _services = [('Haircut & Style', '45 min', 600), ('Hair Spa', '60 min', 1200), ('Manicure', '30 min', 450)];
  static const _times = ['10:00', '11:30', '13:00', '15:30', '17:00', '18:30'];

  bool _wireframe = false;
  int _screen = 0;
  int _service = 0;
  int? _time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              DemoChip(
                label: 'Wireframe',
                icon: Icons.grid_on_rounded,
                light: false,
                selected: _wireframe,
                onTap: () => setState(() => _wireframe = true),
              ),
              DemoChip(
                label: 'Final UI',
                icon: Icons.palette_outlined,
                light: false,
                selected: !_wireframe,
                onTap: () => setState(() => _wireframe = false),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Step ${_screen + 1} of 3 · ${_screens[_screen]}',
            style: AppTypography.body(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.demoAccentTint, height: 1.3),
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: PhoneFrame(
              width: 320,
              height: 620,
              child: ColoredBox(
                color: _wireframe ? AppColors.white : DemoColors.panel,
                child: AnimatedSwitcher(
                  duration: AppMotion.lift,
                  child: KeyedSubtree(key: ValueKey('$_screen$_wireframe'), child: _body()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Wireframe mode swaps colour and type for greys and outlines.
  Color get _ink => _wireframe ? AppColors.softGrey : DemoColors.ink;
  Color get _accent => _wireframe ? AppColors.softGrey : AppColors.demoAccent;

  TextStyle _text(double size, {bool bold = false, Color? color}) =>
      AppTypography.body(fontSize: size, fontWeight: bold ? FontWeight.w700 : FontWeight.w500, color: color ?? _ink, height: 1.3);

  BoxDecoration _box({bool selected = false}) => BoxDecoration(
    color: _wireframe ? AppColors.white : (selected ? AppColors.demoAccent.withValues(alpha: 0.08) : DemoColors.page),
    borderRadius: BorderRadius.circular(_wireframe ? 4 : 14),
    border: Border.all(color: selected ? _accent : (_wireframe ? AppColors.softGrey : DemoColors.line), width: selected ? 2 : 1),
  );

  Widget _body() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 46, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (_screen > 0)
                IconButton(
                  tooltip: 'Back',
                  onPressed: () => setState(() => _screen--),
                  icon: Icon(Icons.arrow_back_rounded, color: _ink),
                  visualDensity: VisualDensity.compact,
                ),
              Text(_wireframe ? '[ Bookly ]' : 'Bookly', style: _text(20, bold: true)),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(child: [_chooseService, _pickTime, _confirmed][_screen]()),
        ],
      ),
    );
  }

  Widget _primary(String label, VoidCallback? onTap) {
    return SizedBox(
      height: 50,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: _wireframe ? AppColors.softGrey : AppColors.demoAccent,
          disabledBackgroundColor: AppColors.lightGrey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_wireframe ? 4 : 14)),
        ),
        child: Text(label, style: _text(15, bold: true, color: AppColors.white)),
      ),
    );
  }

  Widget _chooseService() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('What would you like?', style: _text(16, bold: true)),
        const SizedBox(height: 12),
        for (var i = 0; i < _services.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => setState(() => _service = i),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: _box(selected: i == _service),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _wireframe ? AppColors.lightGrey : AppColors.demoAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(_wireframe ? 2 : 12),
                      ),
                      child: _wireframe ? null : const Icon(Icons.content_cut_rounded, color: AppColors.demoAccent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_services[i].$1, style: _text(14, bold: true)),
                          Text(_services[i].$2, style: _text(12)),
                        ],
                      ),
                    ),
                    Text(rupees(_services[i].$3), style: _text(14, bold: true, color: _accent)),
                  ],
                ),
              ),
            ),
          ),
        const Spacer(),
        _primary('Continue', () => setState(() => _screen = 1)),
      ],
    );
  }

  Widget _pickTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Tomorrow · ${_services[_service].$1}', style: _text(16, bold: true)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var i = 0; i < _times.length; i++)
              InkWell(
                onTap: i == 2 ? null : () => setState(() => _time = i),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 82,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: _box(selected: i == _time),
                  child: Text(
                    i == 2 ? 'Booked' : _times[i],
                    textAlign: TextAlign.center,
                    style: _text(14, bold: true, color: i == 2 ? AppColors.lightGrey : null),
                  ),
                ),
              ),
          ],
        ),
        const Spacer(),
        _primary('Book appointment', _time == null ? null : () => setState(() => _screen = 2)),
      ],
    );
  }

  Widget _confirmed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Icon(Icons.check_circle_rounded, size: 64, color: _accent),
        const SizedBox(height: 14),
        Text('You are booked!', textAlign: TextAlign.center, style: _text(20, bold: true)),
        const SizedBox(height: 8),
        Text('${_services[_service].$1}\nTomorrow at ${_times[_time ?? 0]}', textAlign: TextAlign.center, style: _text(14)),
        const Spacer(),
        _primary(
          'Start over',
          () => setState(() {
            _screen = 0;
            _time = null;
          }),
        ),
      ],
    );
  }
}
