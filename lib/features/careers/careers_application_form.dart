import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/site_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/utils/responsive.dart';
import '../../models/contact_enquiry.dart' show SubmissionResult, SubmissionStatus;
import '../../models/job_application.dart';
import '../../repositories/careers_repository.dart';
import '../../repositories/content/careers_content.dart';
import '../../services/file_picker.dart' as files;
import '../../services/link_service.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/site_dialog.dart';

/// Opens the browser's file dialog for a résumé; null if cancelled.
typedef ResumePicker = Future<ResumeFile?> Function();

Future<ResumeFile?> _pickResume() async {
  final picked = await files.pickFile(extensions: ResumeFile.extensions);
  return picked == null ? null : ResumeFile(name: picked.name, bytes: picked.bytes);
}

/// Job and internship application form. [selection] holds the chosen
/// opening's id: each card's Apply button fills it in, and the form's own
/// position menu writes to it.
///
/// Applications go to the contact Worker's careers endpoint (see
/// [CareersRepository]), which emails HR with the résumé attached.
class CareersApplicationForm extends StatefulWidget {
  const CareersApplicationForm({
    super.key,
    required this.selection,
    this.repository = const ApiCareersRepository(),
    this.fixedPosition = false,
    this.pickResume = _pickResume,
    this.onSubmitted,
  });

  final ValueNotifier<String?> selection;
  final CareersRepository repository;

  /// Shows the selected position as a read-only field (the form was opened
  /// from that position's card) instead of a menu of every position.
  final bool fixedPosition;
  final ResumePicker pickResume;

  /// Called after a successful send, before the confirmation appears, e.g.
  /// to close the dialog holding the form.
  final VoidCallback? onSubmitted;

  @override
  State<CareersApplicationForm> createState() => _CareersApplicationFormState();
}

