import '../../models/about_page.dart';
import '../../models/site_section.dart';
import '../../repositories/content/service_pages_content.dart';

/// Route arguments understood by the Careers page.
enum CareersPageArgs {
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

  /// Websites and software built for clients.
  static const String ourWork = '/our-work';

  /// All services, and our expertise in AI and technology.
  static const String services = '/services';
  static const String expertise = '/expertise';

  /// Careers page: open positions and the job application form.
  static const String careers = '/careers';

  /// Service detail pages and their working demos.
  static const String servicePrefix = '/services/';
  static const String demoPrefix = '/demos/';
  static String service(String slug) => '$servicePrefix$slug';
  static String demo(String slug) => '$demoPrefix$slug';

  /// A demonstration project's own page, e.g. `/portfolio/lumen-dental`.
  static const String projectPrefix = '/portfolio/';
  static String project(String slug) => '$projectPrefix$slug';

  /// Shareable homepage section links, e.g. `/#/services` or `/#/why-choose`.
  static String section(SiteSection section) =>
      '/${section.name.replaceAllMapped(RegExp('[A-Z]'), (m) => '-${m[0]!.toLowerCase()}')}';

  static SiteSection? sectionFor(String route) {
    final normalised = normalise(route);
    for (final s in SiteSection.values) {
      // `/about`, `/services`, `/expertise` and `/careers` are pages.
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
      // The former Internship pages now open Careers.
      '/internship' || '/internship-careers' || '/internships' || '/jobs' => careers,
      _ when normalised.startsWith('/internship/') => careers,
      '/projects' || '/work' => portfolio,
      '/clients' || '/our-clients' => ourWork,
      // Flutter is now part of Mobile Application Development.
      '/services/flutter-development' => service('mobile-app-development'),
      // Project pages; unknown project links open the portfolio.
      _ when normalised.startsWith(projectPrefix) =>
        ServicePagesContent.projectBySlug(normalised.substring(projectPrefix.length)) == null ? portfolio : normalised,
      _ => normalised,
    };
  }

  /// Drops any query or fragment and a trailing slash, so
  /// `/business-solutions/?ref=x` resolves like `/business-solutions`.
  static String normalise(String route) {
    final cut = route.indexOf(RegExp('[?#]'));
    final path = cut < 0 ? route : route.substring(0, cut);
    if (path.isEmpty) return home;
    return path.endsWith('/') && path.length > 1 ? path.substring(0, path.length - 1) : path;
  }
}
