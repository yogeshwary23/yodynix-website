import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../../models/pillar_page.dart' show PillarStep;

/// Whether an opening is a full-time job or an internship. Each is listed
/// on its own tab, applied for separately and reported to HR as such.
enum OpeningKind {
  job('Job Application'),
  internship('Internship Application');

  const OpeningKind(this.applicationLabel);

  /// "Job Application" / "Internship Application".
  final String applicationLabel;
}

/// One open position on the Careers page: a job or an internship.
class JobOpening {
  const JobOpening({
    required this.id,
    required this.kind,
    required this.title,
    required this.icon,
    required this.summary,
    required this.skills,
    required this.eligibility,
    this.employmentType,
    this.duration,
  });

  /// Stable key used to pre-select the position in the application form.
  final String id;
  final OpeningKind kind;
  final String title;
  final IconData icon;
  final String summary;

  /// Required skills, shown as chips on the card.
  final List<String> skills;

  /// Who can apply.
  final String eligibility;

  /// Jobs only, e.g. "Full-time · On-site".
  final String? employmentType;

  /// Internships only; null uses [CareersContent.internshipDuration].
  final String? duration;

  bool get isInternship => kind == OpeningKind.internship;

  /// The internship's length (its own or the default); null for jobs.
  String? get internshipDuration => isInternship ? (duration ?? CareersContent.internshipDuration) : null;
}

/// Copy for the Careers page: job openings, internship opportunities, why
/// join, the hiring process and the application form.
///
/// No salary, stipend, paid internship or placement is stated or implied.
/// Add terms here only once they are approved.
class CareersContent {
  CareersContent._();

  static const String badge = 'Careers at YODYNIX';
  static const String heading = 'Build What Matters With Us.';
  static const String description =
      'We are growing our development team in Pune. Join YODYNIX to design, build and ship '
      'cross-platform apps and modern websites for businesses that depend on them.';

  static const List<(IconData, String)> highlights = [
    (Icons.work_outline_rounded, '4 job openings and 4 internship opportunities'),
    (Icons.location_on_outlined, 'Based at our office in Moshi, Pune'),
    (Icons.groups_outlined, 'Work alongside experienced developers and leadership'),
  ];

  static final heroImage = AssetPaths.internshipCareers('hero');
  static const heroImageAlt = 'A small team discussing project plans together in a modern office.';
  static final applicationImage = AssetPaths.internshipCareers('application');
  static const applicationImageAlt = 'Two colleagues planning ideas together on a whiteboard.';

  static const String openingsLead =
      'We are hiring for full-time roles and offering internships. Review the skills each '
      'position needs, then apply directly from the one that suits you.';

  static const String jobsLead = 'Full-time roles based at our office in Moshi, Pune.';

  static const String internshipsLead =
      'Learn by building real products alongside our team. Choose the internship that matches '
      'your interests and apply with your résumé.';

  /// How long internships run unless an internship sets its own
  /// [JobOpening.duration]. Change it here to update every internship card.
  static const String internshipDuration = '3 months';

  static const String _employment = 'Full-time · On-site';
  static const String _graduates = 'A degree in Computer Science, IT or a related field, or equivalent practical experience.';
  static const String _students =
      'Final-year students or recent graduates of a degree or diploma in Computer Science, IT '
      'or a related field.';

  /// Full-time job openings.
  static const List<JobOpening> openings = [
    JobOpening(
      id: 'flutter-developer',
      kind: OpeningKind.job,
      title: 'Flutter Developer',
      icon: Icons.flutter_dash_rounded,
      summary:
          'Build and maintain production-quality cross-platform mobile applications in Flutter, '
          'from clean UI architecture through to Firebase-backed features and release.',
      skills: ['Flutter', 'Dart', 'State management', 'REST APIs', 'Firebase integration'],
      employmentType: _employment,
      eligibility: '$_graduates Flutter apps you have built and can show us.',
    ),
    JobOpening(
      id: 'mobile-app-developer',
      kind: OpeningKind.job,
      title: 'Mobile App Developer',
      icon: Icons.devices_other_rounded,
      summary:
          'Design and develop reliable Android and iOS applications with a scalable architecture, '
          'integrating REST APIs and Firebase services end to end.',
      skills: ['Android & iOS development', 'Mobile app architecture', 'API and Firebase integration', 'App store releases'],
      employmentType: _employment,
      eligibility: '$_graduates Mobile apps you have built or contributed to.',
    ),
    JobOpening(
      id: 'web-developer',
      kind: OpeningKind.job,
      title: 'Web Developer',
      icon: Icons.language_rounded,
      summary:
          'Develop fast, accessible and fully responsive websites and web applications using '
          'modern web technologies, including Flutter Web.',
      skills: ['HTML, CSS, JavaScript', 'Responsive design', 'Flutter Web or a modern framework', 'Web performance & SEO basics'],
      employmentType: _employment,
      eligibility: '$_graduates Websites or web apps you have built.',
    ),
    JobOpening(
      id: 'full-stack-developer',
      kind: OpeningKind.job,
      title: 'Full Stack Developer',
      icon: Icons.layers_outlined,
      summary:
          'Build complete features across the front end and back end: responsive interfaces, '
          'REST APIs, databases and cloud deployment, from design through to release.',
      skills: [
        'JavaScript / TypeScript',
        'Node.js or a similar back end',
        'REST API design',
        'SQL and NoSQL databases',
        'Git & cloud deployment',
      ],
      employmentType: _employment,
      eligibility: '$_graduates Projects that show both front-end and back-end work.',
    ),
  ];

