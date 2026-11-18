/// Homepage sections and navigation entries in navigation order. Sections
/// with a [navLabel] appear in the navigation bar; the others are reachable by
/// scrolling or CTAs. Entries with [hasOwnPage] open a page of their own and
/// are not on the homepage.
enum SiteSection {
  home(navLabel: 'Home'),
  intro,
  about(navLabel: 'About', hasOwnPage: true),
  services(navLabel: 'Services', hasOwnPage: true),
  expertise(navLabel: 'Expertise', hasOwnPage: true),
  internship(navLabel: 'Internship', hasOwnPage: true),
  whyChoose,
  contact(navLabel: 'Contact');

  const SiteSection({this.navLabel, this.hasOwnPage = false});

  final String? navLabel;
  final bool hasOwnPage;

  bool get inNavigation => navLabel != null;
  bool get onHomePage => !hasOwnPage;

  static List<SiteSection> get navigation => values.where((s) => s.inNavigation).toList();
}
