import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yodynix_website/app/yodynix_app.dart';
import 'package:yodynix_website/core/constants/site_config.dart';
import 'package:yodynix_website/core/routing/app_router.dart';
import 'package:yodynix_website/core/routing/app_routes.dart';
import 'package:yodynix_website/features/home/home_page.dart';
import 'package:yodynix_website/features/internship/internship_application_form.dart';
import 'package:yodynix_website/features/internship/internship_page.dart';
import 'package:yodynix_website/features/internship/internship_program_page.dart';
import 'package:yodynix_website/models/internship_program.dart';
import 'package:yodynix_website/models/site_section.dart';
import 'package:yodynix_website/repositories/content/internship_content.dart';
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  NavigatorState navigator(WidgetTester tester) => tester.state<NavigatorState>(find.byType(Navigator).first);

  Widget pageFor(String route) {
    final built = AppRouter.onGenerateRoute(RouteSettings(name: route)) as PageRouteBuilder;
    return built.pageBuilder(_FakeContext(), kAlwaysCompleteAnimation, kAlwaysCompleteAnimation);
  }

  /// Centres [finder] in its scroll view, waits for reveals, then taps it.
  /// Leaves any text field first, so its caret scroll-into-view cannot move
  /// the page (and block pointers) mid-tap.
  Future<void> tapCentred(WidgetTester tester, Finder finder) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.tap(finder);
  }

  const slugs = [
    'flutter-development',
    'web-development',
    'ui-ux-design',
    'python-development',
    'digital-marketing',
    'ai-automation',
    'full-stack-development',
  ];

  group('routes', () {
    test('the landing page and all seven programme pages have their own routes', () {
      expect(pageFor('/internship'), isA<InternshipPage>());
      expect(pageFor('/internship/'), isA<InternshipPage>());
      expect(InternshipContent.programs.map((p) => p.slug), slugs);
      for (final slug in slugs) {
        final page = pageFor('/internship/$slug');
        expect(page, isA<InternshipProgramPage>(), reason: slug);
        expect((page as InternshipProgramPage).program.slug, slug);
      }
      expect(pageFor('/internship/not-a-program'), isA<HomePage>());
    });

    test('the retired Internship & Careers link opens the Internship page', () {
      expect(AppRoutes.resolve('/internship-careers'), AppRoutes.internship);
      expect(pageFor('/internship-careers'), isA<InternshipPage>());
      // `/internship` is a page now, not a homepage scroll link.
      expect(AppRoutes.sectionFor('/internship'), isNull);
      final initial = AppRouter.onGenerateInitialRoutes('/internship/python-development', onSectionLink: (_) {});
      expect(initial.map((r) => r.settings.name), ['/', '/internship/python-development']);
    });

    test('navigation items and order are unchanged', () {
      expect(
        [for (final s in SiteSection.values) ?s.navLabel],
        ['Home', 'About', 'Services', 'Expertise', 'Internship', 'Contact'],
      );
    });
  });

  group('content', () {
    test('each programme has its own photo and complete, programme-specific content', () {
      final images = <String>{InternshipContent.heroImage, InternshipContent.mentorImage, InternshipContent.projectImage};
      for (final p in InternshipContent.programs) {
        expect(images.add(p.image), isTrue, reason: 'photo reused: ${p.image}');
        expect(p.skills, isNotEmpty, reason: p.slug);
        expect(p.learnTopics.length, greaterThanOrEqualTo(4), reason: p.slug);
        expect(p.technologies, isNotEmpty, reason: p.slug);
        expect(p.projects.length, greaterThanOrEqualTo(3), reason: p.slug);
        expect(p.roadmapFocus.length, InternshipContent.roadmap.length, reason: p.slug);
        expect(p.whoCanApply, isNotEmpty, reason: p.slug);
        expect(p.faqs, isNotEmpty, reason: p.slug);
        expect(p.introduction, isNotEmpty, reason: p.slug);
      }
      expect(InternshipContent.roadmap.map((s) => s.title), [
        'Introduction & Orientation',
        'Fundamentals',
        'Guided Practice',
        'Practical Project',
        'Review & Improvement',
        'Final Evaluation',
      ]);
    });

    testWidgets('every internship photo is bundled', (tester) async {
      await tester.runAsync(AssetRegistry.instance.init);
      final paths = [
        InternshipContent.heroImage,
        InternshipContent.mentorImage,
        InternshipContent.projectImage,
        InternshipContent.applicationImage,
        for (final p in InternshipContent.programs) p.image,
      ];
      for (final path in paths) {
        expect(AssetRegistry.instance.resolve(path), isNotNull, reason: path);
      }
    });

    test('no terms are invented: duration is flexible, the rest is To Be Announced', () {
      expect(InternshipConfig.duration, 'Flexible');
      final values = {for (final (_, label, value) in const ProgramTerms().resolved()) label: value};
      expect(values['Duration'], 'Flexible');
      for (final label in ['Fees', 'Stipend', 'Certificate Policy']) {
        expect(values[label], toBeAnnounced, reason: label);
      }
      for (final p in InternshipContent.programs) {
        expect(p.terms.fees, isNull, reason: p.slug);
        expect(p.terms.stipend, isNull, reason: p.slug);
      }
    });
  });

  testWidgets('nav Internship opens the landing page, whose cards open each programme', (tester) async {
    await pumpAt(tester, const Size(1440, 900));
    await tester.tap(find.text('Internship').first);
    await settle(tester);
    expect(find.byType(InternshipPage), findsOneWidget);
    expect(find.text(InternshipContent.heading), findsOneWidget);
    for (final p in InternshipContent.programs) {
      expect(find.text(p.title), findsOneWidget, reason: p.title);
    }
    expect(find.text(toBeAnnounced), findsWidgets);

    await tapCentred(tester, find.text('Explore Program').at(3));
    await settle(tester);
    final page = tester.widget<InternshipProgramPage>(find.byType(InternshipProgramPage));
    expect(page.program.slug, 'python-development');
    expect(find.byType(InternshipPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a programme page shows every section and links back to the programmes', (tester) async {
    await pumpAt(tester, const Size(1440, 900));
    navigator(tester).pushNamed('/internship/ui-ux-design');
    await settle(tester);
    final program = InternshipContent.bySlug('ui-ux-design')!;
    expect(find.text(program.title), findsOneWidget);
    for (final heading in [
      'Introduction',
      'What You Will Learn',
      'Skills & Technologies',
      'Learning Methodology',
      'Mentor-Guided Learning',
      'Practical Project-Based Learning',
      'Project Examples',
      'Learning Roadmap',
      'Who Can Apply',
      'Flexible Duration',
      'Free Internship Opportunities',
      'Paid Internship Opportunities',
      'FAQ',
    ]) {
      expect(find.textContaining(RegExp('^${RegExp.escape(heading)}\$', caseSensitive: false)), findsWidgets, reason: heading);
    }
    for (final project in program.projects) {
      expect(find.text(project.title), findsOneWidget);
    }
    expect(find.text('Practice Project'), findsNWidgets(program.projects.length));

    await tester.tap(find.text('Back to Internship Programs').first);
    await settle(tester);
    expect(find.byType(InternshipPage), findsOneWidget);
    expect(find.byType(InternshipProgramPage), findsNothing);

    // Back from the landing page returns home.
    navigator(tester).pop();
    await settle(tester);
    expect(find.byType(InternshipPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final (label, size) in const [('desktop', Size(1440, 900)), ('mobile', Size(390, 844))]) {
    testWidgets('application form validates and never fakes success on $label', (tester) async {
      await pumpAt(tester, size);
      navigator(tester).pushNamed('/internship/web-development');
      await settle(tester);

      final form = find.byType(InternshipApplicationForm);
      Finder inForm(Finder f) => find.descendant(of: form, matching: f);
      expect(inForm(find.text('Online applications are not connected yet')), findsOneWidget);
      // The programme is pre-selected on its own page.
      expect(inForm(find.text('Web Development')), findsOneWidget);

      final submit = inForm(find.text(InternshipConfig.applicationsOpen ? 'Submit Application' : 'Register Interest'));
      await tapCentred(tester, submit);
      await tester.pump();
      for (final error in [
        'Please enter your full name',
        'Please enter your email address',
        'Please enter your mobile number',
        'Please enter your college or institution',
        'Please select your current education',
        'Please choose free or paid',
      ]) {
        expect(find.text(error), findsOneWidget, reason: error);
      }

      await tester.enterText(inForm(find.widgetWithText(TextFormField, 'Full Name *')), 'Asha Patel');
      await tester.enterText(inForm(find.widgetWithText(TextFormField, 'Email Address *')), 'asha@example');
      await tester.enterText(inForm(find.widgetWithText(TextFormField, 'Mobile Number *')), '98765');
      await tester.enterText(inForm(find.widgetWithText(TextFormField, 'College / Institution *')), 'Pune University');
      await tapCentred(tester, submit);
      await tester.pump();
      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(find.text('Please enter a valid mobile number'), findsOneWidget);

      await tester.enterText(inForm(find.widgetWithText(TextFormField, 'Email Address *')), 'asha@example.com');
      await tester.enterText(inForm(find.widgetWithText(TextFormField, 'Mobile Number *')), '+91 98765 43210');
      await tapCentred(tester, inForm(find.text('Current Education *')));
      await settle(tester);
      await tester.tap(find.text(InternshipContent.educationOptions[1]).last);
      await settle(tester);
      await tapCentred(tester, inForm(find.text('Free Internship')));
      await tester.pump();

      await tapCentred(tester, submit);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining('Not sent'), findsOneWidget);
      expect(find.textContaining('Thank you'), findsNothing);
      expect(find.textContaining('has been received'), findsNothing);
      // Nothing was sent, so the details stay in the form.
      expect(find.text('Asha Patel'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

/// The router's page builders ignore their context.
class _FakeContext extends Fake implements BuildContext {}