class _CareersApplicationFormState extends State<CareersApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _resumeKey = GlobalKey<FormFieldState<ResumeFile>>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _education = TextEditingController();
  final _skills = TextEditingController();
  final _note = TextEditingController();

  bool _submitting = false;
  bool _picking = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  /// Bumped to rebuild the position menu when a card pre-selects one.
  int _positionVersion = 0;

  /// Bumped to rebuild every field empty after a successful send.
  int _formVersion = 0;
  final _shownAt = DateTime.now();

  /// Sent with each attempt and kept until one succeeds, so a retry after a
  /// lost response cannot store the application twice.
  String _submissionId = _newSubmissionId();

  static String _newSubmissionId() {
    final random = Random.secure();
    String hex(int bytes) => List.generate(bytes, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    return '${hex(4)}-${hex(2)}-${hex(2)}-${hex(2)}-${hex(6)}';
  }

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
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  List<TextEditingController> get _controllers => [_name, _email, _mobile, _education, _skills, _note];

  JobOpening? get _position => CareersContent.byId(widget.selection.value ?? '');

  Future<void> _chooseResume(FormFieldState<ResumeFile> field) async {
    if (_picking) return;
    setState(() => _picking = true);
    final file = await widget.pickResume();
    if (!mounted) return;
    setState(() => _picking = false);
    if (file != null) field.didChange(file);
    field.validate();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final valid = _formKey.currentState!.validate();
    setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
    if (!valid) return;

    setState(() => _submitting = true);
    final position = _position!;
    final application = JobApplication(
      kind: position.kind,
      position: position.title,
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      mobile: _mobile.text.trim(),
      education: _education.text.trim(),
      skills: _skills.text.trim(),
      message: _note.text.trim(),
      resume: _resumeKey.currentState!.value!,
      submissionId: _submissionId,
      timeToComplete: DateTime.now().difference(_shownAt),
    );
    final result = await widget.repository.submit(application);
    if (!mounted) return;
    final sent = result.status == SubmissionStatus.success;
    setState(() {
      _submitting = false;
      if (sent) _clear();
    });
    if (sent) widget.onSubmitted?.call();
    _showResult(context, result, application);
  }

  void _clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _autovalidate = AutovalidateMode.disabled;
    _formVersion++;
    _submissionId = _newSubmissionId();
    if (!widget.fixedPosition) widget.selection.value = null;
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

    final position = _position;
    return Form(
      key: _formKey,
      autovalidateMode: _autovalidate,
      child: AutofillGroup(
        key: ValueKey('form-$_formVersion'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              position?.kind.applicationLabel ?? 'Job & Internship Application',
              style: AppTypography.display(fontSize: 24, fontWeight: FontWeight.w700, color: context.tone.ink),
            ),
            const SizedBox(height: 6),
            Text('Fields marked * are required.', style: AppTypography.body(fontSize: 13.5, color: context.tone.muted)),
            const SizedBox(height: 24),
            _positionField(),
            const SizedBox(height: 16),
            pair(
              _field(
                controller: _name,
                label: 'Full Name *',
                icon: Icons.person_outline_rounded,
                autofill: const [AutofillHints.name],
                validator: (v) {
                  final text = v?.trim() ?? '';
                  if (text.isEmpty) return 'Please enter your full name';
                  if (text.length < 2 || text.length > 100) return 'Please enter your full name (2–100 characters)';
                  return null;
                },
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
                controller: _education,
                label: 'Education *',
                hint: 'e.g. B.E. Computer Engineering, 2025',
                icon: Icons.school_outlined,
                validator: (v) {
                  final text = v?.trim() ?? '';
                  if (text.isEmpty) return 'Please enter your education';
                  if (text.length < 2 || text.length > 200) return 'Please keep this to 200 characters';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _skills,
              minLines: 2,
              maxLines: 4,
              maxLength: 500,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'Relevant Skills *',
                alignLabelWithHint: true,
                hintText: 'e.g. Flutter, Dart, Firebase, REST APIs, Figma',
                prefixIcon: Icon(Icons.auto_awesome_outlined, size: 20),
              ),
              validator: (v) {
                final text = v?.trim() ?? '';
                if (text.isEmpty) return 'Please list your relevant skills';
                if (text.length < 2) return 'Please list your relevant skills';
                return null;
              },
            ),
            const SizedBox(height: 8),
            FormField<ResumeFile>(
              key: _resumeKey,
              validator: (file) => file == null ? 'Please upload your résumé' : file.problem,
              builder: (field) => _ResumeTile(
                file: field.value,
                error: field.errorText,
                busy: _picking,
                onChoose: () => _chooseResume(field),
                onRemove: () {
                  field.didChange(null);
                  if (_autovalidate != AutovalidateMode.disabled) field.validate();
                },
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _note,
              minLines: 3,
              maxLines: 6,
              maxLength: 1500,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'Additional Message',
                alignLabelWithHint: true,
                hintText: 'Anything else you would like us to know: recent projects, links or availability.',
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: position?.isInternship ?? false ? 'Submit Internship Application' : 'Submit Application',
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
                    'Your details and résumé are sent only to our hiring team and used only to assess '
                    'your application.',
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

  /// The position: filled in and read-only when opened from a card,
  /// otherwise a menu of every job and internship.
  Widget _positionField() {
    final position = _position;
    if (widget.fixedPosition && position != null) {
      return TextFormField(
        key: ValueKey('fixed-${position.id}'),
        initialValue: position.title,
        readOnly: true,
        enableInteractiveSelection: false,
        decoration: InputDecoration(
          labelText: 'Position Applied For',
          prefixIcon: Icon(position.isInternship ? Icons.school_outlined : Icons.work_outline_rounded, size: 20),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              widthFactor: 1,
              child: Text(
                position.isInternship ? 'Internship' : 'Job',
                style: AppTypography.body(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent),
              ),
            ),
          ),
        ),
      );
    }
    DropdownMenuItem<String> item(JobOpening o) => DropdownMenuItem(
      value: o.id,
      child: Text(o.title, overflow: TextOverflow.ellipsis),
    );
    DropdownMenuItem<String> heading(String text) => DropdownMenuItem(
      enabled: false,
      child: Text(
        text.toUpperCase(),
        style: AppTypography.body(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.accent),
      ),
    );
    return DropdownButtonFormField<String>(
      key: ValueKey('position-$_positionVersion'),
      initialValue: position?.id,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Position Applied For *', prefixIcon: Icon(Icons.work_outline_rounded, size: 20)),
      items: [
        heading('Job Openings'),
        for (final o in CareersContent.openings) item(o),
        heading('Internship Opportunities'),
        for (final o in CareersContent.internships) item(o),
      ],
      // Writing to the shared notifier keeps card pre-selection and manual
      // choice in sync.
      onChanged: (v) => widget.selection.value = v,
      validator: (v) => v == null ? 'Please choose a position' : null,
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
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
      decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon, size: 20)),
      validator: validator,
    );
  }
}

/// The résumé upload: a dashed drop-zone style tile with a button, or the
/// chosen file's name and size with a remove button.
class _ResumeTile extends StatelessWidget {
  const _ResumeTile({required this.file, required this.error, required this.busy, required this.onChoose, required this.onRemove});

  final ResumeFile? file;
  final String? error;
  final bool busy;
  final VoidCallback onChoose;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final f = file;
    final hasError = error != null;
    final border = hasError ? AppColors.errorOnCard : (f != null ? AppColors.champagneGold : AppColors.cardBorder);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          decoration: BoxDecoration(
            color: f != null ? AppColors.goldWash : AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: border, width: hasError || f != null ? 1.4 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: f != null ? AppColors.white : AppColors.goldWash,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.goldLine),
                ),
                child: Icon(f != null ? Icons.description_outlined : Icons.upload_file_rounded, size: 20, color: AppColors.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f?.name ?? 'Résumé *',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.ink, height: 1.3),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      f != null ? '${f.extension.toUpperCase()} · ${f.sizeLabel}' : 'PDF, DOC or DOCX, up to 5 MB',
                      style: AppTypography.body(fontSize: 12.5, color: AppColors.muted, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (f != null)
                IconButton(
                  tooltip: 'Remove résumé',
                  onPressed: onRemove,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: AppColors.slate,
                )
              else
                SecondaryButton(
                  label: busy ? 'Opening…' : 'Upload',
                  icon: Icons.attach_file_rounded,
                  size: ButtonSize.small,
                  onPressed: busy ? null : onChoose,
                ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
            child: Text(error!, style: AppTypography.body(fontSize: 12, color: AppColors.errorOnCard, height: 1.3)),
          ),
      ],
    );
  }
}

