// Scrolls the entire homepage (so every reveal animation paints), opens each
// dialog type and visits every service page, demo, Careers, pillar, About
// and legal page at four widths, failing on any Flutter layout or paint error.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yodynix_website/app/yodynix_app.dart';
import 'package:yodynix_website/core/routing/app_routes.dart';
import 'package:yodynix_website/models/about_page.dart';
import 'package:yodynix_website/repositories/content/pillar_pages_content.dart';
import 'package:yodynix_website/repositories/content/service_pages_content.dart';
import 'package:yodynix_website/features/demos/demo_catalog.dart';
import 'package:yodynix_website/repositories/content/services_content.dart';

void main() {
  for (final w in [1440.0, 1100.0, 820.0, 390.0]) {
    testWidgets('no layout or paint errors across pages, dialogs, services and demos at ${w.toInt()}px', (tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      final reports = <String>[];
      final old = FlutterError.onError;
      FlutterError.onError = (d) {
        final s = d.toString();
        final first = s.split('\n').firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
        final loc = RegExp(r'file:///[^\n]*?lib/[^\n]*').firstMatch(s)?.group(0) ?? '';
        reports.add('$first @ $loc');
      };
      tester.view.physicalSize = Size(w, 900);
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(const YodynixApp());
      await tester.runAsync(GoogleFonts.pendingFonts);
      await tester.pump(const Duration(seconds: 1));

      // Scroll the whole page so every Reveal paints.
      final scrollable = find.byType(Scrollable).first;
      for (var i = 0; i < 60; i++) {
        await tester.drag(scrollable, const Offset(0, -500));
        await tester.pump(const Duration(milliseconds: 900));
      }

      Future<void> openAndClose(Finder f) async {
        if (f.evaluate().isEmpty) {
          reports.add('MISSING ${f.describeMatch(Plurality.zero)}');
          return;
        }
        // Centre the trigger, as a visitor would see it.
        Scrollable.ensureVisible(tester.element(f.first), alignment: 0.5);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 900));
        final barriers = find.byType(ModalBarrier, skipOffstage: false);
        final before = barriers.evaluate().length;
        await tester.tap(f.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 500));
        // Only close what actually opened, so a missed tap never pops a page.
        if (barriers.evaluate().length == before) {
          reports.add('DID NOT OPEN ${f.describeMatch(Plurality.one)}');
          return;
        }
        final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
        nav.pop();
        await tester.pump(const Duration(milliseconds: 500));
      }

      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      final routes = [for (final s in ServicesContent.services) s.route, for (final d in DemoCatalog.demos) d.route];
      for (final r in routes) {
        nav.pushNamed(r);
        await tester.pump(const Duration(milliseconds: 500));
        // Tapping a project card opens its details dialog.
        final service = r.startsWith('/services/') ? ServicePagesContent.bySlug(r.substring('/services/'.length)) : null;
        if (service != null) {
          final concept = ServicePagesContent.of(service).projects.firstWhere((p) => !p.hasDemo);
          await openAndClose(find.text(concept.name, skipOffstage: false));
        }
        final s = find.byType(Scrollable).last;
        for (var i = 0; i < 24; i++) {
          await tester.drag(s, const Offset(0, -500), warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 900));
        }
        nav.pop();
        await tester.pump(const Duration(milliseconds: 500));
      }
      for (final r in [AppRoutes.careers, AppRoutes.portfolio, AppRoutes.industries]) {
        nav.pushNamed(r);
        await tester.pump(const Duration(milliseconds: 500));
        final s = find.byType(Scrollable).last;
        for (var i = 0; i < 48; i++) {
          await tester.drag(s, const Offset(0, -500), warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 900));
        }
        nav.pop();
        await tester.pump(const Duration(milliseconds: 500));
      }
      for (final page in PillarPagesContent.pages) {
        nav.pushNamed(page.route);
        await tester.pump(const Duration(milliseconds: 500));
        final s = find.byType(Scrollable).last;
        for (var i = 0; i < 40; i++) {
          await tester.drag(s, const Offset(0, -500), warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 900));
        }
        nav.pop();
        await tester.pump(const Duration(milliseconds: 500));
      }
      for (final page in AboutPage.values) {
        nav.pushNamed(page.route);
        await tester.pump(const Duration(milliseconds: 500));
        final s = find.byType(Scrollable).last;
        for (var i = 0; i < 40; i++) {
          await tester.drag(s, const Offset(0, -500), warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 900));
        }
        nav.pop();
        await tester.pump(const Duration(milliseconds: 500));
      }
      for (final r in ['/privacy-policy', '/terms-and-conditions']) {
        nav.pushNamed(r);
        await tester.pump(const Duration(milliseconds: 500));
        nav.pop();
        await tester.pump(const Duration(milliseconds: 500));
      }

      FlutterError.onError = old;
      tester.view.reset();
      // ignore: avoid_print
      print('=== $w: ${reports.length} reports\n${reports.toSet().join('\n')}');
    });
  }
}
