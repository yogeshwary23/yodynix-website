import 'package:flutter/widgets.dart';

/// One service or technology area shown on a pillar detail page. [image] is
/// an extension-less asset base path.
class PillarOffering {
  const PillarOffering({
    required this.title,
    required this.tagline,
    required this.description,
    required this.icon,
    required this.image,
    required this.imageAlt,
    required this.primaryPoints,
    required this.secondaryPoints,
    this.skills = const [],
  });

  final String title;
  final String tagline;
  final String description;
  final IconData icon;
  final String image;
  final String imageAlt;

  /// Listed under [PillarPageContent.primaryLabel], e.g. "Key Features".
  final List<String> primaryPoints;

  /// Listed under [PillarPageContent.secondaryLabel], e.g. "Business Benefits".
  final List<String> secondaryPoints;

  /// Optional skill tags, listed under [PillarPageContent.skillsLabel].
  final List<String> skills;
}

/// A numbered step in a page's "how it works" band.
class PillarStep {
  const PillarStep(this.title, this.description, this.icon);

  final String title;
  final String description;
  final IconData icon;
}

/// Configures the enquiry / application form at the foot of a pillar page.
class PillarFormConfig {
  const PillarFormConfig({
    required this.kind,
    required this.title,
    required this.lead,
    required this.optionLabel,
    required this.extraFieldLabel,
    required this.extraFieldIcon,
    required this.messageLabel,
    required this.messageHint,
    required this.submitLabel,
    required this.image,
    required this.imageAlt,
    this.extraFieldRequired = false,
    this.extraFieldHint,
    this.messageRequired = true,
  });

  /// Identifies the form in submitted data, e.g. "business_enquiry".
  final String kind;
  final String title;
  final String lead;
  final String optionLabel;
  final String extraFieldLabel;
  final IconData extraFieldIcon;
  final bool extraFieldRequired;
  final String? extraFieldHint;
  final String messageLabel;
  final String messageHint;
  final bool messageRequired;
  final String submitLabel;
  final String image;
  final String imageAlt;
}

/// Everything a pillar detail page renders: hero, offerings, process band,
/// form and labels. One instance per route.
class PillarPageContent {
  const PillarPageContent({
    required this.route,
    required this.title,
    required this.eyebrow,
    required this.heroHeading,
    required this.heroLead,
    required this.heroImage,
    required this.heroImageAlt,
    required this.highlights,
    required this.offeringsEyebrow,
    required this.offeringsHeading,
    required this.offeringsLead,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.ctaPrefix,
    required this.offerings,
    required this.stepsEyebrow,
    required this.stepsHeading,
    required this.stepsLead,
    required this.steps,
    required this.form,
    this.skillsLabel = 'Skills Covered',
    this.note,
    this.noteIcon,
    this.stepsImage,
    this.stepsImageAlt,
  });

  final String route;
  final String title;
  final String eyebrow;
  final String heroHeading;
  final String heroLead;
  final String heroImage;
  final String heroImageAlt;
  final List<(IconData, String)> highlights;

  final String offeringsEyebrow;
  final String offeringsHeading;
  final String offeringsLead;
  final String primaryLabel;
  final String secondaryLabel;
  final String skillsLabel;

  /// CTA text before the offering title, e.g. "Enquire About".
  final String ctaPrefix;
  final List<PillarOffering> offerings;

  final String stepsEyebrow;
  final String stepsHeading;
  final String stepsLead;
  final List<PillarStep> steps;
  final String? stepsImage;
  final String? stepsImageAlt;

  /// Highlighted notice under the steps (integrity, disclaimers, honesty).
  final String? note;
  final IconData? noteIcon;

  final PillarFormConfig form;
}
