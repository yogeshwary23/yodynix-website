import 'package:flutter/material.dart';

import '../../core/routing/app_navigation.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../widgets/motion_effects.dart';
import '../widgets/section_widgets.dart';

/// The strip at the top of every inner page naming where Back leads, e.g.
/// "Back to Portfolio". It follows the real page stack, so it returns to the
/// page the visitor came from (see [AppNavigation.back]).
class BackBar extends StatelessWidget {
  const BackBar({super.key});

  @override
  Widget build(BuildContext context) {
    final navigation = AppNavigation.current;
    if (navigation == null) return const SizedBox.shrink();
    return ValueListenableBuilder<int>(
      valueListenable: navigation.stackVersion,
      builder: (context, _, _) {
        final previous = navigation.previousPage(context);
        if (previous == null) return const SizedBox.shrink();
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.pearlWhite,
            border: Border(bottom: BorderSide(color: AppColors.goldLine)),
          ),
          child: MaxWidth(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: context.responsive(mobile: 8.0, desktop: 10.0)),
              child: Align(
                alignment: Alignment.centerLeft,
                child: BackLink(label: 'Back to ${AppRouter.titleFor(previous.settings.name!)}'),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// "← Back to …": returns to the previous page through [AppNavigation.back].
class BackLink extends StatefulWidget {
  const BackLink({super.key, required this.label});

  final String label;

  @override
  State<BackLink> createState() => _BackLinkState();
}

class _BackLinkState extends State<BackLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final reduced = prefersReducedMotion(context);
    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => AppNavigation.back(context),
          child: ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: AppMotion.hover,
                    curve: AppMotion.ease,
                    width: 30,
                    height: 30,
                    transform: Matrix4.translationValues(_hover && !reduced ? -3 : 0, 0, 0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _hover ? AppColors.buttonGold : null,
                      color: _hover ? null : AppColors.white,
                      border: Border.all(color: _hover ? AppColors.champagneGold : AppColors.goldLine),
                    ),
                    child: Icon(Icons.arrow_back_rounded, size: 16, color: _hover ? AppColors.onPrimary : AppColors.accent),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _hover ? AppColors.accentDeep : AppColors.accent,
                        height: 1.2,
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
  }
}
