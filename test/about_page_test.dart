import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yodynix_website/app/yodynix_app.dart';
import 'package:yodynix_website/core/constants/asset_paths.dart';
import 'package:yodynix_website/core/constants/site_config.dart';
import 'package:yodynix_website/core/routing/app_routes.dart';
import 'package:yodynix_website/features/about/about_page_view.dart';
import 'package:yodynix_website/models/about_page.dart';
import 'package:yodynix_website/models/team_member.dart';
import 'package:yodynix_website/repositories/content/company_content.dart';
import 'package:yodynix_website/repositories/content/pillar_pages_content.dart';
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

  // A route or size animation starts on the frame after the change, so pump
  // once to start it and again to finish it.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> open(WidgetTester tester, AboutPage page) async {
    tester.state<NavigatorState>(find.byType(Navigator).first).pushNamed(page.route);
    await settle(tester);
  }

  AboutPage? shownPage(WidgetTester tester) {
    final views = find.byType(AboutPageView, skipOffstage: false).evaluate();
    return views.isEmpty ? null : (views.last.widget as AboutPageView).page;
  }

  final navAbout = find.descendant(of: find.byType(SiteNavbar), matching: find.text('About'));
  final aboutMenu = find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'About menu');

  testWidgets('every About photo is bundled and no photo repeats across the site', (tester) async {
    await tester.runAsync(AssetRegistry.instance.init);
    final about = <String>[
      AssetPaths.about,
      for (final p in CompanyContent.philosophy) p.image!,
      for (final s in CompanyContent.processSteps) ?s.image,
    ];
    final elsewhere = <String>[
      for (final p in CompanyContent.corePillars) p.image,
      for (final page in PillarPagesContent.pages) ...[
        page.heroImage,
        page.form.image,
        ?page.stepsImage,
        for (final o in page.offerings) o.image,
      ],
    ];
    for (final path in [...about, for (final page in AboutPage.values) page.image]) {
      expect(AssetRegistry.instance.resolve(path), isNotNull, reason: path);
    }
    expect(about.toSet().length, about.length, reason: 'About photos repeat');
    expect(about.toSet().intersection(elsewhere.toSet()), isEmpty);
    for (final m in [...TeamConfig.leadership, ...TeamConfig.development]) {
      expect(AssetRegistry.instance.has(m.photoPath), isTrue, reason: m.photoPath);
    }
    expect(CompanyContent.philosophy.length, 6);
    expect(CompanyContent.processSteps.where((s) => s.image != null).map((s) => s.title), [
      'Discover',
      'Plan',
      'Design',
      'Develop',
      'Test',
      'Launch',
    ]);
  });

  test('About links resolve to their pages, with Who We Are as the default', () {
    expect(AppRoutes.resolve('/about'), AboutPage.whoWeAre.route);
    expect(AppRoutes.resolve('/about/'), AboutPage.whoWeAre.route);
    expect(AppRoutes.resolve('/founder'), AboutPage.team.route);
    expect(AppRoutes.resolve('/team/'), AboutPage.team.route);
    expect(AppRoutes.resolve('/process'), AboutPage.howWeWork.route);
    for (final page in AboutPage.values) {
      expect(AboutPage.byRoute(AppRoutes.resolve(page.route)), page);
      expect(AppRoutes.sectionFor(page.route), isNull);
    }
  });

  for (final (label, size) in const [
    ('desktop', Size(1440, 900)),
    ('narrow desktop', Size(1100, 900)),
    ('tablet', Size(820, 1180)),
    ('mobile', Size(390, 844)),
  ]) {
    testWidgets('each About page renders its own content on $label', (tester) async {
      await pumpAt(tester, size);

      // The homepage keeps only a short overview linking to the four pages.
      expect(find.text(CompanyContent.processHeading), findsNothing);
      expect(find.text(TeamConfig.leadership.first.name), findsNothing);

      Future<void> expectTexts(List<String> texts) async {
        for (final text in texts) {
          final f = find.text(text);
          expect(f, findsWidgets, reason: text);
          await tester.ensureVisible(f.last);
          await tester.pump(const Duration(milliseconds: 900));
        }
      }

      await open(tester, AboutPage.whoWeAre);
      await expectTexts([CompanyContent.aboutHeading, 'Our Vision', 'Our Mission', 'Our Approach']);

      await open(tester, AboutPage.philosophy);
      await expectTexts([CompanyContent.philosophyHeading, for (final p in CompanyContent.philosophy) p.title]);

      await open(tester, AboutPage.howWeWork);
      await expectTexts([CompanyContent.processHeading, 'Discover', 'Launch']);

      await open(tester, AboutPage.team);
      final leaders = TeamConfig.leadership;
      final developers = TeamConfig.development;
      await expectTexts([
        CompanyContent.teamHeading,
        'LEADERSHIP TEAM',
        'DEVELOPMENT TEAM',
        for (final m in [...leaders, ...developers]) ...[m.name, m.designation.toUpperCase()],
      ]);
      expect(find.textContaining('Years of Industry Experience'), findsNothing);
      expect(developers.map((m) => m.name), ['Akash Balasaheb Shewale', 'Yogiraj Ashok Khalate', 'Ankita Raju Mortale']);

      // The visible frame (the clip), not the image, which a crop zoom scales.
      Rect portrait(TeamMember m) => tester.getRect(
        find
            .ancestor(
              of: find.byWidgetPredicate((w) => w is Image && (w.semanticLabel?.contains(m.name) ?? false)).last,
              matching: find.byType(ClipRRect),
            )
            .first,
      );

      // Founder and Partner portraits match exactly; so do all developers'.
      final founderPhoto = portrait(leaders[0]);
      final partnerPhoto = portrait(leaders[1]);
      void sameSize(Rect a, Rect b) {
        expect(a.width, closeTo(b.width, 0.5));
        expect(a.height, closeTo(b.height, 0.5));
      }

      sameSize(partnerPhoto, founderPhoto);
      final devPhotos = developers.map(portrait).toList();
      for (final r in devPhotos) {
        sameSize(r, devPhotos.first);
        expect(r.top, greaterThan(founderPhoto.bottom), reason: 'developers below leadership');
      }

      // Two leaders side by side except on phones; developers 3 / 2 / 1 across.
      if (size.width >= 640) {
        expect(partnerPhoto.left, greaterThan(founderPhoto.right));
        expect(partnerPhoto.top, closeTo(founderPhoto.top, 0.5));
      } else {
        expect(partnerPhoto.top, greaterThan(founderPhoto.bottom));
      }
      final devColumns = size.width >= 1024 ? 3 : (size.width >= 640 ? 2 : 1);
      expect(devPhotos.where((r) => (r.top - devPhotos.first.top).abs() < 0.5).length, devColumns);
      for (var i = 1; i < devColumns; i++) {
        expect(devPhotos[i].left, greaterThan(devPhotos[i - 1].right), reason: 'developer order');
      }
      expect(tester.takeException(), isNull);
    });
  }

  for (final (label, size, columns) in const [
    ('desktop', Size(1440, 900), 3),
    ('small desktop', Size(1024, 800), 3),
    ('tablet', Size(820, 1180), 2),
    ('mobile', Size(390, 844), 1),
  ]) {
    testWidgets('philosophy cards lay out $columns per row, equally sized, on $label', (tester) async {
      await pumpAt(tester, size);
      await open(tester, AboutPage.philosophy);
      final cards = [
        for (final p in CompanyContent.philosophy)
          find.byWidgetPredicate((w) => w is Semantics && w.properties.label == '${p.title}. ${p.description}'),
      ];
      for (final card in cards) {
        await tester.ensureVisible(card);
        await tester.pump(const Duration(milliseconds: 900));
      }
      final rects = [for (final card in cards) tester.getRect(card)];
      for (final (i, r) in rects.indexed) {
        expect(r.width, moreOrLessEquals(rects.first.width, epsilon: 0.5), reason: 'card $i width');
        expect(r.right, lessThanOrEqualTo(size.width), reason: 'card $i overflows');
        if (columns > 1) expect(r.height, moreOrLessEquals(rects.first.height, epsilon: 0.5), reason: 'card $i height');
      }
      // Cards in the same row share a top edge; the next row starts below.
      for (var i = 1; i < rects.length; i++) {
        if (i % columns == 0) {
          expect(rects[i].top, greaterThan(rects[i - 1].bottom), reason: 'card $i starts a row');
        } else {
          expect(rects[i].top, moreOrLessEquals(rects[i - 1].top, epsilon: 0.5), reason: 'card $i same row');
          expect(rects[i].left, greaterThan(rects[i - 1].right), reason: 'card $i to the right');
        }
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('About dropdown opens, lists the four pages and navigates', (tester) async {
    await pumpAt(tester, const Size(1440, 900));
    expect(aboutMenu, findsNothing);

    await tester.tap(navAbout.last);
    await settle(tester);
    expect(aboutMenu, findsOneWidget);
    for (final page in AboutPage.values) {
      expect(find.descendant(of: aboutMenu, matching: find.text(page.title)), findsOneWidget);
    }

    await tester.tap(find.descendant(of: aboutMenu, matching: find.text('Our Philosophy')));
    await settle(tester);
    expect(shownPage(tester), AboutPage.philosophy);
    expect(aboutMenu, findsNothing);

    // Tapping outside closes the menu without navigating.
    await tester.tap(navAbout.last);
    await settle(tester);
    expect(aboutMenu, findsOneWidget);
    await tester.tapAt(const Offset(700, 700));
    await settle(tester);
    expect(aboutMenu, findsNothing);
    expect(shownPage(tester), AboutPage.philosophy);

    // Clicking "About" while the menu is open goes to the default page.
    await tester.tap(navAbout.last);
    await settle(tester);
    await tester.tap(navAbout.last);
    await settle(tester);
    expect(shownPage(tester), AboutPage.defaultPage);

    // Sibling pages replace each other, so "back" always returns home.
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await settle(tester);
    expect(shownPage(tester), isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile drawer expands About into its four pages', (tester) async {
    await pumpAt(tester, const Size(390, 844));
    await tester.tap(find.byTooltip('Open menu'));
    await settle(tester);
    final drawer = find.byType(Drawer);
    expect(find.descendant(of: drawer, matching: find.text('How We Work')), findsNothing);

    await tester.tap(find.descendant(of: drawer, matching: find.text('About')));
    await settle(tester);
    for (final page in AboutPage.values) {
      expect(find.descendant(of: drawer, matching: find.text(page.title)), findsOneWidget);
    }

    await tester.tap(find.descendant(of: drawer, matching: find.text('How We Work')));
    await settle(tester);
    expect(shownPage(tester), AboutPage.howWeWork);
    expect(tester.takeException(), isNull);
  });
}
