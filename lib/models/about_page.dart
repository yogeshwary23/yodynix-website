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
  ),
  team(
    title: 'Meet Our Team',
    route: '/about/team',
    icon: Icons.groups_2_outlined,
    summary: 'The founder and the people who plan, build and deliver every project.',
    image: 'assets/images/team/founder_office',
    imageAlt: 'The YODYNIX office.',
  ),
  philosophy(
    title: 'Our Philosophy',
    route: '/about/philosophy',
    icon: Icons.auto_awesome_outlined,
    summary: 'Six principles that shape every project and every partnership.',
    image: 'assets/images/about/philosophy_partnerships',
    imageAlt: 'Colleagues collaborating around a table.',
  ),
  howWeWork(
    title: 'How We Work',
    route: '/about/how-we-work',
    icon: Icons.route_outlined,
    summary: 'Our step-by-step process, from first conversation to launch and beyond.',
    image: 'assets/images/about/process_plan',
    imageAlt: 'A project plan being sketched out.',
  );

  const AboutPage({
    required this.title,
    required this.route,
    required this.icon,
    required this.summary,
    required this.image,
    required this.imageAlt,
  });

  final String title;
  final String route;
  final IconData icon;
  final String summary;

  /// Extension-less photo used on the homepage About overview cards.
  final String image;
  final String imageAlt;

  /// Opened when a visitor clicks "About" itself.
  static const AboutPage defaultPage = whoWeAre;

  static AboutPage? byRoute(String route) {
    for (final page in values) {
      if (page.route == route) return page;
    }
    return null;
  }
}
