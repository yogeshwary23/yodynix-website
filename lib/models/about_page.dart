import 'package:flutter/material.dart';

/// The four About pages, in the order they appear in the About dropdown.
/// Each one has its own route, e.g. `/#/about/who-we-are`.
enum AboutPage {
  whoWeAre(
    title: 'Who We Are',
    route: '/about/who-we-are',
    icon: Icons.apartment_rounded,
    summary: 'Our story, vision, mission and the approach behind YODYNIX.',
    image: 'assets/images/about/about_visual',
    imageAlt: 'A technology team at work on their computers in a bright, open office.',
    highlight: 'Practical Technology.',
    sceneVariant: 'who',
    sceneLabel: 'Three gold-edged glass layers, a gold ribbon rising beside the photograph and a gold sphere in orbit.',
  ),
  team(
    title: 'Meet Our Team',
    route: '/about/team',
    icon: Icons.groups_2_outlined,
    summary: 'The founder and the people who plan, build and deliver every project.',
    image: 'assets/images/team/founder_office',
    imageAlt: 'The founder of YODYNIX working at a desk in the YODYNIX office.',
    highlight: 'YODYNIX.',
    sceneVariant: 'team',
    sceneLabel: 'Two gold and three platinum spheres linked by gold arcs on a pearl disc, and a gold halo.',
  ),
  philosophy(
    title: 'Our Philosophy',
    route: '/about/philosophy',
    icon: Icons.auto_awesome_outlined,
    summary: 'Six principles that shape every project and every partnership.',
    image: 'assets/images/about/philosophy_partnerships',
    imageAlt: 'Colleagues collaborating around a table.',
    heroImage: 'assets/images/about/philosophy_hero',
    heroImageAlt: 'Colleagues taking notes together around a wooden table.',
    highlight: 'Every Project',
    sceneVariant: 'philosophy',
    sceneLabel: 'Six gold-rimmed glass tiles turning in an arc beside the photograph, and a gold compass.',
  ),
  howWeWork(
    title: 'How We Work',
    route: '/about/how-we-work',
    icon: Icons.route_outlined,
    summary: 'Our step-by-step process, from first conversation to launch and beyond.',
    image: 'assets/images/about/process_plan',
    imageAlt: 'A project plan being sketched out.',
    heroImage: 'assets/images/about/process_hero',
    heroImageAlt: 'A team planning a project with notes on a glass wall.',
    highlight: 'Final Experience.',
    sceneVariant: 'process',
    sceneLabel: 'Meshing gold and platinum gears, and a gold halo with a sphere travelling round it.',
  );

  const AboutPage({
    required this.title,
    required this.route,
    required this.icon,
    required this.summary,
    required this.image,
    required this.imageAlt,
    this.heroImage,
    this.heroImageAlt,
    required this.highlight,
    required this.sceneVariant,
    required this.sceneLabel,
  });

  final String title;
  final String route;
  final IconData icon;
  final String summary;

  /// Extension-less photo used on the homepage About overview cards, and in
  /// the page's own hero unless [heroImage] is given (when [image] already
  /// appears further down that page).
  final String image;
  final String imageAlt;
  final String? heroImage;
  final String? heroImageAlt;

  /// The closing words of the page heading, set in metallic gold.
  final String highlight;

  /// The hero's 3D around its photo: `aboutPage` in web/three/yodynix3d.js.
  final String sceneVariant;
  final String sceneLabel;

  /// Opened when a visitor clicks "About" itself.
  static const AboutPage defaultPage = whoWeAre;

  static AboutPage? byRoute(String route) {
    for (final page in values) {
      if (page.route == route) return page;
    }
    return null;
  }
}
