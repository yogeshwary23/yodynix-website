import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/site_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../models/contact_enquiry.dart' show SubmissionResult, SubmissionStatus;
import '../../models/pillar_page.dart';
import '../../models/program_enquiry.dart';
import '../../repositories/program_enquiry_repository.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/site_dialog.dart';

/// Enquiry / application form for a pillar page. [selection] lets the page's
/// CTAs pre-select an option before scrolling here.
class PillarEnquiryForm extends StatefulWidget {
  const PillarEnquiryForm({
    super.key,
    required this.config,
    required this.options,
    required this.selection,
    this.repository = const PendingBackendProgramEnquiryRepository(),
    this.notice,
  });

  final PillarFormConfig config;
  final List<String> options;
  final ValueNotifier<String?> selection;
  final ProgramEnquiryRepository repository;

  /// Optional line shown above the submit button.
  final String? notice;

  @override
  State<PillarEnquiryForm> createState() => _PillarEnquiryFormState();
}

class _PillarEnquiryFormState extends State<PillarEnquiryForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _extra = TextEditingController();
  final _message = TextEditingController();

  bool _submitting = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  /// Bumped to rebuild the dropdown when a CTA pre-selects an option.
  int _optionVersion = 0;

  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  @override
  void initState() {
    super.initState();
    widget.selection.addListener(_onSelection);
  }

  @override
  void didUpdateWidget(PillarEnquiryForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selection != widget.selection) {
      oldWidget.selection.removeListener(_onSelection);
      widget.selection.addListener(_onSelection);
    }
  }

  void _onSelection() => setState(() => _optionVersion++);

  @override
  void dispose() {
    widget.selection.removeListener(_onSelection);
    for (final c in [_name, _email, _phone, _extra, _message]) {
      c.dispose();
    }
    super.dispose();
  }

  String? get _option {
    final value = widget.selection.value;
    return widget.options.contains(value) ? value : null;
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState!.validate();
    setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
    if (!valid) return;

    setState(() => _submitting = true);
    final config = widget.config;
    final extra = _extra.text.trim();
    final enquiry = ProgramEnquiry(
      kind: config.kind,
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      option: _option!,
      extraField: config.extraFieldLabel.replaceAll('*', '').trim(),
      extraValue: extra.isEmpty ? null : extra,
      message: _message.text.trim(),
    );
    final result = await widget.repository.submit(enquiry);
    if (!mounted) return;
    setState(() => _submitting = false);
    _showResult(result, enquiry);
  }

  void _showResult(SubmissionResult result, ProgramEnquiry enquiry) {
    final firstName = enquiry.fullName.split(' ').first;
    final noun = widget.config.title.toLowerCase();
    final (icon, color, title, message) = switch (result.status) {
      SubmissionStatus.success => (
        Icons.check_circle_outline_rounded,
        AppColors.successOnCard,
        'Thank you, $firstName!',
        'Your $noun has been received. We will reply by email soon.',
      ),
      SubmissionStatus.backendNotConnected => (
        Icons.mark_email_read_outlined,
        AppColors.cardAccent,
        'Thank you, $firstName!',
        'Your details look complete. Online submissions are being connected and will be '
            'live shortly, so this $noun has not been sent yet. Thank you for your patience.',
      ),
      SubmissionStatus.failure => (
        Icons.error_outline_rounded,
        AppColors.errorOnCard,
        'Something went wrong',
        result.message ?? 'Your $noun could not be sent. Please try again in a moment.',
      ),
    };
    showSiteDialog(
      context,
      maxWidth: 500,
      builder: (dialogContext) => SiteDialogBody(
        icon: icon,
        color: color,
        title: title,
        description: message,
        actions: [
          PrimaryButton(label: 'Done', size: ButtonSize.small, icon: null, onPressed: () => Navigator.of(dialogContext).pop()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
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
              config.title,
              style: AppTypography.display(fontSize: 24, fontWeight: FontWeight.w700, color: context.tone.ink),
            ),
            const SizedBox(height: 6),
            Text('Fields marked * are required.', style: AppTypography.body(fontSize: 13.5, color: context.tone.muted)),
            const SizedBox(height: 26),
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
                label: 'Email *',
                icon: Icons.mail_outline_rounded,
                keyboard: TextInputType.emailAddress,
                autofill: const [AutofillHints.email],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter your email';
                  if (!_emailPattern.hasMatch(v.trim())) return 'Please enter a valid email address';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            pair(
              _field(
                controller: _phone,
                label: 'Phone *',
                icon: Icons.phone_iphone_rounded,
                keyboard: TextInputType.phone,
                autofill: const [AutofillHints.telephoneNumber],
                formatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d+\-\s()]'))],
                validator: (v) {
                  final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                  if (digits.isEmpty) return 'Please enter your phone number';
                  if (digits.length < 7 || digits.length > 15) return 'Please enter a valid phone number';
                  return null;
                },
              ),
              _field(
                controller: _extra,
                label: config.extraFieldLabel,
                hint: config.extraFieldHint,
                icon: config.extraFieldIcon,
                validator: config.extraFieldRequired
                    ? (v) => (v == null || v.trim().length < 2)
                          ? 'Please enter your ${config.extraFieldLabel.replaceAll('*', '').trim().toLowerCase()}'
                          : null
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey('option-$_optionVersion'),
              initialValue: _option,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: config.optionLabel,
                prefixIcon: const Icon(Icons.category_outlined, size: 20),
              ),
              items: [
                for (final option in widget.options)
                  DropdownMenuItem(
                    value: option,
                    child: Text(option, overflow: TextOverflow.ellipsis),
                  ),
              ],
              // Writing to the shared notifier keeps CTA pre-selection and
              // manual choice in sync; the listener bump is harmless here.
              onChanged: (v) => widget.selection.value = v,
              validator: (v) => v == null ? 'Please choose an option' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _message,
              minLines: 5,
              maxLines: 8,
              maxLength: 1500,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(labelText: config.messageLabel, alignLabelWithHint: true, hintText: config.messageHint),
              validator: (v) {
                final text = v?.trim() ?? '';
                if (!config.messageRequired) return null;
                if (text.isEmpty) return 'Please add a short message';
                if (text.length < 20) return 'Please add a little more detail (at least 20 characters)';
                return null;
              },
            ),
            if (widget.notice != null) ...[
              const SizedBox(height: 8),
              _InfoLine(icon: Icons.info_outline_rounded, text: widget.notice!),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              label: config.submitLabel,
              icon: Icons.send_rounded,
              size: ButtonSize.large,
              expand: true,
              loading: _submitting,
              onPressed: _submit,
            ),
            const SizedBox(height: 14),
            _InfoLine(
              icon: Icons.lock_outline_rounded,
              text: 'Your details are used only to respond to you. You can also write to ${ContactConfig.email}.',
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
          child: Text(text, style: AppTypography.body(fontSize: 13, color: context.tone.muted, height: 1.4)),
        ),
      ],
    );
  }
}
