import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import 'demo_kit.dart';

/// Mobile App demo: FitSlot, a fitness-class booking app shown in a phone
/// frame. Pick a day, book a class (seat counts update), then view or
/// cancel bookings.
class ClassBookingDemo extends StatefulWidget {
  const ClassBookingDemo({super.key});

  @override
  State<ClassBookingDemo> createState() => _ClassBookingDemoState();
}

class _Session {
  _Session(this.day, this.time, this.name, this.coach, this.seats);

  final int day;
  final String time;
  final String name;
  final String coach;
  int seats;
  bool booked = false;
}

class _ClassBookingDemoState extends State<ClassBookingDemo> {
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  late final List<_Session> _sessions = [
    _Session(0, '6:30 AM', 'Morning Yoga', 'Coach Meera', 6),
    _Session(0, '7:00 PM', 'HIIT Express', 'Coach Arjun', 2),
    _Session(1, '7:00 AM', 'Strength Basics', 'Coach Kabir', 8),
    _Session(1, '6:30 PM', 'Zumba', 'Coach Riya', 1),
    _Session(2, '6:30 AM', 'Pilates Core', 'Coach Meera', 5),
    _Session(2, '7:30 PM', 'Spin Class', 'Coach Arjun', 0),
    _Session(3, '7:00 AM', 'Mobility Flow', 'Coach Riya', 9),
    _Session(4, '6:30 PM', 'Boxing Fit', 'Coach Kabir', 3),
    _Session(5, '8:00 AM', 'Weekend Bootcamp', 'Coach Arjun', 12),
  ];

  int _day = 0;
  int _tab = 0;
  String? _toast;

  void _toggle(_Session s) {
    setState(() {
      if (s.booked) {
        s.booked = false;
        s.seats++;
        _toast = 'Cancelled ${s.name}';
      } else if (s.seats > 0) {
        s.booked = true;
        s.seats--;
        _toast = 'Booked ${s.name} · ${_days[s.day]} ${s.time}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final booked = _sessions.where((s) => s.booked).toList();
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: PhoneFrame(
            child: ColoredBox(
              color: DemoColors.panel,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 44, 20, 18),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.charcoal, AppColors.charcoalRaised],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FitSlot', style: AppTypography.display(fontSize: 22, color: AppColors.white, height: 1.2)),
                        const SizedBox(height: 4),
                        Text(
                          _tab == 0
                              ? 'Book your next class'
                              : '${booked.length} upcoming booking${booked.length == 1 ? '' : 's'}',
                          style: AppTypography.body(fontSize: 13, color: AppColors.lightGrey, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _tab == 0 ? _schedule() : _bookings(booked)),
                  if (_toast != null)
                    Container(
                      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(color: AppColors.charcoal, borderRadius: BorderRadius.circular(AppRadius.sm)),
                      child: Text(
                        _toast!,
                        style: AppTypography.body(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                          height: 1.3,
                        ),
                      ),
                    ),
                  NavigationBarTheme(
                    data: NavigationBarThemeData(
                      backgroundColor: DemoColors.page,
                      indicatorColor: AppColors.demoAccent.withValues(alpha: 0.14),
                      labelTextStyle: WidgetStatePropertyAll(
                        AppTypography.body(fontSize: 11.5, fontWeight: FontWeight.w600, color: DemoColors.ink, height: 1.2),
                      ),
                    ),
                    child: NavigationBar(
                      height: 64,
                      selectedIndex: _tab,
                      onDestinationSelected: (i) => setState(() {
                        _tab = i;
                        _toast = null;
                      }),
                      destinations: [
                        const NavigationDestination(
                          icon: Icon(Icons.calendar_month_outlined, color: DemoColors.muted),
                          selectedIcon: Icon(Icons.calendar_month_rounded, color: AppColors.demoAccent),
                          label: 'Classes',
                        ),
                        NavigationDestination(
                          icon: Badge(
                            isLabelVisible: booked.isNotEmpty,
                            backgroundColor: AppColors.demoAccent,
                            label: Text('${booked.length}'),
                            child: const Icon(Icons.confirmation_number_outlined, color: DemoColors.muted),
                          ),
                          selectedIcon: const Icon(Icons.confirmation_number_rounded, color: AppColors.demoAccent),
                          label: 'My Bookings',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _schedule() {
    final today = _sessions.where((s) => s.day == _day).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 62,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            itemCount: _days.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) => DemoChip(label: _days[i], selected: i == _day, onTap: () => setState(() => _day = i)),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            children: [
              if (today.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No classes scheduled.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body(fontSize: 14, color: DemoColors.muted),
                  ),
                ),
              for (final s in today) _SessionCard(session: s, onTap: () => _toggle(s)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bookings(List<_Session> booked) {
    if (booked.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event_busy_outlined, size: 40, color: DemoColors.muted),
              const SizedBox(height: 10),
              Text(
                'No bookings yet. Pick a class from the schedule.',
                textAlign: TextAlign.center,
                style: AppTypography.body(fontSize: 14, color: DemoColors.text, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [for (final s in booked) _SessionCard(session: s, onTap: () => _toggle(s), dayLabel: _days[s.day])],
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.onTap, this.dayLabel});

  final _Session session;
  final VoidCallback onTap;
  final String? dayLabel;

  @override
  Widget build(BuildContext context) {
    final s = session;
    final full = s.seats == 0 && !s.booked;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DemoColors.page,
        borderRadius: BorderRadius.circular(AppRadius.sm + 2),
        border: Border.all(color: s.booked ? AppColors.demoAccent : DemoColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayLabel == null ? s.time : '$dayLabel · ${s.time}',
                  style: AppTypography.body(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.demoAccent,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.name,
                  style: AppTypography.body(fontSize: 15, fontWeight: FontWeight.w700, color: DemoColors.ink, height: 1.3),
                ),
                Text(
                  '${s.coach} · ${full ? 'Full' : '${s.seats} seat${s.seats == 1 ? '' : 's'} left'}',
                  style: AppTypography.body(fontSize: 12, color: DemoColors.muted, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 36,
            child: s.booked
                ? OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.demoAccent,
                      side: const BorderSide(color: AppColors.demoAccent),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Cancel'),
                  )
                : FilledButton(
                    onPressed: full ? null : onTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.demoAccent,
                      disabledBackgroundColor: DemoColors.line,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    child: Text(full ? 'Full' : 'Book'),
                  ),
          ),
        ],
      ),
    );
  }
}
