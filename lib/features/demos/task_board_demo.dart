import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import 'demo_kit.dart';

/// Flutter demo: TaskFlow, one task board codebase previewed at phone,
/// tablet and desktop widths. Tasks can be added and moved between columns.
class TaskBoardDemo extends StatefulWidget {
  const TaskBoardDemo({super.key});

  @override
  State<TaskBoardDemo> createState() => _TaskBoardDemoState();
}

enum _Device {
  phone('Phone', Icons.smartphone_rounded, 360),
  tablet('Tablet', Icons.tablet_mac_rounded, 640),
  desktop('Desktop', Icons.desktop_windows_outlined, 980);

  const _Device(this.label, this.icon, this.width);

  final String label;
  final IconData icon;
  final double width;
}

class _Task {
  _Task(this.title, this.tag, this.column);

  final String title;
  final String tag;
  int column;
}

class _TaskBoardDemoState extends State<TaskBoardDemo> {
  static const _columns = ['To Do', 'In Progress', 'Done'];

  _Device _device = _Device.desktop;
  final _input = TextEditingController();
  final List<_Task> _tasks = [
    _Task('Design login screen', 'Design', 2),
    _Task('Connect tasks API', 'Backend', 1),
    _Task('Offline sync for tasks', 'Mobile', 0),
    _Task('Push notification reminders', 'Mobile', 0),
    _Task('Write widget tests', 'QA', 1),
  ];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _add() {
    final title = _input.text.trim();
    if (title.isEmpty) return;
    setState(() {
      _tasks.add(_Task(title, 'New', 0));
      _input.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Preview on:',
                style: AppTypography.body(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.lightGrey, height: 1.2),
              ),
              for (final d in _Device.values)
                DemoChip(
                  label: d.label,
                  icon: d.icon,
                  light: false,
                  selected: d == _device,
                  onTap: () => setState(() => _device = d),
                ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = _device.width.clamp(280.0, constraints.maxWidth);
              return Center(
                child: AnimatedContainer(
                  duration: AppMotion.lift,
                  curve: AppMotion.ease,
                  width: width,
                  decoration: BoxDecoration(
                    color: DemoColors.panel,
                    borderRadius: BorderRadius.circular(_device == _Device.phone ? 28 : AppRadius.md),
                    border: Border.all(
                      color: AppColors.demoAccent.withValues(alpha: 0.4),
                      width: _device == _Device.phone ? 6 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _board(width),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Same Flutter widgets, three layouts: columns stack on phones and sit side by side on wider screens.',
            textAlign: TextAlign.center,
            style: AppTypography.body(fontSize: 13, color: AppColors.softGrey, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _board(double width) {
    final stacked = width < 600;
    final columns = [
      for (var i = 0; i < _columns.length; i++)
        _Column(
          title: _columns[i],
          tasks: _tasks.where((t) => t.column == i).toList(),
          onMove: (t, dir) => setState(() => t.column = (t.column + dir).clamp(0, _columns.length - 1)),
        ),
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('TaskFlow', style: AppTypography.display(fontSize: 19, color: DemoColors.ink, height: 1.2)),
              const Spacer(),
              Text(
                '${_tasks.where((t) => t.column == 2).length}/${_tasks.length} done',
                style: AppTypography.body(fontSize: 12.5, fontWeight: FontWeight.w600, color: DemoColors.muted, height: 1.2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DemoField(label: 'New task', controller: _input, onSubmitted: (_) => _add()),
              ),
              const SizedBox(width: 8),
              DemoButton(label: 'Add', icon: Icons.add_rounded, onPressed: _add),
            ],
          ),
          const SizedBox(height: 14),
          if (stacked)
            for (final c in columns) Padding(padding: const EdgeInsets.only(bottom: 12), child: c)
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < columns.length; i++) ...[if (i > 0) const SizedBox(width: 12), Expanded(child: columns[i])],
              ],
            ),
        ],
      ),
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({required this.title, required this.tasks, required this.onMove});

  final String title;
  final List<_Task> tasks;
  final void Function(_Task task, int direction) onMove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: DemoColors.line.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
            child: Text(
              '$title · ${tasks.length}',
              style: AppTypography.body(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: DemoColors.text,
                letterSpacing: 0.4,
                height: 1.2,
              ),
            ),
          ),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text('Nothing here', style: AppTypography.body(fontSize: 12.5, color: DemoColors.muted, height: 1.2)),
            ),
          for (final t in tasks)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
              decoration: BoxDecoration(
                color: DemoColors.page,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: DemoColors.line),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          style: AppTypography.body(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: DemoColors.ink,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          t.tag,
                          style: AppTypography.body(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.demoAccent,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (t.column > 0) _move(Icons.chevron_left_rounded, 'Move back', () => onMove(t, -1)),
                  if (t.column < 2) _move(Icons.chevron_right_rounded, 'Move forward', () => onMove(t, 1)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _move(IconData icon, String tip, VoidCallback onTap) => IconButton(
    tooltip: tip,
    onPressed: onTap,
    icon: Icon(icon, size: 20),
    color: DemoColors.text,
    visualDensity: VisualDensity.compact,
  );
}
