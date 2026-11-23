import 'package:yodynix_website/core/routing/app_routes.dart';
import 'package:yodynix_website/features/demos/demo_catalog.dart';
import 'package:yodynix_website/models/about_page.dart';
import 'package:yodynix_website/repositories/content/pillar_pages_content.dart';
import 'package:yodynix_website/repositories/content/service_pages_content.dart';
import 'package:yodynix_website/repositories/content/services_content.dart';

const siteOrigin = 'https://www.yodynix.it.com';

/// Every public page's route, built from the same content the router uses,
/// so a new service, project or demo is listed without editing this file.
/// Aliases (e.g. `/team`) and homepage section links are left out: each
/// page appears once, under its own route.
List<String> publicRoutes() => [
  AppRoutes.home,
  for (final page in AboutPage.values) page.route,
  for (final page in PillarPagesContent.pages) page.route,
  AppRoutes.services,
  for (final service in ServicesContent.services) service.route,
  AppRoutes.expertise,
  AppRoutes.portfolio,
  for (final project in ServicePagesContent.allProjects) AppRoutes.project(project.slug),
  for (final demo in DemoCatalog.demos) demo.route,
  AppRoutes.industries,
  AppRoutes.careers,
  AppRoutes.privacy,
  AppRoutes.terms,
];

/// The sitemap for [routes], each URL as `https://www.yodynix.it.com<route>`.
String sitemapXml(List<String> routes, {required DateTime lastModified, required String note}) {
  final date = lastModified.toIso8601String().substring(0, 10);
  final urls = [
    for (final route in routes) '  <url>\n    <loc>$siteOrigin$route</loc>\n    <lastmod>$date</lastmod>\n  </url>',
  ];
  return '<?xml version="1.0" encoding="UTF-8"?>\n'
      '<!--\n$note\n-->\n'
      '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
      '${urls.join('\n')}\n'
      '</urlset>\n';
}
