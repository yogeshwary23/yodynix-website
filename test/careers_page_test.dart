import 'dart:typed_data';

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
import 'package:yodynix_website/models/contact_enquiry.dart' show SubmissionResult, SubmissionStatus;
import 'package:yodynix_website/models/job_application.dart';
import 'package:yodynix_website/models/site_section.dart';
import 'package:yodynix_website/repositories/careers_repository.dart';
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

  const titles = ['Flutter Developer', 'Mobile App Developer', 'Web Developer', 'Full Stack Developer'];
  const internshipTitles = ['Flutter Development Intern', 'Mobile App Development Intern', 'Web Development Intern', 'UI/UX Design Intern'];

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

    test('four jobs and four separate internships, each with skills and eligibility', () {
      expect(CareersContent.openings.map((o) => o.title), titles);
      expect(CareersContent.internships.map((o) => o.title), internshipTitles);
      expect(CareersContent.allOpenings.map((o) => o.id).toSet(), hasLength(8));
      for (final o in CareersContent.openings) {
        expect(o.kind, OpeningKind.job, reason: o.title);
        expect(o.employmentType, isNotNull, reason: o.title);
        expect(o.internshipDuration, isNull, reason: o.title);
        expect(o.summary.toLowerCase(), isNot(contains('intern')), reason: o.title);
      }
      for (final o in CareersContent.internships) {
        expect(o.kind, OpeningKind.internship, reason: o.title);
        expect(o.internshipDuration, CareersContent.internshipDuration, reason: o.title);
      }
      for (final o in CareersContent.allOpenings) {
        expect(o.skills, isNotEmpty, reason: o.title);
        expect(o.eligibility, isNotEmpty, reason: o.title);
      }
    });

    test('no pay, stipend or placement claims anywhere in the careers copy', () {
      final copy = [
        CareersContent.description,
        CareersContent.openingsLead,
        CareersContent.jobsLead,
        CareersContent.internshipsLead,
        CareersContent.applicationLead,
        for (final (_, h) in CareersContent.highlights) h,
        for (final (_, t, d) in CareersContent.benefits) '$t $d',
        for (final s in CareersContent.hiringProcess) '${s.title} ${s.description}',
        for (final o in CareersContent.allOpenings) '${o.title} ${o.summary} ${o.eligibility} ${o.employmentType ?? ''}',
      ].join(' ').toLowerCase();
      for (final word in ['salary', 'stipend', 'paid', 'placement', 'guarantee', 'ctc', 'lpa', '₹']) {
        expect(copy, isNot(contains(word)), reason: word);
      }
    });

    test('server refusals become specific messages for the applicant', () {
      String msg(int status, Object? body) => ApiCareersRepository.failureMessage(status, body);
      expect(msg(409, {'ok': false, 'error': 'duplicate_application'}), contains('already applied'));
      expect(msg(429, {'ok': false, 'error': 'rate_limited'}), contains('wait a minute'));
      expect(msg(413, {'ok': false, 'error': 'payload_too_large'}), contains('5 MB'));
      expect(
        msg(400, {
          'ok': false,
          'error': 'validation_failed',
          'fields': {'resume': 'Résumé content does not match its file type'},
        }),
        contains('Résumé content does not match its file type'),
      );
      expect(msg(404, {'ok': false, 'error': 'not_found'}), contains('temporarily unavailable'));
      expect(msg(500, {'ok': false, 'error': 'storage_failed'}), contains('could not save'));
      expect(msg(502, null), contains('(502)'));
    });

    test('résumé checks: type and size', () {
      ResumeFile file(String name, int size) => ResumeFile(name: name, bytes: Uint8List(size));
      expect(file('cv.pdf', 10).problem, isNull);
      expect(file('CV.DOCX', 10).problem, isNull);
      expect(file('cv.doc', 10).problem, isNull);
      expect(file('cv.png', 10).problem, isNotNull);
      expect(file('cv.pdf', 0).problem, isNotNull);
      expect(file('cv.pdf', ResumeFile.maxBytes + 1).problem, isNotNull);
    });

    test('contact details: one official number and the new address', () {
      expect(ContactConfig.phones, ['+91 97661 82320']);
      expect(ContactConfig.phones.join().replaceAll(RegExp(r'\D'), ''), isNot(contains('7448049320')));
      expect(ContactConfig.address, 'Yashada Supreme, 8th Floor, Office No. 802, Moshi, Pune – 412105, Maharashtra, India.');
      expect(Uri.parse(ContactConfig.directionsUrl).queryParameters['destination'], ContactConfig.address);
    });
  });

  for (final (label, size) in const [('desktop', Size(1440, 900)), ('mobile', Size(390, 844))]) {
    testWidgets('Careers tabs switch between jobs and internships, and Apply opens the form on $label', (tester) async {
      await pumpAt(tester, size);
      tester.state<NavigatorState>(find.byType(Navigator).first).pushNamed(AppRoutes.careers);
      await settle(tester);

      expect(find.byType(CareersPage), findsOneWidget);
      expect(find.text(CareersContent.heading), findsOneWidget);
      Finder cardTitle(String t) =>
          find.descendant(of: find.byType(JobOpeningCard, skipOffstage: false), matching: find.text(t, skipOffstage: false));

      // Jobs first.
      expect(find.byType(JobOpeningCard, skipOffstage: false), findsNWidgets(4));
      for (final t in titles) {
        expect(cardTitle(t), findsOneWidget, reason: t);
      }
      expect(find.text('Apply for Internship', skipOffstage: false), findsNothing);

      // Switch to internships.
      final tab = find.textContaining('Internship', skipOffstage: false).first;
      Scrollable.ensureVisible(tester.element(tab), alignment: 0.3);
      await tester.pump(const Duration(milliseconds: 900));
      await tester.tap(find.descendant(of: find.byType(OpeningsTabs), matching: find.textContaining('Internship')).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      expect(find.byType(JobOpeningCard, skipOffstage: false), findsNWidgets(4));
      for (final t in internshipTitles) {
        expect(cardTitle(t), findsOneWidget, reason: t);
      }
      expect(find.text('Duration: ${CareersContent.internshipDuration}', skipOffstage: false), findsNWidgets(4));

      // "Apply for Internship" on the last card opens the form with it filled in.
      final apply = find.descendant(
        of: find.byType(JobOpeningCard, skipOffstage: false).at(3),
        matching: find.text('Apply for Internship', skipOffstage: false),
      );
      Scrollable.ensureVisible(tester.element(apply), alignment: 0.5);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      await tester.tap(apply);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      final form = find.byWidgetPredicate((w) => w is CareersApplicationForm && w.fixedPosition);
      expect(form, findsOneWidget);
      expect(find.descendant(of: form, matching: find.text('Internship Application')), findsOneWidget);
      final position = tester.widget<TextField>(
        find.descendant(
          of: find.descendant(of: form, matching: find.widgetWithText(TextFormField, 'Position Applied For')),
          matching: find.byType(TextField),
        ),
      );
      expect(position.controller!.text, 'UI/UX Design Intern');
      expect(position.readOnly, isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Apply buttons are separate, pressable accessibility nodes', (tester) async {
    final semantics = tester.ensureSemantics();
    var applied = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          // The card fills its grid cell, so it needs a bounded height.
          body: SizedBox(
            height: 900,
            child: JobOpeningCard(opening: CareersContent.internships.first, onApply: () => applied++),
          ),
        ),
      ),
    );
    await tester.pump();
    final button = find.bySemanticsLabel('Apply for Internship');
    expect(button, findsOneWidget);
    expect(
      tester.getSemantics(button),
      matchesSemantics(label: 'Apply for Internship', isButton: true, hasEnabledState: true, isEnabled: true, hasTapAction: true),
    );
    tester.semantics.tap(find.semantics.byLabel('Apply for Internship'));
    expect(applied, 1);
    semantics.dispose();
  });

  testWidgets('application form validates every field, then sends the application with the résumé', (tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repository = _RecordingRepository();
    final selection = ValueNotifier<String?>('web-developer');
    addTearDown(selection.dispose);
    var resume = ResumeFile(name: 'photo.png', bytes: Uint8List(100));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: CareersApplicationForm(selection: selection, repository: repository, pickResume: () async => resume),
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
      'Please enter your education',
      'Please list your relevant skills',
      'Please upload your résumé',
    ]) {
      expect(find.text(error), findsOneWidget, reason: error);
    }
    expect(repository.sent, isEmpty);

    // Format checks.
    await tester.enterText(find.widgetWithText(TextFormField, 'Email Address *'), 'asha@');
    await tester.enterText(find.widgetWithText(TextFormField, 'Mobile Number *'), '98765');
    await tester.pump();
    expect(find.text('Please enter a valid email address'), findsOneWidget);
    expect(find.text('Please enter a valid mobile number'), findsOneWidget);

    // A file of the wrong type is refused.
    await tester.tap(find.text('Upload'));
    await tester.pump();
    expect(find.text('Please upload a PDF, DOC or DOCX file'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove résumé'));
    await tester.pump();
    resume = ResumeFile(name: 'Asha CV.pdf', bytes: Uint8List(2048));
    await tester.tap(find.text('Upload'));
    await tester.pump();
    expect(find.text('Asha CV.pdf'), findsOneWidget);
    expect(find.text('PDF · 2 KB'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Full Name *'), 'Asha Patel');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email Address *'), 'asha@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Mobile Number *'), '+91 98765 43210');
    await tester.enterText(find.widgetWithText(TextFormField, 'Education *'), 'B.E. Computer Engineering, 2025');
    await tester.enterText(find.widgetWithText(TextFormField, 'Relevant Skills *'), 'HTML, CSS, JavaScript, Flutter Web');
    await tester.enterText(find.widgetWithText(TextFormField, 'Additional Message'), 'Portfolio: github.com/asha');

    await tester.tap(find.text('Submit Application'));
    await tester.pumpAndSettle();
    expect(repository.sent, hasLength(1));
    final sent = repository.sent.single;
    expect(sent.kind, OpeningKind.job);
    expect(sent.position, 'Web Developer');
    expect(sent.education, 'B.E. Computer Engineering, 2025');
    expect(sent.resume.name, 'Asha CV.pdf');
    expect(sent.toFields()['kind'], 'job');
    expect(sent.submissionId, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')));
    expect(sent.toFields()['submissionId'], sent.submissionId);
    expect(find.text('Application Submitted'), findsOneWidget);
    // Mentioned only because the server reported the confirmation as sent.
    expect(find.textContaining('A confirmation has been sent to asha@example.com.'), findsOneWidget);
    // A confirmed send clears the form for the next applicant.
    expect(selection.value, isNull);
    expect(tester.takeException(), isNull);
  });
}

class _RecordingRepository implements CareersRepository {
  final sent = <JobApplication>[];

  @override
  Future<SubmissionResult> submit(JobApplication application) async {
    sent.add(application);
    return const SubmissionResult(SubmissionStatus.success, null, true);
  }
}

/// The router's page builders ignore their context.
class _FakeContext extends Fake implements BuildContext {}
