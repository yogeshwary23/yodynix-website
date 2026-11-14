/// Homepage sections in page order. Sections with a [navLabel] appear in the
/// navigation bar; the others are reachable by scrolling or CTAs.
enum SiteSection {
  home(navLabel: 'Home'),
  intro,
  about(navLabel: 'About'),
  services(navLabel: 'Services'),
  expertise(navLabel: 'Expertise'),
  internship(navLabel: 'Internship'),
  whyChoose,
  finalCta,
  contact(navLabel: 'Contact');

  const SiteSection({this.navLabel});

  final String? navLabel;

  bool get inNavigation => navLabel != null;

  static List<SiteSection> get navigation => values.where((s) => s.inNavigation).toList();
}
