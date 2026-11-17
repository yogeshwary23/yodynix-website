import 'package:flutter/material.dart';

/// One sector on the Industries page.
class IndustryProfile {
  const IndustryProfile({
    required this.id,
    required this.name,
    required this.icon,
    required this.summary,
    required this.solutions,
    required this.serviceIds,
    required this.sceneLabel,
  });

  /// Also the `industries` scene variant and its still render name.
  final String id;
  final String name;
  final IconData icon;
  final String summary;
  final List<String> solutions;

  /// Services most relevant to the sector, by `ServiceOffering.id`.
  final List<String> serviceIds;
  final String sceneLabel;
}

/// Copy for the Industries page.
///
/// PLACEHOLDER: the summaries and solution lists below are starting points
/// written for layout, not statements about work YODYNIX has delivered.
/// Replace them with your own copy before launch; the page shows a visible
/// "placeholder" marker while [isPlaceholder] is true.
class IndustriesContent {
  IndustriesContent._();

  /// Set to false once the copy below has been replaced.
  static const bool isPlaceholder = true;

  static const String heading = 'Technology Shaped Around Your Industry.';
  static const String lead =
      '[Placeholder] A short introduction to how YODYNIX approaches each sector. '
      'Replace with your own description of the industries you serve.';

  static const List<IndustryProfile> industries = [
    IndustryProfile(
      id: 'finance',
      name: 'Finance & Professional Services',
      icon: Icons.account_balance_outlined,
      summary:
          '[Placeholder] Describe the digital needs of finance and professional-services firms, '
          'and how your team would approach them.',
      solutions: ['Client portals', 'Secure enquiry and onboarding forms', 'Reporting dashboards'],
      serviceIds: ['custom_software_development', 'website_development', 'business_automation'],
      sceneLabel: 'Stacks of gold coins beside rising glass bars and a floating chrome ring.',
    ),
    IndustryProfile(
      id: 'healthcare',
      name: 'Healthcare & Clinics',
      icon: Icons.local_hospital_outlined,
      summary:
          '[Placeholder] Describe how clinics and practices could use websites, booking and '
          'patient communication tools.',
      solutions: ['Clinic websites', 'Appointment booking', 'Patient enquiry assistants'],
      serviceIds: ['website_development', 'mobile_app_development', 'ai_solutions_chatbots'],
      sceneLabel: 'A glass capsule filled with liquid gold beside a polished platinum cross.',
    ),
    IndustryProfile(
      id: 'retail',
      name: 'Retail & E-commerce',
      icon: Icons.shopping_bag_outlined,
      summary: '[Placeholder] Describe the online-store, catalogue and marketing needs of retail brands.',
      solutions: ['Online stores', 'Product catalogues', 'Campaign planning'],
      serviceIds: ['ecommerce_development', 'digital_marketing', 'branding_digital_presence'],
      sceneLabel: 'A champagne-gold shopping bag with platinum handles beside a glass gift box tied in gold.',
    ),
    IndustryProfile(
      id: 'education',
      name: 'Education & Training',
      icon: Icons.school_outlined,
      summary:
          '[Placeholder] Describe how institutes and trainers could use class booking, learning '
          'portals and student communication.',
      solutions: ['Course and institute websites', 'Class booking apps', 'Student enquiry automation'],
      serviceIds: ['mobile_app_development', 'flutter_development', 'business_automation'],
      sceneLabel: 'A stack of porcelain, gold and charcoal books beneath a graduation cap with a gold tassel.',
    ),
    IndustryProfile(
      id: 'realestate',
      name: 'Real Estate & Construction',
      icon: Icons.apartment_outlined,
      summary: '[Placeholder] Describe the listing, lead-management and presentation needs of property businesses.',
      solutions: ['Property showcase websites', 'Lead and CRM tools', 'Project presentations'],
      serviceIds: ['website_development', 'custom_software_development', 'ui_ux_design'],
      sceneLabel: 'Glass and chrome towers on a porcelain site plan, one capped in gold.',
    ),
    IndustryProfile(
      id: 'hospitality',
      name: 'Hospitality & Food',
      icon: Icons.restaurant_outlined,
      summary:
          '[Placeholder] Describe how restaurants, cafés and hotels could use reservations, menus '
          'and guest messaging.',
      solutions: ['Reservation and menu websites', 'Guest messaging assistants', 'Brand identity'],
      serviceIds: ['website_development', 'ai_solutions_chatbots', 'branding_digital_presence'],
      sceneLabel: 'A polished platinum cloche with a gold knob on a gold plate.',
    ),
  ];
}

/// Copy for the Portfolio page.
///
/// The projects themselves come from the service pages: every one is a
/// demonstration built by YODYNIX, never client work, and the page says so.
/// PLACEHOLDER: the introduction and the "Client Work" note are layout copy
/// to replace before launch.
class PortfolioContent {
  PortfolioContent._();

  static const bool isPlaceholder = true;

  static const String heading = 'Demonstration Projects, Built to Explore.';
  static const String lead =
      '[Placeholder] Introduce the portfolio in your own words. Every project below is a '
      'demonstration built by YODYNIX to show our capabilities: none is client work.';

  static const String clientWorkHeading = 'Client Case Studies';
  static const String clientWorkBody =
      '[Placeholder] Published client work will appear here once projects are complete and '
      'clients have approved sharing them. Replace this note when you add the first case study.';
}
