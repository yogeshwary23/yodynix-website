import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yodynix_website/app/yodynix_app.dart';
import 'package:yodynix_website/core/routing/app_routes.dart';
import 'package:yodynix_website/features/expertise/expertise_page.dart';
import 'package:yodynix_website/features/industries/industries_page.dart';
import 'package:yodynix_website/features/portfolio/portfolio_page.dart';
import 'package:yodynix_website/features/portfolio/portfolio_widgets.dart';
import 'package:yodynix_website/features/portfolio/project_detail_page.dart';
import 'package:yodynix_website/repositories/content/expertise_content.dart';
import 'package:yodynix_website/repositories/content/industries_content.dart';
import 'package:yodynix_website/repositories/content/portfolio_content.dart';
import 'package:yodynix_website/repositories/content/service_pages_content.dart';
import 'package:yodynix_website/repositories/content/services_content.dart';
import 'package:yodynix_website/services/asset_registry.dart';
import 'package:yodynix_website/shared/layouts/site_navbar.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  void expectNoPlaceholders() {
    expect(find.textContaining('[Placeholder]', skipOffstage: false), findsNothing);
    expect(find.textContaining(RegExp('placeholder', caseSensitive: false), skipOffstage: false), findsNothing);
  }

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
    await tester.pump(const Duration(milliseconds: 800));
  }

  for (final (label, size) in const [('desktop', Size(1440, 900)), ('mobile', Size(390, 844))]) {
    testWidgets('Expertise opens on Our Expertise, with no AI & Technology hero, on $label', (tester) async {
      await pumpAt(tester, size);
      tester.state<NavigatorState>(find.byType(Navigator).first).pushNamed('/expertise');
      await settle(tester);
      final page = find.byType(ExpertisePage);
      expect(page, findsOneWidget);
      Finder onPage(Finder f) => find.descendant(of: page, matching: f);
      expect(onPage(find.text('Intelligence, Applied With Care.', skipOffstage: false)), findsNothing);
      expect(onPage(find.textContaining(RegExp('AI & Technology', caseSensitive: false), skipOffstage: false)), findsNothing);
      // The page now opens straight on the Our Expertise heading, in view.
      final heading = onPage(find.text(ExpertiseContent.heading));
      expect(heading, findsOneWidget);
      expect(tester.getTopLeft(heading).dy, lessThan(size.height * 0.6));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Portfolio opens from the navbar and labels every project as a demonstration', (tester) async {
    await pumpAt(tester, const Size(1440, 900));
    await tester.tap(find.descendant(of: find.byType(SiteNavbar), matching: find.text('Portfolio')));
    await settle(tester);
    expect(find.byType(PortfolioPage), findsOneWidget);
    expect(find.text(PortfolioContent.disclosure), findsOneWidget);
    expectNoPlaceholders();

    // Every sample project from the service pages is listed once, with a
    // case study, and only working demos claim technologies.
    final projects = [for (final s in ServicesContent.services) ...ServicePagesContent.of(s).projects];
    for (final p in projects) {
      expect(find.text(p.name, skipOffstage: false), findsAtLeastNWidgets(1), reason: p.name);
      final study = PortfolioContent.of(p.id);
      expect(study, isNotNull, reason: p.id);
      if (!p.hasDemo) expect(study!.technologies, isEmpty, reason: p.id);
    }
    expect(PortfolioContent.caseStudies.keys.toSet(), {for (final p in projects) p.id});

    // Status filter: concepts only.
    await tester.ensureVisible(find.text('Concepts', skipOffstage: false));
    await tester.tap(find.text('Concepts'));
    await settle(tester);
    final demo = projects.firstWhere((p) => p.hasDemo && p.name != projects.firstWhere((p) => p.hasDemo).name);
    expect(find.text(demo.name, skipOffstage: false), findsNothing);
    await tester.tap(find.text('All projects'));
    await settle(tester);

    // Each area filter shows only the projects of its services.
    Finder onPage(Finder f) => find.descendant(of: find.byType(PortfolioPage), matching: f);
    for (final (label, ids) in PortfolioContent.filters.skip(1)) {
      final pill = onPage(find.text(label, skipOffstage: false)).first;
      await tester.ensureVisible(pill);
      await tester.tap(pill);
      await settle(tester);
      for (final s in ServicesContent.services) {
        for (final p in ServicePagesContent.of(s).projects) {
          expect(onPage(find.text(p.name, skipOffstage: false)), ids.contains(s.id) ? findsOneWidget : findsNothing, reason: '$label: ${p.name}');
        }
      }
    }

    // A card opens the project's own page; Back returns to the Portfolio.
    final mobile = ServicePagesContent.of(ServicesContent.services.firstWhere((s) => s.id == 'mobile_app_development')).projects;
    final concept = mobile.firstWhere((p) => !p.hasDemo);
    await tester.tap(onPage(find.text('Mobile Applications', skipOffstage: false)));
    await settle(tester);
    final card = find.text(concept.name, skipOffstage: false);
    await tester.ensureVisible(card);
    await tester.tap(card);
    await settle(tester);
    expect(find.byType(ProjectDetailPage), findsOneWidget);
    expect(find.text('Open Working Demo'), findsNothing);
    expect(find.text('Request Demo', skipOffstage: false), findsWidgets);
    expect(find.descendant(of: find.byType(ProjectDetailPage), matching: find.text(PortfolioContent.of(concept.id)!.objective, skipOffstage: false)), findsOneWidget);
    expect(find.text('Back to Portfolio', skipOffstage: false), findsWidgets);
    await tester.tap(find.text('Back to Portfolio').first);
    await settle(tester);
    expect(find.byType(ProjectDetailPage), findsNothing);
    expect(find.byType(PortfolioPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets("a working demo's project page offers the demo", (tester) async {
    await pumpAt(tester, const Size(1440, 900));
    final demo = ServicePagesContent.allProjects.firstWhere((p) => p.hasDemo);
    tester.state<NavigatorState>(find.byType(Navigator).first).pushNamed(AppRoutes.project(demo.slug));
    await settle(tester);
    expect((tester.widget(find.byType(ProjectDetailPage)) as ProjectDetailPage).project.id, demo.id);
    expect(find.text('Open Working Demo'), findsOneWidget);
    expectNoPlaceholders();
    expect(tester.takeException(), isNull);
  });

  testWidgets('every portfolio project has its own full-colour visual', (tester) async {
    await tester.runAsync(AssetRegistry.instance.init);
    final images = <String>[];
    for (final p in ServicePagesContent.allProjects) {
      final study = PortfolioContent.of(p.id)!;
      expect(p.coverPhoto, isNotNull, reason: p.id);
      images.add(p.coverPhoto!);
      // Working demos show their real screenshot on a device; concepts never
      // claim a screen.
      expect(study.device != null, p.hasDemo, reason: p.id);
      if (p.hasDemo) {
        expect(p.deviceStill, isNotNull, reason: p.id);
        expect(study.photo, isNotNull, reason: p.id);
        images.add(AssetRegistry.instance.resolve(p.image)!);
      }
    }
    expect(images.toSet(), hasLength(images.length), reason: 'no image is used twice');
  });

  test('industry categories: the four required sectors are separate, with no duplicates', () {
    final names = [for (final i in IndustriesContent.industries) i.name];
    expect(names.toSet(), hasLength(names.length));
    expect({for (final i in IndustriesContent.industries) i.id}, hasLength(names.length));
    for (final n in ['Financial Services', 'Oil & Gas', 'Retail & Logistics', 'E-commerce']) {
      expect(names, contains(n));
    }
    for (final old in ['Finance & Professional Services', 'Retail & E-commerce', 'E-commerce & Retail']) {
      expect(names, isNot(contains(old)));
    }
  });

  testWidgets('Industries page lists all eight sectors, each with its own photograph', (tester) async {
    await pumpAt(tester, const Size(1440, 900));
    await tester.tap(find.descendant(of: find.byType(SiteNavbar), matching: find.text('Industries')));
    await settle(tester);
    expect(find.byType(IndustriesPage), findsOneWidget);
    expect(find.text(IndustriesContent.lead), findsOneWidget);
    expectNoPlaceholders();
    expect(IndustriesContent.industries, hasLength(8));
    final photos = [for (final i in IndustriesContent.industries) AssetRegistry.instance.resolve(i.photo)];
    expect(photos, everyElement(isNotNull));
    expect(photos.toSet(), hasLength(photos.length), reason: 'no photograph is reused');
    for (final i in IndustriesContent.industries) {
      expect(i.solutions, hasLength(5), reason: i.id);
      expect(find.text(i.summary, skipOffstage: false), findsOneWidget, reason: i.id);
      expect(find.text(i.name, skipOffstage: false), findsAtLeastNWidgets(1), reason: i.name);
      for (final id in i.serviceIds) {
        expect(ServicesContent.services.any((s) => s.id == id), isTrue, reason: '${i.id} → $id');
      }
    }
  });
}
