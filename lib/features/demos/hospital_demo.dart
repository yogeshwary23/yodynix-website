import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import 'demo_kit.dart';

/// Custom Software demo: ClinicDesk HMS, the front office of a fictional
/// hospital. Issue OPD tokens, call the next patient, admit and discharge
/// patients on the ward bed board, and settle bills; every number on the
/// dashboard follows. Sample data only, kept for the browser session.
class HospitalDemo extends StatefulWidget {
  const HospitalDemo({super.key});

  @override
  State<HospitalDemo> createState() => _HospitalDemoState();
}

enum _View {
  opd('OPD Queue', Icons.confirmation_number_outlined),
  beds('Ward Beds', Icons.bed_outlined),
  billing('Billing', Icons.receipt_long_outlined);

  const _View(this.label, this.icon);

  final String label;
  final IconData icon;
}

enum _TokenStatus {
  waiting('Waiting'),
  consulting('In consultation'),
  done('Seen');

  const _TokenStatus(this.label);

  final String label;
}

const List<String> _departments = ['General Medicine', 'Paediatrics', 'Orthopaedics', 'Gynaecology', 'ENT'];

/// Ward name and its daily bed charge in rupees.
const List<(String, int)> _wards = [('General Ward', 1500), ('Semi-private', 3000), ('ICU', 8000)];

class _Token {
  _Token(this.number, this.name, this.age, this.department, [this.status = _TokenStatus.waiting]);

  final int number;
  final String name;
  final int age;
  final String department;
  _TokenStatus status;
}

class _Bed {
  _Bed(this.ward, this.code, [this.patient]);

  final String ward;
  final String code;
  String? patient;
}

class _Bill {
  _Bill(this.number, this.patient, this.item, this.amount, {this.paid = false});

  final int number;
  final String patient;
  final String item;
  final int amount;
  bool paid;
}

class _HospitalDemoState extends State<HospitalDemo> {
  _View _view = _View.opd;
  int _nextToken = 107;
  int _nextBill = 1004;

  final List<_Token> _tokens = [
    _Token(101, 'Meera Kulkarni', 34, 'Gynaecology', _TokenStatus.done),
    _Token(102, 'Arjun Patil', 8, 'Paediatrics', _TokenStatus.done),
    _Token(103, 'Suresh Pawar', 61, 'General Medicine', _TokenStatus.consulting),
    _Token(104, 'Fatima Sayyed', 27, 'ENT'),
    _Token(105, 'Rohan Jadhav', 45, 'Orthopaedics'),
    _Token(106, 'Lata Shinde', 52, 'General Medicine'),
  ];

  final List<_Bed> _beds = [
    _Bed('General Ward', 'G1', 'Ganesh More'),
    _Bed('General Ward', 'G2'),
    _Bed('General Ward', 'G3', 'Kavita Bhosale'),
    _Bed('General Ward', 'G4'),
    _Bed('General Ward', 'G5'),
    _Bed('General Ward', 'G6', 'Nitin Gaikwad'),
    _Bed('Semi-private', 'S1'),
    _Bed('Semi-private', 'S2', 'Asha Deshpande'),
    _Bed('Semi-private', 'S3'),
    _Bed('Semi-private', 'S4'),
    _Bed('ICU', 'I1', 'Ramesh Kale'),
    _Bed('ICU', 'I2'),
    _Bed('ICU', 'I3'),
  ];

  final List<_Bill> _bills = [
    _Bill(1003, 'Arjun Patil', 'OPD consultation · Paediatrics', 500),
    _Bill(1002, 'Meera Kulkarni', 'OPD consultation · Gynaecology', 500, paid: true),
    _Bill(1001, 'Prakash Naik', 'Ward stay · General Ward', 4500, paid: true),
  ];

  _Token? get _serving {
    for (final t in _tokens) {
      if (t.status == _TokenStatus.consulting) return t;
    }
    return null;
  }

