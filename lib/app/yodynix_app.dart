import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/routing/app_navigation.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../features/home/home_page.dart';
import '../providers/section_navigator.dart';

class YodynixApp extends StatefulWidget {
  const YodynixApp({super.key});

  @override
  State<YodynixApp> createState() => _YodynixAppState();
}

class _YodynixAppState extends State<YodynixApp> {
  final SectionNavigator _sections = SectionNavigator();

  /// Keeps the page stack and the browser's history in step: Back and
  /// Forward, refreshes, deep links and section links such as `/#/contact`
  /// (which scroll the existing homepage rather than stacking a second one).
  late final AppNavigation _navigation = AppNavigation(sections: _sections, observers: [_PageTitleObserver()]);

  @override
  void dispose() {
    _navigation.dispose();
    _sections.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SectionNavigatorScope(
      navigator: _sections,
      child: MaterialApp.router(
        title: HomePage.documentTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        themeMode: ThemeMode.light,
        routerDelegate: _navigation,
        routeInformationParser: _navigation.routeInformationParser,
        routeInformationProvider: _navigation.routeInformationProvider,
        backButtonDispatcher: RootBackButtonDispatcher(),
      ),
    );
  }
}

/// Pages set the browser tab title when they open, but a page revealed by
/// going back is not rebuilt, so its title is restored here.
class _PageTitleObserver extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _restore(previousRoute);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => _restore(previousRoute);

  void _restore(Route<dynamic>? current) {
    final name = current?.settings.name;
    if (current == null || name == null) return;
    final title = current.isFirst ? HomePage.documentTitle : '${AppRouter.pageTitle(name) ?? 'Page Not Found'} | YODYNIX';
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(label: title, primaryColor: AppColors.primary.toARGB32()),
    );
  }
}
