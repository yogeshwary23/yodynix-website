/// Steps the browser's own history back. Only meaningful on the web; other
/// platforms (unit tests) get a no-op and fall back to popping the route.
library;

export 'browser_history_stub.dart' if (dart.library.js_interop) 'browser_history_web.dart';
