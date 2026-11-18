import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// The site-wide ambient background: small champagne-gold, gold and silver
/// spheres drifting at different depths, a few nearby ones joined by
/// hairline gold lines, each fading in and out over its own lifetime.
///
/// One [ParticleField] lives for the whole app. It moves the particles and
/// works out the links once per frame, in screen coordinates, on a single
/// ticker that runs only while a layer is mounted and never when the visitor
/// prefers reduced motion. Each section paints a [ParticleNetworkLayer]
/// between its background and its content; the layer draws its own slice of
/// the shared field, so the network runs on unbroken from one section into
/// the next and stays still as the page scrolls past, like a fixed
/// background. Layers never take part in hit testing.
class ParticleNetworkLayer extends LeafRenderObjectWidget {
  const ParticleNetworkLayer({super.key});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderParticleLayer(MediaQuery.maybeDisableAnimationsOf(context) ?? false);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderParticleLayer).reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }
}

class _RenderParticleLayer extends RenderBox {
  _RenderParticleLayer(this._reduced);

  bool _reduced;
  set reduced(bool value) {
    if (value == _reduced) return;
    _reduced = value;
    if (attached) ParticleField.instance._sync();
  }

  /// Whether the last paint drew anything, so a layer leaving the screen
  /// repaints once more to clear itself.
  bool _drew = false;

  @override
  bool get isRepaintBoundary => true;

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    ParticleField.instance._add(this);
  }

  @override
  void detach() {
    ParticleField.instance._remove(this);
    super.detach();
  }

  Rect? get _screenRect => hasSize ? localToGlobal(Offset.zero) & size : null;

  /// Called by the field after each step.
  void _onFieldChanged() {
    if (!attached || !hasSize) return;
    final rect = _screenRect!;
    if (_drew || rect.overlaps(Offset.zero & ParticleField.instance._viewport)) markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final field = ParticleField.instance;
    final rect = _screenRect!;
    _drew = field._ready && rect.overlaps(Offset.zero & field._viewport);
    if (!_drew) return;
    final canvas = context.canvas
      ..save()
      ..clipRect(offset & size)
      ..translate(offset.dx - rect.left, offset.dy - rect.top);
    field._paint(canvas);
    canvas.restore();
  }
}

class _Particle {
  double x = 0, y = 0;
  double z = 0; // depth: 0 far and faint, 1 near and bright
  double heading = 0, speed = 0, turn = 0;
  double age = 0, life = 1;
  int kind = 0; // 0 champagne, 1 gold, 2 silver
  double glowPeriod = 0, glowPhase = 0; // 0 period: never glows

  // Per-frame results.
  double sx = 0, sy = 0, alpha = 0, glow = 0;
  int links = 0;
}

/// The shared particle simulation behind every [ParticleNetworkLayer].
class ParticleField {
  ParticleField._();

  static final ParticleField instance = ParticleField._();

  static const _cell = 64.0;
  static const _sphereRadius = 26.0;
  static const _lineColor = Color(0xFFC4A060);
  static const _buckets = 6;
  static const _lineAlpha = 0.7;

  final List<_RenderParticleLayer> _layers = [];
  final math.Random _random = math.Random(7);
  final List<_Particle> _particles = [];
  Ticker? _ticker;
  Duration _last = Duration.zero;
  double _sinceStep = 0;
  double _time = 0;
  Size _viewport = Size.zero;
  Offset _pointerTarget = Offset.zero;
  Offset _pointer = Offset.zero;
  bool _routed = false;

  ui.Image? _atlas;
  bool _loading = false;
  bool get _ready => _atlas != null && _particles.isNotEmpty;

  // Drawing buffers, reused every frame.
  Float32List _transforms = Float32List(0);
  Float32List _rects = Float32List(0);
  Int32List _colors = Int32List(0);
  int _sprites = 0;
  final List<Float32List> _lines = List.generate(_buckets, (_) => Float32List(0));
  final List<int> _lineCounts = List.filled(_buckets, 0);
  final Paint _spritePaint = Paint()..filterQuality = FilterQuality.medium;
  final Paint _linePaint = Paint()
    ..strokeWidth = 0.8
    ..strokeCap = StrokeCap.round;