  /// Internship opportunities, kept separate from [openings].
  static const List<JobOpening> internships = [
    JobOpening(
      id: 'flutter-development-intern',
      kind: OpeningKind.internship,
      title: 'Flutter Development Intern',
      icon: Icons.flutter_dash_rounded,
      summary:
          'Learn production Flutter by building real screens and features alongside our '
          'developers, with regular code reviews along the way.',
      skills: ['Dart fundamentals', 'Flutter widgets & layouts', 'Git basics'],
      eligibility: '$_students Some Flutter or Dart practice, such as a personal or college project.',
    ),
    JobOpening(
      id: 'mobile-app-development-intern',
      kind: OpeningKind.internship,
      title: 'Mobile App Development Intern',
      icon: Icons.phone_android_rounded,
      summary:
          'Work on Android and iOS apps end to end, from implementing screens to connecting APIs, '
          'testing and preparing releases.',
      skills: ['Programming fundamentals', 'Flutter, Kotlin or Swift basics', 'REST API concepts'],
      eligibility: '$_students An interest in mobile apps and a project you can talk about.',
    ),
    JobOpening(
      id: 'web-development-intern',
      kind: OpeningKind.internship,
      title: 'Web Development Intern',
      icon: Icons.language_rounded,
      summary:
          'Build responsive pages and features with HTML, CSS and JavaScript, and learn how '
          'production websites are planned, reviewed and shipped.',
      skills: ['HTML & CSS', 'JavaScript basics', 'Responsive layouts'],
      eligibility: '$_students A website or web project you have built.',
    ),
    JobOpening(
      id: 'ui-ux-design-intern',
      kind: OpeningKind.internship,
      title: 'UI/UX Design Intern',
      icon: Icons.design_services_outlined,
      summary:
          'Research, wireframe and design interfaces for web and mobile products, and follow your '
          'designs through to development.',
      skills: ['Figma', 'Wireframing & prototyping', 'Design fundamentals', 'User research basics'],
      eligibility:
          'Students or recent graduates in design, HCI, Computer Science or a related field, or '
          'self-taught designers, with a portfolio of design work.',
    ),
  ];

  /// Every position, jobs first.
  static const List<JobOpening> allOpenings = [...openings, ...internships];

  static JobOpening? byId(String id) {
    for (final o in allOpenings) {
      if (o.id == id) return o;
    }
    return null;
  }

  static const List<(IconData, String, String)> benefits = [
    (Icons.rocket_launch_outlined, 'Meaningful Projects', 'Ship real products for growing businesses, startups and entrepreneurs.'),
    (Icons.trending_up_rounded, 'Professional Growth', 'Grow your craft with code reviews, modern tooling and room to take ownership.'),
    (Icons.handshake_outlined, 'Collaborative Team', 'A focused team where clear communication and quality work come first.'),
    (Icons.auto_awesome_outlined, 'Modern Technology', 'Work with Flutter, Firebase, AI-assisted tooling and current web standards.'),
  ];

  static const List<PillarStep> hiringProcess = [
    PillarStep('Apply Online', 'Choose a position and send your details with your résumé attached.', Icons.send_outlined),
    PillarStep('Profile Review', 'Our team reviews your experience and work samples.', Icons.fact_check_outlined),
    PillarStep('Technical Interview', 'A practical conversation about your skills and past projects.', Icons.forum_outlined),
    PillarStep('Offer & Onboarding', 'Successful candidates receive an offer and a structured start.', Icons.verified_outlined),
  ];

  static const String applicationLead =
      'Select the position you are applying for and share a few details about your experience. '
      'Our hiring team reviews every application and replies by email.';
}