void _showResult(BuildContext context, SubmissionResult result, JobApplication application) {
  final firstName = application.fullName.split(' ').first;
  final position = application.position;
  final noun = application.kind == OpeningKind.internship ? 'internship application' : 'application';
  final (icon, color, title, message) = switch (result.status) {
    SubmissionStatus.success => (
      Icons.check_circle_outline_rounded,
      AppColors.successOnCard,
      'Application Submitted',
      'Thank you, $firstName! Your $noun for $position has been received. Our hiring team will '
          'review it and contact you by email.'
          '${result.confirmationSent ? ' A confirmation has been sent to ${application.email}.' : ''}',
    ),
    SubmissionStatus.backendNotConnected => (
      Icons.mark_email_read_outlined,
      AppColors.cardAccent,
      'Thank you, $firstName!',
      'Your details look complete, but online applications are not connected yet, so this '
          '$noun has not been sent. Please email your résumé to ${ContactConfig.email}.',
    ),
    SubmissionStatus.failure => (
      Icons.error_outline_rounded,
      AppColors.errorOnCard,
      'Application Not Sent',
      '${result.message ?? 'Unable to submit your $noun right now. Please try again.'} You can also email '
          'your résumé to ${ContactConfig.email}.',
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
            onPressed: () => LinkService.email(ContactConfig.email, subject: '${application.kind.applicationLabel}: $position'),
          ),
        PrimaryButton(label: 'Done', size: ButtonSize.small, icon: null, onPressed: () => Navigator.of(dialogContext).pop()),
      ],
    ),
  );
}
