import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yodynix_website/app/yodynix_app.dart';
import 'package:yodynix_website/features/expertise/expertise_page.dart';
import 'package:yodynix_website/features/industries/industries_page.dart';
import 'package:yodynix_website/features/portfolio/portfolio_page.dart';
import 'package:yodynix_website/repositories/content/expertise_content.dart';
import 'package:yodynix_website/repositories/content/industries_content.dart';
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
    expect(find.text('All projects shown are demonstration projects built by YODYNIX, not client work.'), findsOneWidget);
    expect(find.text('Placeholder copy: replace before launch'), findsOneWidget);

    // Every sample project from the service pages is listed once.
    final projects = [for (final s in ServicesContent.services) ...ServicePagesContent.of(s).projects];
    for (final p in projects) {
      expect(find.text(p.name, skipOffstage: false), findsAtLeastNWidgets(1), reason: p.name);
    }

    // Filtering by a service shows only its projects.
    final service = ServicesContent.services.first;
    final chip = find.widgetWithText(ChoiceChip, service.title, skipOffstage: false);
    await tester.ensureVisible(chip);
    await tester.tap(chip);
    await settle(tester);
    final other = ServicePagesContent.of(ServicesContent.services[1]).projects.first;
    expect(find.text(other.name, skipOffstage: false), findsNothing);
    for (final p in ServicePagesContent.of(service).projects) {
      expect(find.text(p.name, skipOffstage: false), findsAtLeastNWidgets(1));
    }
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

  testWidgets('Industries page lists every sector with its placeholder marker', (tester) async {
    await pumpAt(tester, const Size(1440, 900));
    await tester.tap(find.descendant(of: find.byType(SiteNavbar), matching: find.text('Industries')));
    await settle(tester);
    expect(find.byType(IndustriesPage), findsOneWidget);
    expect(find.text('Placeholder copy: replace before launch'), findsOneWidget);
    for (final i in IndustriesContent.industries) {
      expect(find.text(i.name, skipOffstage: false), findsAtLeastNWidgets(1), reason: i.name);
      for (final id in i.serviceIds) {
        expect(ServicesContent.services.any((s) => s.id == id), isTrue, reason: '${i.id} → $id');
      }
    }
  });
}
