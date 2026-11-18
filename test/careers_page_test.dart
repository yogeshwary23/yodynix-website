import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yodynix_website/app/yodynix_app.dart';
import 'package:yodynix_website/core/constants/site_config.dart';
import 'package:yodynix_website/core/routing/app_router.dart';
import 'package:yodynix_website/core/routing/app_routes.dart';
import 'package:yodynix_website/core/theme/app_theme.dart';
import 'package:yodynix_website/features/careers/careers_application_form.dart';
import 'package:yodynix_website/features/careers/careers_page.dart';
import 'package:yodynix_website/models/contact_enquiry.dart';
import 'package:yodynix_website/models/site_section.dart';
import 'package:yodynix_website/repositories/contact_repository.dart';
import 'package:yodynix_website/repositories/content/careers_content.dart';
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

  Widget pageFor(String route) {
    final built = AppRouter.onGenerateRoute(RouteSettings(name: route)) as PageRouteBuilder;
    return built.pageBuilder(_FakeContext(), kAlwaysCompleteAnimation, kAlwaysCompleteAnimation);
  }

  const titles = ['Flutter Developer', 'Junior Flutter Developer', 'Mobile App Developer', 'Web Developer'];

  group('routes and content', () {
    test('Careers replaces Internship in the navigation', () {
      expect(SiteSection.careers.navLabel, 'Careers');
      expect([for (final s in SiteSection.values) ?s.navLabel], isNot(contains('Internship')));
    });

    test('/careers and every former internship link open the Careers page', () {
      for (final r in [
        '/careers',
        '/careers/',
        '/internship',
        '/internship/',
        '/internships',
        '/internship-careers',
        '/internship/flutter-development',
        '/jobs',
      ]) {
        expect(AppRoutes.resolve(r), AppRoutes.careers, reason: r);
        expect(pageFor(r), isA<CareersPage>(), reason: r);
      }
    });

    test('exactly four professional openings, each with skills', () {
      expect(CareersContent.openings.map((o) => o.title), titles);
      expect(CareersContent.openings.map((o) => o.id).toSet(), hasLength(4));
      for (final o in CareersContent.openings) {
        expect(o.skills, isNotEmpty, reason: o.title);
        expect(o.summary.toLowerCase(), isNot(contains('intern')), reason: o.title);
      }
    });

    test('contact details: one official number and the new address', () {
      expect(ContactConfig.phones, ['+91 97661 82320']);
      expect(ContactConfig.phones.join().replaceAll(RegExp(r'\D'), ''), isNot(contains('7448049320')));
      expect(ContactConfig.address, 'Yashada Supreme, 8th Floor, Office No. 802, Moshi, Pune – 412105, Maharashtra, India.');
      expect(Uri.parse(ContactConfig.directionsUrl).queryParameters['destination'], ContactConfig.address);
    });
  });

  for (final (label, size) in const [('desktop', Size(1440, 900)), ('mobile', Size(390, 844))]) {
    testWidgets('Careers page shows four job cards and Apply Now pre-selects the role on $label', (tester) async {
      await pumpAt(tester, size);
      tester.state<NavigatorState>(find.byType(Navigator).first).pushNamed(AppRoutes.careers);
      await settle(tester);

      expect(find.byType(CareersPage), findsOneWidget);
      expect(find.text(CareersContent.heading), findsOneWidget);
      expect(find.byType(JobOpeningCard, skipOffstage: false), findsNWidgets(4));
      for (final t in titles) {
        expect(
          find.descendant(of: find.byType(JobOpeningCard, skipOffstage: false), matching: find.text(t, skipOffstage: false)),
          findsOneWidget,
          reason: t,
        );
      }
      // Nothing on the page presents these roles as internships.
      expect(
        find.descendant(
          of: find.byType(CareersPage),
          matching: find.textContaining(RegExp(r'intern', caseSensitive: false), skipOffstage: false),
        ),
        findsNothing,
      );

      // "Apply Now" on the third card selects Mobile App Developer in the form.
      final apply = find.descendant(
        of: find.byType(JobOpeningCard, skipOffstage: false).at(2),
        matching: find.text('Apply Now', skipOffstage: false),
      );
      Scrollable.ensureVisible(tester.element(apply), alignment: 0.5);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      await tester.tap(apply);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      final form = find.byType(CareersApplicationForm);
      expect(find.descendant(of: form, matching: find.text('Mobile App Developer')), findsOneWidget);
      // The form is scrolled into view.
      final formTop = tester.getTopLeft(form).dy;
      expect(formTop, lessThan(size.height));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('application form validates, then submits the chosen role through the enquiry backend', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repository = _RecordingRepository();
    final selection = ValueNotifier<String?>('web-developer');
    addTearDown(selection.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: CareersApplicationForm(selection: selection, repository: repository),
          ),
        ),
      ),
    );
    await tester.runAsync(GoogleFonts.pendingFonts);
    await tester.pump();

    expect(find.text('Web Developer'), findsOneWidget);
    await tester.tap(find.text('Submit Application'));
    await tester.pump();
    for (final error in [
      'Please enter your full name',
      'Please enter your email address',
      'Please enter your mobile number',
      'Please select your experience',
      'Please tell us a little about yourself',
    ]) {
      expect(find.text(error), findsOneWidget, reason: error);
    }
    expect(repository.sent, isEmpty);

    await tester.enterText(find.widgetWithText(TextFormField, 'Full Name *'), 'Asha Patel');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email Address *'), 'asha@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Mobile Number *'), '+91 98765 43210');
    await tester.enterText(find.widgetWithText(TextFormField, 'Résumé / Portfolio Link'), 'github.com/asha');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'About You *'),
      'Three years building responsive websites with Flutter Web.',
    );
    await tester.tap(find.text('Professional Experience *'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1–3 years').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit Application'));
    await tester.pumpAndSettle();
    expect(repository.sent, hasLength(1));
    final sent = repository.sent.single;
    expect(sent.service, 'Careers Application: Web Developer');
    expect(sent.description, contains('Experience: 1–3 years'));
    expect(sent.description, contains('github.com/asha'));
    expect(sent.preferredContactMethod, 'Email');
    expect(find.text('Application Submitted'), findsOneWidget);
    // A confirmed send clears the form for the next applicant.
    expect(selection.value, isNull);
    expect(tester.takeException(), isNull);
  });
}

class _RecordingRepository implements ContactRepository {
  final sent = <ContactEnquiry>[];

  @override
  Future<SubmissionResult> submit(ContactEnquiry enquiry) async {
    sent.add(enquiry);
    return const SubmissionResult(SubmissionStatus.success);
  }
}

/// The router's page builders ignore their context.
class _FakeContext extends Fake implements BuildContext {}
