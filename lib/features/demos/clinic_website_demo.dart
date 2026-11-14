import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import 'demo_kit.dart';

/// Website Development demo: a one-page clinic site with treatments, hours
/// and a validated appointment request form. Nothing is sent anywhere.
class ClinicWebsiteDemo extends StatefulWidget {
  const ClinicWebsiteDemo({super.key});

  @override
  State<ClinicWebsiteDemo> createState() => _ClinicWebsiteDemoState();
}

class _ClinicWebsiteDemoState extends State<ClinicWebsiteDemo> {
  static const _treatments = [
    (Icons.clean_hands_outlined, 'Check-up & Cleaning', 'A gentle 30-minute check-up with professional cleaning.'),
    (Icons.auto_awesome_outlined, 'Teeth Whitening', 'Safe, dentist-supervised whitening in one visit.'),
    (Icons.straighten_rounded, 'Clear Aligners', 'Discreet aligners with progress checks every month.'),
    (Icons.child_care_rounded, 'Children’s Dentistry', 'Friendly first visits that build good habits early.'),
  ];
  static const _hours = [('Mon – Fri', '9:00 am – 7:00 pm'), ('Saturday', '9:00 am – 2:00 pm'), ('Sunday', 'Closed')];
  static const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  final _formKey = GlobalKey<FormState>();
  final _bookingKey = GlobalKey();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  String? _treatment;
  String? _day;
  String? _confirmed;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _toBooking() {
    final target = _bookingKey.currentContext;
    if (target != null) Scrollable.ensureVisible(target, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _confirmed = _name.text.trim().split(' ').first);
  }

