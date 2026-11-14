import 'package:flutter/material.dart';

import '../core/constants/asset_paths.dart';
import '../core/constants/site_config.dart';
import '../core/routing/app_routes.dart';

/// Shown wherever a programme term has not been officially confirmed.
const toBeAnnounced = 'To Be Announced';

/// Editable programme terms. Any `null` value falls back to the shared
/// default in [InternshipConfig], and a `null` there reads [toBeAnnounced].
/// Nothing here should ever state a fee, stipend, certificate, placement or
/// fixed duration that YODYNIX has not confirmed.
class ProgramTerms {
  const ProgramTerms({
    this.duration,
    this.mode,
    this.eligibility,
    this.fees,
    this.stipend,
    this.certificatePolicy,
    this.availability,
  });

  final String? duration;
  final String? mode;
  final String? eligibility;
  final String? fees;
  final String? stipend;
  final String? certificatePolicy;

  /// Whether applications are open for this programme, e.g. "Open now".
  final String? availability;

  /// Label / value pairs for display, with shared defaults applied.
  List<(IconData, String, String)> resolved() => [
    (Icons.schedule_rounded, 'Duration', duration ?? InternshipConfig.duration),
    (Icons.laptop_mac_rounded, 'Mode', mode ?? InternshipConfig.mode ?? toBeAnnounced),
    (Icons.how_to_reg_outlined, 'Eligibility', eligibility ?? InternshipConfig.eligibility ?? toBeAnnounced),
    (Icons.receipt_long_outlined, 'Fees', fees ?? InternshipConfig.fees ?? toBeAnnounced),
    (Icons.payments_outlined, 'Stipend', stipend ?? InternshipConfig.stipend ?? toBeAnnounced),
    (
      Icons.workspace_premium_outlined,
      'Certificate Policy',
      certificatePolicy ?? InternshipConfig.certificatePolicy ?? toBeAnnounced,
    ),
    (Icons.event_available_outlined, 'Applications', availability ?? InternshipConfig.availability ?? toBeAnnounced),
  ];
}

/// One item under "What You Will Learn".
class LearningTopic {
  const LearningTopic(this.title, this.description, this.icon);

  final String title;
  final String description;
  final IconData icon;
}

/// An illustrative learning project. These are practice briefs for interns,
/// never claims of completed YODYNIX client work.
class SampleLearningProject {
  const SampleLearningProject(this.title, this.description, this.icon);

  final String title;
  final String description;
  final IconData icon;
}

/// A question and answer shown in an FAQ list.
class Faq {
  const Faq(this.question, this.answer);

  final String question;
  final String answer;
}

/// One of the seven internship programmes. All copy lives in
/// `InternshipContent`, so details can be edited in one place.
class InternshipProgram {
  const InternshipProgram({
    required this.slug,
    required this.title,
    required this.shortTitle,
    required this.icon,
    required this.description,
    required this.introduction,
    required this.imageAlt,
    required this.skills,
    required this.learnTopics,
    required this.technologies,
    required this.mentorFocus,
    required this.projectFocus,
    required this.roadmapFocus,
    required this.projects,
    required this.whoCanApply,
    required this.faqs,
    this.terms = const ProgramTerms(),
  });

  /// URL segment, e.g. `flutter-development`.
  final String slug;

  /// Full name, e.g. "Flutter Development Internship".
  final String title;

  /// Domain only, e.g. "Flutter Development" (used in forms and menus).
  final String shortTitle;
  final IconData icon;

  /// One-line summary shown on cards.
  final String description;

  /// Opening paragraphs of the detail page.
  final List<String> introduction;
  final String imageAlt;

  /// Key skills shown on cards and the detail page.
  final List<String> skills;
  final List<LearningTopic> learnTopics;

  /// Tools and technologies used in the programme.
  final List<String> technologies;

  /// What mentor guidance focuses on in this programme.
  final List<String> mentorFocus;

  /// What project-based work looks like in this programme.
  final List<String> projectFocus;

  /// One programme-specific line per roadmap stage (six stages).
  final List<String> roadmapFocus;
  final List<SampleLearningProject> projects;
  final List<String> whoCanApply;
  final List<Faq> faqs;
  final ProgramTerms terms;

  String get route => AppRoutes.internshipProgram(slug);

  /// Photograph, also the file name in `assets/images/internship_careers/`.
  String get image => AssetPaths.internshipCareers(slug.replaceAll('-', '_'));
}
