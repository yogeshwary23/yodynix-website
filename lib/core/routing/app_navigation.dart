import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../providers/section_navigator.dart';
import 'app_router.dart';
import 'app_routes.dart';
import 'browser_history.dart';

/// Ties the site's page stack to the browser's history.
///
/// Pages are still ordinary named routes on one [Navigator] (pushed with
/// `pushNamed`, read through `ModalRoute`), but the browser now keeps one
/// history entry per page instead of Flutter's default single entry:
///
/// * Opening a page adds an entry; replacing one (e.g. a redirected link)
///   rewrites the current entry, so history never gains duplicates.
/// * The browser's Back and Forward buttons, typed URLs and refreshes arrive
///   as route information and are reconciled with the stack: going back to
///   the page underneath pops it (keeping its state and scroll position),
///   an earlier page is returned to, anything else is opened.
/// * In-app Back links ([back]) step the browser's own history when the
///   page underneath is the previous entry, so the two never drift apart.
class AppNavigation extends RouterDelegate<RouteInformation> with ChangeNotifier {
  AppNavigation({required this.sections, this.observers = const []}) {
    _current = this;
  }

  /// The delegate of the running app; null before it starts.
  static AppNavigation? get current => _current;
  static AppNavigation? _current;

  final SectionNavigator sections;
  final List<NavigatorObserver> observers;
  final AppRouteInformationProvider routeInformationProvider = AppRouteInformationProvider();
  final AppRouteInformationParser routeInformationParser = const AppRouteInformationParser();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'site');

  late final _RouteStack _stack = _RouteStack(_onStackChanged);

  /// Ticks after the page stack settles, for widgets that show where Back
  /// leads (see `BackBar`).
  final ValueNotifier<int> stackVersion = ValueNotifier(0);
  String? _initialRoute;

  /// The first report rewrites the entry the visitor arrived on (e.g. a
  /// section link that resolves to the homepage) rather than adding one.
  bool _pendingReplace = true;
  bool _reportScheduled = false;
  bool _disposed = false;

  /// The page routes on the stack, bottom first. Dialogs are excluded.
  List<Route<dynamic>> get pages => _stack.pages;

  /// The page route below the one that owns [context], if any.
  Route<dynamic>? previousPage(BuildContext context) {
    final route = ModalRoute.of(context);
    final pages = _stack.pages;
    final index = route == null ? -1 : pages.indexOf(route);
    return index > 0 ? pages[index - 1] : null;
  }

  /// The page route already showing [route] (a resolved path), if any.
  Route<dynamic>? pageFor(String route) {
    final pages = _stack.pages;
    for (var i = pages.length - 1; i >= 0; i--) {
      if (_resolve(pages[i]) == route) return pages[i];
    }
    return null;
  }

  /// Returns to the page that owns [context]'s predecessor: through the
  /// browser's history when that page is the previous entry, otherwise by
  /// popping. With nothing underneath it opens the homepage.
  static void back(BuildContext context) {
    final nav = _current;
    final navigator = Navigator.of(context);
    final previous = nav?.previousPage(context);
    if (nav == null || previous == null) {
      if (navigator.canPop()) {
        navigator.pop();
      } else {
        navigator.pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
      }
      return;
    }
    if (browserHistoryAvailable && nav.routeInformationProvider.history.previousIs(previous.settings.name!)) {
      browserHistoryBack();
    } else {
      navigator.popUntil((r) => r == previous);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    if (identical(_current, this)) _current = null;
    stackVersion.dispose();
    routeInformationProvider.dispose();
    super.dispose();
  }

  @override
  RouteInformation? get currentConfiguration => null; // Reported directly; see [_report].

  @override
  Future<void> setInitialRoutePath(RouteInformation configuration) {
    _initialRoute = _location(configuration.uri);
    return SynchronousFuture<void>(null);
  }

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) {
    _followBrowser(configuration.uri);
    return SynchronousFuture<void>(null);
  }

  @override
  Future<bool> popRoute() => navigatorKey.currentState?.maybePop() ?? SynchronousFuture<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: _initialRoute ?? _location(routeInformationProvider.value.uri),
      onGenerateRoute: AppRouter.onGenerateRoute,
      onGenerateInitialRoutes: (_, initialRoute) =>
          AppRouter.onGenerateInitialRoutes(initialRoute, onSectionLink: sections.revealOnLaunch),
      observers: [_stack, ...observers],
    );
  }

  /// Brings the stack in line with a URL the browser moved to.
  void _followBrowser(Uri uri) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    // The browser has already made (or moved to) this entry.
    _pendingReplace = true;
    final path = uri.path.isEmpty ? AppRoutes.home : uri.path;
    final target = AppRoutes.resolve(path);
    final section = target == AppRoutes.home ? null : AppRoutes.sectionFor(target);
    final top = _stack.pages.isEmpty ? null : _stack.pages.last;

    if (target == AppRoutes.home || section != null) {
      // Homepage and its section links share the one homepage underneath.
      navigator.popUntil((r) => r.isFirst);
      if (section != null) WidgetsBinding.instance.addPostFrameCallback((_) => sections.scrollTo(section));
    } else if (top != null && _resolve(top) == target) {
      // Already showing.
    } else if (pageFor(target) case final existing?) {
      navigator.popUntil((r) => r == existing);
    } else {
      navigator.pushNamed(uri.hasQuery ? '$target?${uri.query}' : target);
    }
    _scheduleReport();
  }

  void _onStackChanged({required bool replaced}) {
    _pendingReplace = _pendingReplace || replaced;
    _scheduleReport();
  }

  /// Reports the top page once the navigator has finished its update.
  void _scheduleReport() {
    if (_reportScheduled) return;
    _reportScheduled = true;
    scheduleMicrotask(_report);
  }

  void _report() {
    _reportScheduled = false;
    if (_disposed) return;
    final pages = _stack.pages;
    stackVersion.value++;
    if (pages.isEmpty) return;
    routeInformationProvider.report(pages.last.settings.name!, replace: _pendingReplace);
    _pendingReplace = false;
  }

  static String _resolve(Route<dynamic> route) => AppRoutes.resolve(route.settings.name!);

  static String _location(Uri uri) {
    final path = uri.path.isEmpty ? AppRoutes.home : uri.path;
    return uri.hasQuery ? '$path?${uri.query}' : path;
  }
}