  bool get _reduced => _layers.any((l) => l._reduced);

  void _add(_RenderParticleLayer layer) {
    _layers.add(layer);
    _loadAtlas();
    _sync();
  }

  void _remove(_RenderParticleLayer layer) {
    _layers.remove(layer);
    _sync();
  }

  /// Starts or stops the ticker and pointer tracking to match the layers.
  void _sync() {
    _resize();
    final animate = _layers.isNotEmpty && !_reduced;
    if (animate) {
      _ticker ??= Ticker(_tick, debugLabel: 'ParticleField');
      if (!_ticker!.isActive) {
        _last = Duration.zero;
        _ticker!.start();
      }
    } else {
      _ticker?.stop();
      _step(0);
      _notify();
    }
    final track = animate;
    if (track != _routed) {
      _routed = track;
      final router = GestureBinding.instance.pointerRouter;
      track ? router.addGlobalRoute(_onPointer) : router.removeGlobalRoute(_onPointer);
    }
  }

  void _onPointer(PointerEvent event) {
    if (event.kind != PointerDeviceKind.mouse || _viewport.isEmpty) return;
    if (event is PointerHoverEvent || event is PointerMoveEvent) {
      _pointerTarget = Offset(
        (event.position.dx / _viewport.width * 2 - 1).clamp(-1.0, 1.0),
        (event.position.dy / _viewport.height * 2 - 1).clamp(-1.0, 1.0),
      );
    }
  }

  void _tick(Duration elapsed) {
    // Long gaps (a hidden tab) resume smoothly rather than jumping ahead.
    final dt = _last == Duration.zero ? 0.0 : math.min(0.1, (elapsed - _last).inMicroseconds / 1e6);
    _last = elapsed;
    _sinceStep += dt;
    // About 30 steps a second: drift this slow looks the same, at half the work.
    if (_sinceStep < 1 / 32) return;
    _resize();
    _step(_sinceStep);
    _sinceStep = 0;
    _notify();
  }

  void _notify() {
    for (final layer in List.of(_layers)) {
      layer._onFieldChanged();
    }
  }

  // ----------------------------------------------------------- simulation

