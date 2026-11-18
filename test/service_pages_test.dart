import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yodynix_website/app/yodynix_app.dart';
import 'package:yodynix_website/core/constants/asset_paths.dart';
import 'package:yodynix_website/core/routing/app_router.dart';
import 'package:yodynix_website/core/routing/app_routes.dart';
import 'package:yodynix_website/features/demos/demo_catalog.dart';
import 'package:yodynix_website/features/demos/demo_page.dart';
import 'package:yodynix_website/features/home/home_page.dart';
import 'package:yodynix_website/features/services/service_detail_page.dart';
import 'package:yodynix_website/models/site_section.dart';
import 'package:yodynix_website/repositories/content/service_pages_content.dart';
import 'package:yodynix_website/repositories/content/services_content.dart';
import 'package:yodynix_website/services/asset_registry.dart';
import 'package:yodynix_website/shared/layouts/site_navbar.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(AssetRegistry.instance.init);
    await tester.pumpWidget(const YodynixApp());
    await tester.runAsync(GoogleFonts.pendingFonts);
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  NavigatorState navigator(WidgetTester tester) => tester.state<NavigatorState>(find.byType(Navigator).first);

  Widget? topPage(WidgetTester tester) {
    final route = find.byWidgetPredicate((w) => w is ServiceDetailPage || w is DemoPage, skipOffstage: false).evaluate();
    return route.isEmpty ? null : route.last.widget;
  }

  final servicesMenu = find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Services menu');

  test('homepage section navigation has no Students item, in the agreed order', () {
    expect(
      [for (final s in SiteSection.values) ?s.navLabel],
      ['Home', 'About', 'Services', 'Expertise', 'Internship', 'Contact'],
    );
  });

  test('retired Students links redirect home', () {
    for (final r in ['/students', '/student-development']) {
      expect(AppRoutes.resolve(r), AppRoutes.home, reason: r);
    }
  });

  test('Portfolio links, including old project URLs, open the Portfolio page', () {
    for (final r in ['/portfolio', '/portfolio/', '/portfolio/smart-crm', '/projects']) {
      expect(AppRoutes.resolve(r), AppRoutes.portfolio, reason: r);
    }
    expect(AppRoutes.resolve('/industries/'), AppRoutes.industries);
  });

  test('every service has its own route, page content and 4–5 sample projects', () {
    final routes = <String>{};
    for (final s in ServicesContent.services) {
      expect(routes.add(s.route), isTrue, reason: s.route);
      expect(ServicePagesContent.bySlug(s.slug), same(s));
      final content = ServicePagesContent.of(s);
      expect(content.projects.length, inInclusiveRange(4, 5), reason: s.title);
      expect(content.offers, isNotEmpty);
      expect(content.technologies, isNotEmpty);
      expect(content.process, isNotEmpty);
      expect(content.projects.where((p) => p.hasDemo), hasLength(1), reason: s.title);
    }
    expect(routes, hasLength(10));
  });

  test('demo links only exist where a working demo exists', () {
    final linked = <String>{};
    for (final p in ServicePagesContent.allProjects) {
      if (!p.hasDemo) continue;
      expect(DemoCatalog.byRoute(p.demoRoute!), isNotNull, reason: p.demoRoute);
      expect(linked.add(p.demoRoute!), isTrue, reason: p.demoRoute);
      // Demos are in-site routes, never external URLs.
      expect(p.demoRoute, startsWith(AppRoutes.demoPrefix));
    }
    expect(linked, {for (final d in DemoCatalog.demos) d.route});
    for (final d in DemoCatalog.demos) {
      expect(d.project.demoRoute, d.route);
    }
  });

  testWidgets('every service and project photo is bundled and unique', (tester) async {
    await tester.runAsync(AssetRegistry.instance.init);
    final paths = [
      for (final s in ServicesContent.services) AssetPaths.service(s.id),
      for (final p in ServicePagesContent.allProjects) p.image,
    ];
    expect(paths.toSet(), hasLength(paths.length));
    for (final path in paths) {
      expect(AssetRegistry.instance.resolve(path), isNotNull, reason: path);
    }
  });

  test('service and demo URLs build their own pages; unknown URLs fall back home', () {
    Widget build(String name) {
      final route = AppRouter.onGenerateRoute(RouteSettings(name: name)) as PageRouteBuilder;
      return route.pageBuilder(_FakeContext(), kAlwaysCompleteAnimation, kAlwaysCompleteAnimation);
    }

    for (final s in ServicesContent.services) {
      expect(build(s.route), isA<ServiceDetailPage>());
      expect(build('${s.route}/'), isA<ServiceDetailPage>());
    }
    for (final d in DemoCatalog.demos) {
      expect(build(d.route), isA<DemoPage>());
    }
    expect(build('/services/not-a-service'), isA<HomePage>());
    expect(build('/demos/nope'), isA<HomePage>());
    expect(build('/students'), isA<HomePage>());

    final deep = AppRouter.onGenerateInitialRoutes('/services/website-development', onSectionLink: (_) {});
    expect(deep.map((r) => r.settings.name), ['/', '/services/website-development']);
    final demo = AppRouter.onGenerateInitialRoutes('/demos/mini-crm', onSectionLink: (_) {});
    expect(demo.map((r) => r.settings.name), ['/', '/demos/mini-crm']);
  });

  testWidgets('Services dropdown lists all services and opens their pages', (tester) async {
    await pumpAt(tester, const Size(1440, 900));
    final navServices = find.descendant(of: find.byType(SiteNavbar), matching: find.text('Services'));
    expect(find.descendant(of: find.byType(SiteNavbar), matching: find.text('Students')), findsNothing);
    expect(find.descendant(of: find.byType(SiteNavbar), matching: find.text('Portfolio')), findsOneWidget);
    expect(find.descendant(of: find.byType(SiteNavbar), matching: find.text('Industries')), findsOneWidget);

    await tester.tap(navServices.last);
    await settle(tester);
    expect(servicesMenu, findsOneWidget);
    for (final s in ServicesContent.services) {
      expect(find.descendant(of: servicesMenu, matching: find.text(s.title)), findsOneWidget);
    }

    final target = ServicesContent.services[3];
    await tester.tap(find.descendant(of: servicesMenu, matching: find.text(target.title)));
    await settle(tester);
    expect((topPage(tester) as ServiceDetailPage).service.id, target.id);

    // Picking another service replaces the page, so "back" returns home.
    await tester.tap(navServices.last);
    await settle(tester);
    await tester.tap(find.descendant(of: servicesMenu, matching: find.text(ServicesContent.services.first.title)));
    await settle(tester);
    expect((topPage(tester) as ServiceDetailPage).service.id, ServicesContent.services.first.id);
    navigator(tester).pop();
    await settle(tester);
    expect(topPage(tester), isNull);
    expect(tester.takeException(), isNull);
  });

  for (final (label, size) in [('desktop', Size(1440, 900)), ('mobile', Size(390, 844))]) {
    testWidgets('service page shows one live demo and labelled concepts on $label', (tester) async {
      await pumpAt(tester, size);
      final service = ServicesContent.services.first;
      navigator(tester).pushNamed(service.route);
      await settle(tester);

      final content = ServicePagesContent.of(service);
      expect(find.text(content.heroHeading), findsOneWidget);
      for (final heading in ['What We Offer', 'Our Process', 'Sample Portfolio']) {
        expect(
          find.text(heading.toUpperCase(), skipOffstage: false).evaluate().isNotEmpty ||
              find.text(heading, skipOffstage: false).evaluate().isNotEmpty,
          isTrue,
          reason: heading,
        );
      }
      for (final p in content.projects) {
        expect(find.text(p.name, skipOffstage: false), findsWidgets, reason: p.name);
      }
      expect(find.text('Concept · no live demo yet', skipOffstage: false), findsNWidgets(3));

      final demoButton = find.text('View Live Demo', skipOffstage: false).first;
      // Centre it in the viewport, as a visitor would see it.
      Scrollable.ensureVisible(tester.element(demoButton), alignment: 0.5);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      await tester.tap(demoButton);
      await settle(tester);
      expect(topPage(tester), isA<DemoPage>());
      expect(find.textContaining('not a client', skipOffstage: false), findsOneWidget);

      // "Back" from a demo returns to its service page.
      navigator(tester).pop();
      await settle(tester);
      expect((topPage(tester) as ServiceDetailPage).service.id, service.id);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('mobile drawer expands Services into the ten service pages', (tester) async {
    await pumpAt(tester, const Size(390, 844));
    await tester.tap(find.byTooltip('Open menu'));
    await settle(tester);
    final drawer = find.byType(Drawer);
    expect(find.descendant(of: drawer, matching: find.text('Students')), findsNothing);
    expect(find.descendant(of: drawer, matching: find.text('Portfolio')), findsOneWidget);
    expect(find.descendant(of: drawer, matching: find.text('Industries')), findsOneWidget);
    expect(find.descendant(of: drawer, matching: find.text('Internship')), findsOneWidget);

    await tester.tap(find.descendant(of: drawer, matching: find.text('Services')));
    await settle(tester);
    for (final s in ServicesContent.services) {
      expect(find.descendant(of: drawer, matching: find.text(s.title)), findsOneWidget);
    }
    final target = ServicesContent.services.last;
    await tester.ensureVisible(find.descendant(of: drawer, matching: find.text(target.title)));
    // ensureVisible jumps the list; lay it out before tapping the new position.
    await tester.pump();
    await tester.tap(find.descendant(of: drawer, matching: find.text(target.title)));
    await settle(tester);
    expect((topPage(tester) as ServiceDetailPage).service.id, target.id);
    expect(tester.takeException(), isNull);
  });
}

/// The router's page builders ignore their context.
class _FakeContext extends Fake implements BuildContext {}
