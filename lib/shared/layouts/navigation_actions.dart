import 'package:flutter/material.dart';

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
/// the enquiry form.
void goToSection(BuildContext context, SiteSection section, {String? enquiryService}) {
  final nav = SectionNavigatorScope.read(context);
  if (enquiryService != null) nav.contactPrefill.value = enquiryService;

  final route = ModalRoute.of(context);
  if (route != null && !route.isFirst) {
    Navigator.of(context).popUntil((r) => r.isFirst);
    WidgetsBinding.instance.addPostFrameCallback((_) => nav.scrollTo(section));
  } else {
    nav.scrollTo(section);
  }
}

/// The About page shown by the route that owns [context], if any.
AboutPage? currentAboutPage(BuildContext context) {
  final name = ModalRoute.of(context)?.settings.name;
  return name == null ? null : AboutPage.byRoute(AppRoutes.resolve(name));
}

/// Opens one of the About pages. From the homepage the page is pushed; from
/// any other page it replaces that page, so "back" always returns home.
void openAboutPage(BuildContext context, AboutPage page) {
  if (currentAboutPage(context) == page) return;
  final route = ModalRoute.of(context);
  final navigator = Navigator.of(context);
  if (route == null || route.isFirst) {
    navigator.pushNamed(page.route);
  } else {
    navigator.pushReplacementNamed(page.route);
  }
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

/// Opens a service's own page. Like [openAboutPage], it is pushed from the
/// homepage and replaces any other sub-page, so "back" returns home.
void openServicePage(BuildContext context, ServiceOffering service) {
  if (currentService(context)?.id == service.id) return;
  final route = ModalRoute.of(context);
  final navigator = Navigator.of(context);
  if (route == null || route.isFirst) {
    navigator.pushNamed(service.route);
  } else {
    navigator.pushReplacementNamed(service.route);
  }
}

/// Whether [context] belongs to the Internship landing page or one of its
/// programme pages.
bool isInternshipRoute(BuildContext context) {
  final name = ModalRoute.of(context)?.settings.name;
  if (name == null) return false;
  final route = AppRoutes.resolve(name);
  return route == AppRoutes.internship || route.startsWith(AppRoutes.internshipPrefix);
}

/// Opens the Internship landing page, or a programme page when [slug] is
/// given. Pushed from the homepage and replacing any other sub-page, like
/// [openServicePage]. [apply] scrolls the landing page to its form.
void openInternshipPage(BuildContext context, {String? slug, bool apply = false}) {
  final target = slug == null ? AppRoutes.internship : AppRoutes.internshipProgram(slug);
  final current = ModalRoute.of(context);
  final name = current?.settings.name;
  if (!apply && name != null && AppRoutes.resolve(name) == target) return;
  final navigator = Navigator.of(context);
  final arguments = apply ? InternshipPageArgs.apply : null;
  if (current == null || current.isFirst) {
    navigator.pushNamed(target, arguments: arguments);
  } else {
    navigator.pushReplacementNamed(target, arguments: arguments);
  }
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
