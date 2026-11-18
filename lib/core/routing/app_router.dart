import 'package:flutter/material.dart';

import '../../features/about/about_page_view.dart';
import '../../features/careers/careers_page.dart';
import '../../features/demos/demo_catalog.dart';
import '../../features/demos/demo_page.dart';
import '../../features/expertise/expertise_page.dart';
import '../../features/home/home_page.dart';
import '../../features/home/legal_page.dart';
import '../../features/industries/industries_page.dart';
import '../../features/pillars/pillar_detail_page.dart';
import '../../features/portfolio/portfolio_page.dart';
import '../../features/services/service_detail_page.dart';
import '../../features/services/services_page.dart';
import '../../models/about_page.dart';
import '../../models/site_section.dart';
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
    final Widget page;
    if (aboutPage != null) {
      page = AboutPageView(page: aboutPage);
    } else if (pillarPage != null) {
      page = PillarDetailPage(content: pillarPage);
    } else if (service != null) {
      page = ServiceDetailPage(service: service);
    } else if (demo != null) {
      page = DemoPage(demo: demo);
    } else if (name == AppRoutes.careers) {
      page = CareersPage(scrollToApply: settings.arguments == CareersPageArgs.apply);
    } else if (name == AppRoutes.services) {
      page = const ServicesPage();
    } else if (name == AppRoutes.expertise) {
      page = const ExpertisePage();
    } else if (name == AppRoutes.portfolio) {
      page = const PortfolioPage();
    } else if (name == AppRoutes.industries) {
      page = const IndustriesPage();
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
      transitionDuration: AppMotion.pageEnter,
      reverseTransitionDuration: AppMotion.page,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: _cinematic,
    );
  }

  /// The incoming page rises a little and settles from a slight zoom as it
  /// fades in, like a camera easing onto the next scene. Reduced motion keeps
  /// only the fade.
  static Widget _cinematic(BuildContext context, Animation<double> animation, Animation<double> _, Widget child) {
    final fade = CurvedAnimation(parent: animation, curve: const Interval(0, 0.7, curve: Curves.easeOut));
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      return FadeTransition(opacity: fade, child: child);
    }
    final move = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.025), end: Offset.zero).animate(move),
        child: ScaleTransition(scale: Tween(begin: 1.015, end: 1.0).animate(move), child: child),
      ),
    );
  }

  /// Deep links (e.g. `/#/services/website-development`) always keep the homepage
  /// underneath so "back" and in-page navigation work as expected. Section
  /// links (e.g. `/#/contact`) open the homepage at that section.
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
