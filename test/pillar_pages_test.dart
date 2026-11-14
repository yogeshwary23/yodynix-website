import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yodynix_website/app/yodynix_app.dart';
import 'package:yodynix_website/core/routing/app_router.dart';
import 'package:yodynix_website/features/internship/internship_page.dart';
import 'package:yodynix_website/features/pillars/pillar_detail_page.dart';
import 'package:yodynix_website/features/pillars/pillar_enquiry_form.dart';
import 'package:yodynix_website/repositories/content/company_content.dart';
import 'package:yodynix_website/repositories/content/pillar_pages_content.dart';
import 'package:yodynix_website/services/asset_registry.dart';

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
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  test('every pillar card links to a detail page with a unique set of photos', () {
    final images = <String>{};
    for (final pillar in CompanyContent.corePillars) {
      if (pillar.route == '/internship') continue; // Its own page; see internship_pages_test.
      final page = PillarPagesContent.byRoute(pillar.route);
      expect(page, isNotNull, reason: pillar.route);
      expect(images.add(pillar.image), isTrue, reason: pillar.image);
      expect(images.add(page!.heroImage), isTrue, reason: page.heroImage);
      for (final o in page.offerings) {
        expect(images.add(o.image), isTrue, reason: o.image);
      }
    }
    expect(PillarPagesContent.pages.map((p) => p.route).toSet(), {'/business-solutions', '/technology-innovation'});
    expect(CompanyContent.corePillars.map((p) => p.route), contains('/internship'));
  });

  testWidgets('every referenced pillar photo is bundled', (tester) async {
    await tester.runAsync(AssetRegistry.instance.init);
    final paths = <String>[
      for (final p in CompanyContent.corePillars) p.image,
      for (final page in PillarPagesContent.pages) ...[
        page.heroImage,
        page.form.image,
        ?page.stepsImage,
        for (final o in page.offerings) o.image,
      ],
    ];
    for (final path in paths) {
      expect(AssetRegistry.instance.resolve(path), isNotNull, reason: path);
    }
  });

  testWidgets('direct URL load keeps the homepage underneath for back navigation', (tester) async {
    final routes = AppRouter.onGenerateInitialRoutes('/business-solutions', onSectionLink: (_) {});
    expect(routes.map((r) => r.settings.name), ['/', '/business-solutions']);
    // The retired Internship & Careers page now opens the Internship page.
    final retired = AppRouter.onGenerateInitialRoutes('/internship-careers', onSectionLink: (_) {});
    expect(retired.map((r) => r.settings.name), ['/', '/internship']);
    final trailing = AppRouter.onGenerateInitialRoutes('/business-solutions/', onSectionLink: (_) {});
    expect(trailing.length, 2);
  });

  for (final pillar in CompanyContent.corePillars) {
    testWidgets('clicking "${pillar.title}" opens its page and back returns home', (tester) async {
      await pumpAt(tester, const Size(1440, 900));
      final card = find.bySemanticsLabel(RegExp(RegExp.escape(pillar.title)));
      await tester.ensureVisible(find.text(pillar.headline));
      await tester.pump(const Duration(milliseconds: 900));
      await tester.tap(find.text(pillar.headline));
      await settle(tester);
      final page = PillarPagesContent.byRoute(pillar.route);
      if (page == null) {
        expect(find.byType(InternshipPage), findsOneWidget);
      } else {
        expect(find.byType(PillarDetailPage), findsOneWidget);
        expect(find.text(page.heroHeading), findsOneWidget);
        expect(card, findsWidgets); // Related pillars link onward.
      }

      await tester.tap(find.text('Home').first);
      await settle(tester);
      expect(find.byType(PillarDetailPage), findsNothing);
      expect(find.byType(InternshipPage), findsNothing);
    });
  }

  testWidgets('offering CTA pre-selects the option and an honest result is shown', (tester) async {
    await pumpAt(tester, const Size(1440, 900));
    tester.state<NavigatorState>(find.byType(Navigator).first).pushNamed('/business-solutions');
    await settle(tester);

    final cta = find.text('Enquire About Business Automation');
    await tester.ensureVisible(cta);
    await tester.pump(const Duration(milliseconds: 1500));
    // Bring the button clear of the navbar and let its reveal finish.
    final page = find.descendant(of: find.byType(PillarDetailPage), matching: find.byType(Scrollable)).first;
    await tester.drag(page, const Offset(0, 300));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.tap(cta);
    await settle(tester);
    final form = find.byType(PillarEnquiryForm);
    expect(tester.getTopLeft(form).dy, lessThan(900));
    expect(find.descendant(of: form, matching: find.text('Business Automation')), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Full Name *'), 'Asha Patel');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email *'), 'asha@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Phone *'), '+91 98765 43210');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Project Details *'),
      'We want to automate invoice reminders for our store.',
    );
    final send = find.text('Send Project Enquiry');
    await tester.ensureVisible(send);
    await tester.tap(send);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('has not been sent yet'), findsOneWidget);
  });
}
