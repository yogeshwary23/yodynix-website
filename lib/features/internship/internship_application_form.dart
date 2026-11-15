import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/site_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../models/contact_enquiry.dart' show SubmissionResult, SubmissionStatus;
import '../../models/internship_application.dart';
import '../../repositories/content/internship_content.dart';
import '../../repositories/internship_application_repository.dart';
import '../../services/link_service.dart';
import '../../shared/widgets/buttons.dart';

/// Internship application / register-interest form. [selection] holds the
/// preferred programme's slug so page CTAs can pre-select it.
///
/// While no backend is connected the form says so up front, and a submission
/// reports that nothing was sent instead of showing a false success.
class InternshipApplicationForm extends StatefulWidget {
  const InternshipApplicationForm({
    super.key,
    required this.selection,
    this.repository = const PendingBackendInternshipRepository(),
  });

  final ValueNotifier<String?> selection;
  final InternshipApplicationRepository repository;

  @override
  State<InternshipApplicationForm> createState() => _InternshipApplicationFormState();
}

class _InternshipApplicationFormState extends State<InternshipApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _institution = TextEditingController();
  final _experience = TextEditingController();
  final _message = TextEditingController();

  String? _education;
  InternshipType? _type;
  bool _typeError = false;
  bool _submitting = false;
  SubmissionResult? _result;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  /// Bumped to rebuild the programme dropdown when a CTA pre-selects one.
  int _programVersion = 0;

  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  @override
  void initState() {
    super.initState();
    widget.selection.addListener(_onSelection);
  }

  @override
  void didUpdateWidget(InternshipApplicationForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selection != widget.selection) {
      oldWidget.selection.removeListener(_onSelection);
      widget.selection.addListener(_onSelection);
    }
  }

  void _onSelection() => setState(() => _programVersion++);

  @override
  void dispose() {
    widget.selection.removeListener(_onSelection);
    for (final c in [_name, _email, _mobile, _institution, _experience, _message]) {
      c.dispose();
    }
    super.dispose();
  }

  String? get _program {
    final slug = widget.selection.value;
    return InternshipContent.bySlug(slug ?? '')?.slug;
  }

  String? _trimmed(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _submit() async {
    final valid = _formKey.currentState!.validate();
    setState(() {
      _typeError = _type == null;
      _autovalidate = AutovalidateMode.onUserInteraction;
      _result = null;
    });
    if (!valid || _type == null) return;

    setState(() => _submitting = true);
    final application = InternshipApplication(
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      mobile: _mobile.text.trim(),
      institution: _institution.text.trim(),
      education: _education!,
      program: InternshipContent.bySlug(_program!)!.title,
      type: _type!,
      experience: _trimmed(_experience),
      message: _trimmed(_message),
    );
    SubmissionResult result;
    try {
      result = await widget.repository.submit(application);
    } catch (_) {
      result = const SubmissionResult(SubmissionStatus.failure);
    }
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _result = result;
    });
    if (result.status == SubmissionStatus.success) _reset();
  }

  /// Clears every field after a confirmed submission.
  void _reset() {
    _formKey.currentState!.reset();
    for (final c in [_name, _email, _mobile, _institution, _experience, _message]) {
      c.clear();
    }
    setState(() {
      _education = null;
      _type = null;
      _autovalidate = AutovalidateMode.disabled;
    });
    widget.selection.value = null;
  }

  @override
  Widget build(BuildContext context) {
    final twoColumn = context.screenWidth >= 760;
    Widget pair(Widget a, Widget b) => twoColumn
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: a),
              const SizedBox(width: 16),
              Expanded(child: b),
            ],
          )
        : Column(children: [a, const SizedBox(height: 16), b]);

    return Form(
      key: _formKey,
      autovalidateMode: _autovalidate,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              InternshipConfig.applicationsOpen ? 'Internship Application' : 'Register Your Interest',
              style: AppTypography.display(fontSize: 24, fontWeight: FontWeight.w700, color: context.tone.ink),
            ),
            const SizedBox(height: 6),
            Text('Fields marked * are required.', style: AppTypography.body(fontSize: 13.5, color: context.tone.muted)),
            if (!widget.repository.isConnected) ...[
              const SizedBox(height: 18),
              _StatusPanel(
                icon: Icons.cloud_off_rounded,
                color: context.tone.ink,
                title: 'Online applications are not connected yet',
                text:
                    'This form needs a backend integration before it can send applications. You can '
                    'check your details here, but submissions are not received or stored yet.',
              ),
            ],
            const SizedBox(height: 24),
            pair(
              _field(
                controller: _name,
                label: 'Full Name *',
                icon: Icons.person_outline_rounded,
                autofill: const [AutofillHints.name],
                validator: (v) => (v == null || v.trim().length < 2) ? 'Please enter your full name' : null,
              ),
              _field(
                controller: _email,
                label: 'Email Address *',
                icon: Icons.mail_outline_rounded,
                keyboard: TextInputType.emailAddress,
                autofill: const [AutofillHints.email],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter your email address';
                  if (!_emailPattern.hasMatch(v.trim())) return 'Please enter a valid email address';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            pair(
              _field(
                controller: _mobile,
                label: 'Mobile Number *',
                icon: Icons.phone_iphone_rounded,
                keyboard: TextInputType.phone,
                autofill: const [AutofillHints.telephoneNumber],
                formatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d+\-\s()]'))],
                validator: (v) {
                  final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                  if (digits.isEmpty) return 'Please enter your mobile number';
                  if (digits.length < 10 || digits.length > 15) return 'Please enter a valid mobile number';
                  return null;
                },
              ),
              _field(
                controller: _institution,
                label: 'College / Institution *',
                icon: Icons.account_balance_outlined,
                validator: (v) => (v == null || v.trim().length < 2) ? 'Please enter your college or institution' : null,
              ),
            ),
            const SizedBox(height: 16),
            pair(
              DropdownButtonFormField<String>(
                initialValue: _education,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Current Education *',
                  prefixIcon: Icon(Icons.school_outlined, size: 20),
                ),
                items: [
                  for (final e in InternshipContent.educationOptions)
                    DropdownMenuItem(
                      value: e,
                      child: Text(e, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (v) => setState(() => _education = v),
                validator: (v) => v == null ? 'Please select your current education' : null,
              ),
              DropdownButtonFormField<String>(
                key: ValueKey('program-$_programVersion'),
                initialValue: _program,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Preferred Internship Program *',
                  prefixIcon: Icon(Icons.category_outlined, size: 20),
                ),
                items: [
                  for (final p in InternshipContent.programs)
                    DropdownMenuItem(
                      value: p.slug,
                      child: Text(p.shortTitle, overflow: TextOverflow.ellipsis),
                    ),
                ],
                // Writing to the shared notifier keeps CTA pre-selection and
                // manual choice in sync.
                onChanged: (v) => widget.selection.value = v,
                validator: (v) => v == null ? 'Please choose a programme' : null,
              ),
            ),
            const SizedBox(height: 18),
            _TypeSelector(
              value: _type,
              error: _typeError,
              onChanged: (t) => setState(() {
                _type = t;
                _typeError = false;
              }),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _experience,
              minLines: 3,
              maxLines: 6,
              maxLength: 800,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'Skills or Previous Experience',
                alignLabelWithHint: true,
                hintText: 'Languages, tools, courses or projects you have worked on (optional).',
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _message,
              minLines: 3,
              maxLines: 6,
              maxLength: 1200,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'Message',
                alignLabelWithHint: true,
                hintText: 'Why this programme interests you, or any questions (optional).',
              ),
              validator: (v) {
                final text = v?.trim() ?? '';
                if (text.isNotEmpty && text.length < 10) return 'Please add a little more detail, or leave this empty';
                return null;
              },
            ),
            if (_result != null) ...[
              const SizedBox(height: 16),
              _ResultPanel(result: _result!, firstName: _name.text.trim().split(' ').first),
            ],
            const SizedBox(height: 20),
            PrimaryButton(
              label: InternshipConfig.applicationsOpen ? 'Submit Application' : 'Register Interest',
              icon: Icons.send_rounded,
              size: ButtonSize.large,
              expand: true,
              loading: _submitting,
              onPressed: _submitting ? null : _submit,
            ),
            const SizedBox(height: 14),
            const _InfoLine(
              icon: Icons.lock_outline_rounded,
              text:
                  'Privacy: your details are used only to respond about internship opportunities. They are '
                  'not shared with third parties or saved in your browser.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboard,
    List<String>? autofill,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      autofillHints: autofill,
      inputFormatters: formatters,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20)),
      validator: validator,
    );
  }
}

