import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../../models/pillar_page.dart' show PillarStep;

/// One open position on the Careers page.
class JobOpening {
  const JobOpening({
    required this.id,
    required this.title,
    required this.icon,
    required this.summary,
    required this.skills,
  });

  /// Stable key used to pre-select the position in the application form.
  final String id;
  final String title;
  final IconData icon;
  final String summary;

  /// Required skills, shown as chips on the job card.
  final List<String> skills;
}

/// Copy for the Careers page: open positions, why join, the hiring process
/// and the application form.
///
/// Only details YODYNIX has confirmed are stated: no salary, experience
/// band or employment terms are implied. Add them here once approved.
class CareersContent {
  CareersContent._();

  static const String badge = 'Careers at YODYNIX';
  static const String heading = 'Build What Matters With Us.';
  static const String description =
      'We are growing our development team in Pune. Join YODYNIX to design, build and ship '
      'cross-platform apps and modern websites for businesses that depend on them.';

  static const List<(IconData, String)> highlights = [
    (Icons.work_outline_rounded, '4 open positions across mobile and web'),
    (Icons.location_on_outlined, 'Based at our office in Moshi, Pune'),
    (Icons.groups_outlined, 'Work alongside experienced developers and leadership'),
  ];

  static final heroImage = AssetPaths.internshipCareers('hero');
  static const heroImageAlt = 'A small team discussing project plans together in a modern office.';
  static final applicationImage = AssetPaths.internshipCareers('application');
  static const applicationImageAlt = 'Two colleagues planning ideas together on a whiteboard.';

  static const String openingsLead =
      'We are hiring for the roles below. Review the skills each role needs, then apply '
      'directly from the position that suits you.';

  static const List<JobOpening> openings = [
    JobOpening(
      id: 'flutter-developer',
      title: 'Flutter Developer',
      icon: Icons.flutter_dash_rounded,
      summary:
          'Build and maintain production-quality cross-platform mobile applications in Flutter, '
          'from clean UI architecture through to Firebase-backed features and release.',
      skills: ['Flutter', 'Dart', 'Cross-platform mobile app development', 'Firebase integration'],
    ),
    JobOpening(
      id: 'junior-flutter-developer',
      title: 'Junior Flutter Developer',
      icon: Icons.phone_android_rounded,
      summary:
          'Turn designs into polished, responsive Flutter screens and connect them to live APIs, '
          'working closely with senior developers on real client projects.',
      skills: ['Flutter', 'Dart', 'UI implementation', 'API integration'],
    ),
    JobOpening(
      id: 'mobile-app-developer',
      title: 'Mobile App Developer',
      icon: Icons.devices_other_rounded,
      summary:
          'Design and develop reliable Android and iOS applications with a scalable architecture, '
          'integrating REST APIs and Firebase services end to end.',
      skills: ['Android & iOS app development', 'Mobile application architecture', 'API and Firebase integration'],
    ),
    JobOpening(
      id: 'web-developer',
      title: 'Web Developer',
      icon: Icons.language_rounded,
      summary:
          'Develop fast, accessible and fully responsive websites and web applications using '
          'modern web technologies, including Flutter Web.',
      skills: ['Responsive website development', 'HTML, CSS, JavaScript', 'Flutter Web / modern web technologies'],
    ),
  ];

  static JobOpening? byId(String id) {
    for (final o in openings) {
      if (o.id == id) return o;
    }
    return null;
  }

  static const List<(IconData, String, String)> benefits = [
    (
      Icons.rocket_launch_outlined,
      'Meaningful Projects',
      'Ship real products for growing businesses, startups and entrepreneurs.',
    ),
    (
      Icons.trending_up_rounded,
      'Professional Growth',
      'Grow your craft with code reviews, modern tooling and room to take ownership.',
    ),
    (
      Icons.handshake_outlined,
      'Collaborative Team',
      'A focused team where clear communication and quality work come first.',
    ),
    (
      Icons.auto_awesome_outlined,
      'Modern Technology',
      'Work with Flutter, Firebase, AI-assisted tooling and current web standards.',
    ),
  ];

  static const List<PillarStep> hiringProcess = [
    PillarStep('Apply Online', 'Choose a position and send your details with a link to your résumé.', Icons.send_outlined),
    PillarStep('Profile Review', 'Our team reviews your experience and work samples.', Icons.fact_check_outlined),
    PillarStep('Technical Interview', 'A practical conversation about your skills and past projects.', Icons.forum_outlined),
    PillarStep('Offer & Onboarding', 'Successful candidates receive an offer and a structured start.', Icons.verified_outlined),
  ];

  static const String applicationLead =
      'Select the position you are applying for and share a few details about your experience. '
      'Our hiring team reviews every application and replies by email.';

  static const List<String> experienceOptions = [
    'Fresher',
    'Less than 1 year',
    '1–3 years',
    '3–5 years',
    'More than 5 years',
  ];
}
