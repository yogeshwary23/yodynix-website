import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/rendering.dart' show PlatformViewHitTestBehavior;
import 'package:flutter/widgets.dart';

import 'scene3d.dart';

extension type _Engine(JSObject _) implements JSObject {
  external bool supported();
  external _View mount(JSObject host, String scene, JSObject options);
}

extension type _View(JSObject _) implements JSObject {
  external void setActive(bool active);
  external void setProgress(double progress);
  external void setPointer(double x, double y);
  external void setFocus(double focus);
  external void dispose();
}

class _WebSceneHandle implements SceneHandle {
  _WebSceneHandle(this._view);

  _View? _view;

  @override
  void setActive(bool active) => _view?.setActive(active);

  @override
  void setProgress(double progress) => _view?.setProgress(progress);

  @override
  void setPointer(double x, double y) => _view?.setPointer(x, y);

  @override
  void setFocus(double focus) => _view?.setFocus(focus);

  @override
  void dispose() {
    _view?.dispose();
    _view = null;
  }
}

/// Loads the engine module on first use, so pages that never show a 3D
/// scene never download Three.js.
class ThreePlatform {
  ThreePlatform._();

  static _Engine? _engine;
  static Future<bool>? _loading;
  static bool? _supported;

  /// Null until [ensureLoaded] has finished.
  static bool? get supportedSync => _supported;

  static Future<bool> ensureLoaded() => _loading ??= _load();

  static Future<bool> _load() async {
    try {
      final document = globalContext.getProperty<JSObject>('document'.toJS);
      final base = document.getProperty<JSString>('baseURI'.toJS).toDart;
      final url = Uri.parse(base).resolve('three/yodynix3d.js').toString();
      final module = await importModule(url.toJS).toDart;
      final engine = _Engine(module);
      _supported = engine.supported();
      if (_supported!) _engine = engine;
    } catch (error) {
      debugPrint('YODYNIX 3D unavailable: $error');
      _supported = false;
    }
    return _supported!;
  }

  static int get cpuCores {
    final navigator = globalContext.getProperty<JSObject?>('navigator'.toJS);
    final cores = navigator?.getProperty<JSNumber?>('hardwareConcurrency'.toJS);
    return cores?.toDartInt ?? 4;
  }

  /// An HTML element hosting [scene]; [onMounted] receives its handle once
  /// the engine has attached to the element, and [onLost] fires if the
  /// browser drops the WebGL context.
  static Widget buildHost({
    required Scene3D scene,
    required SceneOptions options,
    required ValueChanged<SceneHandle> onMounted,
    required VoidCallback onLost,
  }) {
    return HtmlElementView.fromTagName(
      tagName: 'div',
      // Pointer events pass through to Flutter, so scrolling and clicks over
      // the scene behave exactly as they do elsewhere on the page.
      hitTestBehavior: PlatformViewHitTestBehavior.transparent,
      onElementCreated: (element) {
        final engine = _engine;
        if (engine == null) return;
        final host = element as JSObject;
        final style = host.getProperty<JSObject>('style'.toJS);
        style
          ..setProperty('width'.toJS, '100%'.toJS)
          ..setProperty('height'.toJS, '100%'.toJS)
          ..setProperty('pointerEvents'.toJS, 'none'.toJS);
        host.callMethod<JSAny?>('addEventListener'.toJS, 'yodynix3d-lost'.toJS, ((JSAny _) => onLost()).toJS);
        final view = engine.mount(host, scene.name, _options(options));
        onMounted(_WebSceneHandle(view));
      },
    );
  }

  static JSObject _options(SceneOptions o) {
    final background = o.background;
    return <String, Object?>{
      'quality': o.quality.name,
      'reducedMotion': o.reducedMotion,
      'background': background == null ? null : background.toARGB32() & 0xFFFFFF,
      'image': o.image,
      'variant': o.variant,
      'lean': o.lean,
    }.jsify()! as JSObject;
  }
}