/// Free / Paid choice, with an inline error when left empty.
class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.value, required this.error, required this.onChanged});

  final InternshipType? value;
  final bool error;
  final ValueChanged<InternshipType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Internship Type',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Internship Type *',
            style: AppTypography.body(fontSize: 14, fontWeight: FontWeight.w600, color: context.tone.ink, height: 1.3),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final t in InternshipType.values)
                ChoiceChip(
                  label: Text('${t.label} Internship'),
                  selected: value == t,
                  onSelected: (_) => onChanged(t),
                  showCheckmark: true,
                  checkmarkColor: AppColors.cardAccent,
                  selectedColor: AppColors.cardTile,
                  backgroundColor: AppColors.cardField,
                  side: BorderSide(
                    color: value == t ? context.tone.accent : (error ? AppColors.errorOnCard : context.tone.border),
                  ),
                  labelStyle: AppTypography.body(fontSize: 14, fontWeight: FontWeight.w600, color: context.tone.ink, height: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
            ],
          ),
          if (error) ...[
            const SizedBox(height: 8),
            Text(
              'Please choose free or paid',
              style: AppTypography.body(fontSize: 12.5, color: AppColors.errorOnCard, height: 1.3),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Availability and terms depend on the specific opportunity and are confirmed with you first.',
            style: AppTypography.body(fontSize: 12.5, color: context.tone.muted, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.result, required this.firstName});

  final SubmissionResult result;
  final String firstName;

  @override
  Widget build(BuildContext context) {
    final email = ContactConfig.email;
    return switch (result.status) {
      SubmissionStatus.success => _StatusPanel(
        icon: Icons.check_circle_outline_rounded,
        color: AppColors.successOnCard,
        title: 'Thank you, $firstName!',
        text: 'Your registration has been received. We will contact you by email about suitable opportunities.',
      ),
      SubmissionStatus.backendNotConnected => _StatusPanel(
        icon: Icons.info_outline_rounded,
        color: context.tone.ink,
        title: 'Not sent: online applications are not connected yet',
        text:
            'Your details look complete, but this form cannot send them yet, so nothing was received or '
            'stored. You can email $email instead.',
        action: SecondaryButton(
          label: 'Email Us',
          icon: Icons.mail_outline_rounded,
          size: ButtonSize.small,
          onPressed: () => LinkService.email(email, subject: 'Internship interest'),
        ),
      ),
      SubmissionStatus.failure => _StatusPanel(
        icon: Icons.error_outline_rounded,
        color: AppColors.errorOnCard,
        title: 'Something went wrong',
        text: result.message ?? 'Your registration could not be sent. Your details are still in the form, so please try again.',
      ),
    };
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.icon, required this.color, required this.title, required this.text, this.action});

  final IconData icon;
  final Color color;
  final String title;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body(fontSize: 14.5, fontWeight: FontWeight.w700, color: context.tone.ink, height: 1.35),
                  ),
                  const SizedBox(height: 4),
                  Text(text, style: AppTypography.body(fontSize: 13.5, height: 1.55, color: context.tone.body)),
                  if (action != null) ...[const SizedBox(height: 12), action!],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 15, color: context.tone.muted),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: AppTypography.body(fontSize: 13, color: context.tone.muted, height: 1.45)),
        ),
      ],
    );
  }
}
