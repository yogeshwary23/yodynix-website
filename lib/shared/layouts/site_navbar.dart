import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/utils/responsive.dart';
import '../../models/about_page.dart';
import '../../models/content_models.dart';
import '../../models/site_section.dart';
import '../../providers/section_navigator.dart';
import '../../repositories/content/services_content.dart';
import '../widgets/brand_logo.dart';
import '../widgets/buttons.dart';
import '../widgets/section_widgets.dart';
import 'navigation_actions.dart';

/// Sticky top navigation. Collapses to logo + menu button below
/// [Breakpoints.navCollapse]; the menu opens [MobileNavDrawer].
class SiteNavbar extends StatelessWidget {
  const SiteNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = SectionNavigatorScope.of(context);
    final aboutPage = currentAboutPage(context);
    final service = currentService(context);
    final sitePage = currentSitePage(context);
    final isActive = _activeResolver(nav.active, aboutPage, service, internship: isInternshipRoute(context), page: sitePage);
    final compact = context.useCompactNav;
    final height = context.isMobile ? 68.0 : 80.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: nav.isScrolled ? 0.97 : 1),
        border: const Border(bottom: BorderSide(color: AppColors.stone)),
        boxShadow: nav.isScrolled
            ? [BoxShadow(color: AppColors.charcoal.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 6))]
            : null,
      ),
      // The bar is a light surface: the wordmark reads its colours from it.
      child: SurfaceTone(
        colors: SurfaceColors.light,
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          label: 'Main navigation',
          child: MaxWidth(
            child: Row(
              children: [
                Semantics(
                  button: true,
                  label: 'YODYNIX home',
                  excludeSemantics: true,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => goToSection(context, SiteSection.home),
                      child: BrandLogo(height: context.isMobile ? 38 : 44),
                    ),
                  ),
                ),
                const Spacer(),
                if (!compact) ...[
                  // Scales down rather than overflowing (e.g. while fonts load).
                  Flexible(
                    flex: 12,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Row(
                        children: [
                          for (final section in SiteSection.navigation) ...[
                            if (section == SiteSection.internship)
                              for (final page in SitePage.values)
                                _NavItem(label: page.label, active: page == sitePage, onTap: () => openSitePage(context, page)),
                            if (section == SiteSection.about)
                              _DropdownNavItem(
                                label: 'About',
                                active: isActive(section),
                                onTitleTap: () => openAboutPage(context, AboutPage.defaultPage),
                                menuBuilder: (run) =>
                                    _AboutMenu(current: aboutPage, onSelect: (page) => run(() => openAboutPage(context, page))),
                              )
                            else if (section == SiteSection.services)
                              _DropdownNavItem(
                                label: 'Services',
                                active: isActive(section),
                                onTitleTap: () => goToSection(context, SiteSection.services),
                                menuBuilder: (run) => _ServicesMenu(
                                  current: service,
                                  onSelect: (s) => run(() => openServicePage(context, s)),
                                  onViewAll: () => run(() => goToSection(context, SiteSection.services)),
                                ),
                              )
                            else
                              _NavItem(
                                label: section.navLabel!,
                                active: isActive(section),
                                onTap: () => section == SiteSection.internship
                                    ? openInternshipPage(context)
                                    : goToSection(context, section),
                              ),
                          ],
                          const SizedBox(width: 20),
                          _ClientLoginButton(onTap: () => showClientLoginDialog(context)),
                          const SizedBox(width: 12),
                          PrimaryButton(
                            label: 'Get Started',
                            size: ButtonSize.small,
                            onPressed: () => goToSection(context, SiteSection.contact),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  if (!context.isMobile) ...[
                    PrimaryButton(
                      label: 'Get Started',
                      size: ButtonSize.small,
                      onPressed: () => goToSection(context, SiteSection.contact),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Builder(
                    builder: (context) => Tooltip(
                      message: 'Open menu',
                      child: Material(
                        color: AppColors.pearlWhite,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                          side: BorderSide(color: AppColors.stone),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Scaffold.of(context).openEndDrawer(),
                          child: const SizedBox(
                            width: 46,
                            height: 46,
                            child: Icon(Icons.menu_rounded, color: AppColors.charcoal),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// On an About, service or internship page that area's item is active, whatever the
/// homepage scroll position underneath.
bool Function(SiteSection) _activeResolver(
  SiteSection scrolled,
  AboutPage? aboutPage,
  ServiceOffering? service, {
  bool internship = false,
  SitePage? page,
}) {
  return (s) {
    if (page != null) return false;
    if (aboutPage != null) return s == SiteSection.about;
    if (service != null) return s == SiteSection.services;
    if (internship) return s == SiteSection.internship;
    return scrolled == s;
  };
}

class _NavItem extends StatefulWidget {
  const _NavItem({required this.label, required this.active, required this.onTap, this.highlighted = false, this.trailing});

  final String label;
  final bool active;
  final VoidCallback onTap;

  /// Shows the hover style regardless of the pointer, e.g. while a dropdown
  /// owned by this item is open.
  final bool highlighted;
  final Widget? trailing;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final hover = _hover || widget.highlighted;
    return Semantics(
      button: true,
      selected: widget.active,
      label: widget.label,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Balances the underline below so labels stay vertically centred.
                const SizedBox(height: 9),
                // The label lifts a pixel as the gold underline grows beneath it.
                AnimatedSlide(
                  offset: Offset(0, hover && !widget.active ? -0.06 : 0),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: AppTypography.body(
                      fontSize: 14.5,
                      fontWeight: widget.active ? FontWeight.w700 : FontWeight.w500,
                      color: widget.active || hover ? AppColors.accent : AppColors.charcoal,
                      height: 1.2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.label),
                        if (widget.trailing != null) ...[const SizedBox(width: 3), widget.trailing!],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  height: 3,
                  width: widget.active ? 22 : (hover ? 12 : 0),
                  // Liquid-gold indicator with a soft glow once active.
                  decoration: BoxDecoration(
                    gradient: widget.active ? AppColors.liquidGold : null,
                    color: widget.active ? null : AppColors.champagneGold.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: widget.active ? AppColors.glowShadow(0.9) : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A navigation item with a dropdown menu (About, Services). Hovering — or
/// tapping while closed, for touch screens — opens the menu; clicking the
/// label while it is open runs [onTitleTap].
class _DropdownNavItem extends StatefulWidget {
  const _DropdownNavItem({required this.label, required this.active, required this.onTitleTap, required this.menuBuilder});

  final String label;
  final bool active;
  final VoidCallback onTitleTap;

  /// Builds the menu. Menu actions go through `run`, which closes the menu
  /// immediately before navigating.
  final Widget Function(void Function(VoidCallback action) run) menuBuilder;

  @override
  State<_DropdownNavItem> createState() => _DropdownNavItemState();
}

class _DropdownNavItemState extends State<_DropdownNavItem> with SingleTickerProviderStateMixin {
  final _menu = OverlayPortalController();
  final _link = LayerLink();
  late final AnimationController _animation =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 220),
        reverseDuration: const Duration(milliseconds: 160),
      )..addStatusListener((status) {
        if (status == AnimationStatus.dismissed && _menu.isShowing) _menu.hide();
      });
  late final CurvedAnimation _curved = CurvedAnimation(parent: _animation, curve: AppMotion.ease, reverseCurve: Curves.easeIn);
  Timer? _closeTimer;

  bool get _isOpen => _animation.status.isForwardOrCompleted;

  void _open() {
    _closeTimer?.cancel();
    if (!_menu.isShowing) _menu.show();
    _animation.forward();
  }

  void _close() {
    _closeTimer?.cancel();
    _animation.reverse();
  }

  /// Short grace period so the pointer can cross from the label to the menu.
  void _scheduleClose() {
    _closeTimer?.cancel();
    _closeTimer = Timer(const Duration(milliseconds: 160), _close);
  }

  void _run(VoidCallback action) {
    _closeTimer?.cancel();
    _animation.value = 0;
    action();
  }

  void _onTap() => _isOpen ? _run(widget.onTitleTap) : _open();

  @override
  void dispose() {
    _closeTimer?.cancel();
    _curved.dispose();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _menu,
      overlayChildBuilder: (_) => Align(
        alignment: Alignment.topLeft,
        child: CompositedTransformFollower(
          link: _link,
          targetAnchor: Alignment.bottomCenter,
          followerAnchor: Alignment.topCenter,
          child: TapRegion(
            groupId: _link,
            onTapOutside: (_) => _close(),
            child: Actions(
              actions: {DismissIntent: CallbackAction<DismissIntent>(onInvoke: (_) => _close())},
              child: MouseRegion(
                onEnter: (_) => _open(),
                onExit: (_) => _scheduleClose(),
                // The transparent top padding bridges the gap under the label.
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: FadeTransition(
                    opacity: _curved,
                    child: SlideTransition(
                      position: Tween(begin: const Offset(0, -0.03), end: Offset.zero).animate(_curved),
                      child: ScaleTransition(
                        alignment: Alignment.topCenter,
                        scale: Tween(begin: 0.96, end: 1.0).animate(_curved),
                        child: widget.menuBuilder(_run),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      child: CompositedTransformTarget(
        link: _link,
        child: TapRegion(
          groupId: _link,
          child: FocusableActionDetector(
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => _onTap()),
              DismissIntent: CallbackAction<DismissIntent>(onInvoke: (_) => _close()),
            },
            shortcuts: const {SingleActivator(LogicalKeyboardKey.arrowDown): ActivateIntent()},
            onShowHoverHighlight: (hovering) => hovering ? _open() : _scheduleClose(),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, _) => _NavItem(
                label: widget.label,
                active: widget.active,
                highlighted: _isOpen,
                onTap: _onTap,
                trailing: Transform.rotate(
                  angle: _curved.value * math.pi,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: widget.active || _isOpen ? AppColors.accent : AppColors.charcoal.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutMenu extends StatelessWidget {
  const _AboutMenu({required this.current, required this.onSelect});

  final AboutPage? current;
  final ValueChanged<AboutPage> onSelect;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'About menu',
      explicitChildNodes: true,
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.goldLine),
          boxShadow: [BoxShadow(color: AppColors.charcoal.withValues(alpha: 0.14), blurRadius: 40, offset: const Offset(0, 22))],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                child: Text(
                  'ABOUT YODYNIX',
                  style: AppTypography.body(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    letterSpacing: 1.4,
                    height: 1.2,
                  ),
                ),
              ),
              for (final page in AboutPage.values)
                _AboutMenuItem(page: page, active: page == current, onTap: () => onSelect(page)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutMenuItem extends StatefulWidget {
  const _AboutMenuItem({required this.page, required this.active, required this.onTap});

  final AboutPage page;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_AboutMenuItem> createState() => _AboutMenuItemState();
}

class _AboutMenuItemState extends State<_AboutMenuItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final page = widget.page;
    final active = widget.active;
    final lit = active || _hover;

    return Semantics(
      button: true,
      selected: active,
      label: page.title,
      excludeSemantics: true,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (hovering) => setState(() => _hover = hovering),
        onFocusChange: (focused) => setState(() => _hover = focused),
        borderRadius: BorderRadius.circular(AppRadius.md),
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashColor: AppColors.accent.withValues(alpha: 0.08),
        child: AnimatedContainer(
          duration: AppMotion.hover,
          curve: AppMotion.ease,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: active ? AppColors.primarySoft : (_hover ? AppColors.warmIvory : Colors.transparent),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: active ? AppColors.primary.withValues(alpha: 0.45) : Colors.transparent),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: AppMotion.hover,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: lit ? AppColors.primary : AppColors.warmIvory,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: lit ? AppColors.primary : AppColors.lightGrey),
                ),
                child: Icon(page.icon, size: 19, color: lit ? AppColors.onPrimary : AppColors.ink),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      page.title,
                      style: AppTypography.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: lit ? AppColors.accent : AppColors.ink,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      page.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(fontSize: 12.5, color: AppColors.muted, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (active)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                )
              else
                AnimatedSlide(
                  duration: AppMotion.hover,
                  offset: Offset(_hover ? 0 : -0.4, 0),
                  child: AnimatedOpacity(
                    duration: AppMotion.hover,
                    opacity: _hover ? 1 : 0,
                    child: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.accent),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Two-column menu of the ten services, each opening its own page.
class _ServicesMenu extends StatelessWidget {
  const _ServicesMenu({required this.current, required this.onSelect, required this.onViewAll});

  final ServiceOffering? current;
  final ValueChanged<ServiceOffering> onSelect;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    const services = ServicesContent.services;
    final half = (services.length / 2).ceil();
    Widget column(Iterable<ServiceOffering> items) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (final s in items) _ServicesMenuItem(service: s, active: s.id == current?.id, onTap: () => onSelect(s))],
      ),
    );

    return Semantics(
      container: true,
      label: 'Services menu',
      explicitChildNodes: true,
      child: Container(
        width: 620,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.goldLine),
          boxShadow: [BoxShadow(color: AppColors.charcoal.withValues(alpha: 0.14), blurRadius: 40, offset: const Offset(0, 22))],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                child: Text(
                  'OUR SERVICES',
                  style: AppTypography.body(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    letterSpacing: 1.4,
                    height: 1.2,
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [column(services.take(half)), const SizedBox(width: 6), column(services.skip(half))],
              ),
              const SizedBox(height: 6),
              Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 12), color: AppColors.border),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onViewAll,
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text('View all services'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    textStyle: AppTypography.body(fontSize: 13.5, fontWeight: FontWeight.w700, height: 1.2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServicesMenuItem extends StatefulWidget {
  const _ServicesMenuItem({required this.service, required this.active, required this.onTap});

  final ServiceOffering service;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_ServicesMenuItem> createState() => _ServicesMenuItemState();
}

class _ServicesMenuItemState extends State<_ServicesMenuItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    final active = widget.active;
    final lit = active || _hover;
    return Semantics(
      button: true,
      selected: active,
      label: s.title,
      excludeSemantics: true,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (hovering) => setState(() => _hover = hovering),
        onFocusChange: (focused) => setState(() => _hover = focused),
        borderRadius: BorderRadius.circular(AppRadius.md),
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashColor: AppColors.accent.withValues(alpha: 0.08),
        child: AnimatedContainer(
          duration: AppMotion.hover,
          curve: AppMotion.ease,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: active ? AppColors.primarySoft : (_hover ? AppColors.warmIvory : Colors.transparent),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: active ? AppColors.primary.withValues(alpha: 0.45) : Colors.transparent),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: AppMotion.hover,
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: lit ? AppColors.primary : AppColors.warmIvory,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: lit ? AppColors.primary : AppColors.lightGrey),
                ),
                child: Icon(s.icon, size: 17, color: lit ? AppColors.onPrimary : AppColors.ink),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  s.title,
                  style: AppTypography.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: lit ? AppColors.accent : AppColors.ink,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientLoginButton extends StatelessWidget {
  const _ClientLoginButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.charcoal,
        overlayColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        shape: const StadiumBorder(),
        textStyle: AppTypography.body(fontSize: 14.5, fontWeight: FontWeight.w600, height: 1.2),
      ),
      icon: const Icon(Icons.account_circle_outlined, size: 20),
      label: const Text('Client Login'),
    );
  }
}

class MobileNavDrawer extends StatelessWidget {
  const MobileNavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = SectionNavigatorScope.of(context);
    final aboutPage = currentAboutPage(context);
    final service = currentService(context);
    final sitePage = currentSitePage(context);
    final isActive = _activeResolver(nav.active, aboutPage, service, internship: isInternshipRoute(context), page: sitePage);

    // Closes the drawer first; [context] stays valid for the follow-up action.
    void navigate(VoidCallback action) {
      Navigator.of(context).pop();
      action();
    }

    return Drawer(
      width: 320,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(left: Radius.circular(24))),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const BrandLogo(height: 38),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Close menu',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    for (final section in SiteSection.navigation) ...[
                      if (section == SiteSection.internship)
                        for (final page in SitePage.values)
                          _DrawerItem(
                            label: page.label,
                            active: page == sitePage,
                            onTap: () => navigate(() => openSitePage(context, page)),
                          ),
                      if (section == SiteSection.about)
                        _DrawerGroup(
                          label: 'About',
                          active: isActive(section),
                          initiallyExpanded: aboutPage != null,
                          children: [
                            for (final page in AboutPage.values)
                              _DrawerSubItem(
                                icon: page.icon,
                                label: page.title,
                                active: page == aboutPage,
                                onTap: () => navigate(() => openAboutPage(context, page)),
                              ),
                          ],
                        )
                      else if (section == SiteSection.services)
                        _DrawerGroup(
                          label: 'Services',
                          active: isActive(section),
                          initiallyExpanded: service != null,
                          children: [
                            for (final s in ServicesContent.services)
                              _DrawerSubItem(
                                icon: s.icon,
                                label: s.title,
                                active: s.id == service?.id,
                                onTap: () => navigate(() => openServicePage(context, s)),
                              ),
                            _DrawerSubItem(
                              icon: Icons.grid_view_rounded,
                              label: 'View all services',
                              active: false,
                              onTap: () => navigate(() => goToSection(context, SiteSection.services)),
                            ),
                          ],
                        )
                      else
                        _DrawerItem(
                          label: section.navLabel!,
                          active: isActive(section),
                          onTap: () => navigate(
                            () => section == SiteSection.internship ? openInternshipPage(context) : goToSection(context, section),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              SecondaryButton(
                label: 'Client Login',
                icon: Icons.account_circle_outlined,
                expand: true,
                onPressed: () => navigate(() => showClientLoginDialog(context)),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Get Started',
                expand: true,
                onPressed: () => navigate(() => goToSection(context, SiteSection.contact)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: active ? AppColors.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(
                  label,
                  style: AppTypography.body(
                    fontSize: 16,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? AppColors.accent : AppColors.ink,
                    height: 1.2,
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded, color: active ? AppColors.accent : AppColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Expandable entry in the mobile drawer (About, Services) listing its
/// pages. Starts expanded while one of those pages is open.
class _DrawerGroup extends StatefulWidget {
  const _DrawerGroup({required this.label, required this.active, required this.initiallyExpanded, required this.children});

  final String label;
  final bool active;
  final bool initiallyExpanded;
  final List<Widget> children;

  @override
  State<_DrawerGroup> createState() => _DrawerGroupState();
}

class _DrawerGroupState extends State<_DrawerGroup> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            expanded: _expanded,
            child: Material(
              color: active ? AppColors.primarySoft : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Text(
                        widget.label,
                        style: AppTypography.body(
                          fontSize: 16,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? AppColors.accent : AppColors.ink,
                          height: 1.2,
                        ),
                      ),
                      const Spacer(),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: AppMotion.hover,
                        curve: AppMotion.ease,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: active || _expanded ? AppColors.accent : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: AppMotion.ease,
              alignment: Alignment.topCenter,
              child: !_expanded
                  ? const SizedBox(width: double.infinity)
                  : Container(
                      margin: const EdgeInsets.fromLTRB(22, 6, 0, 6),
                      padding: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        border: const Border(left: BorderSide(color: AppColors.lightGrey, width: 2)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: widget.children),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerSubItem extends StatelessWidget {
  const _DrawerSubItem({required this.icon, required this.label, required this.active, required this.onTap});

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: active,
      child: Material(
        color: active ? AppColors.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 18, color: active ? AppColors.accent : AppColors.muted),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.body(
                      fontSize: 15,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? AppColors.accent : AppColors.body,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
