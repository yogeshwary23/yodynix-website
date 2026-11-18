import '../../models/about_page.dart';
import '../../models/site_section.dart';

/// Route arguments understood by the Internship landing page.
enum InternshipPageArgs {
  /// Open with the application form in view.
  apply,
}

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String privacy = '/privacy-policy';
  static const String terms = '/terms-and-conditions';

  /// Opens the default About page ([AboutPage.defaultPage]).
  static const String about = '/about';

  // Core pillar detail pages.
  static const String businessSolutions = '/business-solutions';
  static const String technologyInnovation = '/technology-innovation';

  /// Demonstration projects and the sectors we work with.
  static const String portfolio = '/portfolio';
  static const String industries = '/industries';

  /// All services, and our expertise in AI and technology.
  static const String services = '/services';
  static const String expertise = '/expertise';

  /// Internship landing page and its programme pages.
  static const String internship = '/internship';
  static const String internshipPrefix = '/internship/';
  static String internshipProgram(String slug) => '$internshipPrefix$slug';

  /// Service detail pages and their working demos.
  static const String servicePrefix = '/services/';
  static const String demoPrefix = '/demos/';
  static String service(String slug) => '$servicePrefix$slug';
  static String demo(String slug) => '$demoPrefix$slug';

  /// Shareable homepage section links, e.g. `/#/services` or `/#/why-choose`.
  static String section(SiteSection section) =>
      '/${section.name.replaceAllMapped(RegExp('[A-Z]'), (m) => '-${m[0]!.toLowerCase()}')}';

  static SiteSection? sectionFor(String route) {
    final normalised = normalise(route);
    for (final s in SiteSection.values) {
      // `/about`, `/services`, `/expertise` and `/internship` are pages.
      if (!s.onHomePage) continue;
      if (section(s) == normalised) return s;
    }
    return null;
  }

  /// Maps older or shorthand links onto the page that now owns that content,
  /// e.g. `/founder` → Meet Our Team, `/process` → How We Work.
  static String resolve(String route) {
    final normalised = normalise(route);
    return switch (normalised) {
      about || '/who-we-are' => AboutPage.whoWeAre.route,
      '/founder' || '/team' => AboutPage.team.route,
      '/philosophy' => AboutPage.philosophy.route,
      '/process' || '/how-we-work' => AboutPage.howWeWork.route,
      // Retired pages: the old Students area now opens the homepage.
      '/student-development' || '/students' => home,
      '/internship-careers' || '/internships' || '/careers' => internship,
      '/projects' || '/work' => portfolio,
      _ when normalised.startsWith('/portfolio/') => portfolio,
      _ => normalised,
    };
  }

  /// Strips a trailing slash so `/business-solutions/` resolves too.
  static String normalise(String route) => route.endsWith('/') && route.length > 1 ? route.substring(0, route.length - 1) : route;
}
