import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yodynix_website/app/yodynix_app.dart';
import 'package:yodynix_website/features/contact/contact_form.dart';
import 'package:yodynix_website/features/expertise/expertise_page.dart';
import 'package:yodynix_website/features/expertise/expertise_section.dart';
import 'package:yodynix_website/features/home/hero_stats_bar.dart';
import 'package:yodynix_website/features/services/services_page.dart';
import 'package:yodynix_website/features/services/services_section.dart';
import 'package:yodynix_website/shared/layouts/site_navbar.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const YodynixApp());
    await tester.runAsync(GoogleFonts.pendingFonts);
    await tester.pump(const Duration(seconds: 1));
  }

  for (final (label, size) in const [('desktop', Size(1440, 900)), ('tablet', Size(820, 1180)), ('mobile', Size(390, 844))]) {
    testWidgets('homepage renders without layout errors on $label', (tester) async {
      await pumpAt(tester, size);
      expect(find.byType(HeroStatsBar), findsOneWidget);
      expect(find.byType(ContactForm), findsOneWidget);
      // About, Services, Expertise and Internship live on their own pages.
      expect(find.byType(ServicesSection), findsNothing);
      expect(find.byType(ExpertiseSection), findsNothing);
      expect(find.text('Meet Our Team'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Expertise and View all services open their own pages', (tester) async {
    await pumpAt(tester, const Size(1440, 900));
    Future<void> settle() async {
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    }

    final navbar = find.byType(SiteNavbar);
    await tester.tap(find.descendant(of: navbar, matching: find.text('Expertise')));
    await settle();
    expect(find.byType(ExpertisePage), findsOneWidget);

    await tester.tap(find.descendant(of: find.byType(SiteNavbar).last, matching: find.text('Services')).last);
    await settle();
    await tester.tap(find.text('View all services'));
    await settle();
    expect(find.byType(ServicesPage), findsOneWidget);
    expect(find.byType(ExpertisePage), findsNothing, reason: 'the Services page replaces the Expertise page');
    expect(tester.takeException(), isNull);
  });

  testWidgets('enquiry form shows validation errors when empty', (tester) async {
    await pumpAt(tester, const Size(1440, 900));
    final send = find.text('Send Enquiry');
    await tester.ensureVisible(send);
    await tester.tap(send);
    await tester.pump();
    expect(find.text('Please enter your full name'), findsOneWidget);
    expect(find.text('Please choose a service'), findsOneWidget);
    expect(find.text('Please choose how you would like us to contact you'), findsOneWidget);
  });

  testWidgets('Get Started scrolls to the contact form', (tester) async {
    await pumpAt(tester, const Size(1440, 900));
    await tester.tap(find.text('Get Started'));
    // Decorative visuals animate continuously, so pump for the scroll duration
    // instead of waiting for the tree to settle.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final top = tester.getTopLeft(find.byType(ContactForm)).dy;
    expect(top, lessThan(900));
  });

  testWidgets('client login opens the coming-soon dialog', (tester) async {
    await pumpAt(tester, const Size(1440, 900));
    await tester.tap(find.text('Client Login').first);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Client Portal: Coming Soon'), findsOneWidget);
  });
}
