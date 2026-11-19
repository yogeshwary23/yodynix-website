import 'package:flutter/material.dart';

import '../../core/routing/app_navigation.dart';
import '../../core/routing/app_routes.dart';
import '../../models/about_page.dart';
import '../../models/content_models.dart';
import '../../models/site_section.dart';
import '../../providers/section_navigator.dart';
import '../../repositories/content/service_pages_content.dart';
import '../widgets/buttons.dart';
import '../widgets/site_dialog.dart';

/// Navigates to a homepage section from anywhere — closing dialogs or
/// returning from sub-pages first — and optionally pre-selects a service in
/// the enquiry form. [showForm] scrolls to the form itself rather than the
/// top of the Contact section. Entries with their own page (About, Services,
/// Expertise, Careers) open that page.
void goToSection(BuildContext context, SiteSection section, {String? enquiryService, bool showForm = false}) {
  final nav = SectionNavigatorScope.read(context);
  if (enquiryService != null) nav.contactPrefill.value = enquiryService;

  switch (section) {
    case SiteSection.about:
      return openAboutPage(context, AboutPage.defaultPage);
    case SiteSection.services:
      return _openPage(context, AppRoutes.services);
    case SiteSection.expertise:
      return _openPage(context, AppRoutes.expertise);
    case SiteSection.careers:
      return openCareersPage(context);
    default:
  }

  final route = ModalRoute.of(context);
  if (route != null && !route.isFirst) {
    Navigator.of(context).popUntil((r) => r.isFirst);
    WidgetsBinding.instance.addPostFrameCallback((_) => nav.scrollTo(section, toForm: showForm));
  } else {
    nav.scrollTo(section, toForm: showForm);
  }
}

/// The About page shown by the route that owns [context], if any.
AboutPage? currentAboutPage(BuildContext context) {
  final name = ModalRoute.of(context)?.settings.name;
  return name == null ? null : AboutPage.byRoute(AppRoutes.resolve(name));
}

/// Opens one of the About pages (see [openRoute]).
void openAboutPage(BuildContext context, AboutPage page) {
  if (currentAboutPage(context) == page) return;
  openRoute(context, page.route);
}

/// The service whose detail page (or demo) owns [context], if any.
ServiceOffering? currentService(BuildContext context) {
  final name = ModalRoute.of(context)?.settings.name;
  if (name == null) return null;
  final route = AppRoutes.resolve(name);
  if (route.startsWith(AppRoutes.servicePrefix)) {
    return ServicePagesContent.bySlug(route.substring(AppRoutes.servicePrefix.length));
  }
  return null;
}

/// Opens a service's own page (see [openRoute]).
void openServicePage(BuildContext context, ServiceOffering service) {
  if (currentService(context)?.id == service.id) return;
  openRoute(context, service.route);
}

/// Whether [context] belongs to the Careers page.
bool isCareersRoute(BuildContext context) {
  final name = ModalRoute.of(context)?.settings.name;
  if (name == null) return false;
  return AppRoutes.resolve(name) == AppRoutes.careers;
}

/// Opens the Careers page (see [openRoute]). [apply] scrolls the page to
/// its form, re-opening Careers in place when it is already showing.
void openCareersPage(BuildContext context, {bool apply = false}) =>
    openRoute(context, AppRoutes.careers, arguments: apply ? CareersPageArgs.apply : null);

/// Top-level pages listed in the navigation beside the homepage sections.
enum SitePage {
  portfolio('Portfolio', AppRoutes.portfolio),
  industries('Industries', AppRoutes.industries);

  const SitePage(this.label, this.route);

  final String label;
  final String route;
}

/// The [SitePage] shown by the route that owns [context], if any.
SitePage? currentSitePage(BuildContext context) {
  final name = ModalRoute.of(context)?.settings.name;
  if (name == null) return null;
  final route = AppRoutes.resolve(name);
  if (route.startsWith(AppRoutes.projectPrefix)) return SitePage.portfolio;
  for (final p in SitePage.values) {
    if (p.route == route) return p;
  }
  return null;
}

/// Opens a [SitePage] (see [openRoute]).
void openSitePage(BuildContext context, SitePage page) => _openPage(context, page.route);

/// The navigation entry whose own page (Services or Expertise) owns
/// [context], if any.
SiteSection? currentSectionPage(BuildContext context) {
  final name = ModalRoute.of(context)?.settings.name;
  return switch (name == null ? null : AppRoutes.resolve(name)) {
    AppRoutes.services => SiteSection.services,
    AppRoutes.expertise => SiteSection.expertise,
    _ => null,
  };
}

void _openPage(BuildContext context, String route) => openRoute(context, route);

/// Opens the page at [route] (a resolved path) on top of the current one, so
/// Back returns to where the visitor came from. Nothing happens if it is
/// already showing; if it is open further back, the stack returns to it
/// (keeping its state) instead of gaining a second copy. [arguments] always
/// open a fresh instance, replacing the page when it is the one showing.
void openRoute(BuildContext context, String route, {Object? arguments}) {
  final navigator = Navigator.of(context);
  final name = ModalRoute.of(context)?.settings.name;
  final showing = name != null && AppRoutes.resolve(name) == route;
  if (showing) {
    if (arguments != null) navigator.pushReplacementNamed(route, arguments: arguments);
    return;
  }
  final existing = AppNavigation.current?.pageFor(route);
  if (existing != null) {
    navigator.popUntil((r) => r == existing);
    if (arguments != null) navigator.pushReplacementNamed(route, arguments: arguments);
    return;
  }
  navigator.pushNamed(route, arguments: arguments);
}

void showClientLoginDialog(BuildContext context) {
  showSiteDialog(
    context,
    maxWidth: 480,
    builder: (dialogContext) => SiteDialogBody(
      icon: Icons.lock_outline_rounded,
      title: 'Client Portal: Coming Soon',
      description:
          'A secure client portal for project updates, files and communication '
          'is currently being built. Until it launches, our team will keep you updated '
          'directly.',
      actions: [
        PrimaryButton(
          label: 'Contact Us',
          size: ButtonSize.small,
          onPressed: () => goToSection(dialogContext, SiteSection.contact),
        ),
        SecondaryButton(label: 'Close', size: ButtonSize.small, onPressed: () => Navigator.of(dialogContext).pop()),
      ],
    ),
  );
}
