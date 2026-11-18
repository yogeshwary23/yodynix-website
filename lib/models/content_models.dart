import 'package:flutter/widgets.dart';

import '../shared/widgets/visuals/pillar_visuals.dart' show PillarArt;
import '../core/routing/app_routes.dart';

/// A titled point with an icon — used by intro areas, philosophy, process,
/// and "why choose" cards.
class FeaturePoint {
  const FeaturePoint({required this.title, required this.description, required this.icon, this.color, this.image, this.imageAlt});

  final String title;
  final String description;
  final IconData icon;
  final Color? color;

  /// Optional photograph (extension-less asset path) and its description.
  final String? image;
  final String? imageAlt;
}

/// One of the three core pillars shown under the intro. [route] opens the
/// pillar's detail page; [image] is its photo's extension-less asset path,
/// with [art] as the illustrated fallback.
class CorePillar {
  const CorePillar({
    required this.title,
    required this.headline,
    required this.description,
    required this.icon,
    required this.art,
    required this.image,
    required this.imageAlt,
    required this.artwork,
    required this.artworkAlt,
    this.artworkOnLeft = false,
    required this.route,
    required this.actionLabel,
  });

  final String title;
  final String headline;
  final String description;
  final IconData icon;
  final PillarArt art;

  /// Photograph, on the homepage pillar card and the pillar detail page.
  final String image;
  final String imageAlt;

  /// Extension-less transparent 3D still that the homepage pillar card lays
  /// over [image], where the photo fades to ivory: on its right, or its left
  /// when [artworkOnLeft] (chosen so the fade never covers a face).
  final String artwork;
  final String artworkAlt;
  final bool artworkOnLeft;
  final String route;
  final String actionLabel;
}

class ServiceOffering {
  const ServiceOffering({
    required this.id,
    required this.title,
    required this.summary,
    required this.description,
    required this.capabilities,
    required this.icon,
    required this.color,
    required this.imageAlt,
  });

  /// Also used as the image file name in `assets/images/services/`.
  final String id;

  /// URL segment of the service's own page, e.g. `website-development`.
  String get slug => id.replaceAll('_', '-');
  String get route => AppRoutes.service(slug);
  final String title;
  final String summary;
  final String description;
  final List<String> capabilities;
  final IconData icon;
  final Color color;
  final String imageAlt;
}

class TechItem {
  const TechItem(this.name, this.icon, this.color);

  final String name;
  final IconData icon;
  final Color color;
}

class TechCategory {
  const TechCategory({required this.name, required this.description, required this.icon, required this.items});

  final String name;
  final String description;
  final IconData icon;
  final List<TechItem> items;
}

class ProcessStep {
  const ProcessStep({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.activities,
    this.image,
    this.imageAlt,
  });

  final String number;
  final String title;
  final String description;
  final IconData icon;
  final List<String> activities;

  /// Optional photograph (extension-less asset path) and its description.
  final String? image;
  final String? imageAlt;
}
