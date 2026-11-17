import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yodynix_website/app/yodynix_app.dart';
import 'package:yodynix_website/features/contact/contact_form.dart';

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
      expect(find.text('Meet Our Team'), findsOneWidget);
      expect(find.byType(ContactForm), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

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
