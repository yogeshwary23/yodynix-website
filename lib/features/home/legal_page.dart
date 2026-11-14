import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/site_section.dart';
import '../../shared/layouts/navigation_actions.dart';
import '../../shared/layouts/subpage_scaffold.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/section_widgets.dart';

/// Placeholder for Privacy Policy and Terms pages until the approved legal
/// text is supplied. States plainly that the document is being prepared.
class LegalPage extends StatelessWidget {
  const LegalPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SubpageScaffold(
      title: title,
      child: SectionShell(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('Legal'),
              const SizedBox(height: 18),
              Semantics(header: true, child: Text(title, style: AppTypography.display(fontSize: 40))),
              const SizedBox(height: 18),
              Text(
                'Our $title is being prepared and will be published on this page. '
                'If you have any questions in the meantime, please get in touch through the '
                'enquiry form.',
                style: AppTypography.body(fontSize: 17),
              ),
              const SizedBox(height: 12),
              Text(
                'This page will be updated before any personal data is collected through the website.',
                style: AppTypography.body(fontSize: 15, color: AppColors.muted),
              ),
              const SizedBox(height: 32),
              PrimaryButton(label: 'Contact Us', onPressed: () => goToSection(context, SiteSection.contact)),
            ],
          ),
        ),
      ),
    );
  }
}
