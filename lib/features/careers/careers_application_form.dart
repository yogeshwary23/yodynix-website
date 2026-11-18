import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/site_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/utils/responsive.dart';
import '../../models/contact_enquiry.dart';
import '../../repositories/contact_repository.dart';
import '../../repositories/content/careers_content.dart';
import '../../services/link_service.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/site_dialog.dart';

/// Job application form. [selection] holds the chosen opening's id so each
/// job card's "Apply Now" can pre-select it.
///
/// Applications travel through the same enquiry backend as the contact form
/// (see [ContactRepository]), so they reach the hiring inbox by email.
class CareersApplicationForm extends StatefulWidget {
  const CareersApplicationForm({super.key, required this.selection, this.repository = const ApiContactRepository()});

  final ValueNotifier<String?> selection;
  final ContactRepository repository;

  @override
  State<CareersApplicationForm> createState() => _CareersApplicationFormState();
}

class _CareersApplicationFormState extends State<CareersApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _link = TextEditingController();
  final _note = TextEditingController();

  String? _experience;
  bool _submitting = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  /// Bumped to rebuild the position dropdown when a card pre-selects one.
  int _positionVersion = 0;

  /// Bumped to rebuild every field empty after a successful send.
  int _formVersion = 0;
  final _shownAt = DateTime.now();

  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  @override
  void initState() {
    super.initState();
    widget.selection.addListener(_onSelection);
  }

  @override
  void didUpdateWidget(CareersApplicationForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selection != widget.selection) {
      oldWidget.selection.removeListener(_onSelection);
      widget.selection.addListener(_onSelection);
    }
  }

  void _onSelection() => setState(() => _positionVersion++);

  @override
  void dispose() {
    widget.selection.removeListener(_onSelection);
    for (final c in [_name, _email, _mobile, _link, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  JobOpening? get _position => CareersContent.byId(widget.selection.value ?? '');

  Future<void> _submit() async {
    if (_submitting) return;
    final valid = _formKey.currentState!.validate();
    setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
    if (!valid) return;

    setState(() => _submitting = true);
    final position = _position!;
    final link = _link.text.trim();
    final application = ContactEnquiry(
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      mobile: _mobile.text.trim(),
      service: 'Careers Application: ${position.title}',
      description: [
        'Position: ${position.title}',
        'Experience: $_experience',
        if (link.isNotEmpty) 'Résumé / Portfolio: $link',
        '',
        _note.text.trim(),
      ].join('\n'),
      preferredContactMethod: 'Email',
      timeToComplete: DateTime.now().difference(_shownAt),
    );
    final result = await widget.repository.submit(application);
    if (!mounted) return;
    setState(() {
      _submitting = false;
      if (result.status == SubmissionStatus.success) _clear();
    });
    _showResult(result, application.fullName, position.title);
  }

  void _clear() {
    for (final c in [_name, _email, _mobile, _link, _note]) {
      c.clear();
    }
    _experience = null;
    _autovalidate = AutovalidateMode.disabled;
    _formVersion++;
    widget.selection.value = null;
  }

  void _showResult(SubmissionResult result, String fullName, String position) {
    final firstName = fullName.split(' ').first;
    final (icon, color, title, message) = switch (result.status) {
      SubmissionStatus.success => (
        Icons.check_circle_outline_rounded,
        AppColors.successOnCard,
        'Application Submitted',
        'Thank you, $firstName! Your application for $position has been received. Our hiring '
            'team will review it and contact you by email.',
      ),
      SubmissionStatus.backendNotConnected => (
        Icons.mark_email_read_outlined,
        AppColors.cardAccent,
        'Thank you, $firstName!',
        'Your details look complete, but online applications are not connected yet, so this '
            'application has not been sent. Please email your résumé to ${ContactConfig.email}.',
      ),
      SubmissionStatus.failure => (
        Icons.error_outline_rounded,
        AppColors.errorOnCard,
        'Application Not Sent',
        'Unable to submit your application right now. Please try again or email your résumé to '
            '${ContactConfig.email}.',
      ),
    };
    final sent = result.status == SubmissionStatus.success;
    showSiteDialog(
      context,
      maxWidth: 500,
      builder: (dialogContext) => SiteDialogBody(
        icon: icon,
        color: color,
        title: title,
        description: message,
        actions: [
          if (!sent)
            SecondaryButton(
              label: 'Email Us',
              icon: Icons.mail_outline_rounded,
              size: ButtonSize.small,
              onPressed: () => LinkService.email(ContactConfig.email, subject: 'Job application: $position'),
            ),
          PrimaryButton(label: 'Done', size: ButtonSize.small, icon: null, onPressed: () => Navigator.of(dialogContext).pop()),
        ],
      ),
    );
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
        key: ValueKey('form-$_formVersion'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Job Application',
              style: AppTypography.display(fontSize: 24, fontWeight: FontWeight.w700, color: context.tone.ink),
            ),
            const SizedBox(height: 6),
            Text('Fields marked * are required.', style: AppTypography.body(fontSize: 13.5, color: context.tone.muted)),
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
              DropdownButtonFormField<String>(
                key: ValueKey('position-$_positionVersion'),
                initialValue: _position?.id,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Position Applying For *',
                  prefixIcon: Icon(Icons.work_outline_rounded, size: 20),
                ),
                items: [
                  for (final o in CareersContent.openings)
                    DropdownMenuItem(
                      value: o.id,
                      child: Text(o.title, overflow: TextOverflow.ellipsis),
                    ),
                ],
                // Writing to the shared notifier keeps card pre-selection and
                // manual choice in sync.
                onChanged: (v) => widget.selection.value = v,
                validator: (v) => v == null ? 'Please choose a position' : null,
              ),
            ),
            const SizedBox(height: 16),
            pair(
              DropdownButtonFormField<String>(
                initialValue: _experience,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Professional Experience *',
                  prefixIcon: Icon(Icons.timeline_rounded, size: 20),
                ),
                items: [
                  for (final e in CareersContent.experienceOptions)
                    DropdownMenuItem(
                      value: e,
                      child: Text(e, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (v) => setState(() => _experience = v),
                validator: (v) => v == null ? 'Please select your experience' : null,
              ),
              _field(
                controller: _link,
                label: 'Résumé / Portfolio Link',
                icon: Icons.link_rounded,
                keyboard: TextInputType.url,
                autofill: const [AutofillHints.url],
                validator: (v) {
                  final text = v?.trim() ?? '';
                  if (text.isEmpty) return null;
                  final uri = Uri.tryParse(text.contains('://') ? text : 'https://$text');
                  if (text.length > 200 || uri == null || !uri.host.contains('.')) return 'Please enter a valid link';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _note,
              minLines: 4,
              maxLines: 8,
              maxLength: 1100,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'About You *',
                alignLabelWithHint: true,
                hintText: 'Your key skills, recent projects and why this role interests you.',
              ),
              validator: (v) {
                final text = v?.trim() ?? '';
                if (text.isEmpty) return 'Please tell us a little about yourself';
                if (text.length < 20) return 'Please add a little more detail (at least 20 characters)';
                return null;
              },
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Submit Application',
              icon: Icons.send_rounded,
              size: ButtonSize.large,
              expand: true,
              loading: _submitting,
              onPressed: _submit,
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(Icons.lock_outline_rounded, size: 15, color: context.tone.muted),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your details are used only to assess your application. You can also email your '
                    'résumé to ${ContactConfig.email}.',
                    style: AppTypography.body(fontSize: 13, color: context.tone.muted, height: 1.45),
                  ),
                ),
              ],
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
