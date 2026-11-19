import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yodynix_website/core/constants/asset_paths.dart';
import 'package:yodynix_website/core/constants/site_config.dart';
import 'package:yodynix_website/core/routing/app_router.dart';
import 'package:yodynix_website/core/routing/app_routes.dart';
import 'package:yodynix_website/features/home/home_page.dart';
import 'package:yodynix_website/app/yodynix_app.dart';
import 'package:yodynix_website/repositories/content/careers_content.dart';
import 'package:yodynix_website/repositories/content/services_content.dart';
import 'package:yodynix_website/services/asset_registry.dart';
import 'package:yodynix_website/shared/widgets/social_icon.dart';

import '../tool/sitemap/sitemap_routes.dart';

/// Width and height of a PNG file.
(int, int) pngSize(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  return (data.getUint32(16), data.getUint32(20));
}

void main() {
  final indexHtml = File('web/index.html').readAsStringSync();

  String? meta(String attr, String name) =>
      RegExp('<meta $attr="${RegExp.escape(name)}" content="([^"]*)"').firstMatch(indexHtml)?.group(1);

  group('sitemap.xml', () {
    final xml = File('web/sitemap.xml').readAsStringSync();
    final locs = [for (final m in RegExp(r'<loc>([^<]+)</loc>').allMatches(xml)) m.group(1)!];

    test('is a sitemaps.org urlset with a dated entry per URL', () {
      expect(xml, startsWith('<?xml version="1.0" encoding="UTF-8"?>'));
      expect(xml, contains('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'));
      expect(xml.trimRight(), endsWith('</urlset>'));
      expect('<url>'.allMatches(xml).length, locs.length);
      expect(RegExp(r'<lastmod>\d{4}-\d{2}-\d{2}</lastmod>').allMatches(xml).length, locs.length);
    });

    test('lists the homepage, and only absolute URLs of real pages on the site', () {
      expect(locs, contains('$siteOrigin/'));
      expect(locs.toSet(), hasLength(locs.length), reason: 'no duplicates');
      for (final loc in locs) {
        expect(loc, startsWith('$siteOrigin/'), reason: loc);
        final route = loc.substring(siteOrigin.length);
        expect(AppRouter.pageTitle(route), isNotNull, reason: '$route must open a real page');
      }
    });

    test('the full route list (for clean URLs) holds each real page once, under its own route', () {
      final routes = publicRoutes();
      expect(routes.toSet(), hasLength(routes.length), reason: 'no duplicates');
      for (final route in routes) {
        expect(AppRouter.pageTitle(route), isNotNull, reason: route);
        expect(AppRoutes.resolve(route), route, reason: '$route must not be an alias');
      }
      expect(routes, containsAll([AppRoutes.home, AppRoutes.careers, AppRoutes.services, AppRoutes.portfolio]));
    });
  });

  test('robots.txt allows crawling and points at the sitemap', () {
    final robots = File('web/robots.txt').readAsLinesSync().map((l) => l.trim()).toList();
    expect(robots, contains('User-agent: *'));
    expect(robots, contains('Allow: /'));
    expect(robots.where((l) => l.toLowerCase().startsWith('disallow:') && l.substring(9).trim().isNotEmpty), isEmpty);
    expect(robots, contains('Sitemap: $siteOrigin/sitemap.xml'));
  });

  group('structured data', () {
    final blocks = RegExp(r'<script type="application/ld\+json">([\s\S]*?)</script>').allMatches(indexHtml).toList();
    final data = jsonDecode(blocks.single.group(1)!) as Map<String, dynamic>;
    final graph = (data['@graph'] as List).cast<Map<String, dynamic>>();
    final org = graph.singleWhere((n) => n['@type'] == 'ProfessionalService');
    final site = graph.singleWhere((n) => n['@type'] == 'WebSite');

    test('one JSON-LD block, schema.org context', () {
      expect(data['@context'], 'https://schema.org');
    });

    test('the business details match the site configuration', () {
      expect(org['name'], SiteConfig.brandName);
      expect(org['slogan'], SiteConfig.tagline);
      expect(org['url'], '${SiteConfig.website}/');
      expect(org['email'], ContactConfig.email);
      expect(org['telephone'], ContactConfig.phones.first);
      expect(org['contactPoint']['email'], ContactConfig.email);
      expect(org['contactPoint']['telephone'], ContactConfig.phones.first);
      final address = org['address'] as Map<String, dynamic>;
      expect(address['@type'], 'PostalAddress');
      for (final part in [address['streetAddress'], address['addressLocality'], address['addressRegion'], address['postalCode']]) {
        // "Moshi, Pune" in the config is "Moshi" + locality "Pune" here.
        for (final word in (part as String).split(RegExp(r',\s*'))) {
          expect(ContactConfig.address, contains(word), reason: word);
        }
      }
      expect(address['addressCountry'], 'IN');
    });

    test('sameAs lists exactly the configured social profiles', () {
      expect(org['sameAs'], [for (final l in SocialConfig.links) l.url]);
      expect(org['sameAs'], [
        'https://www.instagram.com/yodynix/',
        'https://www.facebook.com/people/Yodynix/61592544453906/',
        'https://www.linkedin.com/company/yodynix/',
      ]);
    });

    test('the logo is the charcoal and gold brand mark, at a stable URL Google accepts', () {
      final logo = org['logo'] as Map<String, dynamic>;
      expect(logo['url'], '$siteOrigin/logo.png');
      final bytes = File('web/logo.png').readAsBytesSync();
      expect(bytes, File(AssetPaths.logo).readAsBytesSync(), reason: 'same file as the logo the site shows');
      final (w, h) = pngSize(bytes);
      expect((logo['width'], logo['height']), (w, h));
      // Google: at least 112 x 112 px, in a supported format.
      expect(w >= 112 && h >= 112, isTrue);
      expect(String.fromCharCodes(bytes.sublist(1, 4)), 'PNG');
    });

    test('the website is published by the organization', () {
      expect(site['url'], '$siteOrigin/');
      expect(site['name'], SiteConfig.brandName);
      expect(site['publisher'], {'@id': org['@id']});
    });
  });

  group('sharing metadata', () {
    test('Open Graph and Twitter use the official tagline and the 1200 x 630 sharing image', () {
      const title = 'YODYNIX | Technology. Intelligence. Innovation.';
      expect(SiteConfig.tagline, 'Technology. Intelligence. Innovation.');
      expect(HomePage.documentTitle, title, reason: 'the title the app sets, which Google renders');
      expect(indexHtml, contains('<title>$title</title>'));
      expect(meta('property', 'og:title'), title);
      expect(meta('name', 'twitter:title'), title);

      const image = '$siteOrigin/og-image.png';
      expect(meta('property', 'og:url'), '$siteOrigin/');
      expect(meta('property', 'og:site_name'), SiteConfig.brandName);
      expect(meta('property', 'og:image'), image);
      expect(meta('property', 'og:image:width'), '1200');
      expect(meta('property', 'og:image:height'), '630');
      expect(meta('property', 'og:image:alt'), isNotEmpty);
      expect(meta('name', 'twitter:card'), 'summary_large_image');
      expect(meta('name', 'twitter:image'), image);
      expect(pngSize(File('web/og-image.png').readAsBytesSync()), (1200, 630));
    });

    test('the canonical URL is the homepage', () {
      expect(indexHtml, contains('<link rel="canonical" href="$siteOrigin/">'));
    });
  });

  test('the no-JavaScript summary lists every service, opening and social profile', () {
    final noscript = RegExp(r'<noscript>([\s\S]*?)</noscript>').firstMatch(indexHtml)!.group(1)!.replaceAll('&amp;', '&');
    for (final s in ServicesContent.services) {
      expect(noscript, contains(s.title), reason: s.title);
    }
    for (final o in CareersContent.allOpenings) {
      expect(noscript, contains(o.title), reason: o.title);
    }
    expect(noscript, isNot(contains('Junior Flutter Developer')));
    for (final l in SocialConfig.links) {
      expect(noscript, contains('href="${l.url}"'), reason: l.platform.label);
    }
    expect(noscript, contains(ContactConfig.phones.first));
  });

  testWidgets('the footer and the Contact section open all three social profiles', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    tester.view.physicalSize = const Size(1400, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final opened = <String>[];
    const channel = MethodChannel('plugins.flutter.io/url_launcher');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'launch') opened.add((call.arguments as Map)['url'] as String);
      return true;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));

    // The real homepage, which holds both the Contact section and the footer.
    await tester.runAsync(AssetRegistry.instance.init);
    await tester.pumpWidget(const YodynixApp());
    await tester.runAsync(GoogleFonts.pendingFonts);
    await tester.pump(const Duration(seconds: 1));

    final urls = [for (final l in SocialConfig.links) l.url];

    // Footer: one round icon button per profile, named by its tooltip.
    for (final label in ['Instagram', 'Facebook', 'LinkedIn']) {
      await tester.ensureVisible(find.byTooltip(label));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.byTooltip(label));
      await tester.pump();
    }
    expect(opened, urls);

    // LinkedIn shows its own "in" mark, not the generic briefcase icon.
    final linkedIn = find.byTooltip('LinkedIn');
    expect(
      find.descendant(of: linkedIn, matching: find.byWidgetPredicate((w) => w is CustomPaint && w.painter is LinkedInGlyphPainter)),
      findsOneWidget,
    );
    expect(find.descendant(of: linkedIn, matching: find.byIcon(Icons.work_outline_rounded)), findsNothing);

    // Contact: one Social Media card with a line per profile.
    opened.clear();
    await tester.ensureVisible(find.text('Social Media'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Social Media'), findsOneWidget);
    for (final line in ['Instagram', 'Facebook', 'LinkedIn']) {
      await tester.tap(find.text(line));
      await tester.pump();
    }
    expect(opened, urls);
    expect(tester.takeException(), isNull);
  });
}
