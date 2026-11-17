/// Bridge to the WebGL engine in `web/three/yodynix3d.js`. On the web it
/// lazily imports the engine as an ES module; elsewhere (unit tests, other
/// platforms) 3D is unavailable and widgets show their fallback.
library;

export 'three_platform_stub.dart' if (dart.library.js_interop) 'three_platform_web.dart';
