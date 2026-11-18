import 'package:flutter/material.dart';

import '../../core/constants/site_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../models/site_section.dart';
import '../../services/link_service.dart';
import '../widgets/section_widgets.dart';
import 'navigation_actions.dart';
import 'site_navbar.dart';

/// Page frame shared by every public page: the charcoal [TopInfoBar] above
/// the white [SiteNavbar], over the page's vertical scroll view [child].
///
/// Scrolling down folds the information bar away while the navbar stays
/// pinned; scrolling back to the top restores it. The two thresholds are
/// further apart than the bar is tall, so the viewport growing as the bar
/// folds can never flip the state back (no flicker on short pages).
class SiteHeaderFrame extends StatefulWidget {
  const SiteHeaderFrame({super.key, required this.child});

  final Widget child;

  @override
  State<SiteHeaderFrame> createState() => _SiteHeaderFrameState();
}

class _SiteHeaderFrameState extends State<SiteHeaderFrame> {
  static const double _collapseAfter = 56;
  static const double _expandBelow = 4;

  bool _collapsed = false;
  bool _elevated = false;

  bool _onScroll(ScrollNotification notification) {
    // Only the page's own scroll view; carousels and inner lists are ignored.
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) return false;
    final offset = notification.metrics.pixels;
    final collapsed = _collapsed ? offset > _expandBelow : offset > _collapseAfter;
    final elevated = offset > _expandBelow;
    if (collapsed != _collapsed || elevated != _elevated) {
      setState(() {
        _collapsed = collapsed;
        _elevated = elevated;
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TopInfoBar(collapsed: _collapsed),
        SiteNavbar(elevated: _elevated),
        Expanded(
          child: NotificationListener<ScrollNotification>(onNotification: _onScroll, child: widget.child),
        ),
      ],
    );
  }
}

/// Slim charcoal bar with direct contact links, the brand line and a
/// "Get in Touch" shortcut. Folds to zero height when [collapsed].
class TopInfoBar extends StatelessWidget {
  const TopInfoBar({super.key, this.collapsed = false});

  final bool collapsed;

  static String get _phone => ContactConfig.phones.first;

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    final height = context.responsive(mobile: 40.0, tablet: 46.0, desktop: 54.0);

    return ClipRect(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: AppMotion.ease,
        height: collapsed ? 0 : height,
        color: AppColors.topBar,
        // Lays out at full height and is clipped while folding, so the
        // content slides away instead of being squeezed.
        child: OverflowBox(
          alignment: Alignment.bottomCenter,
          minHeight: height,
          maxHeight: height,
          child: Semantics(
            container: true,
            label: 'Contact information',
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.topBarGold.withValues(alpha: 0.22))),
              ),
              child: MaxWidth(
                maxWidth: Breakpoints.headerMaxWidth,
                child: Row(
                  children: [
                    // Contacts take the free space; the phone always shows in
                    // full, the email shrinks to an icon on phones.
                    Expanded(
                      child: Row(
                        children: [
                          _InfoLink(
                            icon: Icons.phone_in_talk_outlined,
                            label: _phone,
                            semanticLabel: 'Call $_phone',
                            onTap: () => LinkService.call(_phone),
                          ),
                          const _Divider(),
                          Flexible(
                            child: _InfoLink(
                              icon: Icons.mail_outline_rounded,
                              label: mobile ? null : ContactConfig.email,
                              semanticLabel: 'Email ${ContactConfig.email}',
                              onTap: () => LinkService.email(ContactConfig.email),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (context.isDesktop) ...[const _Tagline(), const _Divider(spacing: 26)],
                    _GetInTouch(compact: mobile, onTap: () => goToSection(context, SiteSection.contact)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A fine vertical rule between items on the information bar.
class _Divider extends StatelessWidget {
  const _Divider({this.spacing = 22});

  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 20,
      margin: EdgeInsets.symmetric(horizontal: spacing),
      color: AppColors.white.withValues(alpha: 0.16),
    );
  }
}

class _InfoLink extends StatefulWidget {
  const _InfoLink({required this.icon, required this.semanticLabel, required this.onTap, this.label});

  final IconData icon;
  final String? label;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  State<_InfoLink> createState() => _InfoLinkState();
}

class _InfoLinkState extends State<_InfoLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    final link = Semantics(
      link: true,
      label: widget.semanticLabel,
      excludeSemantics: true,
      child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            onTap: widget.onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: context.isDesktop ? 18 : 16, color: AppColors.topBarGold),
                  if (label != null) ...[
                    const SizedBox(width: 10),
                    Flexible(
                      child: AnimatedDefaultTextStyle(
                        duration: AppMotion.hover,
                        style: AppTypography.body(
                          fontSize: context.isDesktop ? 15 : 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                          height: 1.2,
                          color: _hover ? AppColors.topBarGold : AppColors.white,
                        ),
                        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
                      ),
                    ),
                  ],
                ],
            ),
          ),
        ),
      ),
    );
    // Icon-only links (the email on phones) name themselves on hover.
    return label == null ? Tooltip(message: widget.semanticLabel, child: link) : link;
  }
}

/// "Technology • Intelligence • Innovation", with champagne separators.
class _Tagline extends StatelessWidget {
  const _Tagline();

  static const _words = ['Technology', 'Intelligence', 'Innovation'];

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.body(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.8,
      height: 1.2,
      color: AppColors.white.withValues(alpha: 0.86),
    );
    return Semantics(
      label: _words.join(', '),
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(
          children: [
            for (var i = 0; i < _words.length; i++) ...[
              if (i > 0) const TextSpan(text: '  •  ', style: TextStyle(color: AppColors.topBarGold)),
              TextSpan(text: _words[i]),
            ],
          ],
        ),
        style: style,
        maxLines: 1,
      ),
    );
  }
}

class _GetInTouch extends StatefulWidget {
  const _GetInTouch({required this.onTap, this.compact = false});

  final VoidCallback onTap;
  final bool compact;

  @override
  State<_GetInTouch> createState() => _GetInTouchState();
}

class _GetInTouchState extends State<_GetInTouch> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final fg = _hover ? AppColors.topBar : AppColors.topBarGold;
    return Semantics(
      button: true,
      label: 'Get in Touch',
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: AppMotion.hover,
            curve: AppMotion.ease,
            padding: EdgeInsets.symmetric(horizontal: widget.compact ? 12 : 18, vertical: widget.compact ? 5 : 7),
            decoration: BoxDecoration(
              color: _hover ? AppColors.topBarGold : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.topBarGold.withValues(alpha: _hover ? 1 : 0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Get in Touch',
                  style: AppTypography.body(
                    fontSize: widget.compact ? 12 : 14.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    height: 1.2,
                    color: fg,
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedSlide(
                  duration: AppMotion.hover,
                  offset: Offset(_hover ? 0.15 : 0, 0),
                  child: Icon(Icons.arrow_forward_rounded, size: widget.compact ? 13 : 16, color: fg),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
