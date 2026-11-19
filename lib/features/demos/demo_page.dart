import 'package:flutter/material.dart';

import '../../core/routing/app_navigation.dart';
import '../../core/routing/app_router.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../models/site_section.dart';
import '../../shared/layouts/navigation_actions.dart';
import '../../shared/layouts/subpage_scaffold.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/section_widgets.dart';
import '../services/service_detail_page.dart';
import 'demo_catalog.dart';
import 'demo_kit.dart';

/// Hosts one working demo: breadcrumb, an honest "sample project" notice,
/// the demo itself in a browser-style window, and the service CTA.
class DemoPage extends StatelessWidget {
  const DemoPage({super.key, required this.demo});

  final DemoEntry demo;

  @override
  Widget build(BuildContext context) {
    final service = demo.service;
    final project = demo.project;
    // Back to wherever the demo was opened from: a project, the portfolio
    // or the service page; a direct visit goes to the service page.
    final previous = AppNavigation.current?.previousPage(context);
    final hasOrigin = previous != null && previous.settings.name != AppRoutes.home;
    final backLabel = hasOrigin ? 'Back to ${AppRouter.titleFor(previous.settings.name!)}' : 'Back to ${service.title}';
    void back() => hasOrigin ? AppNavigation.back(context) : openRoute(context, service.route);
    void startProject() => goToSection(context, SiteSection.contact, enquiryService: service.title);

    return SubpageScaffold(
      title: '${project.name} Demo',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionShell(
            topPadding: context.responsive(mobile: 28.0, desktop: 44.0),
            bottomPadding: context.responsive(mobile: 48.0, desktop: 72.0),
            background: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ServiceBreadcrumb(service: service, current: 'Live Demo'),
                SizedBox(height: context.responsive(mobile: 22.0, desktop: 34.0)),
                Align(alignment: Alignment.centerLeft, child: Eyebrow('${service.title} · Live Demo')),
                const SizedBox(height: 16),
                Semantics(
                  header: true,
                  child: Text(
                    project.name,
                    style: AppTypography.display(fontSize: context.responsive(mobile: 30.0, tablet: 38.0, desktop: 44.0)),
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Text(
                    project.summary,
                    style: AppTypography.body(fontSize: context.responsive(mobile: 15.5, desktop: 17.0), height: 1.7),
                  ),
                ),
                const SizedBox(height: 22),
                const _Notice(),
                const SizedBox(height: 28),
                DemoWindow(
                  title: demo.windowTitle,
                  light: demo.light,
                  child: Builder(builder: demo.builder),
                ),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SecondaryButton(label: backLabel, icon: Icons.arrow_back_rounded, onPressed: back),
                    PrimaryButton(label: 'Start Your Project', onPressed: startProject),
                  ],
                ),
              ],
            ),
          ),
          ServiceProjectCta(service: service, onStart: startProject),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This is a YODYNIX sample project built to show how we work. It is not a client '
              'site: the business, people and data are fictional, nothing you enter is sent or '
              'stored, and the demo resets when you leave the page.',
              style: AppTypography.body(fontSize: 14, color: AppColors.body, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
