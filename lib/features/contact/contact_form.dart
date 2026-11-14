import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/site_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../models/contact_enquiry.dart';
import '../../providers/section_navigator.dart';
import '../../repositories/contact_repository.dart';
import '../../repositories/content/services_content.dart';
import '../../services/link_service.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/site_dialog.dart';

/// Project enquiry form: validation and submission flow are complete; the
/// injected [ContactRepository] decides where the data goes.
class ContactForm extends StatefulWidget {
  const ContactForm({super.key, required this.repository});

  final ContactRepository repository;

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _business = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _description = TextEditingController();

  String? _service;
  String? _budget;
  String? _contactMethod;
  bool _contactMethodError = false;
  bool _submitting = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  /// Bumped to rebuild the service dropdown when a CTA pre-selects a service.
  int _serviceFieldVersion = 0;

  /// Bumped to rebuild every field empty after a successful send.
  int _formVersion = 0;
  final _shownAt = DateTime.now();
  ValueNotifier<String?>? _prefill;

  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final prefill = SectionNavigatorScope.read(context).contactPrefill;
    if (prefill != _prefill) {
      _prefill?.removeListener(_applyPrefill);
      _prefill = prefill..addListener(_applyPrefill);
      _readPrefill();
    }
  }

  /// Returns true when a valid prefilled service was applied.
  bool _readPrefill() {
    final value = _prefill?.value;
    if (value == null || !ServicesContent.enquiryOptions.contains(value)) return false;
    _service = value;
    _serviceFieldVersion++;
    return true;
  }

  void _applyPrefill() {
    if (_readPrefill()) setState(() {});
  }

  @override
  void dispose() {
    _prefill?.removeListener(_applyPrefill);
    for (final c in [_name, _business, _email, _mobile, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final valid = _formKey.currentState!.validate();
    setState(() {
      _contactMethodError = _contactMethod == null;
      _autovalidate = AutovalidateMode.onUserInteraction;
    });
    if (!valid || _contactMethod == null) return;

    setState(() => _submitting = true);
    final enquiry = ContactEnquiry(
      fullName: _name.text.trim(),
      businessName: _business.text.trim().isEmpty ? null : _business.text.trim(),
      email: _email.text.trim(),
      mobile: _mobile.text.trim(),
      service: _service!,
      budget: _budget,
      description: _description.text.trim(),
      preferredContactMethod: _contactMethod!,
      timeToComplete: DateTime.now().difference(_shownAt),
    );
    final result = await widget.repository.submit(enquiry);
    if (!mounted) return;
    setState(() {
      _submitting = false;
      if (result.status == SubmissionStatus.success) _clear();
    });
    _showResult(result, enquiry);
  }

  void _clear() {
    for (final c in [_name, _business, _email, _mobile, _description]) {
      c.clear();
    }
    _service = null;
    _budget = null;
    _contactMethod = null;
    _contactMethodError = false;
    _autovalidate = AutovalidateMode.disabled;
    _formVersion++;
  }

  void _showResult(SubmissionResult result, ContactEnquiry enquiry) {
    final firstName = enquiry.fullName.split(' ').first;
    final (icon, color, title, message) = switch (result.status) {
      SubmissionStatus.success => (
        Icons.check_circle_outline_rounded,
        AppColors.success,
        'Enquiry Submitted',
        'Thank you! Your enquiry has been submitted successfully. Our team will contact you soon.',
      ),
      SubmissionStatus.backendNotConnected => (
        Icons.mark_email_read_outlined,
        AppColors.primary,
        'Thank you, $firstName!',
        'Your details look complete. Online enquiries are being connected and will be '
            'live shortly, so this message has not been sent yet. Thank you for your patience.',
      ),
      SubmissionStatus.failure => (
        Icons.error_outline_rounded,
        AppColors.error,
        'Enquiry Not Sent',
        'Unable to submit your enquiry right now. Please try again or contact us by email.',
      ),
    };
    final failed = result.status == SubmissionStatus.failure;
    showSiteDialog(
      context,
      maxWidth: 500,
      builder: (dialogContext) => SiteDialogBody(
        icon: icon,
        color: color,
        title: title,
        description: message,
        actions: [
          if (failed)
            SecondaryButton(
              label: 'Email Us',
              icon: Icons.mail_outline_rounded,
              size: ButtonSize.small,
              onPressed: () => LinkService.email(ContactConfig.email, subject: 'Project enquiry'),
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
            Text('Project Enquiry', style: AppTypography.display(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Fields marked * are required.', style: AppTypography.body(fontSize: 13.5, color: AppColors.muted)),
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
                controller: _business,
                label: 'Business Name',
                icon: Icons.business_outlined,
                autofill: const [AutofillHints.organizationName],
              ),
            ),
            const SizedBox(height: 16),
            pair(
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
                  if (digits.length < 7 || digits.length > 15) return 'Please enter a valid mobile number';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            pair(
              DropdownButtonFormField<String>(
                key: ValueKey('service-$_serviceFieldVersion'),
                initialValue: _service,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Service Required *',
                  prefixIcon: Icon(Icons.design_services_outlined, size: 20),
                ),
                items: [
                  for (final option in ServicesContent.enquiryOptions)
                    DropdownMenuItem(
                      value: option,
                      child: Text(option, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (v) => setState(() => _service = v),
                validator: (v) => v == null ? 'Please choose a service' : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: _budget,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Project Budget',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined, size: 20),
                ),
                items: [
                  for (final option in ContactConfig.budgetOptions)
                    DropdownMenuItem(
                      value: option,
                      child: Text(option, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (v) => setState(() => _budget = v),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              minLines: 5,
              maxLines: 8,
              maxLength: 1500,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'Project Description *',
                alignLabelWithHint: true,
                hintText: 'Tell us about your goals, audience, timeline and any references you like.',
              ),
              validator: (v) {
                final text = v?.trim() ?? '';
                if (text.isEmpty) return 'Please describe your project';
                if (text.length < 20) return 'Please add a little more detail (at least 20 characters)';
                return null;
              },
            ),
            const SizedBox(height: 14),
            Text(
              'Preferred Contact Method *',
              style: AppTypography.body(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final method in ContactConfig.preferredContactMethods)
                  ChoiceChip(
                    label: Text(method),
                    avatar: Icon(
                      switch (method) {
                        'Email' => Icons.mail_outline_rounded,
                        'WhatsApp' => Icons.chat_outlined,
                        _ => Icons.call_outlined,
                      },
                      size: 17,
                      color: _contactMethod == method ? AppColors.primary : AppColors.muted,
                    ),
                    showCheckmark: false,
                    selected: _contactMethod == method,
                    onSelected: (_) => setState(() {
                      _contactMethod = method;
                      _contactMethodError = false;
                    }),
                    side: BorderSide(
                      color: _contactMethod == method
                          ? AppColors.primary
                          : (_contactMethodError ? AppColors.error : AppColors.border),
                    ),
                  ),
              ],
            ),
            if (_contactMethodError) ...[
              const SizedBox(height: 8),
              Text(
                'Please choose how you would like us to contact you',
                style: AppTypography.body(fontSize: 13, color: AppColors.error),
              ),
            ],
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Send Enquiry',
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
                const Icon(Icons.lock_outline_rounded, size: 15, color: AppColors.muted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your details are used only to respond to your enquiry.',
                    style: AppTypography.body(fontSize: 13, color: AppColors.muted, height: 1.4),
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
