import 'package:flutter/widgets.dart';

import '../core/constants/asset_paths.dart';
import 'pillar_page.dart' show PillarStep;

/// One "What We Offer" item on a service page.
class ServiceFeature {
  const ServiceFeature(this.title, this.description, this.icon);

  final String title;
  final String description;
  final IconData icon;
}

/// A YODYNIX sample project shown in a service page's portfolio. These are
/// demo and concept pieces, never client work. Only projects with a
/// [demoRoute] have a working demo; every other one is labelled a concept.
class SampleProject {
  const SampleProject({
    required this.id,
    required this.name,
    required this.category,
    required this.summary,
    required this.overview,
    required this.features,
    required this.technologies,
    required this.imageAlt,
    this.demoRoute,
  });

  /// Also the image file name in `assets/images/service_projects/`.
  final String id;
  final String name;

  /// What kind of project it is, e.g. "Clinic website".
  final String category;
  final String summary;
  final String overview;
  final List<String> features;
  final List<String> technologies;
  final String imageAlt;

  /// In-site route of the working demo; null for concepts.
  final String? demoRoute;

  bool get hasDemo => demoRoute != null;
  String get image => AssetPaths.serviceProject(id);
}

/// Everything a service detail page shows beyond the shared
/// [ServiceOffering] fields (title, description, capabilities, photo).
class ServicePageContent {
  const ServicePageContent({
    required this.heroHeading,
    required this.heroLead,
    required this.overview,
    required this.idealFor,
    required this.offers,
    required this.technologies,
    required this.process,
    required this.projects,
  });

  final String heroHeading;
  final String heroLead;

  /// Overview paragraphs.
  final List<String> overview;

  /// Who the service suits, listed beside the overview.
  final List<String> idealFor;
  final List<ServiceFeature> offers;
  final List<String> technologies;
  final List<PillarStep> process;
  final List<SampleProject> projects;

  /// The project with a working demo, featured in "Project Details".
  SampleProject get featured => projects.firstWhere((p) => p.hasDemo, orElse: () => projects.first);
}
