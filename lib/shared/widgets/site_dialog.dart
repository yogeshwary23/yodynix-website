import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import 'cards.dart';

/// Opens a centred, scrollable dialog with the site's styling and a fade/scale
/// transition.
Future<T?> showSiteDialog<T>(BuildContext context, {required WidgetBuilder builder, double maxWidth = 860}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: AppColors.deepCharcoal.withValues(alpha: 0.6),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (dialogContext, _, _) {
      final mobile = dialogContext.isMobile;
      return SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(mobile ? 12 : 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Material(
                color: AppColors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(mobile ? 20 : 28),
                  side: const BorderSide(color: AppColors.lightGrey),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    SingleChildScrollView(child: builder(dialogContext)),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Tooltip(
                        message: 'Close',
                        child: Material(
                          color: AppColors.cardRaised.withValues(alpha: 0.92),
                          shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
                          child: IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(curved), child: child),
      );
    },
  );
}

/// Simple icon + title + description + actions dialog body.
class SiteDialogBody extends StatelessWidget {
  const SiteDialogBody({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.actions,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<Widget> actions;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, color: color, gradient: true),
          const SizedBox(height: 22),
          Text(title, style: AppTypography.display(fontSize: 24)),
          const SizedBox(height: 12),
          Text(description, style: AppTypography.body(fontSize: 15.5)),
          const SizedBox(height: 28),
          Wrap(spacing: 12, runSpacing: 12, children: actions),
        ],
      ),
    );
  }
}

/// Bulleted check list used inside dialogs and detail views.
class CheckList extends StatelessWidget {
  const CheckList({super.key, required this.items, this.color = AppColors.accent, this.columns = 1});

  final List<String> items;
  final Color color;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final color = context.readable(this.color);
    final tiles = [
      for (final item in items)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 20,
                height: 20,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(Icons.check_rounded, size: 13, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(item, style: AppTypography.body(fontSize: 14.5, color: context.tone.ink, height: 1.5)),
              ),
            ],
          ),
        ),
    ];
    if (columns <= 1) return Column(children: tiles);
    final perColumn = (tiles.length / columns).ceil();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var c = 0; c < columns; c++) ...[
          Expanded(child: Column(children: tiles.skip(c * perColumn).take(perColumn).toList())),
          if (c < columns - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }
}
