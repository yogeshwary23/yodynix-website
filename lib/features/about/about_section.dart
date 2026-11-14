import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/about_page.dart';
import '../../repositories/content/company_content.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';
import 'about_page_view.dart';

/// Homepage About overview: a short introduction and a card for each of the
/// four About pages, which hold the full content.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionShell(
      background: AppColors.surface,
      glowAt: const Alignment(1.1, -0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            eyebrow: 'About YODYNIX',
            title: CompanyContent.aboutHeading,
            lead: CompanyContent.whoWeAreLead,
            centered: true,
          ),
          const SizedBox(height: 56),
          ResponsiveGrid(
            minItemWidth: 250,
            maxColumns: 4,
            spacing: 20,
            children: [
              for (final (i, page) in AboutPage.values.indexed)
                Reveal(
                  delay: Duration(milliseconds: 70 * i),
                  child: AboutPageCard(page: page),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
