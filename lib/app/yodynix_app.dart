import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/site_config.dart';
import '../core/routing/app_router.dart';
import '../core/routing/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../features/home/home_page.dart';
import '../models/site_section.dart';
import '../providers/section_navigator.dart';

class YodynixApp extends StatefulWidget {
  const YodynixApp({super.key});

  @override
  State<YodynixApp> createState() => _YodynixAppState();
}

class _YodynixAppState extends State<YodynixApp> with WidgetsBindingObserver {
  final SectionNavigator _navigator = SectionNavigator();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Registered before MaterialApp's own observer, so it is asked first.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _navigator.dispose();
    super.dispose();
  }

  /// URLs typed into the address bar and the browser's Forward button arrive
  /// here. By default they are pushed as new routes, which would stack a
  /// second homepage (sharing one scroll controller and section keys) for
  /// links such as `/#/contact`. Homepage and section links instead return
  /// to the existing homepage and scroll to the section; every other link
  /// falls through to the default handling.
  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) async {
    final navigator = _navigatorKey.currentState;
    final path = routeInformation.uri.path;
    final route = AppRoutes.resolve(path.isEmpty ? AppRoutes.home : path);
    final section = route == AppRoutes.home ? SiteSection.home : AppRoutes.sectionFor(route);
    if (navigator == null || section == null) return false;

    navigator.popUntil((r) => r.isFirst);
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigator.scrollTo(section));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SectionNavigatorScope(
      navigator: _navigator,
      child: MaterialApp(
        title: '${SiteConfig.brandName} | ${SiteConfig.brandCategory}',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        navigatorKey: _navigatorKey,
        navigatorObservers: [_HomeTitleObserver()],
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRouter.onGenerateRoute,
        onGenerateInitialRoutes: (route) => AppRouter.onGenerateInitialRoutes(route, onSectionLink: _navigator.revealOnLaunch),
      ),
    );
  }
}

/// Sub-pages set the browser tab title when they open, but the homepage
/// underneath is not rebuilt when they close, so its title is restored here.
class _HomeTitleObserver extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _restore(previousRoute);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => _restore(previousRoute);

  void _restore(Route<dynamic>? current) {
    if (current == null || !current.isFirst) return;
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(label: HomePage.documentTitle, primaryColor: AppColors.primary.toARGB32()),
    );
  }
}
