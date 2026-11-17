import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import 'demo_kit.dart';

/// Custom Software demo: LeadDesk, a mini CRM with search, status filters,
/// pipeline totals, a validated "add lead" dialog and status updates.
class MiniCrmDemo extends StatefulWidget {
  const MiniCrmDemo({super.key});

  @override
  State<MiniCrmDemo> createState() => _MiniCrmDemoState();
}

enum LeadStatus {
  newLead('New'),
  contacted('Contacted'),
  proposal('Proposal'),
  won('Won');

  const LeadStatus(this.label);

  final String label;
}

class _Lead {
  _Lead(this.name, this.company, this.value, this.status);

  final String name;
  final String company;
  final int value;
  LeadStatus status;
}

class _MiniCrmDemoState extends State<MiniCrmDemo> {
  final _search = TextEditingController();
  LeadStatus? _filter;
  final List<_Lead> _leads = [
    _Lead('Priya Nair', 'Nair Interiors', 85000, LeadStatus.proposal),
    _Lead('Rahul Deshmukh', 'Deshmukh Motors', 140000, LeadStatus.contacted),
    _Lead('Sana Kapoor', 'Kapoor Bakes', 32000, LeadStatus.newLead),
    _Lead('Vikram Joshi', 'Joshi Logistics', 260000, LeadStatus.won),
    _Lead('Anita Rao', 'Rao Clinics', 120000, LeadStatus.newLead),
    _Lead('Imran Shaikh', 'Shaikh Textiles', 54000, LeadStatus.contacted),
  ];

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<_Lead> get _visible {
    final q = _search.text.trim().toLowerCase();
    return _leads
        .where((l) => _filter == null || l.status == _filter)
        .where((l) => q.isEmpty || l.name.toLowerCase().contains(q) || l.company.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _addLead() async {
    final lead = await showDialog<_Lead>(context: context, builder: (_) => const _AddLeadDialog());
    if (lead != null) setState(() => _leads.insert(0, lead));
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final open = _leads.where((l) => l.status != LeadStatus.won).fold(0, (s, l) => s + l.value);
    final won = _leads.where((l) => l.status == LeadStatus.won).fold(0, (s, l) => s + l.value);

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
              Row(
                children: [
                  Expanded(
                    child: Text('LeadDesk', style: AppTypography.display(fontSize: 22, color: DemoColors.ink, height: 1.2)),
                  ),
                  DemoButton(label: 'Add lead', icon: Icons.person_add_alt_1_rounded, onPressed: _addLead),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _Stat(width: statWidth, label: 'Total leads', value: '${_leads.length}'),
                  _Stat(width: statWidth, label: 'Open pipeline', value: rupees(open)),
                  _Stat(width: statWidth, label: 'Won', value: rupees(won)),
                  _Stat(
                    width: statWidth,
                    label: 'Win rate',
                    value: '${(_leads.where((l) => l.status == LeadStatus.won).length * 100 / _leads.length).round()}%',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              DemoField(label: 'Search name or company', controller: _search),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  DemoChip(label: 'All', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                  for (final s in LeadStatus.values)
                    DemoChip(label: s.label, selected: _filter == s, onTap: () => setState(() => _filter = s)),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: DemoColors.line),
                ),
                child: Column(
                  children: [
                    if (visible.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: Text(
                          'No leads match your search.',
                          style: AppTypography.body(fontSize: 14, color: DemoColors.muted),
                        ),
                      ),
                    for (var i = 0; i < visible.length; i++)
                      _LeadRow(
                        lead: visible[i],
                        wide: wide,
                        divider: i > 0,
                        onStatus: (s) => setState(() => visible[i].status = s),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

class _LeadRow extends StatelessWidget {
  const _LeadRow({required this.lead, required this.wide, required this.divider, required this.onStatus});

  final _Lead lead;
  final bool wide;
  final bool divider;
  final ValueChanged<LeadStatus> onStatus;

  @override
  Widget build(BuildContext context) {
    final status = PopupMenuButton<LeadStatus>(
      tooltip: 'Change status',
      initialValue: lead.status,
      onSelected: onStatus,
      color: DemoColors.page,
      itemBuilder: (_) => [for (final s in LeadStatus.values) PopupMenuItem(value: s, child: Text(s.label))],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: lead.status == LeadStatus.won ? AppColors.demoAccent : AppColors.demoAccent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              lead.status.label,
              style: AppTypography.body(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: lead.status == LeadStatus.won ? AppColors.white : AppColors.demoAccent,
                height: 1.2,
              ),
            ),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 18,
              color: lead.status == LeadStatus.won ? AppColors.white : AppColors.demoAccent,
            ),
          ],
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: divider ? const Border(top: BorderSide(color: DemoColors.line)) : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.charcoal,
            child: Text(
              lead.name[0],
              style: AppTypography.body(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white, height: 1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lead.name,
                  style: AppTypography.body(fontSize: 14, fontWeight: FontWeight.w700, color: DemoColors.ink, height: 1.3),
                ),
                Text(
                  wide ? lead.company : '${lead.company} · ${rupees(lead.value)}',
                  style: AppTypography.body(fontSize: 12.5, color: DemoColors.muted, height: 1.3),
                ),
              ],
            ),
          ),
          if (wide)
            SizedBox(
              width: 120,
              child: Text(
                rupees(lead.value),
                style: AppTypography.body(fontSize: 14, fontWeight: FontWeight.w600, color: DemoColors.text, height: 1.3),
              ),
            ),
          SizedBox(
            width: 120,
            child: Align(alignment: Alignment.centerRight, child: status),
          ),
        ],
      ),
    );
  }
}

class _AddLeadDialog extends StatefulWidget {
  const _AddLeadDialog();

  @override
  State<_AddLeadDialog> createState() => _AddLeadDialogState();
}

class _AddLeadDialogState extends State<_AddLeadDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _company = TextEditingController();
  final _value = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _company.dispose();
    _value.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_form.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(_Lead(_name.text.trim(), _company.text.trim(), int.parse(_value.text.trim()), LeadStatus.newLead));
  }

  @override
  Widget build(BuildContext context) {
    String? required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
    return AlertDialog(
      backgroundColor: DemoColors.page,
      title: Text('Add lead', style: AppTypography.display(fontSize: 20, color: DemoColors.ink, height: 1.2)),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DemoField(label: 'Contact name', controller: _name, validator: required),
              const SizedBox(height: 12),
              DemoField(label: 'Company', controller: _company, validator: required),
              const SizedBox(height: 12),
              DemoField(
                label: 'Deal value (₹)',
                controller: _value,
                keyboardType: TextInputType.number,
                validator: (v) => (int.tryParse(v?.trim() ?? '') ?? 0) > 0 ? null : 'Enter a whole amount',
                onSubmitted: (_) => _save(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        DemoButton(label: 'Save lead', onPressed: _save),
      ],
    );
  }
}
