import 'package:flutter/material.dart';

import '../../features/about/about_page_view.dart';
import '../../features/demos/demo_catalog.dart';
import '../../features/demos/demo_page.dart';
import '../../features/home/home_page.dart';
import '../../features/home/legal_page.dart';
import '../../features/internship/internship_page.dart';
import '../../features/internship/internship_program_page.dart';
import '../../features/pillars/pillar_detail_page.dart';
import '../../features/services/service_detail_page.dart';
import '../../models/about_page.dart';
import '../../models/site_section.dart';
import '../../repositories/content/internship_content.dart';
import '../../repositories/content/pillar_pages_content.dart';
import '../../repositories/content/service_pages_content.dart';
import '../theme/app_tokens.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = AppRoutes.resolve(settings.name ?? AppRoutes.home);
    final aboutPage = AboutPage.byRoute(name);
    final pillarPage = PillarPagesContent.byRoute(name);
    final service = name.startsWith(AppRoutes.servicePrefix)
        ? ServicePagesContent.bySlug(name.substring(AppRoutes.servicePrefix.length))
        : null;
    final demo = DemoCatalog.byRoute(name);
    final program = name.startsWith(AppRoutes.internshipPrefix)
        ? InternshipContent.bySlug(name.substring(AppRoutes.internshipPrefix.length))
        : null;
    final Widget page;
    if (aboutPage != null) {
      page = AboutPageView(page: aboutPage);
    } else if (pillarPage != null) {
      page = PillarDetailPage(content: pillarPage);
    } else if (service != null) {
      page = ServiceDetailPage(service: service);
    } else if (demo != null) {
      page = DemoPage(demo: demo);
    } else if (name == AppRoutes.internship) {
      page = InternshipPage(scrollToApply: settings.arguments == InternshipPageArgs.apply);
    } else if (program != null) {
      page = InternshipProgramPage(program: program);
    } else if (name == AppRoutes.privacy) {
      page = const LegalPage(title: 'Privacy Policy');
    } else if (name == AppRoutes.terms) {
      page = const LegalPage(title: 'Terms & Conditions');
    } else {
      page = const HomePage();
    }
    return PageRouteBuilder<void>(
      // Canonical name, so redirected links (e.g. `/team`) show the page's own URL.
      settings: RouteSettings(name: name, arguments: settings.arguments),
      transitionDuration: AppMotion.page,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    );
  }

  /// Deep links (e.g. `/#/services/website-development`) always keep the homepage
  /// underneath so "back" and in-page navigation work as expected. Section
  /// links (e.g. `/#/internship`) open the homepage at that section.
  static List<Route<dynamic>> onGenerateInitialRoutes(
    String initialRoute, {
    required void Function(SiteSection section) onSectionLink,
  }) {
    final home = onGenerateRoute(const RouteSettings(name: AppRoutes.home));
    if (initialRoute == AppRoutes.home || initialRoute.isEmpty) return [home];

    final section = AppRoutes.sectionFor(initialRoute);
    if (section != null) {
      onSectionLink(section);
      return [home];
    }
    return [home, onGenerateRoute(RouteSettings(name: initialRoute))];
  }
}
