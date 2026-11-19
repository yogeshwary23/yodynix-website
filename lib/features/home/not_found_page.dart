import 'package:flutter/material.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../models/site_section.dart';
import '../../shared/layouts/navigation_actions.dart';
import '../../shared/layouts/subpage_scaffold.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';

/// Shown for links that match no page, with ways back into the site.
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key, required this.path});

  /// The address that was requested.
  final String path;

  @override
  Widget build(BuildContext context) {
    return SubpageScaffold(
      title: 'Page Not Found',
      child: SectionShell(
        background: AppColors.pearlWhite,
        topPadding: context.responsive(mobile: 64.0, desktop: 112.0),
        bottomPadding: context.responsive(mobile: 72.0, desktop: 128.0),
        child: Reveal(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  GradientText(
                    '404',
                    style: AppTypography.display(fontSize: context.responsive(mobile: 72.0, desktop: 112.0), fontWeight: FontWeight.w800, height: 1),
                    gradient: AppColors.metallicGoldText,
                  ),
                  const SizedBox(height: 20),
                  Semantics(
                    header: true,
                    child: Text(
                      "We Couldn't Find That Page.",
                      textAlign: TextAlign.center,
                      style: AppTypography.display(fontSize: context.responsive(mobile: 28.0, desktop: 38.0)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'The address $path may have moved or been typed incorrectly. '
                    'Use the links below to continue exploring YODYNIX.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body(fontSize: 16, height: 1.7, color: AppColors.body),
                  ),
                  const SizedBox(height: 28),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      PrimaryButton(label: 'Go to Homepage', onPressed: () => goToSection(context, SiteSection.home)),
                      SecondaryButton(label: 'View Services', onPressed: () => openRoute(context, AppRoutes.services)),
                      SecondaryButton(label: 'View Portfolio', onPressed: () => openRoute(context, AppRoutes.portfolio)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