  void _reset() {
    _formKey.currentState?.reset();
    _name.clear();
    _phone.clear();
    setState(() {
      _treatment = null;
      _day = null;
      _confirmed = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final pad = wide ? 48.0 : 20.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _nav(wide, pad),
            _hero(wide, pad),
            Padding(
              padding: EdgeInsets.fromLTRB(pad, 48, pad, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title('Treatments'),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final (icon, name, text) in _treatments)
                        SizedBox(
                          width: wide ? (constraints.maxWidth - pad * 2 - 48) / 4 : constraints.maxWidth - pad * 2,
                          child: _TreatmentCard(icon: icon, name: name, text: text),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              key: _bookingKey,
              padding: EdgeInsets.fromLTRB(pad, 32, pad, 48),
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: _hoursPanel()),
                        const SizedBox(width: 24),
                        Expanded(flex: 6, child: _bookingPanel()),
                      ],
                    )
                  : Column(children: [_hoursPanel(), const SizedBox(height: 20), _bookingPanel()]),
            ),
            Container(
              color: DemoColors.ink,
              padding: EdgeInsets.symmetric(horizontal: pad, vertical: 20),
              child: Text(
                'Lumen Dental Care · 12 Lake View Road · Sample demo by YODYNIX',
                style: AppTypography.body(fontSize: 12.5, color: AppColors.lightGrey, height: 1.4),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _title(String text) => Text(text, style: AppTypography.display(fontSize: 26, color: DemoColors.ink, height: 1.2));

  Widget _nav(bool wide, double pad) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 16),
      decoration: const BoxDecoration(
        color: DemoColors.page,
        border: Border(bottom: BorderSide(color: DemoColors.line)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: AppColors.electricBlue, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.medical_services_outlined, size: 19, color: AppColors.white),
          ),
          const SizedBox(width: 10),
          Text('Lumen Dental Care', style: AppTypography.display(fontSize: 17, color: DemoColors.ink, height: 1.2)),
          const Spacer(),
          if (wide) ...[
            for (final l in ['Treatments', 'Hours', 'Contact'])
              Padding(
                padding: const EdgeInsets.only(right: 22),
                child: Text(
                  l,
                  style: AppTypography.body(fontSize: 14, fontWeight: FontWeight.w600, color: DemoColors.text, height: 1.2),
                ),
              ),
          ],
          DemoButton(label: 'Book', onPressed: _toBooking),
        ],
      ),
    );
  }

  Widget _hero(bool wide, double pad) {
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GENTLE, MODERN DENTISTRY',
          style: AppTypography.body(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.electricBlue,
            letterSpacing: 1.4,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Healthy smiles for the whole family.',
          style: AppTypography.display(fontSize: wide ? 42 : 30, color: DemoColors.ink, height: 1.15),
        ),
        const SizedBox(height: 14),
        Text(
          'Unhurried appointments, clear treatment plans and a calm clinic close to home.',
          style: AppTypography.body(fontSize: 16, color: DemoColors.text, height: 1.6),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            DemoButton(label: 'Request an appointment', icon: Icons.event_available_outlined, onPressed: _toBooking),
            DemoButton(label: 'See opening hours', outlined: true, onPressed: _toBooking),
          ],
        ),
      ],
    );
    final stats = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.electricBlue, AppColors.cyan],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.sentiment_satisfied_alt_rounded, size: 40, color: AppColors.white),
          const SizedBox(height: 18),
          Text('Open six days a week', style: AppTypography.display(fontSize: 22, color: AppColors.white, height: 1.25)),
          const SizedBox(height: 8),
          Text(
            'Same-week appointments for check-ups and emergencies.',
            style: AppTypography.body(fontSize: 14.5, color: AppColors.white, height: 1.55),
          ),
        ],
      ),
    );
    return Container(
      color: DemoColors.panel,
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: wide ? 56 : 36),
      child: wide
          ? Row(
              children: [
                Expanded(flex: 6, child: copy),
                const SizedBox(width: 40),
                Expanded(flex: 4, child: stats),
              ],
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [copy, const SizedBox(height: 24), stats]),
    );
  }

  Widget _hoursPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DemoColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: DemoColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('Opening Hours'),
          const SizedBox(height: 16),
          for (final (day, time) in _hours)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      day,
                      style: AppTypography.body(fontSize: 15, fontWeight: FontWeight.w600, color: DemoColors.ink, height: 1.3),
                    ),
                  ),
                  Text(time, style: AppTypography.body(fontSize: 15, color: DemoColors.text, height: 1.3)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Text(
            '12 Lake View Road · Parking available',
            style: AppTypography.body(fontSize: 13.5, color: DemoColors.muted, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _bookingPanel() {
    final confirmed = _confirmed;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DemoColors.page,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.electricBlue.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(color: AppColors.electricBlue.withValues(alpha: 0.10), blurRadius: 30, offset: const Offset(0, 12)),
        ],
      ),
      child: AnimatedSize(
        duration: AppMotion.lift,
        alignment: Alignment.topCenter,
        child: confirmed != null
            ? Column(
                key: const ValueKey('done'),
                children: [
                  const Icon(Icons.check_circle_rounded, size: 52, color: AppColors.electricBlue),
                  const SizedBox(height: 14),
                  Text(
                    'Thank you, $confirmed!',
                    textAlign: TextAlign.center,
                    style: AppTypography.display(fontSize: 22, color: DemoColors.ink, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your request for $_treatment on $_day has been noted. In a real site the clinic '
                    'would call you to confirm a time. (Demo only — nothing was sent.)',
                    textAlign: TextAlign.center,
                    style: AppTypography.body(fontSize: 14.5, color: DemoColors.text, height: 1.6),
                  ),
                  const SizedBox(height: 18),
                  DemoButton(label: 'Make another request', outlined: true, onPressed: _reset),
                ],
              )
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _title('Request an Appointment'),
                    const SizedBox(height: 18),
                    DemoField(
                      label: 'Full name',
                      controller: _name,
                      validator: (v) => (v == null || v.trim().length < 2) ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 14),
                    DemoField(
                      label: 'Phone number',
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          RegExp(r'^\+?[0-9 ]{10,14}$').hasMatch(v?.trim() ?? '') ? null : 'Enter a valid phone number',
                    ),
                    const SizedBox(height: 14),
                    _dropdown(
                      'Treatment',
                      _treatments.map((t) => t.$2).toList(),
                      _treatment,
                      (v) => setState(() => _treatment = v),
                    ),
                    const SizedBox(height: 14),
                    _dropdown('Preferred day', _days, _day, (v) => setState(() => _day = v)),
                    const SizedBox(height: 20),
                    DemoButton(label: 'Send request', icon: Icons.send_rounded, expand: true, onPressed: _submit),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _dropdown(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: BorderSide(color: c),
    );
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: [for (final i in items) DropdownMenuItem(value: i, child: Text(i))],
      onChanged: onChanged,
      validator: (v) => v == null ? 'Please choose an option' : null,
      dropdownColor: DemoColors.page,
      style: AppTypography.body(fontSize: 14.5, color: DemoColors.ink, height: 1.4),
      iconEnabledColor: DemoColors.text,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        filled: true,
        fillColor: DemoColors.panel,
        labelStyle: AppTypography.body(fontSize: 14, color: DemoColors.muted, height: 1.2),
        errorStyle: AppTypography.body(fontSize: 12, color: AppColors.electricBlue, fontWeight: FontWeight.w600, height: 1.2),
        border: border(DemoColors.line),
        enabledBorder: border(DemoColors.line),
        focusedBorder: border(AppColors.electricBlue),
        errorBorder: border(AppColors.electricBlue),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _TreatmentCard extends StatelessWidget {
  const _TreatmentCard({required this.icon, required this.name, required this.text});

  final IconData icon;
  final String name;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DemoColors.page,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: DemoColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.electricBlue, size: 22),
          ),
          const SizedBox(height: 14),
          Text(name, style: AppTypography.display(fontSize: 16, color: DemoColors.ink, height: 1.3)),
          const SizedBox(height: 6),
          Text(text, style: AppTypography.body(fontSize: 13.5, color: DemoColors.text, height: 1.55)),
        ],
      ),
    );
  }
}