  void _resize() {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) return;
    final view = views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    if (size.isEmpty || size == _viewport) return;
    final old = _viewport;
    _viewport = size;
    // Sparse on purpose: an atmosphere, not a mesh.
    final target = (size.width * size.height / 21000).round().clamp(22, 72);
    if (!old.isEmpty) {
      for (final p in _particles) {
        p
          ..x = p.x / old.width * size.width
          ..y = p.y / old.height * size.height;
      }
    }
    while (_particles.length > target) {
      _particles.removeLast();
    }
    while (_particles.length < target) {
      // The first scatter starts part-way through each life, so the field
      // is already populated; later ones fade in from nothing.
      _particles.add(_spawn(_Particle(), settled: true));
    }
  }

  _Particle _spawn(_Particle p, {bool settled = false}) {
    final r = _random;
    p
      ..x = r.nextDouble() * _viewport.width
      ..y = r.nextDouble() * _viewport.height
      ..z = math.pow(r.nextDouble(), 1.4).toDouble()
      ..heading = r.nextDouble() * math.pi * 2
      ..turn = (r.nextDouble() - 0.5) * 0.25
      ..life = 11 + r.nextDouble() * 14
      ..kind = switch (r.nextDouble()) { < 0.45 => 0, < 0.8 => 1, _ => 2 }
      ..glowPeriod = r.nextDouble() < 0.16 ? 6 + r.nextDouble() * 6 : 0
      ..glowPhase = r.nextDouble() * math.pi * 2;
    p
      ..speed = 3 + p.z * 9
      ..age = settled ? (_reduced ? p.life / 2 : r.nextDouble() * p.life) : 0;
    return p;
  }

  void _step(double dt) {
    if (_viewport.isEmpty) return;
    _time += dt;
    final w = _viewport.width, h = _viewport.height;
    final wide = w >= 700;
    _pointer = Offset.lerp(_pointer, _pointerTarget, math.min(1, dt * 2.5))!;
    const margin = 40.0;

    for (final p in _particles) {
      p.age += dt;
      p.heading += p.turn * math.sin(_time * 0.2 + p.glowPhase) * dt;
      p.x += math.cos(p.heading) * p.speed * dt;
      p.y += math.sin(p.heading) * p.speed * dt;
      if (p.age >= p.life || p.x < -margin || p.x > w + margin || p.y < -margin || p.y > h + margin) {
        _spawn(p);
      }
      // Nearer particles shift further with the pointer: depth parallax.
      final shift = 4 + p.z * 18;
      p
        ..sx = p.x - _pointer.dx * shift
        ..sy = p.y - _pointer.dy * shift;

      final fade = _smooth(math.min(p.age, p.life - p.age) / 3);
      p.alpha = fade * (0.42 + 0.58 * p.z) * _calm(p.sx, w, wide);
      if (p.glowPeriod > 0) {
        final pulse = math.max(0.0, math.sin(_time * math.pi * 2 / p.glowPeriod + p.glowPhase));
        p.glow = math.pow(pulse, 8).toDouble() * p.alpha;
      } else {
        p.glow = 0;
      }
      p.links = 0;
    }
    _buildSprites(wide);
    _buildLines(w, wide);
  }

  /// Fewer, fainter particles over the central content column on wide
  /// screens; phones are mostly cards, so the field stays even there.
  static double _calm(double x, double width, bool wide) {
    if (!wide) return 0.8;
    final off = (x / width - 0.5).abs();
    return 0.5 + 0.5 * _smooth((off - 0.16) / 0.22);
  }

  static double _smooth(double t) {
    final c = t.clamp(0.0, 1.0);
    return c * c * (3 - 2 * c);
  }

  void _buildSprites(bool wide) {
    final glows = _particles.where((p) => p.glow > 0.01).length;
    final n = _particles.length + glows;
    if (_transforms.length < n * 4) {
      _transforms = Float32List(n * 4);
      _rects = Float32List(n * 4);
      _colors = Int32List(n);
    }
    var i = 0;
    void add(int cell, double x, double y, double radius, double alpha, double cellRadius) {
      final s = radius / cellRadius;
      final o = i * 4;
      _transforms
        ..[o] = s
        ..[o + 1] = 0
        ..[o + 2] = x - s * _cell / 2
        ..[o + 3] = y - s * _cell / 2;
      _rects
        ..[o] = cell * _cell
        ..[o + 1] = 0
        ..[o + 2] = (cell + 1) * _cell
        ..[o + 3] = _cell;
      _colors[i] = ((alpha.clamp(0.0, 1.0) * 255).round() << 24) | 0xFFFFFF;
      i++;
    }

    final scale = wide ? 1.0 : 0.85;
    // Glows first, so the spheres sit on top of them.
    for (final p in _particles) {
      if (p.glow > 0.01) add(3, p.sx, p.sy, (2 + p.z * 5) * 5 * scale, p.glow * 0.6, _cell / 2);
    }
    for (final p in _particles) {
      final radius = (1.4 + math.pow(p.z, 1.4) * 4.4) * scale;
      add(p.kind, p.sx, p.sy, radius, p.alpha, _sphereRadius);
    }
    _sprites = i;
  }

  void _buildLines(double w, bool wide) {
    final reach = (w * 0.13).clamp(100.0, 190.0);
    final reach2 = reach * reach;
    _lineCounts.fillRange(0, _buckets, 0);
    final ps = _particles;
    for (var a = 0; a < ps.length; a++) {
      final p = ps[a];
      if (p.alpha < 0.05) continue;
      for (var b = a + 1; b < ps.length && p.links < 3; b++) {
        final q = ps[b];
        // Only particles at a similar depth connect, and each to at most three.
        if (q.links >= 3 || q.alpha < 0.05 || (p.z - q.z).abs() > 0.45) continue;
        final dx = p.sx - q.sx, dy = p.sy - q.sy;
        final d2 = dx * dx + dy * dy;
        if (d2 > reach2) continue;
        final closeness = 1 - math.sqrt(d2) / reach;
        final alpha = math.pow(closeness, 1.2) * math.min(p.alpha, q.alpha) * _lineAlpha;
        final bucket = (alpha / _lineAlpha * _buckets).floor().clamp(0, _buckets - 1);
        if (alpha < 0.02) continue;
        p.links++;
        q.links++;
        var buffer = _lines[bucket];
        final o = _lineCounts[bucket] * 4;
        if (buffer.length < o + 4) {
          final grown = Float32List(math.max(64, buffer.length * 2));
          grown.setAll(0, buffer);
          buffer = _lines[bucket] = grown;
        }
        buffer
          ..[o] = p.sx
          ..[o + 1] = p.sy
          ..[o + 2] = q.sx
          ..[o + 3] = q.sy;
        _lineCounts[bucket]++;
      }
    }
  }

  // -------------------------------------------------------------- drawing

  void _paint(Canvas canvas) {
    for (var b = 0; b < _buckets; b++) {
      final count = _lineCounts[b];
      if (count == 0) continue;
      _linePaint.color = _lineColor.withValues(alpha: (b + 0.5) / _buckets * _lineAlpha);
      canvas.drawRawPoints(ui.PointMode.lines, Float32List.sublistView(_lines[b], 0, count * 4), _linePaint);
    }
    if (_sprites == 0) return;
    canvas.drawRawAtlas(
      _atlas!,
      Float32List.sublistView(_transforms, 0, _sprites * 4),
      Float32List.sublistView(_rects, 0, _sprites * 4),
      Int32List.sublistView(_colors, 0, _sprites),
      BlendMode.modulate,
      null,
      _spritePaint,
    );
  }

  /// Draws the four sprites once: champagne, gold and silver spheres lit
  /// from the upper left with a bright specular point, and a soft glow.
  Future<void> _loadAtlas() async {
    if (_atlas != null || _loading) return;
    _loading = true;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const tones = [
      [Color(0xFFFFFBEF), Color(0xFFEFD9AA), Color(0xFFC5A465), Color(0xFF8A6D3B)],
      [Color(0xFFFFF4D6), Color(0xFFE6C276), Color(0xFFAD7F30), Color(0xFF6A4A1A)],
      [Color(0xFFFFFFFF), Color(0xFFE6E6E3), Color(0xFFA8A8A4), Color(0xFF6C6C69)],
    ];
    for (var i = 0; i < 3; i++) {
      final center = Offset(i * _cell + _cell / 2, _cell / 2);
      final sphere = Rect.fromCircle(center: center, radius: _sphereRadius);
      canvas.drawCircle(
        center,
        _sphereRadius,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.35, -0.4),
            radius: 1.05,
            colors: tones[i],
            stops: const [0, 0.28, 0.72, 1],
          ).createShader(sphere),
      );
      // Specular highlight.
      final spot = center + const Offset(-0.34, -0.4) * _sphereRadius;
      canvas.drawCircle(
        spot,
        _sphereRadius * 0.3,
        Paint()
          ..shader = const RadialGradient(
            colors: [Color(0xE6FFFFFF), Color(0x00FFFFFF)],
          ).createShader(Rect.fromCircle(center: spot, radius: _sphereRadius * 0.3)),
      );
    }
    final glowCenter = Offset(3 * _cell + _cell / 2, _cell / 2);
    canvas.drawCircle(
      glowCenter,
      _cell / 2,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xCCFFE3A8), Color(0x40F2CF86), Color(0x00F2CF86)],
          stops: [0, 0.35, 1],
        ).createShader(Rect.fromCircle(center: glowCenter, radius: _cell / 2)),
    );
    final picture = recorder.endRecording();
    _atlas = await picture.toImage((_cell * 4).toInt(), _cell.toInt());
    picture.dispose();
    _resize();
    if (_ticker?.isActive != true) _step(0);
    _notify();
  }
}