  int get _waiting => _tokens.where((t) => t.status == _TokenStatus.waiting).length;

  int _rate(String ward) => _wards.firstWhere((w) => w.$1 == ward).$2;

  /// Finishes the current consultation (and bills it), then calls the next
  /// waiting token.
  void _callNext() {
    setState(() {
      final current = _serving;
      if (current != null) {
        current.status = _TokenStatus.done;
        _bills.insert(0, _Bill(_nextBill++, current.name, 'OPD consultation · ${current.department}', 500));
      }
      for (final t in _tokens) {
        if (t.status == _TokenStatus.waiting) {
          t.status = _TokenStatus.consulting;
          break;
        }
      }
    });
  }

  Future<void> _newToken() async {
    final entry = await showDialog<(String, int, String)>(context: context, builder: (_) => const _NewTokenDialog());
    if (entry == null || !mounted) return;
    setState(() {
      _tokens.add(_Token(_nextToken++, entry.$1, entry.$2, entry.$3));
      _view = _View.opd;
    });
  }

  Future<void> _tapBed(_Bed bed) async {
    final patient = bed.patient;
    if (patient != null) {
      // Discharge: free the bed and bill a three-day stay.
      setState(() {
        bed.patient = null;
        _bills.insert(0, _Bill(_nextBill++, patient, 'Ward stay · ${bed.ward} (3 days)', _rate(bed.ward) * 3));
      });
      return;
    }
    final admitted = {for (final b in _beds) b.patient};
    final candidates = [
      for (final t in _tokens)
        if (t.status != _TokenStatus.waiting && !admitted.contains(t.name)) t.name,
    ];
    final chosen = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: DemoColors.page,
        title: Text(
          'Admit to ${bed.code} · ${bed.ward}',
          style: AppTypography.display(fontSize: 19, color: DemoColors.ink, height: 1.2),
        ),
        children: [
          if (candidates.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
              child: Text(
                'No patient from today’s OPD is waiting for a bed. Call the next token first.',
                style: AppTypography.body(fontSize: 14, color: DemoColors.muted, height: 1.5),
              ),
            ),
          for (final name in candidates)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(name),
              child: Text(name, style: AppTypography.body(fontSize: 15, color: DemoColors.ink, height: 1.4)),
            ),
        ],
      ),
    );
    if (chosen != null && mounted) setState(() => bed.patient = chosen);
  }

  @override
  Widget build(BuildContext context) {
    final occupied = _beds.where((b) => b.patient != null).length;
    final collected = _bills.where((b) => b.paid).fold(0, (s, b) => s + b.amount);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        final pad = wide ? 28.0 : 16.0;
        final statWidth = wide ? (constraints.maxWidth - pad * 2 - 36) / 4 : (constraints.maxWidth - pad * 2 - 12) / 2;
        return Padding(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('ClinicDesk HMS', style: AppTypography.display(fontSize: 22, color: DemoColors.ink, height: 1.2)),
                      const SizedBox(height: 2),
                      Text(
                        'Sunrise Multispeciality Hospital · Front office',
                        style: AppTypography.body(fontSize: 13, color: DemoColors.muted, height: 1.3),
                      ),
                    ],
                  ),
                  DemoButton(label: 'New OPD token', icon: Icons.add_rounded, onPressed: _newToken),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _Stat(width: statWidth, label: 'OPD patients today', value: '${_tokens.length}'),
                  _Stat(width: statWidth, label: 'Waiting now', value: '$_waiting'),
                  _Stat(width: statWidth, label: 'Beds occupied', value: '$occupied / ${_beds.length}'),
                  _Stat(width: statWidth, label: 'Collected today', value: rupees(collected)),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final v in _View.values)
                    DemoChip(label: v.label, icon: v.icon, selected: _view == v, onTap: () => setState(() => _view = v)),
                ],
              ),
              const SizedBox(height: 14),
              switch (_view) {
                _View.opd => _opd(wide),
                _View.beds => _bedBoard(),
                _View.billing => _billing(wide),
              },
            ],
          ),
        );
      },
    );
  }

  Widget _opd(bool wide) {
    final serving = _serving;
    final nowServing = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.demoAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.demoAccent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.demoAccent, borderRadius: BorderRadius.circular(AppRadius.sm)),
            child: Text(
              serving == null ? '—' : '${serving.number}',
              style: AppTypography.body(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.white, height: 1),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOW SERVING',
                  style: AppTypography.body(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.demoAccent,
                    letterSpacing: 1,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  serving == null ? 'No patient in consultation' : serving.name,
                  style: AppTypography.body(fontSize: 16, fontWeight: FontWeight.w700, color: DemoColors.ink, height: 1.3),
                ),
                if (serving != null)
                  Text(
                    '${serving.age} yrs · ${serving.department}',
                    style: AppTypography.body(fontSize: 13, color: DemoColors.muted, height: 1.3),
                  ),
              ],
            ),
          ),
          if (wide) ...[
            const SizedBox(width: 12),
            DemoButton(label: 'Call next', icon: Icons.campaign_outlined, onPressed: _waiting == 0 ? null : _callNext),
          ],
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        nowServing,
        if (!wide) ...[
          const SizedBox(height: 10),
          DemoButton(
            label: 'Call next',
            icon: Icons.campaign_outlined,
            expand: true,
            onPressed: _waiting == 0 ? null : _callNext,
          ),
        ],
        const SizedBox(height: 14),
        _Table(
          children: [
            for (final t in _tokens)
              Row(
                children: [
                  _Badge(text: '${t.number}'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.name,
                          style: AppTypography.body(fontSize: 14, fontWeight: FontWeight.w700, color: DemoColors.ink, height: 1.3),
                        ),
                        Text(
                          '${t.age} yrs · ${t.department}',
                          style: AppTypography.body(fontSize: 12.5, color: DemoColors.muted, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  _Pill(text: t.status.label, strong: t.status == _TokenStatus.consulting, faded: t.status == _TokenStatus.done),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget _bedBoard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Tap a free bed to admit a patient seen in today’s OPD, or an occupied bed to discharge and bill the stay.',
          style: AppTypography.body(fontSize: 13, color: DemoColors.muted, height: 1.5),
        ),
        for (final (ward, rate) in _wards) ...[
          const SizedBox(height: 16),
          Text(
            '$ward · ${rupees(rate)} per day',
            style: AppTypography.body(fontSize: 13.5, fontWeight: FontWeight.w700, color: DemoColors.text, height: 1.3),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final bed in _beds.where((b) => b.ward == ward)) _BedTile(bed: bed, onTap: () => _tapBed(bed)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _billing(bool wide) {
    final pending = _bills.where((b) => !b.paid).fold(0, (s, b) => s + b.amount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Pending: ${rupees(pending)}',
          style: AppTypography.body(fontSize: 13.5, fontWeight: FontWeight.w700, color: DemoColors.text, height: 1.3),
        ),
        const SizedBox(height: 10),
        _Table(
          children: [
            for (final b in _bills)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INV-${b.number} · ${b.patient}',
                          style: AppTypography.body(fontSize: 14, fontWeight: FontWeight.w700, color: DemoColors.ink, height: 1.3),
                        ),
                        Text(b.item, style: AppTypography.body(fontSize: 12.5, color: DemoColors.muted, height: 1.3)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    rupees(b.amount),
                    style: AppTypography.body(fontSize: 14, fontWeight: FontWeight.w700, color: DemoColors.text, height: 1.3),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: wide ? 112 : 84,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: b.paid
                          ? const _Pill(text: 'Paid', strong: true)
                          : TextButton(
                              onPressed: () => setState(() => b.paid = true),
                              style: TextButton.styleFrom(foregroundColor: AppColors.demoAccent),
                              child: Text(wide ? 'Mark paid' : 'Pay'),
                            ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.width, required this.label, required this.value});

  final double width;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DemoColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: DemoColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.body(fontSize: 12, fontWeight: FontWeight.w600, color: DemoColors.muted, height: 1.2),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            // Inter, not Sora: the bundled Sora has no ₹ glyph.
            child: Text(
              value,
              style: AppTypography.body(fontSize: 20, fontWeight: FontWeight.w700, color: DemoColors.ink, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}

/// A bordered list with a divider between rows.
class _Table extends StatelessWidget {
  const _Table({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: DemoColors.line),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: i > 0 ? const Border(top: BorderSide(color: DemoColors.line)) : null,
              ),
              child: children[i],
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: AppColors.charcoal, borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
        style: AppTypography.body(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.white, height: 1),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, this.strong = false, this.faded = false});

  final String text;
  final bool strong;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    final Color fill = strong
        ? AppColors.demoAccent
        : faded
        ? DemoColors.panel
        : AppColors.demoAccent.withValues(alpha: 0.10);
    final Color ink = strong ? AppColors.white : (faded ? DemoColors.muted : AppColors.demoAccent);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(text, style: AppTypography.body(fontSize: 12, fontWeight: FontWeight.w700, color: ink, height: 1.2)),
    );
  }
}

class _BedTile extends StatelessWidget {
  const _BedTile({required this.bed, required this.onTap});

  final _Bed bed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final patient = bed.patient;
    final busy = patient != null;
    return Semantics(
      button: true,
      label: busy ? 'Bed ${bed.code}, occupied by $patient. Discharge.' : 'Bed ${bed.code}, free. Admit a patient.',
      child: Material(
        color: busy ? AppColors.demoAccent.withValues(alpha: 0.12) : DemoColors.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: BorderSide(color: busy ? AppColors.demoAccent.withValues(alpha: 0.5) : DemoColors.line),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          onTap: onTap,
          child: SizedBox(
            width: 118,
            height: 70,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(busy ? Icons.hotel_rounded : Icons.bed_outlined, size: 16, color: busy ? AppColors.demoAccent : DemoColors.muted),
                      const SizedBox(width: 6),
                      Text(
                        bed.code,
                        style: AppTypography.body(fontSize: 13, fontWeight: FontWeight.w700, color: DemoColors.ink, height: 1.2),
                      ),
                    ],
                  ),
                  Text(
                    patient ?? 'Free',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(fontSize: 12, color: busy ? DemoColors.text : DemoColors.muted, height: 1.2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NewTokenDialog extends StatefulWidget {
  const _NewTokenDialog();

  @override
  State<_NewTokenDialog> createState() => _NewTokenDialogState();
}

class _NewTokenDialogState extends State<_NewTokenDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _age = TextEditingController();
  String _department = _departments.first;

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_form.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop((_name.text.trim(), int.parse(_age.text.trim()), _department));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DemoColors.page,
      title: Text('New OPD token', style: AppTypography.display(fontSize: 20, color: DemoColors.ink, height: 1.2)),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DemoField(
                label: 'Patient name',
                controller: _name,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DemoField(
                label: 'Age',
                controller: _age,
                keyboardType: TextInputType.number,
                validator: (v) {
                  final age = int.tryParse(v?.trim() ?? '');
                  return age != null && age >= 0 && age <= 120 ? null : 'Enter an age from 0 to 120';
                },
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 14),
              Text(
                'Department',
                style: AppTypography.body(fontSize: 13, fontWeight: FontWeight.w600, color: DemoColors.muted, height: 1.2),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final d in _departments)
                    DemoChip(label: d, selected: _department == d, onTap: () => setState(() => _department = d)),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        DemoButton(label: 'Issue token', onPressed: _save),
      ],
    );
  }
}
