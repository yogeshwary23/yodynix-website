import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import 'back_bar.dart';
import 'site_footer.dart';
import 'site_header.dart';
import 'site_navbar.dart';

/// Page frame for routes other than the homepage (case studies, legal pages):
/// the same two-level sticky header, drawer and footer around scrollable
/// content, with a Back link to the page the visitor came from.
class SubpageScaffold extends StatelessWidget {
  const SubpageScaffold({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Title(
      title: '$title | YODYNIX',
      color: AppColors.primary,
      child: Scaffold(
        endDrawer: context.useCompactNav ? const MobileNavDrawer() : null,
        body: SiteHeaderFrame(
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const BackBar(), child, const SiteFooter()]),
          ),
        ),
      ),
    );
  }
}