/// Tracks the routes on the navigator; [pages] are those with a name.
class _RouteStack extends NavigatorObserver {
  _RouteStack(this.onChanged);

  final void Function({required bool replaced}) onChanged;
  final List<Route<dynamic>> _routes = [];

  List<Route<dynamic>> get pages => [
    for (final r in _routes)
      if (r.settings.name != null && r is PageRoute) r,
  ];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.add(route);
    onChanged(replaced: false);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.remove(route);
    onChanged(replaced: false);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.remove(route);
    onChanged(replaced: false);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = oldRoute == null ? -1 : _routes.indexOf(oldRoute);
    if (newRoute != null) {
      if (index >= 0) {
        _routes[index] = newRoute;
      } else {
        _routes.add(newRoute);
      }
    }
    onChanged(replaced: true);
  }
}

/// Route information is used as-is; the delegate resolves it.
class AppRouteInformationParser extends RouteInformationParser<RouteInformation> {
  const AppRouteInformationParser();

  @override
  Future<RouteInformation> parseRouteInformation(RouteInformation routeInformation) =>
      SynchronousFuture<RouteInformation>(routeInformation);

  @override
  RouteInformation? restoreRouteInformation(RouteInformation configuration) => configuration;
}

/// Receives URLs from the browser and writes the current page back to it as
/// multi-entry history, choosing push or replace for each change.
class AppRouteInformationProvider extends RouteInformationProvider with WidgetsBindingObserver, ChangeNotifier {
  AppRouteInformationProvider() : _value = RouteInformation(uri: _initialUri()) {
    history = BrowserHistoryMirror(_key(_value.uri));
  }

  static Uri _initialUri() {
    final name = WidgetsBinding.instance.platformDispatcher.defaultRouteName;
    return Uri.parse(name.isEmpty ? AppRoutes.home : name);
  }

  /// What the browser's history holds, as far as this session knows.
  late final BrowserHistoryMirror history;

  @override
  RouteInformation get value => _value;
  RouteInformation _value;

  /// Writes [location] to the browser unless it is already showing.
  void report(String location, {required bool replace}) {
    if (location == _key(_value.uri)) return;
    final uri = Uri.parse(location);
    SystemNavigator.selectMultiEntryHistory();
    SystemNavigator.routeInformationUpdated(uri: uri, replace: replace);
    history.reported(location, replace: replace);
    _value = RouteInformation(uri: uri);
  }

  // The delegate reports through [report]; Router never asks (see
  // AppNavigation.currentConfiguration).
  @override
  void routerReportsNewRouteInformation(RouteInformation routeInformation, {RouteInformationReportingType type = RouteInformationReportingType.none}) {}

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    history.arrived(_key(routeInformation.uri));
    _value = routeInformation;
    notifyListeners();
    return SynchronousFuture<bool>(true);
  }

  @override
  void addListener(VoidCallback listener) {
    if (!hasListeners) WidgetsBinding.instance.addObserver(this);
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) WidgetsBinding.instance.removeObserver(this);
  }

  static String _key(Uri uri) {
    final path = uri.path.isEmpty ? AppRoutes.home : uri.path;
    return uri.hasQuery ? '$path?${uri.query}' : path;
  }
}

/// A record of the browser history entries this session created, and where
/// the browser currently is among them, so in-app Back can tell whether
/// stepping the browser back lands on the page underneath.
class BrowserHistoryMirror {
  BrowserHistoryMirror(String initial) : _entries = [initial];

  final List<String> _entries;
  int _index = 0;

  bool previousIs(String location) => _index > 0 && _entries[_index - 1] == location;

  /// The app wrote [location]: a new entry, or a rewrite of the current one.
  void reported(String location, {required bool replace}) {
    if (replace) {
      _entries[_index] = location;
    } else {
      _entries.removeRange(_index + 1, _entries.length);
      _entries.add(location);
      _index++;
    }
  }

  /// The browser moved to [location]: one step back or forward, or a new
  /// entry (a typed URL).
  void arrived(String location) {
    if (_index > 0 && _entries[_index - 1] == location) {
      _index--;
    } else if (_index + 1 < _entries.length && _entries[_index + 1] == location) {
      _index++;
    } else if (_entries[_index] != location) {
      _entries.removeRange(_index + 1, _entries.length);
      _entries.add(location);
      _index++;
    }
  }
}
