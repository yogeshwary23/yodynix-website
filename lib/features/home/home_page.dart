import 'package:flutter/material.dart';

import '../../core/constants/site_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/site_section.dart';
import '../../providers/section_navigator.dart';
import '../../shared/layouts/site_footer.dart';
import '../../shared/layouts/site_header.dart';
import '../../shared/layouts/site_navbar.dart';
import '../about/about_section.dart';
import '../contact/contact_section.dart';
import '../expertise/expertise_section.dart';
import '../internship/internship_section.dart';
import '../services/services_section.dart';
import 'final_cta_section.dart';
import 'hero_section.dart';
import 'intro_section.dart';
import 'why_choose_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  /// Browser tab title; restored by the app's navigator observer whenever
  /// navigation returns to the homepage.
  static const String documentTitle = '${SiteConfig.brandName} | ${SiteConfig.brandCategory}';

  static const Map<SiteSection, Widget> _sections = {
    SiteSection.home: HeroSection(),
    SiteSection.intro: IntroSection(),
    SiteSection.about: AboutSection(),
    SiteSection.services: ServicesSection(),
    SiteSection.expertise: ExpertiseSection(),
    SiteSection.internship: InternshipSection(),
    SiteSection.whyChoose: WhyChooseSection(),
    SiteSection.finalCta: FinalCtaSection(),
    SiteSection.contact: ContactSection(),
  };

  @override
  Widget build(BuildContext context) {
    final nav = SectionNavigatorScope.read(context);
    return Title(
      title: documentTitle,
      color: AppColors.primary,
      child: Scaffold(
        endDrawer: context.useCompactNav ? const MobileNavDrawer() : null,
        body: SiteHeaderFrame(
          child: SingleChildScrollView(
            controller: nav.scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final section in SiteSection.values) KeyedSubtree(key: nav.keyFor(section), child: _sections[section]!),
                const SiteFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
