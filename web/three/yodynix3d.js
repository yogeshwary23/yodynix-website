/**
 * YODYNIX 3D engine.
 *
 * One shared WebGL renderer draws every 3D view on the page. Each view owns a
 * plain 2D canvas inside its Flutter platform view; after a view's scene is
 * rendered into a corner of the shared WebGL canvas, that region is copied
 * into the view's canvas. This keeps the page to a single WebGL context no
 * matter how many views are mounted, and lets every scene share one
 * pre-filtered studio environment map and the shader programs compiled for
 * it.
 *
 * Public API (used from Dart via `lib/shared/three/`):
 *   supported()                       → whether WebGL is available
 *   mount(host, sceneName, options)   → View handle
 *   view.setActive(bool)              → on screen? (off-screen views never render)
 *   view.setProgress(0..1)            → scroll progress through the viewport
 *   view.setPointer(x, y)             → -1..1 pointer position for parallax
 *   view.setFocus(0..1)               → hover / emphasis
 *   view.dispose()                    → frees GPU resources and listeners
 *
 * Scenes are built procedurally from physically based materials (polished
 * platinum chrome, brushed aluminium, champagne and liquid gold, and transmissive glass) so
 * they share one recognisable visual language without large model downloads.
 */
import * as THREE from '../vendor/three/three.module.min.js';
import { RoundedBoxGeometry } from '../vendor/three/RoundedBoxGeometry.js';

// Champagne gold, platinum, pearl, warm beige and charcoal. No blue anywhere.
const BRAND = {
  pearl: 0xf8f6f1,
  beige: 0xede4d6,
  platinum: 0xe4e2dd,
  gold: 0xc6a46a,
  goldDeep: 0xa98245,
  softGold: 0xe3cfa3,
  charcoal: 0x2a2826,
  white: 0xffffff,
};

const QUALITY = {
  high: { dpr: 2, particles: 1, segments: 1, antialias: true, shadow: 1024 },
  medium: { dpr: 1.5, particles: 0.6, segments: 0.75, antialias: true, shadow: 512 },
  low: { dpr: 1, particles: 0.3, segments: 0.5, antialias: false, shadow: 0 },
};

// ───────────────────────────────────────────────────────────────────────────
// Capability check
// ───────────────────────────────────────────────────────────────────────────

let supportCache = null;

export function supported() {
  if (supportCache !== null) return supportCache;
  try {
    const canvas = document.createElement('canvas');
    const gl = canvas.getContext('webgl2') || canvas.getContext('webgl');
    supportCache = !!gl;
    gl?.getExtension('WEBGL_lose_context')?.loseContext();
  } catch (_) {
    supportCache = false;
  }
  return supportCache;
}

// ───────────────────────────────────────────────────────────────────────────
// Shared engine
// ───────────────────────────────────────────────────────────────────────────

let engine = null;

class Engine {
  constructor() {
    this.canvas = document.createElement('canvas');
    this.renderer = new THREE.WebGLRenderer({
      canvas: this.canvas,
      antialias: true,
      alpha: true,
      premultipliedAlpha: true,
      powerPreference: 'high-performance',
    });
    const r = this.renderer;
    r.setPixelRatio(1); // views size the buffer in device pixels themselves
    r.setClearColor(0x000000, 0);
    r.autoClear = false;
    // Khronos PBR Neutral keeps the champagne hue true; ACES pushes gold orange.
    r.toneMapping = THREE.NeutralToneMapping;
    r.toneMappingExposure = 1.0;
    r.outputColorSpace = THREE.SRGBColorSpace;
    // Soft, blurred shadows; only the hero's key light casts any.
    r.shadowMap.enabled = true;
    r.shadowMap.type = THREE.VSMShadowMap;

    const pmrem = new THREE.PMREMGenerator(r);
    const studio = studioEnvironment();
    this.envMap = pmrem.fromScene(studio, 0.02).texture;
    disposeScene(studio);
    pmrem.dispose();

    this.views = new Set();
    this.bufW = 0;
    this.bufH = 0;
    this.raf = 0;
    this.last = 0;
    this.disposeTimer = 0;
    this.lost = false;
    this.loop = this.loop.bind(this);

    this.onLost = (e) => {
      e.preventDefault();
      this.lost = true;
      // Views fall back to still renders; later mounts get a fresh engine.
      if (engine === this) engine = null;
      for (const v of this.views) v.onContextLost();
    };
    this.canvas.addEventListener('webglcontextlost', this.onLost);

    // Pause entirely while the tab is hidden.
    this.onVisibility = () => {
      if (!document.hidden) this.kick();
    };
    document.addEventListener('visibilitychange', this.onVisibility);
  }

  add(view) {
    clearTimeout(this.disposeTimer);
    this.views.add(view);
    this.kick();
  }

  remove(view) {
    this.views.delete(view);
    if (this.views.size === 0) {
      // A short grace period so page transitions don't rebuild the context.
      this.disposeTimer = setTimeout(() => {
        if (this.views.size === 0) this.dispose();
      }, 4000);
    }
  }

  kick() {
    if (!this.raf && !this.lost && !document.hidden) this.raf = requestAnimationFrame(this.loop);
  }

  loop(now) {
    this.raf = 0;
    if (this.lost || document.hidden) return;
    const dt = this.last ? Math.min((now - this.last) / 1000, 1 / 20) : 1 / 60;
    this.last = now;
    let keepGoing = false;
    for (const view of this.views) {
      if (!view.wantsFrame()) continue;
      const start = performance.now();
      view.step(dt);
      this.draw(view);
      view.recordCost(performance.now() - start);
      keepGoing ||= view.isAnimating();
    }
    if (keepGoing) this.kick();
    else this.last = 0;
  }

  draw(view) {
    const { pxW: w, pxH: h } = view;
    if (w < 2 || h < 2) return;
    const r = this.renderer;
    if (w > this.bufW || h > this.bufH) {
      this.bufW = Math.max(this.bufW, w);
      this.bufH = Math.max(this.bufH, h);
      r.setSize(this.bufW, this.bufH, false);
    }
    r.setViewport(0, 0, w, h);
    r.setScissor(0, 0, w, h);
    r.setScissorTest(true);
    // Per view: three.js leaves an opaque scene's background as the shared
    // renderer's clear colour, which would fill transparent views after it.
    const bg = view.scene.background;
    if (bg && bg.isColor) r.setClearColor(bg, 1);
    else r.setClearColor(0x000000, 0);
    r.clear(true, true, true);
    r.render(view.scene, view.camera);
    r.setScissorTest(false);
    view.blit(this.canvas, this.bufH);
  }

  dispose() {
    cancelAnimationFrame(this.raf);
    this.raf = 0;
    this.canvas.removeEventListener('webglcontextlost', this.onLost);
    document.removeEventListener('visibilitychange', this.onVisibility);
    this.envMap.dispose();
    this.renderer.dispose();
    this.renderer.forceContextLoss();
    if (engine === this) engine = null;
  }
}

function getEngine() {
  if (!engine) engine = new Engine();
  return engine;
}

// ───────────────────────────────────────────────────────────────────────────
// View
// ───────────────────────────────────────────────────────────────────────────

const damp = (current, target, rate, dt) => current + (target - current) * (1 - Math.exp(-rate * dt));

class View {
  constructor(host, sceneName, options) {
    const builder = SCENES[sceneName];
    if (!builder) throw new Error(`Unknown YODYNIX scene "${sceneName}"`);

    this.host = host;
    this.options = options;
    this.quality = QUALITY[options.quality] || QUALITY.high;
    this.reduced = !!options.reducedMotion;
    this.engine = getEngine();

    this.canvas = document.createElement('canvas');
    Object.assign(this.canvas.style, {
      width: '100%',
      height: '100%',
      display: 'block',
      pointerEvents: 'none',
    });
    this.canvas.setAttribute('aria-hidden', 'true');
    // Feather the edges so an opaque scene dissolves into the page rather
    // than sitting in a visible box. Transparent scenes need no feathering.
    if (options.feather !== false && options.background != null) {
      const mask = 'radial-gradient(ellipse 50% 50% at 50% 50%, #000 72%, transparent 100%)';
      this.canvas.style.maskImage = mask;
      this.canvas.style.webkitMaskImage = mask;
    }
    host.appendChild(this.canvas);
    this.ctx = this.canvas.getContext('2d');

    this.scene = new THREE.Scene();
    this.scene.environment = this.engine.envMap;
    // An opaque backdrop matching the host surface lets transmissive glass
    // refract something real instead of an empty, transparent buffer.
    if (options.background != null) this.scene.background = new THREE.Color(options.background);
    this.camera = new THREE.PerspectiveCamera(30, 1, 0.1, 100);

    this.state = {
      time: 0,
      progress: 0,
      pointer: new THREE.Vector2(),
      focus: 0,
      targetProgress: 0,
      targetPointer: new THREE.Vector2(),
      targetFocus: 0,
      reduced: !!options.reducedMotion,
    };
    this.active = false;
    this.dirty = true;
    this.pxW = 0;
    this.pxH = 0;
    this.dprScale = 1;
    this.costs = [];

    this.kit = new Kit(this);
    addStudioLights(this.scene);
    this.sceneDef = builder(this.kit, options);
    this.state.progress = this.state.targetProgress = options.progress ?? 0;

    this.resizeObserver = new ResizeObserver(() => this.resize());
    this.resizeObserver.observe(host);
    this.resize();
    this.engine.add(this);
  }

  resize() {
    const rect = this.host.getBoundingClientRect();
    const dpr = Math.min(window.devicePixelRatio || 1, this.quality.dpr) * this.dprScale;
    const w = Math.max(1, Math.round(rect.width * dpr));
    const h = Math.max(1, Math.round(rect.height * dpr));
    if (w === this.pxW && h === this.pxH) return;
    this.pxW = w;
    this.pxH = h;
    this.canvas.width = w;
    this.canvas.height = h;
    this.camera.aspect = rect.width / Math.max(1, rect.height);
    this.sceneDef.frame?.(this.camera, this.camera.aspect);
    this.camera.updateProjectionMatrix();
    this.invalidate();
  }

  invalidate() {
    this.dirty = true;
    this.engine.kick();
  }

  setActive(active) {
    if (this.active === active) return;
    this.active = active;
    if (active) this.invalidate();
  }

  setProgress(p) {
    this.state.targetProgress = p;
    if (this.reduced) this.state.progress = p;
    this.invalidate();
  }

  setPointer(x, y) {
    if (this.reduced) return;
    this.state.targetPointer.set(x, y);
    this.engine.kick();
  }

  setFocus(f) {
    this.state.targetFocus = f;
    if (this.reduced) this.state.focus = f;
    this.invalidate();
  }

  isAnimating() {
    if (!this.active) return false;
    if (!this.reduced) return true;
    return this.dirty;
  }

  wantsFrame() {
    return this.active && this.pxW > 1 && this.pxH > 1 && (this.dirty || !this.reduced);
  }

  step(dt) {
    const s = this.state;
    if (!this.reduced) {
      s.time += dt;
      s.progress = damp(s.progress, s.targetProgress, 6, dt);
      s.pointer.x = damp(s.pointer.x, s.targetPointer.x, 4, dt);
      s.pointer.y = damp(s.pointer.y, s.targetPointer.y, 4, dt);
      s.focus = damp(s.focus, s.targetFocus, 5, dt);
    }
    this.sceneDef.update(s, this.reduced ? 0 : dt);
    this.dirty = false;
  }

  blit(source, bufH) {
    this.ctx.clearRect(0, 0, this.pxW, this.pxH);
    this.ctx.drawImage(source, 0, bufH - this.pxH, this.pxW, this.pxH, 0, 0, this.pxW, this.pxH);
  }

  /** Adaptive quality: drop the render resolution if frames run long. */
  recordCost(ms) {
    if (this.reduced) return;
    this.costs.push(ms);
    if (this.costs.length < 90) return;
    const avg = this.costs.reduce((a, b) => a + b, 0) / this.costs.length;
    this.costs.length = 0;
    if (avg > 14 && this.dprScale > 0.55) {
      this.dprScale = Math.max(0.55, this.dprScale * 0.8);
      this.resize();
    }
  }

  onContextLost() {
    this.host.dispatchEvent(new CustomEvent('yodynix3d-lost', { bubbles: false }));
  }

  dispose() {
    this.engine.remove(this);
    this.resizeObserver.disconnect();
    this.sceneDef.dispose?.();
    disposeScene(this.scene);
    this.kit.dispose();
    this.canvas.width = this.canvas.height = 0;
    this.canvas.remove();
    this.scene = null;
    this.sceneDef = null;
  }
}

function disposeScene(scene) {
  const materials = new Set();
  scene.traverse((obj) => {
    obj.geometry?.dispose();
    const m = obj.material;
    if (Array.isArray(m)) m.forEach((x) => materials.add(x));
    else if (m) materials.add(m);
  });
  for (const m of materials) {
    for (const key of Object.keys(m)) {
      const value = m[key];
      if (value && value.isTexture) value.dispose();
    }
    m.dispose();
  }
}

export function mount(host, sceneName, options = {}) {
  return new View(host, sceneName, options);
}

// ───────────────────────────────────────────────────────────────────────────
// Kit — materials, textures and helpers shared by every scene
// ───────────────────────────────────────────────────────────────────────────

class Kit {
  constructor(view) {
    this.view = view;
    this.scene = view.scene;
    this.camera = view.camera;
    this.quality = view.quality;
    this.textures = [];
  }

  track(texture) {
    this.textures.push(texture);
    return texture;
  }

  dispose() {
    for (const t of this.textures) t.dispose();
    this.textures.length = 0;
  }

  seg(n) {
    return Math.max(8, Math.round(n * this.quality.segments));
  }

  // Subtle, low-frequency roughness variation: fingerprints and polish
  // marks that keep large metal surfaces from looking computer-perfect.
  imperfections() {
    if (this._imperfections) return this._imperfections;
    const size = 256;
    const c = document.createElement('canvas');
    c.width = c.height = size;
    const g = c.getContext('2d');
    g.fillStyle = 'rgb(200,200,200)';
    g.fillRect(0, 0, size, size);
    const rand = mulberry32(7);
    for (let i = 0; i < 70; i++) {
      const x = rand() * size;
      const y = rand() * size;
      const r = 8 + rand() * 40;
      const v = 150 + rand() * 105;
      const grad = g.createRadialGradient(x, y, 0, x, y, r);
      grad.addColorStop(0, `rgba(${v},${v},${v},0.35)`);
      grad.addColorStop(1, `rgba(${v},${v},${v},0)`);
      g.fillStyle = grad;
      g.fillRect(x - r, y - r, r * 2, r * 2);
    }
    const t = new THREE.CanvasTexture(c);
    t.wrapS = t.wrapT = THREE.RepeatWrapping;
    this._imperfections = this.track(t);
    return t;
  }

  chrome(extra = {}) {
    return new THREE.MeshPhysicalMaterial({
      color: 0xf4f3f0,
      metalness: 1,
      roughness: 0.07,
      roughnessMap: this.imperfections(),
      envMapIntensity: 1.15,
      ...extra,
    });
  }

  aluminium(extra = {}) {
    return new THREE.MeshPhysicalMaterial({
      color: 0xdcd9d3,
      metalness: 1,
      roughness: 0.34,
      roughnessMap: this.imperfections(),
      envMapIntensity: 1.1,
      ...extra,
    });
  }

  /** Polished champagne gold. */
  gold(extra = {}) {
    return new THREE.MeshPhysicalMaterial({
      // Polished champagne gold: a bare metal (no lacquer), so reflections
      // take on the gold tint the way real gold does.
      color: 0xe6c993,
      metalness: 1,
      roughness: 0.14,
      roughnessMap: this.imperfections(),
      envMapIntensity: 1.1,
      ...extra,
    });
  }

  /** Liquid gold: near-mirror finish under a wet clearcoat. */
  liquidGold(extra = {}) {
    return this.gold({ color: 0xecd09b, roughness: 0.05, clearcoat: 0.6, clearcoatRoughness: 0.03, envMapIntensity: 1.25, ...extra });
  }

  /**
   * Signature finishes shared by the hero and About sculptures: a deep
   * champagne gold under a thin, glassy lacquer (the warm metal reflection
   * plus a crisp white highlight on top), and a warm polished platinum with
   * a faint clearcoat for the same layered depth.
   */
  lacqueredGold(extra = {}) {
    return this.liquidGold({ color: 0xe8c890, roughness: 0.1, clearcoat: 0.85, clearcoatRoughness: 0.035, envMapIntensity: 1.35, ...extra });
  }

  polishedPlatinum(extra = {}) {
    return this.chrome({ color: 0xf1efea, roughness: 0.06, clearcoat: 0.5, clearcoatRoughness: 0.04, envMapIntensity: 1.3, ...extra });
  }

  /**
   * Glass for transparent canvases: no transmission pass (which needs an
   * opaque backdrop and an extra render), just a pale pane whose
   * clearcoat carries the reflections.
   */
  clearGlass(extra = {}) {
    return new THREE.MeshPhysicalMaterial({
      color: 0xfffbf2,
      metalness: 0,
      roughness: 0.05,
      transparent: true,
      opacity: 0.22,
      clearcoat: 1,
      clearcoatRoughness: 0.02,
      envMapIntensity: 1.8,
      side: THREE.DoubleSide,
      depthWrite: false,
      ...extra,
    });
  }

  /** Pearl porcelain under a glossy coat: the plinths the sculptures stand on. */
  pearl(extra = {}) {
    return this.porcelain({ color: 0xf6efe2, roughness: 0.3, clearcoat: 0.9, clearcoatRoughness: 0.08, ...extra });
  }

  charcoalMetal(extra = {}) {
    return new THREE.MeshPhysicalMaterial({
      color: 0x2f2c29,
      metalness: 0.7,
      roughness: 0.3,
      clearcoat: 1,
      clearcoatRoughness: 0.1,
      ...extra,
    });
  }

  glass(extra = {}) {
    return new THREE.MeshPhysicalMaterial({
      color: 0xffffff,
      metalness: 0,
      roughness: 0.03,
      transmission: 1,
      thickness: 0.5,
      ior: 1.5,
      attenuationColor: new THREE.Color(0xf2e2c4),
      attenuationDistance: 1.1,
      specularIntensity: 1,
      envMapIntensity: 1.3,
      clearcoat: 1,
      clearcoatRoughness: 0.03,
      ...extra,
    });
  }

  frostedGlass(extra = {}) {
    return this.glass({ roughness: 0.32, thickness: 0.25, attenuationColor: new THREE.Color(0xf5ead6), ...extra });
  }

  porcelain(extra = {}) {
    return new THREE.MeshPhysicalMaterial({
      color: 0xf7f4ee,
      metalness: 0,
      roughness: 0.42,
      clearcoat: 0.6,
      clearcoatRoughness: 0.25,
      sheen: 0.2,
      ...extra,
    });
  }

  glow(color = BRAND.softGold, intensity = 2.2) {
    return new THREE.MeshStandardMaterial({
      color: 0x000000,
      emissive: new THREE.Color(color),
      emissiveIntensity: intensity,
      roughness: 1,
      metalness: 0,
    });
  }

  /** Lit screen: emissive UI artwork under a glossy cover glass. */
  screen(texture, intensity = 0.95) {
    return new THREE.MeshPhysicalMaterial({
      color: 0x0d0c0b,
      map: texture,
      emissive: 0xffffff,
      emissiveMap: texture,
      emissiveIntensity: intensity,
      roughness: 0.12,
      metalness: 0,
      clearcoat: 1,
      clearcoatRoughness: 0.02,
      envMapIntensity: 0.6,
    });
  }

  canvasTexture(width, height, draw) {
    const c = document.createElement('canvas');
    c.width = width;
    c.height = height;
    const g = c.getContext('2d');
    draw(g, width, height);
    const t = new THREE.CanvasTexture(c);
    t.colorSpace = THREE.SRGBColorSpace;
    t.anisotropy = 8;
    return this.track(t);
  }

  /**
   * Soft ambient-occlusion shadow on an invisible floor. A [tight] shadow
   * holds its density almost to the edge and then falls off quickly: the
   * crisp occlusion line where a solid base meets the floor. A [warm] shadow
   * is umber rather than charcoal, as shadows read on an ivory floor.
   */
  contactShadow(radius = 1.4, opacity = 0.22, { tight = false, warm = false } = {}) {
    const tex = this.canvasTexture(256, 256, (g, w, h) => {
      const grad = g.createRadialGradient(w / 2, h / 2, 0, w / 2, h / 2, w / 2);
      const stops = tight
        ? [[0, 1], [0.86, 0.8], [0.93, 0.22], [1, 0]]
        : [[0, 1], [0.35, 0.55], [0.7, 0.12], [1, 0]];
      const rgb = warm ? '58,46,32' : '42,40,38';
      for (const [at, a] of stops) grad.addColorStop(at, `rgba(${rgb},${a})`);
      g.fillStyle = grad;
      g.fillRect(0, 0, w, h);
    });
    tex.colorSpace = THREE.NoColorSpace;
    const mat = new THREE.MeshBasicMaterial({ map: tex, transparent: true, opacity, depthWrite: false, toneMapped: false });
    const mesh = new THREE.Mesh(new THREE.PlaneGeometry(radius * 2, radius * 2), mat);
    mesh.rotation.x = -Math.PI / 2;
    mesh.renderOrder = -1;
    mesh.userData.baseOpacity = opacity;
    return mesh;
  }

  /** Fine floating dust that catches the light — gives the space depth. */
  particles(count, spread = 4, color = BRAND.gold, size = 0.022) {
    const n = Math.max(12, Math.round(count * this.quality.particles));
    const positions = new Float32Array(n * 3);
    const rand = mulberry32(11);
    for (let i = 0; i < n; i++) {
      positions[i * 3] = (rand() - 0.5) * spread * 1.6;
      positions[i * 3 + 1] = (rand() - 0.5) * spread;
      positions[i * 3 + 2] = (rand() - 0.5) * spread;
    }
    const geo = new THREE.BufferGeometry();
    geo.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    const sprite = this.canvasTexture(64, 64, (g, w) => {
      const grad = g.createRadialGradient(w / 2, w / 2, 0, w / 2, w / 2, w / 2);
      grad.addColorStop(0, 'rgba(255,255,255,1)');
      grad.addColorStop(0.4, 'rgba(255,255,255,0.6)');
      grad.addColorStop(1, 'rgba(255,255,255,0)');
      g.fillStyle = grad;
      g.fillRect(0, 0, w, w);
    });
    const mat = new THREE.PointsMaterial({
      size,
      map: sprite,
      color,
      transparent: true,
      opacity: 0.55,
      depthWrite: false,
      sizeAttenuation: true,
    });
    return new THREE.Points(geo, mat);
  }

  roundedBox(w, h, d, radius, material, segments = 4) {
    return new THREE.Mesh(new RoundedBoxGeometry(w, h, d, segments, radius), material);
  }
}

/**
 * A photographic product studio, pre-filtered as the environment map for
 * every scene. Polished metal looks real because of what it reflects: a
 * large overhead softbox, two tall strip lights, a warm bounce card and two
 * dark flags give gold and chrome the long highlights and deep contrast of a
 * studio product shot. All warm-neutral, no coloured light.
 */
function studioEnvironment() {
  const scene = new THREE.Scene();
  const box = new THREE.BoxGeometry(1, 1, 1);
  const panel = (color, intensity, [x, y, z], [sx, sy, sz], [rx, ry] = [0, 0]) => {
    const m = new THREE.Mesh(box, new THREE.MeshBasicMaterial({ color: new THREE.Color(color).multiplyScalar(intensity) }));
    m.position.set(x, y, z);
    m.scale.set(sx, sy, sz);
    m.rotation.set(rx, ry, 0);
    scene.add(m);
  };
  // Room: warm grey walls, a lighter floor and a darker ceiling.
  const room = new THREE.Mesh(
    new THREE.BoxGeometry(20, 12, 20),
    new THREE.MeshBasicMaterial({ color: new THREE.Color(0x8c857b), side: THREE.BackSide }),
  );
  room.position.y = 4;
  scene.add(room);
  panel(0xe9e2d5, 1, [0, -1.99, 0], [19.8, 0.02, 19.8]);
  panel(0x4a4540, 1, [0, 9.98, 0], [19.8, 0.02, 19.8]);
  // Light sources.
  panel(0xfff6e6, 9, [0, 9.5, 0], [8, 0.1, 5]); // overhead softbox
  panel(0xfffaf0, 14, [-9.5, 3, 1], [0.1, 9, 1.2]); // left strip
  panel(0xfffaf0, 11, [9.5, 3, -2], [0.1, 9, 1.0]); // right strip
  panel(0xffe7c2, 3.2, [3, 3, 9.5], [7, 6, 0.1]); // warm bounce, front right
  panel(0xffffff, 6, [-4, 5, -9.5], [3, 3, 0.1]); // small kicker behind
  // Flags: dark cards that put deep lines into the reflections.
  panel(0x15130f, 1, [-6, 3, 9.4], [4, 8, 0.1]);
  panel(0x15130f, 1, [7, 3, 6], [0.1, 8, 3], [0, 0.4]);
  return scene;
}

function addStudioLights(scene) {
  // The environment map supplies most of the light; these add a crisp key
  // highlight and a warm rim that separates objects from a light background.
  const key = new THREE.DirectionalLight(0xfff8ec, 1.6);
  key.position.set(3, 5, 4);
  const rim = new THREE.DirectionalLight(0xf3d9a4, 2.2);
  rim.position.set(-4, 2, -3);
  const fill = new THREE.HemisphereLight(0xffffff, 0xe8dfd0, 0.6);
  scene.add(key, rim, fill);
}

function mulberry32(seed) {
  return function () {
    seed |= 0;
    seed = (seed + 0x6d2b79f5) | 0;
    let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

/** Fits the camera so a sphere of [radius] stays in frame at any aspect ratio. */
function fitDistance(camera, radius, aspect) {
  const vFov = THREE.MathUtils.degToRad(camera.fov);
  const hFov = 2 * Math.atan(Math.tan(vFov / 2) * aspect);
  const fov = Math.min(vFov, hFov);
  return radius / Math.sin(fov / 2);
}

/** Camera distance that fits a [halfWidth] × [halfHeight] box (plus [depth] in front). */
function fitBox(camera, halfWidth, halfHeight, aspect, depth = 0.5) {
  const vFov = THREE.MathUtils.degToRad(camera.fov);
  const hFov = 2 * Math.atan(Math.tan(vFov / 2) * aspect);
  return Math.max(halfWidth / Math.tan(hFov / 2), halfHeight / Math.tan(vFov / 2)) + depth;
}

// ───────────────────────────────────────────────────────────────────────────
// Geometry helpers
// ───────────────────────────────────────────────────────────────────────────

/**
 * A flat ribbon swept along [curve] with a rounded-rectangle cross-section —
 * the signature form, echoing the interwoven ribbons of the YODYNIX mark.
 */
function ribbonGeometry(curve, { segments = 400, width = 0.2, thickness = 0.04, profile = 14, twist = 0 } = {}) {
  const frames = curve.computeFrenetFrames(segments, true);
  // Superellipse profile: flat faces with softly rounded edges.
  const prof = [];
  for (let i = 0; i < profile; i++) {
    const a = (i / profile) * Math.PI * 2;
    const c = Math.cos(a);
    const s = Math.sin(a);
    const e = 0.35;
    prof.push([Math.sign(c) * Math.pow(Math.abs(c), e) * width * 0.5, Math.sign(s) * Math.pow(Math.abs(s), e) * thickness * 0.5]);
  }
  const positions = [];
  const point = new THREE.Vector3();
  const n = new THREE.Vector3();
  const b = new THREE.Vector3();
  for (let i = 0; i <= segments; i++) {
    const u = i / segments;
    curve.getPointAt(u, point);
    const k = i % segments;
    const angle = twist * u * Math.PI * 2;
    n.copy(frames.normals[k]).multiplyScalar(Math.cos(angle)).addScaledVector(frames.binormals[k], Math.sin(angle));
    b.copy(frames.binormals[k]).multiplyScalar(Math.cos(angle)).addScaledVector(frames.normals[k], -Math.sin(angle));
    for (const [px, py] of prof) {
      positions.push(point.x + b.x * px + n.x * py, point.y + b.y * px + n.y * py, point.z + b.z * px + n.z * py);
    }
  }
  const index = [];
  for (let i = 0; i < segments; i++) {
    for (let j = 0; j < profile; j++) {
      const a = i * profile + j;
      const bb = i * profile + ((j + 1) % profile);
      const c = (i + 1) * profile + j;
      const d = (i + 1) * profile + ((j + 1) % profile);
      index.push(a, c, bb, bb, c, d);
    }
  }
  const geo = new THREE.BufferGeometry();
  geo.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));
  geo.setIndex(index);
  geo.computeVertexNormals();
  return geo;
}

class TrefoilCurve extends THREE.Curve {
  constructor(scale = 1, depth = 1) {
    super();
    this.scale = scale;
    this.depth = depth;
  }

  getPoint(t, target = new THREE.Vector3()) {
    const a = t * Math.PI * 2;
    return target.set(
      (Math.sin(a) + 2 * Math.sin(2 * a)) * this.scale,
      (Math.cos(a) - 2 * Math.cos(2 * a)) * this.scale,
      -Math.sin(3 * a) * this.scale * this.depth,
    );
  }
}

/**
 * A flat ribbon swept along an open [curve] lying roughly in the view
 * plane. Its width runs across the curve in that plane, so the ribbon faces
 * the camera, and [twist] (radians, by position 0..1 along the curve) turns
 * it about its length to catch the light, and [taper] scales its section,
 * so its ends can narrow to nothing. No Frenet frames, so no flips.
 */
function openRibbonGeometry(curve, { segments = 240, width = 0.25, thickness = 0.02, profile = 12, twist = () => 0, taper = () => 1 } = {}) {
  const prof = [];
  for (let i = 0; i < profile; i++) {
    const a = (i / profile) * Math.PI * 2;
    const c = Math.cos(a);
    const s = Math.sin(a);
    prof.push([Math.sign(c) * Math.pow(Math.abs(c), 0.3) * width * 0.5, Math.sign(s) * Math.pow(Math.abs(s), 0.3) * thickness * 0.5]);
  }
  const forward = new THREE.Vector3(0, 0, 1);
  const point = new THREE.Vector3();
  const tangent = new THREE.Vector3();
  const across = new THREE.Vector3();
  const depth = new THREE.Vector3();
  const positions = [];
  for (let i = 0; i <= segments; i++) {
    const u = i / segments;
    curve.getPointAt(u, point);
    curve.getTangentAt(u, tangent);
    across.crossVectors(tangent, forward).normalize();
    depth.crossVectors(across, tangent).normalize();
    across.applyAxisAngle(tangent, twist(u));
    depth.applyAxisAngle(tangent, twist(u));
    const size = taper(u);
    for (const [x, y] of prof) {
      const px = x * size;
      const py = y * size;
      positions.push(point.x + across.x * px + depth.x * py, point.y + across.y * px + depth.y * py, point.z + across.z * px + depth.z * py);
    }
  }
  const index = [];
  for (let i = 0; i < segments; i++) {
    for (let j = 0; j < profile; j++) {
      const a = i * profile + j;
      const b = i * profile + ((j + 1) % profile);
      const c = (i + 1) * profile + j;
      const d = (i + 1) * profile + ((j + 1) % profile);
      index.push(a, c, b, b, c, d);
    }
  }
  const geo = new THREE.BufferGeometry();
  geo.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));
  geo.setIndex(index);
  geo.computeVertexNormals();
  return geo;
}

/**
 * Maps normalised view coordinates (0..1 across and down, as a Flutter
 * layout sees them) to world space for a camera [distance] away on +z with
 * a 30° field of view, so 3D elements can be placed against a photograph
 * laid out in Flutter. A point at any depth [z] projects to (nx, ny).
 */
function viewPlane(distance, aspect) {
  const halfH = distance * Math.tan(THREE.MathUtils.degToRad(15));
  const halfW = halfH * aspect;
  return (nx, ny, z = 0) => {
    const k = (distance - z) / distance;
    return new THREE.Vector3((nx * 2 - 1) * halfW * k, (1 - ny * 2) * halfH * k, z);
  };
}

/** A floor that shows only the shadows falling on it, for compositing over photographs. */
function shadowCatcher(width, depth, opacity = 0.22) {
  const plane = new THREE.Mesh(
    new THREE.PlaneGeometry(width, depth),
    new THREE.ShadowMaterial({ color: 0x3a2e20, opacity, depthWrite: false }),
  );
  plane.rotation.x = -Math.PI / 2;
  plane.receiveShadow = true;
  return plane;
}

/** A shadow-casting key light from the upper right, as in the hero. */
function keyLight(kit, scene, extent, position = [2, 6, 3]) {
  if (!kit.quality.shadow) return null;
  const key = new THREE.DirectionalLight(0xfff4e2, 1.0);
  key.position.set(...position);
  key.castShadow = true;
  key.shadow.mapSize.set(kit.quality.shadow, kit.quality.shadow);
  Object.assign(key.shadow.camera, { left: -extent, right: extent, top: extent, bottom: -extent, near: 0.5, far: 20 });
  key.shadow.radius = 14;
  key.shadow.blurSamples = 16;
  key.shadow.bias = -0.0008;
  scene.add(key, key.target);
  return key;
}

function gearGeometry(teeth, outer, inner, hole, depth) {
  const shape = new THREE.Shape();
  const step = (Math.PI * 2) / teeth;
  for (let i = 0; i < teeth; i++) {
    const a = i * step;
    const pts = [
      [a, inner],
      [a + step * 0.18, outer],
      [a + step * 0.48, outer],
      [a + step * 0.66, inner],
    ];
    pts.forEach(([ang, r], j) => {
      const x = Math.cos(ang) * r;
      const y = Math.sin(ang) * r;
      if (i === 0 && j === 0) shape.moveTo(x, y);
      else shape.lineTo(x, y);
    });
  }
  shape.closePath();
  const axle = new THREE.Path();
  axle.absarc(0, 0, hole, 0, Math.PI * 2, true);
  shape.holes.push(axle);
  // Lightening holes, as on a machined gear.
  const spokes = 5;
  for (let i = 0; i < spokes; i++) {
    const a = (i / spokes) * Math.PI * 2;
    const r = (inner + hole) * 0.5;
    const p = new THREE.Path();
    p.absarc(Math.cos(a) * r, Math.sin(a) * r, (inner - hole) * 0.26, 0, Math.PI * 2, true);
    shape.holes.push(p);
  }
  const geo = new THREE.ExtrudeGeometry(shape, {
    depth,
    bevelEnabled: true,
    bevelThickness: depth * 0.18,
    bevelSize: depth * 0.12,
    bevelSegments: 3,
    curveSegments: 24,
  });
  geo.center();
  return geo;
}

// ───────────────────────────────────────────────────────────────────────────
// Animation systems shared by the scenes
// ───────────────────────────────────────────────────────────────────────────

/**
 * Liquid gold: a ribbon whose path ripples over time. The ribbon is rebuilt
 * in place each frame (positions and normals only, no reallocation), with
 * travelling waves along its length so highlights slide across the surface
 * like poured metal.
 */
class LiquidRibbon {
  constructor(curve, material, { segments = 400, width = 0.2, thickness = 0.04, twist = 0, amplitude = 0.05, waves = 5 } = {}) {
    this.curve = curve;
    this.options = { segments, width, thickness, twist, amplitude, waves };
    this.geometry = ribbonGeometry(curve, { segments, width, thickness, twist });
    this.mesh = new THREE.Mesh(this.geometry, material);
    this.profile = 14;
    // Rest positions, frames and the per-vertex offsets in the frame.
    this.frames = curve.computeFrenetFrames(segments, true);
    this.rest = this.geometry.attributes.position.array.slice();
    this.centres = [];
    const p = new THREE.Vector3();
    for (let i = 0; i <= segments; i++) this.centres.push(curve.getPointAt(i / segments, p).clone());
  }

  update(time, strength = 1) {
    const { segments, amplitude, waves } = this.options;
    const pos = this.geometry.attributes.position.array;
    const rest = this.rest;
    const prof = this.profile;
    const amp = amplitude * strength;
    for (let i = 0; i <= segments; i++) {
      const u = i / segments;
      const k = i % segments;
      const n = this.frames.normals[k];
      const b = this.frames.binormals[k];
      // Two travelling waves: a slow swell and a quicker ripple.
      const swell = Math.sin(u * Math.PI * 2 * waves - time * 1.3) * amp;
      const ripple = Math.sin(u * Math.PI * 2 * waves * 2.3 + time * 2.1) * amp * 0.35;
      const breathe = 1 + Math.sin(u * Math.PI * 2 * 3 + time * 0.9) * 0.18 * strength;
      const c = this.centres[i];
      for (let j = 0; j < prof; j++) {
        const idx = (i * prof + j) * 3;
        // Scale the cross-section about the centre so the ribbon swells.
        const ox = (rest[idx] - c.x) * breathe;
        const oy = (rest[idx + 1] - c.y) * breathe;
        const oz = (rest[idx + 2] - c.z) * breathe;
        pos[idx] = c.x + ox + n.x * swell + b.x * ripple;
        pos[idx + 1] = c.y + oy + n.y * swell + b.y * ripple;
        pos[idx + 2] = c.z + oz + n.z * swell + b.z * ripple;
      }
    }
    this.geometry.attributes.position.needsUpdate = true;
    this.geometry.computeVertexNormals();
  }
}

/**
 * A glass or metal form that morphs between a sphere, a soft octahedron, a
 * rounded cube and a gently lobed "bloom". The targets are superellipsoids
 * (|x|ⁿ + |y|ⁿ + |z|ⁿ = 1): smooth at every edge, so the shared icosphere
 * vertices never tear into facets, with exact normals from the surface
 * gradient. The transition is a GPU morph rather than a swap.
 */
function morphGeometry(radius, detail) {
  const geo = new THREE.IcosahedronGeometry(radius, detail);
  const base = geo.attributes.position;
  const count = base.count;
  const v = new THREE.Vector3();
  const superellipsoid = (n, scale) => {
    const pos = [];
    const nor = [];
    for (let i = 0; i < count; i++) {
      v.fromBufferAttribute(base, i).normalize();
      const ax = Math.abs(v.x), ay = Math.abs(v.y), az = Math.abs(v.z);
      const k = Math.pow(Math.pow(ax, n) + Math.pow(ay, n) + Math.pow(az, n), 1 / n);
      const px = v.x / k, py = v.y / k, pz = v.z / k;
      pos.push(px * radius * scale, py * radius * scale, pz * radius * scale);
      // ∇(|x|ⁿ + |y|ⁿ + |z|ⁿ) = n·sign(x)|x|ⁿ⁻¹ …
      const g = new THREE.Vector3(
        Math.sign(px) * Math.pow(Math.abs(px), n - 1),
        Math.sign(py) * Math.pow(Math.abs(py), n - 1),
        Math.sign(pz) * Math.pow(Math.abs(pz), n - 1),
      ).normalize();
      nor.push(g.x, g.y, g.z);
    }
    return [pos, nor];
  };
  const [octaPos, octaNor] = superellipsoid(1.35, 1.12);
  const [cubePos, cubeNor] = superellipsoid(5, 0.86);
  const bloomPos = [];
  const sphereNormals = [];
  for (let i = 0; i < count; i++) {
    v.fromBufferAttribute(base, i).normalize();
    sphereNormals.push(v.x, v.y, v.z);
    const lobes = 1 + 0.16 * Math.sin(5 * Math.atan2(v.z, v.x)) * Math.cos(3 * Math.asin(v.y));
    bloomPos.push(v.x * radius * lobes, v.y * radius * lobes, v.z * radius * lobes);
  }
  geo.setAttribute('normal', new THREE.Float32BufferAttribute(sphereNormals, 3));
  const f = (a) => new THREE.Float32BufferAttribute(a, 3);
  geo.morphAttributes.position = [f(octaPos), f(cubePos), f(bloomPos)];
  // The bloom's lobes are gentle, so the sphere normals shade it well.
  geo.morphAttributes.normal = [f(octaNor), f(cubeNor), f(sphereNormals)];
  // Normals are blended relative to the base, so give each target its offset.
  for (const attr of geo.morphAttributes.normal) {
    for (let i = 0; i < attr.array.length; i++) attr.array[i] -= sphereNormals[i];
  }
  for (const attr of geo.morphAttributes.position) {
    for (let i = 0; i < attr.array.length; i++) attr.array[i] -= base.array[i];
  }
  geo.morphTargetsRelative = true;
  return geo;
}

/** Morph weights for a 0..1 phase: sphere → octahedron → cube → bloom. */
function morphWeights(phase, out) {
  const p = Math.min(0.9999, Math.max(0, phase)) * 3;
  const i = Math.floor(p);
  const f = THREE.MathUtils.smootherstep(p - i, 0, 1);
  out[0] = out[1] = out[2] = 0;
  if (i === 0) out[0] = f;
  else if (i === 1) {
    out[0] = 1 - f;
    out[1] = f;
  } else {
    out[1] = 1 - f;
    out[2] = f;
  }
  return out;
}

/**
 * Gold dust that drifts on its own and parts around the cursor. Each mote
 * has a rest position, a slow drift, and a displacement that springs back
 * after the pointer pushes it away.
 */
class DustField {
  constructor(kit, { count = 260, spread = 5, size = 0.024, color = BRAND.gold, opacity = 0.7 } = {}) {
    const n = Math.max(16, Math.round(count * kit.quality.particles));
    this.n = n;
    this.base = new Float32Array(n * 3);
    this.offset = new Float32Array(n * 3);
    this.velocity = new Float32Array(n * 3);
    this.phase = new Float32Array(n);
    const rand = mulberry32(21);
    for (let i = 0; i < n; i++) {
      this.base[i * 3] = (rand() - 0.5) * spread * 1.7;
      this.base[i * 3 + 1] = (rand() - 0.5) * spread;
      this.base[i * 3 + 2] = (rand() - 0.5) * spread * 0.9;
      this.phase[i] = rand() * Math.PI * 2;
    }
    const geo = new THREE.BufferGeometry();
    geo.setAttribute('position', new THREE.BufferAttribute(this.base.slice(), 3));
    const sprite = kit.canvasTexture(64, 64, (g, w) => {
      const grad = g.createRadialGradient(w / 2, w / 2, 0, w / 2, w / 2, w / 2);
      grad.addColorStop(0, 'rgba(255,250,235,1)');
      grad.addColorStop(0.35, 'rgba(255,236,190,0.75)');
      grad.addColorStop(1, 'rgba(255,236,190,0)');
      g.fillStyle = grad;
      g.fillRect(0, 0, w, w);
    });
    this.points = new THREE.Points(
      geo,
      new THREE.PointsMaterial({ size, map: sprite, color, transparent: true, opacity, depthWrite: false, sizeAttenuation: true }),
    );
    this.local = new THREE.Vector3();
  }

  /** [cursor] is the pointer projected into the field's parent space, or null. */
  update(time, dt, cursor) {
    const pos = this.points.geometry.attributes.position.array;
    const { base, offset, velocity, phase } = this;
    const radius = 0.9;
    for (let i = 0; i < this.n; i++) {
      const ix = i * 3;
      const bx = base[ix] + Math.sin(time * 0.25 + phase[i]) * 0.08;
      const by = base[ix + 1] + Math.sin(time * 0.33 + phase[i] * 1.3) * 0.1;
      const bz = base[ix + 2];
      if (cursor) {
        const dx = bx + offset[ix] - cursor.x;
        const dy = by + offset[ix + 1] - cursor.y;
        const d2 = dx * dx + dy * dy;
        if (d2 < radius * radius) {
          const d = Math.sqrt(d2) || 0.001;
          const push = (1 - d / radius) * 6;
          velocity[ix] += (dx / d) * push * dt;
          velocity[ix + 1] += (dy / d) * push * dt;
        }
      }
      // Spring back to rest with damping.
      for (let k = 0; k < 3; k++) {
        velocity[ix + k] += -offset[ix + k] * 4 * dt;
        velocity[ix + k] *= 1 - Math.min(1, 3.2 * dt);
        offset[ix + k] += velocity[ix + k] * dt;
      }
      pos[ix] = bx + offset[ix];
      pos[ix + 1] = by + offset[ix + 1];
      pos[ix + 2] = bz + offset[ix + 2];
    }
    this.points.geometry.attributes.position.needsUpdate = true;
  }
}

/** Projects the -1..1 pointer onto the plane z = [depth] in [object]'s space. */
function pointerOnPlane(camera, pointer, object, depth = 0, out = new THREE.Vector3()) {
  const ray = new THREE.Raycaster();
  ray.setFromCamera(new THREE.Vector2(pointer.x, -pointer.y), camera);
  const plane = new THREE.Plane(new THREE.Vector3(0, 0, 1), -depth);
  const inv = object.matrixWorld.clone().invert();
  ray.ray.applyMatrix4(inv);
  return ray.ray.intersectPlane(plane, out);
}

/**
 * Floating accent objects — chrome spheres, glass cubes and metallic rings —
 * that drift at different depths, each on its own slow rhythm.
 */
function floaters(kit, specs) {
  const group = new THREE.Group();
  const items = specs.map(([kind, x, y, z, size], i) => {
    let mesh;
    if (kind === 'sphere') mesh = new THREE.Mesh(new THREE.SphereGeometry(size, 48, 32), kit.chrome({ roughness: 0.06 }));
    else if (kind === 'goldSphere') mesh = new THREE.Mesh(new THREE.SphereGeometry(size, 48, 32), kit.liquidGold());
    else if (kind === 'cube') mesh = kit.roundedBox(size, size, size, size * 0.12, kit.glass({ thickness: size }), 4);
    else if (kind === 'ring') mesh = new THREE.Mesh(new THREE.TorusGeometry(size, size * 0.12, 24, 96), kit.gold({ roughness: 0.14 }));
    else mesh = new THREE.Mesh(new THREE.TorusGeometry(size, size * 0.08, 24, 96), kit.chrome({ roughness: 0.1 }));
    mesh.position.set(x, y, z);
    mesh.rotation.set(i * 0.7, i * 1.3, i * 0.4);
    mesh.userData = { base: new THREE.Vector3(x, y, z), phase: i * 1.7, spin: 0.15 + (i % 3) * 0.08 };
    group.add(mesh);
    return mesh;
  });
  return {
    group,
    update(time, dt, spread = 0) {
      for (const m of items) {
        const { base, phase, spin } = m.userData;
        m.position.set(
          base.x * (1 + spread),
          base.y * (1 + spread * 0.6) + Math.sin(time * 0.7 + phase) * 0.08,
          base.z + Math.cos(time * 0.5 + phase) * 0.05,
        );
        m.rotation.x += dt * spin;
        m.rotation.y += dt * spin * 0.7;
      }
    },
  };
}

/** Cinematic intro: eases from [from] to 1 over [seconds] after mounting. */
function introCurve(time, seconds = 2.4) {
  const t = Math.min(1, time / seconds);
  return 1 - Math.pow(1 - t, 3);
}

// ───────────────────────────────────────────────────────────────────────────
// Interface artwork for screens (illustrative, not real client work)
// ───────────────────────────────────────────────────────────────────────────

function rr(g, x, y, w, h, r) {
  g.beginPath();
  if (g.roundRect) g.roundRect(x, y, w, h, r);
  else g.rect(x, y, w, h);
}

const FONT = '"Inter", "Segoe UI", system-ui, sans-serif';

function drawBrowser(g, w, h) {
  g.fillStyle = '#f8f6f1';
  g.fillRect(0, 0, w, h);
  // Window chrome.
  g.fillStyle = '#ede4d6';
  g.fillRect(0, 0, w, 54);
  ['#ff6159', '#ffbd2e', '#28c941'].forEach((c, i) => {
    g.fillStyle = c;
    g.beginPath();
    g.arc(30 + i * 24, 27, 7, 0, Math.PI * 2);
    g.fill();
  });
  g.fillStyle = '#ffffff';
  rr(g, 120, 13, w - 240, 28, 14);
  g.fill();
  g.fillStyle = '#8a8277';
  g.font = `500 15px ${FONT}`;
  g.fillText('yourbusiness.com', 140, 32);
  // Navigation.
  g.fillStyle = '#2a2826';
  g.font = `700 20px ${FONT}`;
  g.fillText('Northwind', 48, 100);
  g.fillStyle = '#6a645b';
  g.font = `500 15px ${FONT}`;
  ['Products', 'Solutions', 'Pricing', 'Contact'].forEach((t, i) => g.fillText(t, w - 470 + i * 100, 100));
  // Hero.
  g.fillStyle = '#2a2826';
  g.font = `800 46px ${FONT}`;
  g.fillText('Build something', 48, 190);
  g.fillText('remarkable.', 48, 244);
  g.fillStyle = '#6a645b';
  g.font = `400 18px ${FONT}`;
  g.fillText('Fast, accessible websites that convert.', 48, 284);
  g.fillStyle = '#c6a46a';
  rr(g, 48, 312, 170, 50, 25);
  g.fill();
  g.fillStyle = '#ffffff';
  g.font = `600 17px ${FONT}`;
  g.fillText('Get started', 86, 343);
  // Hero art.
  const grad = g.createLinearGradient(w * 0.55, 140, w - 48, 380);
  grad.addColorStop(0, '#c6a46a');
  grad.addColorStop(1, '#e3cfa3');
  g.fillStyle = grad;
  rr(g, w * 0.55, 140, w * 0.45 - 48, 230, 18);
  g.fill();
  g.strokeStyle = 'rgba(255,255,255,0.6)';
  g.lineWidth = 4;
  g.beginPath();
  for (let i = 0; i <= 10; i++) {
    const x = w * 0.57 + i * ((w * 0.41 - 48) / 10);
    const y = 320 - Math.sin(i * 0.8) * 30 - i * 12;
    if (i === 0) g.moveTo(x, y);
    else g.lineTo(x, y);
  }
  g.stroke();
  // Cards.
  const cw = (w - 96 - 40) / 3;
  for (let i = 0; i < 3; i++) {
    const x = 48 + i * (cw + 20);
    g.fillStyle = '#ffffff';
    rr(g, x, 410, cw, h - 440, 16);
    g.fill();
    g.fillStyle = i === 1 ? '#e3cfa3' : '#c6a46a';
    rr(g, x + 22, 432, 40, 40, 12);
    g.fill();
    g.fillStyle = '#2a2826';
    g.font = `700 18px ${FONT}`;
    g.fillText(['Design', 'Develop', 'Launch'][i], x + 22, 504);
    g.fillStyle = '#e2ddd3';
    rr(g, x + 22, 520, cw - 60, 10, 5);
    g.fill();
    rr(g, x + 22, 540, cw - 100, 10, 5);
    g.fill();
  }
}

function drawShop(g, w, h) {
  drawBrowser(g, w, h);
  // Replace the hero and cards with a storefront: product grid and cart.
  g.fillStyle = '#f8f6f1';
  g.fillRect(0, 120, w, h - 120);
  g.fillStyle = '#2a2826';
  g.font = `800 38px ${FONT}`;
  g.fillText('New arrivals', 48, 180);
  g.fillStyle = '#c6a46a';
  rr(g, w - 220, 140, 172, 50, 25);
  g.fill();
  g.fillStyle = '#ffffff';
  g.font = `600 17px ${FONT}`;
  g.fillText('Cart  (2)', w - 178, 172);
  const cw = (w - 96 - 60) / 4;
  const tints = [['#c6a46a', '#e3cfa3'], ['#2a2826', '#c6a46a'], ['#e3cfa3', '#ede4d6'], ['#c6a46a', '#2a2826']];
  for (let i = 0; i < 4; i++) {
    const x = 48 + i * (cw + 20);
    g.fillStyle = '#ffffff';
    rr(g, x, 220, cw, h - 250, 18);
    g.fill();
    const grad = g.createLinearGradient(x, 236, x + cw, 236 + cw * 0.9);
    grad.addColorStop(0, tints[i][0]);
    grad.addColorStop(1, tints[i][1]);
    g.fillStyle = grad;
    rr(g, x + 14, 236, cw - 28, cw * 0.9, 14);
    g.fill();
    g.fillStyle = '#2a2826';
    g.font = `700 18px ${FONT}`;
    g.fillText(['Classic tee', 'Desk lamp', 'Ceramic set', 'Backpack'][i], x + 18, 260 + cw * 0.9);
    g.fillStyle = '#c6a46a';
    g.font = `700 18px ${FONT}`;
    g.fillText(['$24', '$68', '$42', '$89'][i], x + 18, 290 + cw * 0.9);
  }
}

function drawPhoneApp(variant) {
  return (g, w, h) => {
    g.fillStyle = variant === 0 ? '#f8f6f1' : '#2a2826';
    g.fillRect(0, 0, w, h);
    const ink = variant === 0 ? '#2a2826' : '#ffffff';
    const sub = variant === 0 ? '#6a645b' : '#c9c6bf';
    g.fillStyle = ink;
    g.font = `600 22px ${FONT}`;
    g.fillText('9:41', 40, 56);
    // Dynamic island.
    g.fillStyle = '#0b0a09';
    rr(g, w / 2 - 70, 26, 140, 40, 20);
    g.fill();
    if (variant === 0) {
      g.fillStyle = ink;
      g.font = `800 40px ${FONT}`;
      g.fillText('Good morning', 40, 150);
      g.fillStyle = sub;
      g.font = `400 22px ${FONT}`;
      g.fillText('Your week at a glance', 40, 188);
      const grad = g.createLinearGradient(40, 220, w - 40, 470);
      grad.addColorStop(0, '#c6a46a');
      grad.addColorStop(1, '#e3cfa3');
      g.fillStyle = grad;
      rr(g, 40, 220, w - 80, 250, 32);
      g.fill();
      g.fillStyle = '#ffffff';
      g.font = `600 22px ${FONT}`;
      g.fillText('Orders', 72, 270);
      g.font = `800 64px ${FONT}`;
      g.fillText('1,284', 72, 346);
      g.strokeStyle = 'rgba(255,255,255,0.85)';
      g.lineWidth = 5;
      g.beginPath();
      for (let i = 0; i <= 8; i++) {
        const x = 72 + i * ((w - 144) / 8);
        const y = 440 - Math.abs(Math.sin(i * 0.9)) * 40 - i * 4;
        if (i === 0) g.moveTo(x, y);
        else g.lineTo(x, y);
      }
      g.stroke();
      for (let i = 0; i < 4; i++) {
        const y = 510 + i * 118;
        g.fillStyle = '#ffffff';
        rr(g, 40, y, w - 80, 98, 24);
        g.fill();
        g.fillStyle = ['#c6a46a', '#e3cfa3', '#2a2826', '#c6a46a'][i];
        rr(g, 64, y + 22, 54, 54, 16);
        g.fill();
        g.fillStyle = ink;
        g.font = `600 24px ${FONT}`;
        g.fillText(['New booking', 'Payment received', 'Team update', 'Report ready'][i], 140, y + 46);
        g.fillStyle = sub;
        g.font = `400 19px ${FONT}`;
        g.fillText(['2 minutes ago', 'Today, 9:12', 'Yesterday', 'Mon'][i], 140, y + 76);
      }
    } else {
      g.fillStyle = ink;
      g.font = `800 40px ${FONT}`;
      g.fillText('Insights', 40, 150);
      // Ring chart.
      const cx = w / 2;
      const cy = 400;
      g.lineWidth = 34;
      g.strokeStyle = 'rgba(255,255,255,0.1)';
      g.beginPath();
      g.arc(cx, cy, 150, 0, Math.PI * 2);
      g.stroke();
      g.strokeStyle = '#c6a46a';
      g.lineCap = 'round';
      g.beginPath();
      g.arc(cx, cy, 150, -Math.PI / 2, Math.PI * 0.95);
      g.stroke();
      g.strokeStyle = '#e3cfa3';
      g.beginPath();
      g.arc(cx, cy, 104, -Math.PI / 2, Math.PI * 0.4);
      g.stroke();
      g.fillStyle = '#ffffff';
      g.font = `800 60px ${FONT}`;
      g.textAlign = 'center';
      g.fillText('82%', cx, cy + 20);
      g.textAlign = 'left';
      for (let i = 0; i < 5; i++) {
        const bh = 60 + ((i * 37) % 120);
        g.fillStyle = i === 3 ? '#e3cfa3' : 'rgba(198,164,106,0.85)';
        rr(g, 70 + i * ((w - 140) / 5), 820 - bh, 46, bh, 12);
        g.fill();
      }
      g.fillStyle = 'rgba(255,255,255,0.08)';
      rr(g, 40, 860, w - 80, 120, 28);
      g.fill();
      g.fillStyle = '#ffffff';
      g.font = `600 24px ${FONT}`;
      g.fillText('Weekly growth', 72, 910);
      g.fillStyle = '#e3cfa3';
      g.font = `700 30px ${FONT}`;
      g.fillText('+18.4%', 72, 952);
    }
  };
}

function drawLayer(kind) {
  return (g, w, h) => {
    g.clearRect(0, 0, w, h);
    g.strokeStyle = 'rgba(198,164,106,0.9)';
    g.fillStyle = 'rgba(198,164,106,0.9)';
    g.lineWidth = 6;
    const pad = 48;
    if (kind === 'interface') {
      g.fillStyle = 'rgba(42,40,38,0.85)';
      rr(g, pad, pad, w - pad * 2, 60, 14);
      g.fill();
      g.fillStyle = 'rgba(198,164,106,0.9)';
      for (let i = 0; i < 3; i++) {
        rr(g, pad + i * ((w - pad * 2) / 3) + 8, 140, (w - pad * 2) / 3 - 16, 200, 18);
        g.fill();
      }
      g.fillStyle = 'rgba(227,207,163,0.9)';
      rr(g, pad, 370, w - pad * 2, h - 420, 18);
      g.fill();
    } else if (kind === 'logic') {
      g.lineWidth = 8;
      const nodes = [
        [0.2, 0.3], [0.5, 0.2], [0.8, 0.32], [0.32, 0.72], [0.66, 0.7],
      ];
      g.strokeStyle = 'rgba(198,164,106,0.75)';
      for (const [a, b] of [[0, 1], [1, 2], [0, 3], [1, 4], [3, 4], [2, 4]]) {
        g.beginPath();
        g.moveTo(nodes[a][0] * w, nodes[a][1] * h);
        g.lineTo(nodes[b][0] * w, nodes[b][1] * h);
        g.stroke();
      }
      for (const [x, y] of nodes) {
        g.fillStyle = 'rgba(42,40,38,0.9)';
        rr(g, x * w - 60, y * h - 34, 120, 68, 16);
        g.fill();
      }
    } else if (kind === 'data') {
      for (let r = 0; r < 4; r++) {
        for (let c = 0; c < 6; c++) {
          g.fillStyle = (r + c) % 3 === 0 ? 'rgba(198,164,106,0.9)' : 'rgba(42,40,38,0.75)';
          rr(g, pad + c * ((w - pad * 2) / 6) + 6, pad + r * ((h - pad * 2) / 4) + 6, (w - pad * 2) / 6 - 12, (h - pad * 2) / 4 - 12, 12);
          g.fill();
        }
      }
    } else {
      // Cloud / infrastructure.
      g.lineWidth = 7;
      g.strokeStyle = 'rgba(227,207,163,0.9)';
      for (let i = 0; i < 3; i++) {
        rr(g, pad + i * ((w - pad * 2) / 3) + 12, h * 0.25, (w - pad * 2) / 3 - 24, h * 0.5, 22);
        g.stroke();
        g.fillStyle = 'rgba(198,164,106,0.9)';
        for (let j = 0; j < 3; j++) {
          rr(g, pad + i * ((w - pad * 2) / 3) + 36, h * 0.32 + j * 54, (w - pad * 2) / 3 - 72, 30, 8);
          g.fill();
        }
      }
    }
  };
}

function drawChannelIcon(kind) {
  return (g, w, h) => {
    g.clearRect(0, 0, w, h);
    g.strokeStyle = '#2a2826';
    g.fillStyle = '#2a2826';
    g.lineWidth = 14;
    g.lineCap = 'round';
    g.lineJoin = 'round';
    const cx = w / 2;
    const cy = h / 2;
    if (kind === 'search') {
      g.beginPath();
      g.arc(cx - 14, cy - 14, 52, 0, Math.PI * 2);
      g.stroke();
      g.beginPath();
      g.moveTo(cx + 24, cy + 24);
      g.lineTo(cx + 70, cy + 70);
      g.stroke();
    } else if (kind === 'play') {
      g.beginPath();
      g.moveTo(cx - 34, cy - 50);
      g.lineTo(cx + 50, cy);
      g.lineTo(cx - 34, cy + 50);
      g.closePath();
      g.fill();
    } else if (kind === 'mail') {
      rr(g, cx - 76, cy - 52, 152, 104, 14);
      g.stroke();
      g.beginPath();
      g.moveTo(cx - 70, cy - 44);
      g.lineTo(cx, cy + 8);
      g.lineTo(cx + 70, cy - 44);
      g.stroke();
    } else if (kind === 'share') {
      const pts = [[cx + 46, cy - 50], [cx - 46, cy], [cx + 46, cy + 50]];
      g.beginPath();
      g.moveTo(...pts[0]);
      g.lineTo(...pts[1]);
      g.lineTo(...pts[2]);
      g.stroke();
      for (const p of pts) {
        g.beginPath();
        g.arc(p[0], p[1], 22, 0, Math.PI * 2);
        g.fill();
      }
    } else {
      // Chart.
      g.beginPath();
      g.moveTo(cx - 70, cy + 50);
      g.lineTo(cx - 24, cy);
      g.lineTo(cx + 10, cy + 24);
      g.lineTo(cx + 70, cy - 50);
      g.stroke();
    }
  };
}

// ───────────────────────────────────────────────────────────────────────────
// Scenes
// ───────────────────────────────────────────────────────────────────────────

/** Shared idle motion: a slow float plus pointer parallax on [group]. */
function idle(group, state, { float = 0.05, sway = 0.18, phase = 0 } = {}) {
  const t = state.time;
  group.position.y = (group.userData.baseY ?? 0) + Math.sin(t * 0.8 + phase) * float;
  group.rotation.x = (group.userData.baseRX ?? 0) + state.pointer.y * sway * 0.6;
  group.rotation.z = (group.userData.baseRZ ?? 0) + Math.sin(t * 0.5 + phase) * 0.02;
}

function camOrbit(camera, state, { distance, height = 0.3, look = new THREE.Vector3(), swing = 0.35, base = 0 }) {
  const a = base + state.pointer.x * swing * 0.5;
  camera.position.set(Math.sin(a) * distance, height + state.pointer.y * 0.15, Math.cos(a) * distance);
  camera.lookAt(look);
}

const SCENES = {
  /**
   * Signature hero sculpture: an armillary of polished champagne-gold and
   * chrome bands nested around a liquid-gold core, each band tumbling on its
   * own axis. Fine orbital rings carry small gold and chrome spheres around
   * it, and the whole piece floats above a tiered gold-and-pearl platform.
   *
   * The bands are nested spherical shells (each band's inner and outer
   * distance from the centre lies between its neighbours'), so however they
   * turn they never pass through one another.
   *
   * Rendered on a transparent canvas: the hero paints its own ivory backdrop.
   */
  hero(kit) {
    const { scene, camera } = kit;
    const root = new THREE.Group();
    const sculpture = new THREE.Group();
    sculpture.position.y = 0.36;
    root.add(sculpture);
    scene.add(root);
    const casters = [];

    // A thick ring with softly rounded edges, turned on a lathe: radius R,
    // band width w (along the axis), wall thickness t.
    const band = (R, w, t) => {
      const pts = [];
      const r = Math.min(t, w) * 0.48;
      const corner = (cx, cy, a0) => {
        for (let i = 0; i <= 6; i++) {
          const a = a0 + (i / 6) * (Math.PI / 2);
          pts.push(new THREE.Vector2(cx + Math.cos(a) * r, cy + Math.sin(a) * r));
        }
      };
      const ri = R - t / 2;
      const ro = R + t / 2;
      const h = w / 2;
      corner(ro - r, -h + r, -Math.PI / 2);
      corner(ro - r, h - r, 0);
      corner(ri + r, h - r, Math.PI / 2);
      corner(ri + r, -h + r, Math.PI);
      pts.push(pts[0].clone());
      return new THREE.LatheGeometry(pts, kit.seg(200));
    };

    // [radius, width, thickness, gold?, rest orientation, tumble axis, speed]
    const bandSpecs = [
      [0.72, 0.18, 0.05, false, [1.1, 0.2, 0.5], [1, 0, 0.3], 0.34],
      [0.95, 0.4, 0.06, true, [0.35, 0.6, -0.9], [0.2, 0, 1], -0.22],
      [1.2, 0.28, 0.05, false, [-0.75, 0.3, 0.35], [1, 0, -0.5], 0.17],
      [1.46, 0.5, 0.07, true, [0.55, -0.4, 0.95], [0.4, 0, 1], -0.12],
      [1.7, 0.2, 0.045, false, [1.35, 0.9, 0], [1, 0, 0.2], 0.09],
    ];
    const heroGold = (extra) => kit.lacqueredGold(extra);
    const heroSilver = (extra) => kit.polishedPlatinum(extra);

    const bands = bandSpecs.map(([R, w, t, isGold, rest, axis, speed], i) => {
      const material = isGold ? heroGold() : heroSilver();
      const mesh = new THREE.Mesh(band(R, w, t), material);
      const pivot = new THREE.Group();
      pivot.rotation.set(...rest);
      pivot.add(mesh);
      sculpture.add(pivot);
      casters.push(mesh);
      return { pivot, mesh, rest: pivot.quaternion.clone(), axis: new THREE.Vector3(...axis).normalize(), speed, phase: i * 0.9 };
    });

    // Liquid-gold core with a warm inner light.
    const core = new THREE.Mesh(new THREE.SphereGeometry(0.4, 96, 64), heroGold({ roughness: 0.04 }));
    const coreLight = new THREE.PointLight(0xffdca0, 1.2, 2.2, 2);
    sculpture.add(core, coreLight);
    casters.push(core);

    // Fine orbital rings, each carrying a sphere along its path. They turn
    // about the vertical only, so they never dip into the platform.
    const orbitSpecs = [
      // [radius, tilt x, tilt z, yaw, speed, sphere radius, gold ring?, gold sphere?]
      [2.0, 1.05, 0.25, 0.2, 0.34, 0.12, true, true],
      [2.25, -0.85, -0.35, 1.4, -0.26, 0.13, false, false],
      [2.45, 0.5, 0.75, 2.5, 0.21, 0.115, true, true],
    ];
    const orbits = orbitSpecs.map(([radius, tx, tz, yaw, speed, size, goldRing, goldSphere], i) => {
      const spin = new THREE.Group();
      spin.rotation.y = yaw;
      const tilt = new THREE.Group();
      tilt.rotation.set(Math.PI / 2 + tx, 0, tz);
      spin.add(tilt);
      const ring = new THREE.Mesh(
        new THREE.TorusGeometry(radius, goldRing ? 0.02 : 0.016, 20, kit.seg(360)),
        goldRing ? heroGold({ roughness: 0.12, clearcoat: 0.5 }) : heroSilver({ roughness: 0.07 }),
      );
      const sphere = new THREE.Mesh(new THREE.SphereGeometry(size, 48, 32), goldSphere ? heroGold() : heroSilver({ roughness: 0.04 }));
      // A second, smaller rider opposite the first on the outer rings.
      const rider = i > 0 ? new THREE.Mesh(new THREE.SphereGeometry(size * 0.75, 32, 24), goldSphere ? heroSilver({ roughness: 0.04 }) : heroGold()) : null;
      tilt.add(ring, sphere);
      if (rider) tilt.add(rider);
      sculpture.add(spin);
      casters.push(ring, sphere);
      if (rider) casters.push(rider);
      return { spin, tilt, ring, sphere, rider, radius, speed, yaw, offset: i * 2.2 };
    });

    // Small metallic spheres drifting in the space around the piece.
    const accents = floaters(kit, [
      ['goldSphere', -2.7, 1.6, -0.8, 0.08],
      ['sphere', 2.75, 1.9, -1.2, 0.07],
      ['goldSphere', 2.9, -0.4, 0.3, 0.06],
      ['sphere', -2.85, -0.5, 0.2, 0.05],
      ['goldSphere', -1.5, 2.55, -1.4, 0.05],
    ]);
    root.add(accents.group);
    accents.group.traverse((o) => o.isMesh && casters.push(o));

    const dust = new DustField(kit, { count: 220, spread: 6.4, size: 0.034, opacity: 0.6 });
    root.add(dust.points);

    // Tiered platform: a brushed champagne-gold plinth under a pearl top
    // with an inlaid gold ring and a softly glowing rim.
    const platformTop = -2.0;
    const platform = new THREE.Group();
    const plinth = new THREE.Mesh(
      new THREE.CylinderGeometry(3.05, 3.15, 0.24, kit.seg(200), 1),
      kit.gold({ color: 0xead6ac, roughness: 0.32 }),
    );
    plinth.position.y = platformTop - 0.08 - 0.12;
    const top = new THREE.Mesh(
      new THREE.CylinderGeometry(2.86, 2.9, 0.08, kit.seg(200), 1),
      kit.pearl(),
    );
    top.position.y = platformTop - 0.04;
    top.receiveShadow = true;
    plinth.receiveShadow = true;
    const inlay = new THREE.Mesh(new THREE.TorusGeometry(2.4, 0.018, 12, kit.seg(300)), kit.gold({ roughness: 0.1 }));
    inlay.rotation.x = Math.PI / 2;
    inlay.position.y = platformTop + 0.002;
    const lip = new THREE.Mesh(new THREE.TorusGeometry(2.88, 0.028, 16, kit.seg(300)), kit.liquidGold({ roughness: 0.06 }));
    lip.rotation.x = Math.PI / 2;
    lip.position.y = platformTop;
    const rim = new THREE.Mesh(new THREE.TorusGeometry(3.055, 0.016, 12, kit.seg(300)), kit.glow(BRAND.softGold, 1.6));
    rim.rotation.x = Math.PI / 2;
    rim.position.y = platformTop - 0.08;
    platform.add(plinth, top, inlay, lip, rim);
    // Ambient occlusion: a soft pool under the sculpture, a broad shadow
    // around the plinth and a tight occlusion line where it meets the floor.
    const pool = kit.contactShadow(1.6, 0.18, { warm: true });
    pool.position.y = platformTop + 0.003;
    const ground = kit.contactShadow(4.2, 0.24, { warm: true });
    ground.position.y = platformTop - 0.31;
    const foot = kit.contactShadow(3.4, 0.2, { tight: true, warm: true });
    foot.position.y = platformTop - 0.305;
    platform.add(pool, ground, foot);
    scene.add(platform);

    if (kit.quality.shadow) {
      const key = new THREE.DirectionalLight(0xfff4e2, 1.0);
      key.position.set(1.2, 6, 1.6);
      key.castShadow = true;
      key.shadow.mapSize.set(kit.quality.shadow, kit.quality.shadow);
      Object.assign(key.shadow.camera, { left: -3.4, right: 3.4, top: 3.4, bottom: -3.4, near: 1, far: 12 });
      key.shadow.radius = 18;
      key.shadow.blurSamples = 20;
      key.shadow.bias = -0.0008;
      scene.add(key, key.target);
      for (const m of casters) m.castShadow = true;
    }
    // Warm light raking across the gold from behind-left, and a soft front fill.
    const sweep = new THREE.SpotLight(0xffe2ad, 14, 12, 0.6, 0.8, 1.6);
    sweep.position.set(-3.5, 3.5, -2);
    sweep.target.position.set(0, 0, 0);
    const front = new THREE.PointLight(0xfff6e8, 6, 10, 2);
    front.position.set(0.5, 1.2, 4.2);
    // Warm light bouncing up off the pearl-and-gold platform, so the bands'
    // undersides glow the way metal does above a lit surface.
    const bounce = new THREE.PointLight(0xffe4b8, 2.2, 4.5, 2);
    bounce.position.set(0, platformTop + 0.5, 0.9);
    scene.add(sweep, sweep.target, front, bounce);

    const q = new THREE.Quaternion();
    const look = new THREE.Vector3();
    let distance = 7;
    let rest = null;

    return {
      frame(cam, aspect) {
        distance = fitDistance(cam, 2.85, aspect);
      },
      update(s, dt) {
        const t = s.time;
        const intro = s.reduced ? 1 : introCurve(t, 2.8);
        // Scroll measured from where the hero sits when the page opens.
        if (rest === null) rest = s.targetProgress;
        const scroll = THREE.MathUtils.clamp((s.progress - rest) / Math.max(0.2, 1 - rest), 0, 1);

        // Bands unfold from a closed, aligned stack and then tumble
        // independently; scrolling opens the gimbal further.
        for (const b of bands) {
          q.setFromAxisAngle(b.axis, t * b.speed + b.phase * intro + scroll * 1.4 * Math.sign(b.speed));
          b.pivot.quaternion.identity().slerp(b.rest, intro).multiply(q);
        }
        sculpture.scale.setScalar(0.78 + intro * 0.3);
        core.rotation.y = t * 0.4;
        coreLight.intensity = 1.0 + Math.sin(t * 1.8) * 0.25;

        // The whole sculpture turns slowly; the pointer tilts it.
        sculpture.rotation.y = t * 0.1 + s.pointer.x * 0.35 + scroll * 0.9;
        sculpture.rotation.x = s.pointer.y * 0.18 + Math.sin(t * 0.3) * 0.04;
        sculpture.position.y = 0.36 + Math.sin(t * 0.7) * 0.05 + scroll * 0.25;

        for (const o of orbits) {
          o.spin.rotation.y = o.yaw + t * o.speed * 0.25;
          const a = t * o.speed + o.offset;
          o.sphere.position.set(Math.cos(a) * o.radius, Math.sin(a) * o.radius, 0);
          if (o.rider) o.rider.position.set(Math.cos(a + Math.PI) * o.radius, Math.sin(a + Math.PI) * o.radius, 0);
          o.ring.scale.setScalar(0.85 + intro * 0.15 + scroll * 0.08);
          o.sphere.position.multiplyScalar(0.85 + intro * 0.15 + scroll * 0.08);
        }

        accents.update(t, dt, scroll * 0.3 + (1 - intro) * 0.5);
        accents.group.position.set(s.pointer.x * 0.18, -s.pointer.y * 0.12, 0);
        dust.points.position.set(s.pointer.x * 0.3, -s.pointer.y * 0.2, 0);
        dust.update(t, dt, null);
        rim.material.emissiveIntensity = 1.4 + Math.sin(t * 1.2) * 0.25;
        // The pool under the sculpture softens as it rises.
        const lift = sculpture.position.y - 0.36;
        pool.material.opacity = pool.userData.baseOpacity * (1 - lift * 1.6);
        pool.scale.setScalar(1 + lift * 0.5);

        // Cinematic camera: dolly in on load, rise and pull back on scroll.
        const zoom = 1.3 - intro * 0.3 + scroll * 0.12;
        look.set(0, -0.3 + scroll * 0.3, 0);
        camOrbit(camera, s, {
          distance: distance * zoom,
          height: -0.35 + scroll * 0.9 + (1 - intro) * 0.8,
          look,
          swing: 0.18,
          base: (1 - intro) * -0.45,
        });
      },
    };
  },

  /** Website development: an aluminium laptop with a live browser preview. */
  web(kit, options) {
    const { scene, camera } = kit;
    const group = new THREE.Group();
    scene.add(group);

    const alu = kit.aluminium();
    const base = kit.roundedBox(2.4, 0.07, 1.62, 0.035, alu, 5);
    group.add(base);
    const deck = kit.canvasTexture(1024, 680, (g, w, h) => {
      g.fillStyle = '#d9d6cf';
      g.fillRect(0, 0, w, h);
      g.fillStyle = '#262422';
      rr(g, 70, 40, w - 140, h * 0.5, 18);
      g.fill();
      g.fillStyle = '#34312d';
      const cols = 14;
      const kw = (w - 160) / cols;
      for (let r = 0; r < 5; r++) {
        for (let c = 0; c < cols; c++) rr(g, 80 + c * kw, 50 + r * (h * 0.48 / 5), kw - 6, h * 0.48 / 5 - 6, 6), g.fill();
      }
      g.fillStyle = '#cfcbc3';
      rr(g, w * 0.34, h * 0.6, w * 0.32, h * 0.33, 16);
      g.fill();
    });
    const deckMesh = new THREE.Mesh(new THREE.PlaneGeometry(2.3, 1.52), kit.aluminium({ map: deck, roughness: 0.42 }));
    deckMesh.rotation.x = -Math.PI / 2;
    deckMesh.position.y = 0.0355;
    group.add(deckMesh);

    const hinge = new THREE.Group();
    hinge.position.set(0, 0.035, -0.8);
    group.add(hinge);
    const lid = kit.roundedBox(2.4, 1.56, 0.045, 0.035, alu, 5);
    lid.position.set(0, 0.78, -0.02);
    hinge.add(lid);
    const bezel = new THREE.Mesh(new THREE.PlaneGeometry(2.3, 1.46), new THREE.MeshPhysicalMaterial({ color: 0x0b0a09, roughness: 0.1, clearcoat: 1 }));
    bezel.position.set(0, 0.78, 0.0035);
    hinge.add(bezel);
    const ui = kit.canvasTexture(1280, 800, options.variant === 'shop' ? drawShop : drawBrowser);
    const display = new THREE.Mesh(new THREE.PlaneGeometry(2.18, 1.36), kit.screen(ui));
    display.position.set(0, 0.79, 0.005);
    hinge.add(display);

    // A floating glass panel lifted out of the page: "component" layer.
    const panelArt = kit.canvasTexture(512, 320, (g, w, h) => {
      g.clearRect(0, 0, w, h);
      g.fillStyle = 'rgba(198,164,106,0.95)';
      rr(g, 30, 30, 120, 120, 26);
      g.fill();
      g.fillStyle = 'rgba(42,40,38,0.9)';
      rr(g, 180, 50, w - 220, 26, 13);
      g.fill();
      rr(g, 180, 96, w - 280, 20, 10);
      g.fill();
      g.fillStyle = 'rgba(227,207,163,0.95)';
      rr(g, 30, 190, w - 60, 90, 20);
      g.fill();
    });
    const panel = new THREE.Group();
    const glassPanel = kit.roundedBox(0.95, 0.6, 0.04, 0.04, kit.glass({ thickness: 0.15 }));
    const art = new THREE.Mesh(new THREE.PlaneGeometry(0.85, 0.53), new THREE.MeshBasicMaterial({ map: panelArt, transparent: true, depthWrite: false }));
    art.position.z = 0.022;
    panel.add(glassPanel, art);
    panel.position.set(1.15, 1.25, 0.25);
    panel.rotation.set(0, -0.35, 0.04);
    group.add(panel);

    const shadow = kit.contactShadow(1.9, 0.28);
    shadow.position.y = -0.05;
    group.add(shadow);
    group.userData.baseRX = 0;

    let distance = 6;
    const look = new THREE.Vector3(0.1, 0.55, 0);
    return {
      display,
      panel,
      frame(cam, aspect) {
        distance = fitDistance(cam, 1.55, aspect);
      },
      update(s, dt) {
        const t = s.time;
        hinge.rotation.x = -0.24;
        group.rotation.y = -0.45 + Math.sin(t * 0.3) * 0.06 + s.pointer.x * 0.2 + (s.progress - 0.5) * 0.3;
        panel.position.y = 1.25 + Math.sin(t * 0.9) * 0.05 + s.focus * 0.12;
        panel.rotation.y = -0.35 + Math.sin(t * 0.6) * 0.05;
        camOrbit(camera, s, { distance, height: 1.4, look, swing: 0.2 });
      },
    };
  },

  /** Mobile apps: two titanium-framed phones with live app screens. */
  mobile(kit, options) {
    const { scene, camera } = kit;
    const single = options.variant === 'single';
    const group = new THREE.Group();
    scene.add(group);

    const makePhone = (variant) => {
      const phone = new THREE.Group();
      const frame = kit.roundedBox(0.8, 1.64, 0.085, 0.11, kit.aluminium({ color: variant ? 0xa59f95 : 0xe6e3dd, roughness: 0.22 }), 6);
      const glassFront = kit.roundedBox(0.78, 1.62, 0.004, 0.1, new THREE.MeshPhysicalMaterial({ color: 0x0a0908, roughness: 0.05, clearcoat: 1 }), 6);
      glassFront.position.z = 0.043;
      const tex = kit.canvasTexture(560, 1180, drawPhoneApp(variant));
      const screen = new THREE.Mesh(new THREE.PlaneGeometry(0.72, 1.53), kit.screen(tex, 0.9));
      screen.position.z = 0.0458;
      // Camera module on the back.
      const bump = kit.roundedBox(0.3, 0.3, 0.03, 0.06, kit.aluminium({ color: 0xc4beb4 }), 4);
      bump.position.set(-0.2, 0.55, -0.055);
      phone.add(frame, glassFront, screen, bump);
      return phone;
    };
    const a = makePhone(0);
    const b = makePhone(1);
    a.position.set(-0.45, 0.05, 0.3);
    a.rotation.set(0.05, 0.35, 0.06);
    b.position.set(0.55, -0.1, -0.35);
    b.rotation.set(0.05, -0.4, -0.08);
    group.add(a);
    if (single) {
      a.position.set(0, 0, 0);
      a.rotation.set(0.08, -0.5, 0.12);
    } else {
      group.add(b);
    }

    const ring = new THREE.Mesh(new THREE.TorusGeometry(1.25, 0.008, 8, kit.seg(160)), kit.chrome());
    ring.rotation.x = Math.PI / 2.2;
    ring.position.y = -0.2;
    group.add(ring);

    const shadow = kit.contactShadow(1.5, 0.22);
    shadow.position.y = -1.2;
    scene.add(shadow);

    let distance = 6;
    return {
      frame(cam, aspect) {
        distance = fitDistance(cam, single ? 1.15 : 1.45, aspect);
      },
      update(s, dt) {
        const t = s.time;
        a.position.y = (single ? 0 : 0.05) + Math.sin(t * 0.9) * 0.06;
        b.position.y = -0.1 + Math.sin(t * 0.9 + 1.7) * 0.06;
        a.rotation.y = (single ? -0.5 : 0.35) + Math.sin(t * 0.4) * 0.08 - s.focus * 0.15;
        b.rotation.y = -0.4 + Math.sin(t * 0.4 + 1) * 0.08 + s.focus * 0.15;
        group.rotation.y = s.pointer.x * 0.3 + (s.progress - 0.5) * 0.35;
        ring.rotation.z += dt * 0.2;
        camOrbit(camera, s, { distance, height: 0.2, swing: 0.15 });
      },
    };
  },

  /** AI: a network of glass neurons with signals travelling along connections. */
  ai(kit, options) {
    return neuralScene(kit, { layers: [4, 6, 6, 3], spread: 2.6, radius: 0.11, ...options });
  },

  /** Large neural network for the AI & Technology section. */
  neural(kit, options) {
    return neuralScene(kit, { layers: [5, 8, 10, 8, 4], spread: 4.2, radius: 0.12, pulses: 26, wide: true, ...options });
  },

  /** Custom software: an exploded stack of glass architecture layers. */
  software(kit, options) {
    const { scene, camera } = kit;
    const design = options.variant === 'design';
    const group = new THREE.Group();
    scene.add(group);
    const kinds = ['infrastructure', 'data', 'logic', 'interface'];
    const layers = kinds.map((kind, i) => {
      const layer = new THREE.Group();
      const slab = kit.roundedBox(2.1, 0.06, 1.4, 0.03, i === 0 ? kit.aluminium() : kit.glass({ thickness: 0.2 }), 4);
      const art = kit.canvasTexture(840, 560, drawLayer(kind));
      const face = new THREE.Mesh(new THREE.PlaneGeometry(2.0, 1.32), new THREE.MeshBasicMaterial({ map: art, transparent: true, depthWrite: false }));
      face.rotation.x = -Math.PI / 2;
      face.position.y = 0.032;
      layer.add(slab, face);
      group.add(layer);
      return layer;
    });
    // Chrome columns tying the layers together.
    const posts = [];
    for (const [x, z] of [[-0.98, -0.63], [0.98, -0.63], [-0.98, 0.63], [0.98, 0.63]]) {
      const post = new THREE.Mesh(new THREE.CylinderGeometry(0.014, 0.014, 1, 16), kit.chrome());
      post.position.set(x, 0, z);
      group.add(post);
      posts.push(post);
    }
    const shadow = kit.contactShadow(1.9, 0.22);
    shadow.position.y = -0.9;
    scene.add(shadow);

    let distance = 6;
    return {
      frame(cam, aspect) {
        distance = fitDistance(cam, 1.65, aspect);
      },
      update(s, dt) {
        const t = s.time;
        const gap = 0.32 + s.focus * 0.1 + s.progress * 0.08;
        layers.forEach((layer, i) => {
          layer.position.y = -0.55 + i * gap + Math.sin(t * 0.8 + i * 0.7) * 0.02;
        });
        const top = -0.55 + (layers.length - 1) * gap;
        for (const post of posts) {
          post.scale.y = top + 0.55;
          post.position.y = (top - 0.55) / 2;
        }
        group.rotation.y = (design ? -0.35 : 0.65) + Math.sin(t * 0.25) * 0.1 + s.pointer.x * 0.25 + s.progress * 0.3;
        camOrbit(camera, s, { distance, height: design ? 3.4 : 2.1, look: new THREE.Vector3(0, -0.05, 0), swing: 0.1 });
      },
    };
  },

  /** Business automation: meshing machined gears and a glass data conduit. */
  automation(kit) {
    const { scene, camera } = kit;
    const group = new THREE.Group();
    scene.add(group);

    const big = new THREE.Mesh(gearGeometry(18, 0.82, 0.7, 0.16, 0.16), kit.chrome({ roughness: 0.2 }));
    const small = new THREE.Mesh(gearGeometry(12, 0.56, 0.45, 0.11, 0.16), kit.gold());
    const third = new THREE.Mesh(gearGeometry(10, 0.42, 0.33, 0.08, 0.14), kit.aluminium());
    big.position.set(-0.55, 0.1, 0);
    small.position.set(0.79, -0.12, 0.02);
    third.position.set(0.38, 0.92, -0.04);
    group.add(big, small, third);
    for (const gear of [big, small, third]) {
      const hub = new THREE.Mesh(new THREE.CylinderGeometry(0.07, 0.07, 0.3, 24), kit.charcoalMetal());
      hub.rotation.x = Math.PI / 2;
      gear.add(hub);
    }

    // Glass conduit with data packets flowing through it.
    const path = new THREE.CatmullRomCurve3([
      new THREE.Vector3(-1.9, -0.9, 0.5),
      new THREE.Vector3(-1.1, -1.05, 0.7),
      new THREE.Vector3(0, -0.95, 0.75),
      new THREE.Vector3(1.0, -0.85, 0.5),
      new THREE.Vector3(1.6, -0.1, 0.35),
      new THREE.Vector3(1.4, 0.8, 0.3),
    ]);
    const tube = new THREE.Mesh(new THREE.TubeGeometry(path, kit.seg(160), 0.07, 20, false), kit.glass({ thickness: 0.12 }));
    group.add(tube);
    const packets = [];
    for (let i = 0; i < 7; i++) {
      const p = new THREE.Mesh(new THREE.CapsuleGeometry(0.035, 0.07, 6, 12), kit.glow(i % 2 ? BRAND.softGold : BRAND.gold, 2.4));
      group.add(p);
      packets.push(p);
    }
    const shadow = kit.contactShadow(1.9, 0.18);
    shadow.position.y = -1.35;
    scene.add(shadow);

    const tangent = new THREE.Vector3();
    const up = new THREE.Vector3(0, 1, 0);
    let distance = 6;
    return {
      frame(cam, aspect) {
        distance = fitDistance(cam, 1.8, aspect);
      },
      update(s, dt) {
        const speed = 0.35 + s.focus * 0.4;
        big.rotation.z += dt * speed;
        small.rotation.z -= dt * speed * (18 / 12);
        third.rotation.z -= dt * speed * (18 / 10);
        packets.forEach((p, i) => {
          const u = (s.time * 0.09 * (1 + s.focus) + i / packets.length) % 1;
          path.getPointAt(u, p.position);
          path.getTangentAt(u, tangent);
          p.quaternion.setFromUnitVectors(up, tangent);
        });
        group.rotation.y = -0.3 + s.pointer.x * 0.3 + Math.sin(s.time * 0.3) * 0.05 + (s.progress - 0.5) * 0.3;
        group.rotation.x = 0.12 + s.pointer.y * 0.1;
        camOrbit(camera, s, { distance, height: 0.3, swing: 0.1 });
      },
    };
  },

  /** Digital marketing: channels orbiting a chrome hub above a rising chart. */
  marketing(kit, options) {
    const { scene, camera } = kit;
    const brand = options.variant === 'brand';
    const group = new THREE.Group();
    scene.add(group);

    const hub = new THREE.Mesh(
      brand ? new THREE.IcosahedronGeometry(0.34, 0) : new THREE.SphereGeometry(0.3, kit.seg(64), kit.seg(48)),
      brand ? kit.gold({ flatShading: true }) : kit.chrome({ roughness: 0.08 }),
    );
    hub.position.y = 0.45;
    group.add(hub);

    const heights = [0.45, 0.7, 0.62, 0.95, 1.25];
    const bars = heights.map((h, i) => {
      const bar = kit.roundedBox(0.26, 1, 0.26, 0.04, i === heights.length - 1 ? kit.gold() : kit.glass({ thickness: 0.3 }), 4);
      bar.position.set(-0.7 + i * 0.35, 0, 0.75);
      bar.userData.h = h;
      group.add(bar);
      return bar;
    });
    const trend = new THREE.CatmullRomCurve3(heights.map((h, i) => new THREE.Vector3(-0.7 + i * 0.35, h - 0.95 + 0.22, 0.75)));
    const trendLine = new THREE.Mesh(new THREE.TubeGeometry(trend, 64, 0.012, 8, false), kit.glow(BRAND.gold, 1.6));
    group.add(trendLine);

    const icons = ['search', 'play', 'mail', 'share', 'chart'];
    const channels = icons.map((kind, i) => {
      const tile = new THREE.Group();
      const body = kit.roundedBox(0.36, 0.36, 0.07, 0.08, i % 2 ? kit.porcelain() : kit.chrome({ roughness: 0.25 }), 4);
      const art = kit.canvasTexture(256, 256, drawChannelIcon(kind));
      const face = new THREE.Mesh(new THREE.PlaneGeometry(0.26, 0.26), new THREE.MeshBasicMaterial({ map: art, transparent: true, depthWrite: false }));
      face.position.z = 0.037;
      tile.add(body, face);
      group.add(tile);
      const geo = new THREE.BufferGeometry().setFromPoints([new THREE.Vector3(), new THREE.Vector3()]);
      const line = new THREE.Line(geo, new THREE.LineBasicMaterial({ color: BRAND.gold, transparent: true, opacity: 0.3 }));
      group.add(line);
      return { tile, line, phase: (i / icons.length) * Math.PI * 2 };
    });

    const shadow = kit.contactShadow(1.8, 0.2);
    shadow.position.y = -0.98;
    scene.add(shadow);

    let distance = 6;
    return {
      frame(cam, aspect) {
        distance = fitDistance(cam, 1.65, aspect);
      },
      update(s, dt) {
        const t = s.time;
        const grow = Math.min(1, 0.35 + s.progress * 1.2 + s.focus * 0.3);
        bars.forEach((bar, i) => {
          const h = Math.max(0.05, bar.userData.h * grow);
          bar.scale.y = h;
          bar.position.y = -0.95 + h / 2;
        });
        trendLine.scale.y = grow;
        trendLine.position.y = -0.95 * (1 - grow);
        hub.position.y = 0.45 + Math.sin(t * 0.9) * 0.04;
        for (const c of channels) {
          const a = c.phase + t * 0.25;
          c.tile.position.set(Math.cos(a) * 1.05, 0.45 + Math.sin(a * 2) * 0.12, Math.sin(a) * 0.55 - 0.15);
          c.tile.lookAt(camera.position);
          const pos = c.line.geometry.attributes.position;
          pos.setXYZ(0, hub.position.x, hub.position.y, hub.position.z);
          pos.setXYZ(1, c.tile.position.x, c.tile.position.y, c.tile.position.z);
          pos.needsUpdate = true;
        }
        if (brand) hub.rotation.y += dt * 0.3;
        group.rotation.y = (brand ? 0.5 : 0) + s.pointer.x * 0.3 + (s.progress - 0.5) * 0.2;
        camOrbit(camera, s, { distance, height: 0.7, look: new THREE.Vector3(0, 0.05, 0), swing: 0.15 });
      },
    };
  },

  /**
   * Who We Are: 3D laid over a photograph. Flutter places the photo in the
   * frame; this transparent scene adds what stands in and around it,
   * positioned in the same normalised coordinates (see [viewPlane]):
   *
   *   - a glass globe with two gold meridians, the equator and a few gold
   *     arcs, turning slowly on a gold-and-pearl plinth below the photo's
   *     lower right, with one small sphere in orbit;
   *   - a glass panel of rising gold bars at the photo's left edge;
   *   - a fine gold halo over the upper right;
   *   - a slender gold ribbon along the photo's lower and right edges;
   *   - drifting gold dust.
   *
   * Lit to match the photograph: daylight from behind and above, so the
   * gold takes rim light and shadows fall softly towards the viewer. The
   * pointer sways the camera, separating near and far elements; scrolling
   * turns the globe and lifts the bars.
   */
  about(kit) {
    const { scene, camera } = kit;
    const distance = 10;
    // The Flutter frame is laid out at this aspect ratio.
    const at = viewPlane(distance, 1.08);
    const gold = (extra) => kit.lacqueredGold(extra);
    const silver = (extra) => kit.polishedPlatinum(extra);
    const root = new THREE.Group();
    scene.add(root);
    const casters = [];
    const cast = (...meshes) => meshes.forEach((m) => m.traverse((o) => o.isMesh && casters.push(o)));

    // ── Globe on its plinth, below the photo's lower right ────────────────
    const base = at(0.78, 0.875);
    const globeStand = new THREE.Group();
    globeStand.position.copy(base);
    globeStand.rotation.x = 0.16; // show a little of the plinth's top
    root.add(globeStand);
    const plinth = new THREE.Mesh(new THREE.CylinderGeometry(0.6, 0.64, 0.1, kit.seg(120)), gold({ roughness: 0.24 }));
    plinth.position.y = 0.05;
    const deck = new THREE.Mesh(new THREE.CylinderGeometry(0.55, 0.57, 0.06, kit.seg(120)), kit.pearl());
    deck.position.y = 0.13;
    const lip = new THREE.Mesh(new THREE.TorusGeometry(0.56, 0.012, 12, kit.seg(160)), gold({ roughness: 0.08 }));
    lip.rotation.x = Math.PI / 2;
    lip.position.y = 0.16;
    deck.receiveShadow = true;
    globeStand.add(plinth, deck, lip);
    cast(plinth);

    const globeR = 0.5;
    const globe = new THREE.Group();
    globe.position.y = 0.16 + 0.05 + globeR;
    globe.rotation.z = 0.4; // the axis's tilt
    globeStand.add(globe);
    const glassBall = new THREE.Mesh(new THREE.SphereGeometry(globeR, 64, 48), kit.clearGlass({ opacity: 0.3, envMapIntensity: 2.3 }));
    const coreBall = new THREE.Mesh(new THREE.SphereGeometry(0.09, 48, 32), gold({ roughness: 0.05 }));
    globe.add(glassBall, coreBall);
    // A restrained armillary: two meridians and the equator, fine as wire.
    const wire = (r) => new THREE.TorusGeometry(r, 0.0065, 8, kit.seg(160));
    for (let i = 0; i < 2; i++) {
      const meridian = new THREE.Mesh(wire(globeR * 1.004), gold({ roughness: 0.16 }));
      meridian.rotation.y = (i / 2) * Math.PI;
      globe.add(meridian);
    }
    const equator = new THREE.Mesh(wire(globeR * 1.004), gold({ roughness: 0.16 }));
    equator.rotation.x = Math.PI / 2;
    globe.add(equator);
    // Gold nodes on the surface, linked by arcs that rise off it: a network
    // spanning the globe.
    const rand = mulberry32(5);
    const nodes = [];
    for (let i = 0; i < 6; i++) {
      const lat = (rand() - 0.5) * 2.2;
      const lon = rand() * Math.PI * 2;
      const p = new THREE.Vector3(Math.cos(lat) * Math.cos(lon), Math.sin(lat), Math.cos(lat) * Math.sin(lon)).multiplyScalar(globeR);
      nodes.push(p);
      const dot = new THREE.Mesh(new THREE.SphereGeometry(0.022, 16, 12), gold({ roughness: 0.06 }));
      dot.position.copy(p);
      globe.add(dot);
    }
    for (const [a, b] of [[0, 3], [1, 4], [2, 5]]) {
      const mid = nodes[a].clone().add(nodes[b]).normalize().multiplyScalar(globeR * 1.18);
      const arc = new THREE.QuadraticBezierCurve3(nodes[a], mid, nodes[b]);
      globe.add(new THREE.Mesh(new THREE.TubeGeometry(arc, 32, 0.004, 6), gold({ roughness: 0.1 })));
    }
    cast(coreBall);

    // One small platinum sphere on a tilted orbit; its path is left unseen.
    const orbits = [[0.74, 0.5, 0.22, 0.04]].map(([r, tilt, speed, size], i) => {
      const pivot = new THREE.Group();
      pivot.position.copy(globe.position);
      pivot.rotation.set(Math.PI / 2 + tilt, 0, 0.3);
      const rider = new THREE.Mesh(new THREE.SphereGeometry(size, 32, 24), silver({ roughness: 0.04 }));
      pivot.add(rider);
      globeStand.add(pivot);
      cast(rider);
      return { rider, r, speed, phase: i * 2.4 };
    });

    // Soft shadows under the plinth, falling a little towards the viewer as
    // they do in the photograph, which is lit from the windows behind.
    const contact = kit.contactShadow(0.8, 0.32, { tight: true, warm: true });
    contact.position.copy(base).add(new THREE.Vector3(0, 0.003, 0.08));
    const pool = kit.contactShadow(1.15, 0.16, { warm: true });
    pool.position.copy(base).add(new THREE.Vector3(0.05, 0.002, 0.3));
    pool.scale.set(1, 0.55, 1);
    root.add(contact, pool);

    // ── Glass panel of rising gold bars at the photo's left edge ──────────
    const chart = new THREE.Group();
    chart.position.copy(at(0.12, 0.6, 0.9));
    chart.rotation.set(0.04, 0.42, 0);
    root.add(chart);
    const pane = kit.roundedBox(1.34, 0.98, 0.03, 0.05, kit.clearGlass({ opacity: 0.18 }), 4);
    const frame = kit.roundedBox(1.36, 0.022, 0.05, 0.01, gold({ roughness: 0.12 }), 2);
    frame.position.y = -0.5;
    chart.add(pane, frame);
    const barHeights = [0.24, 0.34, 0.46, 0.6, 0.78];
    const bars = barHeights.map((h, i) => {
      const bar = kit.roundedBox(0.15, 1, 0.08, 0.02, i === barHeights.length - 1 ? gold({ roughness: 0.06 }) : gold({ roughness: 0.16 }), 3);
      bar.userData.h = h;
      bar.position.set(-0.46 + i * 0.23, 0, 0.07);
      chart.add(bar);
      return bar;
    });
    const trend = new THREE.CatmullRomCurve3(barHeights.map((h, i) => new THREE.Vector3(-0.46 + i * 0.23, -0.49 + h + 0.1, 0.1)));
    const trendLine = new THREE.Mesh(new THREE.TubeGeometry(trend, 64, 0.008, 6), gold({ roughness: 0.08 }));
    chart.add(trendLine);

    // ── Halo over the upper right ─────────────────────────────────────────
    const halo = new THREE.Mesh(new THREE.TorusGeometry(0.44, 0.018, 20, kit.seg(200)), gold({ roughness: 0.08 }));
    halo.position.copy(at(0.84, 0.07, -0.6));
    halo.rotation.set(1.22, 0, -0.08);
    root.add(halo);

    // ── Liquid-gold ribbon framing the photo's lower and right edges ─────
    const ribbonCurve = new THREE.CatmullRomCurve3([
      at(0.05, 0.88, 0.1),
      at(0.26, 0.955, 0.5),
      at(0.53, 0.975, 0.8),
      at(0.8, 0.95, 0.6),
      at(0.95, 0.76, 0.1),
      at(0.97, 0.52, -0.4),
      at(0.94, 0.32, -0.8),
    ]);
    const ribbonGeo = openRibbonGeometry(ribbonCurve, {
      segments: kit.seg(320),
      width: 0.15,
      thickness: 0.016,
      twist: (u) => Math.sin(u * Math.PI * 2) * 0.6,
      taper: (u) => Math.pow(Math.sin(Math.PI * u), 0.45),
    });
    const ribbon = new THREE.Mesh(ribbonGeo, kit.liquidGold({ roughness: 0.07, clearcoat: 0.9, clearcoatRoughness: 0.03, envMapIntensity: 1.4 }));
    root.add(ribbon);
    const ribbonCount = ribbonGeo.index.count;

    // ── Small accents and dust ────────────────────────────────────────────
    const accents = floaters(kit, [
      ['sphere', ...at(0.07, 0.2, 0.4).toArray(), 0.07],
      ['goldSphere', ...at(0.5, 0.06, -0.3).toArray(), 0.05],
      ['goldSphere', ...at(0.32, 0.9, 0.8).toArray(), 0.045],
    ]);
    root.add(accents.group);
    cast(accents.group, halo, ...bars);
    const dust = new DustField(kit, { count: 120, spread: 6.5, size: 0.026, opacity: 0.5 });
    scene.add(dust.points);

    // ── Light ─────────────────────────────────────────────────────────────
    // Lit as the photograph is: daylight from the windows behind and above
    // the team (the key, giving gold rims and forward-falling shadows), a
    // warm rim from behind left, and a soft fill from the room in front.
    if (keyLight(kit, scene, 4.5, [1.5, 7, -5])) for (const m of casters) m.castShadow = true;
    const sweep = new THREE.SpotLight(0xffe2ad, 14, 16, 0.7, 0.8, 1.4);
    sweep.position.set(-4, 5, -3);
    const front = new THREE.PointLight(0xfff6e8, 5.5, 14, 2);
    front.position.set(0.5, 0.5, 6);
    const bounce = new THREE.PointLight(0xffe4b8, 2.2, 3, 2);
    bounce.position.copy(base).add(new THREE.Vector3(0, 0.5, 1));
    scene.add(sweep, sweep.target, front, bounce);

    const look = new THREE.Vector3();
    return {
      update(s, dt) {
        const t = s.time;
        const intro = s.reduced ? 1 : introCurve(t, 2.6);
        // -1 as the section enters, 0 centred in the viewport, 1 as it leaves.
        const k = THREE.MathUtils.clamp((s.progress - 0.5) * 2, -1, 1);

        // The ribbon draws itself in, then catches the light as it sways.
        ribbonGeo.setDrawRange(0, Math.floor(ribbonCount * introCurve(s.reduced ? 99 : t, 2.2) / 6) * 6);
        ribbon.rotation.z = Math.sin(t * 0.3) * 0.006 + k * 0.01;

        globe.rotation.y = t * 0.12 + k * 0.5;
        globeStand.scale.setScalar(0.85 + intro * 0.15);
        for (const o of orbits) {
          const a = t * o.speed + o.phase;
          o.rider.position.set(Math.cos(a) * o.r, Math.sin(a) * o.r, 0);
        }

        // Bars rise in turn, and a little further as the section scrolls up.
        bars.forEach((bar, i) => {
          const grow = s.reduced ? 1 : introCurve(Math.max(0, t - 0.4 - i * 0.12), 1.2);
          const h = bar.userData.h * grow * (1 + Math.max(0, k) * 0.08);
          bar.scale.y = Math.max(0.001, h);
          bar.position.y = -0.49 + h / 2;
        });
        chart.position.y = at(0.12, 0.6).y + Math.sin(t * 0.6) * 0.04;
        chart.rotation.y = 0.42 + Math.sin(t * 0.35) * 0.04;

        halo.position.y = at(0.84, 0.07).y + Math.sin(t * 0.7 + 1) * 0.05;
        halo.rotation.z = -0.08 + Math.sin(t * 0.4) * 0.05;

        accents.update(t, dt, 0);
        dust.points.position.set(s.pointer.x * 0.3, -s.pointer.y * 0.2, 0);
        dust.update(t, dt, null);

        // A barely perceptible sway of the whole composition.
        root.rotation.y = Math.sin(t * 0.15) * 0.02;

        // The pointer sways the camera: near and far elements separate.
        camera.position.set(s.pointer.x * 0.35, -s.pointer.y * 0.22, distance * (1 + k * 0.025));
        camera.lookAt(look);
      },
    };
  },

  /** Technology: a rotating metallic ecosystem of interconnected components. */
  ecosystem(kit) {
    const { scene, camera } = kit;
    const group = new THREE.Group();
    scene.add(group);

    const hub = new THREE.Mesh(morphGeometry(0.34, 4), kit.liquidGold({ flatShading: false }));
    group.add(hub);
    const hubWeights = [0, 0, 0];
    const halo = new THREE.Mesh(new THREE.TorusGeometry(0.55, 0.012, 12, kit.seg(160)), kit.chrome());
    halo.rotation.x = Math.PI / 2;
    group.add(halo);

    // Three tilted orbits, each carrying a few component modules.
    const kinds = [
      () => kit.roundedBox(0.26, 0.26, 0.26, 0.05, kit.glass({ thickness: 0.3 }), 4),
      () => kit.roundedBox(0.3, 0.18, 0.06, 0.03, kit.chrome({ roughness: 0.12 }), 3),
      () => new THREE.Mesh(new THREE.CylinderGeometry(0.12, 0.12, 0.08, 40), kit.gold()),
      () => new THREE.Mesh(new THREE.OctahedronGeometry(0.16, 0), kit.glass({ thickness: 0.25 })),
      () => new THREE.Mesh(new THREE.TorusGeometry(0.1, 0.035, 16, 48), kit.gold({ roughness: 0.12 })),
    ];
    const orbits = [];
    const modules = [];
    [[1.05, 0.35, 0.0], [1.5, -0.45, 1.1], [1.95, 0.2, 2.2]].forEach(([radius, tilt, yaw], oi) => {
      const pivot = new THREE.Group();
      pivot.rotation.set(tilt, yaw, 0);
      const ring = new THREE.Mesh(new THREE.TorusGeometry(radius, 0.005, 8, kit.seg(200)), oi === 1 ? kit.gold({ roughness: 0.18 }) : kit.chrome({ roughness: 0.2 }));
      ring.rotation.x = Math.PI / 2;
      pivot.add(ring);
      group.add(pivot);
      orbits.push(pivot);
      const count = 3 + oi;
      for (let i = 0; i < count; i++) {
        const m = kinds[(i + oi * 2) % kinds.length]();
        const a = (i / count) * Math.PI * 2;
        m.userData = { pivot, radius, angle: a, speed: 0.25 - oi * 0.05 };
        pivot.add(m);
        modules.push(m);
      }
    });

    const linkPositions = new Float32Array(modules.length * 6);
    const linkGeo = new THREE.BufferGeometry();
    linkGeo.setAttribute('position', new THREE.BufferAttribute(linkPositions, 3));
    group.add(new THREE.LineSegments(linkGeo, new THREE.LineBasicMaterial({ color: BRAND.goldDeep, transparent: true, opacity: 0.3 })));

    const dust = new DustField(kit, { count: 160, spread: 4.5, size: 0.02, opacity: 0.55 });
    group.add(dust.points);
    const shadow = kit.contactShadow(2, 0.16);
    shadow.position.y = -1.45;
    scene.add(shadow);

    const world = new THREE.Vector3();
    let distance = 6;
    return {
      frame(cam, aspect) {
        distance = fitDistance(cam, 2.15, aspect);
      },
      update(s, dt) {
        const t = s.time;
        hub.morphTargetInfluences.splice(0, 3, ...morphWeights((Math.sin(t * 0.25) * 0.5 + 0.5) * 0.7 + s.progress * 0.3, hubWeights));
        hub.rotation.y = t * 0.4;
        halo.rotation.z = t * 0.3;
        orbits.forEach((o, i) => {
          o.rotation.y += dt * (0.08 + i * 0.03) * (1 + s.focus);
        });
        group.updateMatrixWorld();
        modules.forEach((m, i) => {
          const d = m.userData;
          const a = d.angle + t * d.speed;
          m.position.set(Math.cos(a) * d.radius, Math.sin(t * 0.8 + i) * 0.05, Math.sin(a) * d.radius);
          m.rotation.y = t * 0.6 + i;
          m.rotation.x = t * 0.3;
          m.getWorldPosition(world);
          group.worldToLocal(world);
          linkPositions.set([0, 0, 0, world.x, world.y, world.z], i * 6);
        });
        linkGeo.attributes.position.needsUpdate = true;
        dust.update(t, dt, null);
        group.rotation.x = 0.25 + s.pointer.y * 0.2;
        group.rotation.z = s.pointer.x * -0.1;
        camOrbit(camera, s, { distance: distance * (1.05 - s.progress * 0.15), height: 0.9, swing: 0.5, base: s.progress * 0.8 });
      },
    };
  },

  /** Process: a connected workflow whose stages appear as the page scrolls. */
  workflow(kit) {
    const { scene, camera } = kit;
    const group = new THREE.Group();
    scene.add(group);

    const path = new THREE.CatmullRomCurve3([
      new THREE.Vector3(-2.4, -0.3, 0.2),
      new THREE.Vector3(-1.2, 0.35, -0.2),
      new THREE.Vector3(0, -0.2, 0.25),
      new THREE.Vector3(1.2, 0.4, -0.15),
      new THREE.Vector3(2.4, -0.15, 0.2),
    ]);
    const tube = new THREE.Mesh(new THREE.TubeGeometry(path, kit.seg(200), 0.018, 12, false), kit.gold({ roughness: 0.16 }));
    group.add(tube);

    // Discover, Plan, Design, Build, Launch — each a different form.
    const makers = [
      () => new THREE.Mesh(new THREE.SphereGeometry(0.24, 48, 32), kit.chrome({ roughness: 0.06 })),
      () => kit.roundedBox(0.4, 0.4, 0.4, 0.06, kit.glass({ thickness: 0.4 }), 4),
      () => new THREE.Mesh(new THREE.TorusGeometry(0.22, 0.07, 24, 64), kit.liquidGold()),
      () => new THREE.Mesh(morphGeometry(0.25, 4), kit.glass({ thickness: 0.5 })),
      () => new THREE.Mesh(new THREE.OctahedronGeometry(0.28, 0), kit.gold({ roughness: 0.12, flatShading: true })),
    ];
    const stages = makers.map((make, i) => {
      const stage = new THREE.Group();
      const obj = make();
      const plinth = new THREE.Mesh(new THREE.CylinderGeometry(0.3, 0.32, 0.05, 48), kit.porcelain());
      plinth.position.y = -0.38;
      stage.add(obj, plinth);
      stage.position.copy(path.getPointAt(i / (makers.length - 1)));
      stage.userData.obj = obj;
      group.add(stage);
      return stage;
    });
    const morphing = stages[3].userData.obj;
    const weights = [0, 0, 0];

    const pulses = [];
    for (let i = 0; i < 6; i++) {
      const m = new THREE.Mesh(new THREE.SphereGeometry(0.035, 16, 12), kit.glow(BRAND.softGold, 2.6));
      group.add(m);
      pulses.push(m);
    }
    const dust = new DustField(kit, { count: 120, spread: 4, size: 0.018, opacity: 0.5 });
    group.add(dust.points);
    const shadow = kit.contactShadow(2.8, 0.14);
    shadow.position.y = -0.75;
    shadow.scale.set(1.6, 0.6, 1);
    scene.add(shadow);

    let distance = 6;
    return {
      frame(cam, aspect) {
        distance = fitBox(cam, 2.75, 0.85, aspect);
      },
      update(s, dt) {
        const t = s.time;
        // Stages rise into place one after another as the section scrolls in.
        const reveal = s.reduced ? 1 : Math.min(1, s.progress * 2.2 + 0.05);
        stages.forEach((stage, i) => {
          const local = THREE.MathUtils.clamp(reveal * stages.length - i, 0, 1);
          const e = THREE.MathUtils.smootherstep(local, 0, 1);
          stage.scale.setScalar(0.001 + e);
          stage.userData.obj.rotation.y = t * 0.5 + i;
          stage.userData.obj.position.y = Math.sin(t * 0.9 + i) * 0.05 + (1 - e) * -0.4;
        });
        morphing.morphTargetInfluences.splice(0, 3, ...morphWeights((Math.sin(t * 0.4) * 0.5 + 0.5), weights));
        pulses.forEach((m, i) => {
          const u = ((t * 0.08 + i / pulses.length) % 1) * reveal;
          path.getPointAt(u, m.position);
        });
        dust.update(t, dt, null);
        group.rotation.y = s.pointer.x * 0.2;
        group.rotation.x = 0.18 + s.pointer.y * 0.1;
        camOrbit(camera, s, { distance, height: 0.9, look: new THREE.Vector3(0, -0.05, 0), swing: 0.12 });
      },
    };
  },

  /** Industries: one iconic arrangement per sector (options.variant). */
  industries(kit, options) {
    const { scene, camera } = kit;
    const group = new THREE.Group();
    scene.add(group);
    const variant = options.variant || 'finance';
    const parts = [];
    const add = (mesh, x, y, z) => {
      mesh.position.set(x, y, z);
      mesh.userData.baseY = y;
      group.add(mesh);
      parts.push(mesh);
      return mesh;
    };
    if (variant === 'finance') {
      // Stacks of gold coins beside glass growth bars.
      const coin = new THREE.CylinderGeometry(0.28, 0.28, 0.06, 64);
      [[-0.9, 6], [-0.35, 9], [0.2, 4]].forEach(([x, n]) => {
        for (let i = 0; i < n; i++) {
          const c = new THREE.Mesh(coin, kit.gold({ roughness: 0.16 }));
          c.position.set(x + Math.sin(i * 1.7) * 0.02, -0.75 + i * 0.065, 0.1);
          group.add(c);
        }
      });
      [0.5, 0.8, 1.15].forEach((h, i) => {
        const bar = kit.roundedBox(0.22, h, 0.22, 0.03, kit.glass({ thickness: 0.25 }), 3);
        add(bar, 0.6 + i * 0.28, -0.78 + h / 2, -0.25);
      });
      add(new THREE.Mesh(new THREE.TorusGeometry(0.2, 0.035, 20, 64), kit.chrome()), -0.3, 0.75, -0.2);
    } else if (variant === 'healthcare') {
      // A glass capsule and a platinum cross.
      const capsule = new THREE.Mesh(new THREE.CapsuleGeometry(0.26, 0.7, 12, 32), kit.glass({ thickness: 0.4 }));
      capsule.rotation.z = 0.9;
      add(capsule, -0.45, 0.05, 0.1);
      const half = new THREE.Mesh(new THREE.CapsuleGeometry(0.24, 0.34, 12, 32), kit.liquidGold());
      half.rotation.z = 0.9;
      add(half, -0.62, -0.12, 0.1);
      const cross = new THREE.Group();
      cross.add(kit.roundedBox(0.26, 0.85, 0.2, 0.05, kit.chrome({ roughness: 0.12 }), 4));
      cross.add(kit.roundedBox(0.85, 0.26, 0.2, 0.05, kit.chrome({ roughness: 0.12 }), 4));
      add(cross, 0.65, 0.15, -0.2);
    } else if (variant === 'retail') {
      // A champagne shopping bag with platinum handles and a glass gift box.
      const bag = kit.roundedBox(0.9, 1.0, 0.42, 0.04, kit.gold({ roughness: 0.32, clearcoat: 0.6 }), 4);
      add(bag, -0.25, -0.25, 0);
      const handle = new THREE.Mesh(new THREE.TorusGeometry(0.2, 0.025, 16, 48, Math.PI), kit.chrome());
      handle.position.set(0, 0.5, 0);
      bag.add(handle);
      const box = kit.roundedBox(0.5, 0.5, 0.5, 0.05, kit.glass({ thickness: 0.4 }), 4);
      add(box, 0.7, -0.5, 0.25);
      const ribbon = kit.roundedBox(0.52, 0.06, 0.52, 0.02, kit.liquidGold(), 2);
      box.add(ribbon);
    } else if (variant === 'education') {
      // A stack of books under a mortarboard.
      ['porcelain', 'gold', 'charcoal', 'porcelain'].forEach((m, i) => {
        const mat = m === 'gold' ? kit.gold({ roughness: 0.3 }) : m === 'charcoal' ? kit.charcoalMetal() : kit.porcelain();
        const book = kit.roundedBox(1.0 - i * 0.06, 0.16, 0.7, 0.02, mat, 2);
        book.rotation.y = (i % 2 ? 1 : -1) * 0.12;
        add(book, 0, -0.72 + i * 0.17, 0);
      });
      const cap = new THREE.Group();
      cap.add(kit.roundedBox(0.9, 0.04, 0.9, 0.01, kit.charcoalMetal(), 2));
      const crown = new THREE.Mesh(new THREE.CylinderGeometry(0.26, 0.3, 0.2, 40), kit.charcoalMetal());
      crown.position.y = -0.12;
      cap.add(crown);
      const tassel = new THREE.Mesh(new THREE.CylinderGeometry(0.012, 0.012, 0.4, 8), kit.liquidGold());
      tassel.position.set(0.4, -0.18, 0.4);
      cap.add(tassel);
      cap.rotation.y = 0.6;
      add(cap, 0, 0.12, 0);
    } else if (variant === 'realestate') {
      // Glass towers on a porcelain site plan.
      add(kit.roundedBox(2.2, 0.08, 1.4, 0.03, kit.porcelain(), 3), 0, -0.85, 0);
      [[-0.6, 1.3], [0.05, 1.8], [0.65, 1.0]].forEach(([x, h], i) => {
        const tower = kit.roundedBox(0.42, h, 0.42, 0.03, i === 1 ? kit.glass({ thickness: 0.3 }) : kit.chrome({ roughness: 0.22 }), 3);
        add(tower, x, -0.81 + h / 2, i === 1 ? -0.15 : 0.15);
      });
      add(kit.roundedBox(0.3, 0.05, 0.3, 0.02, kit.liquidGold(), 2), 0.05, 0.98, -0.15);
    } else {
      // Hospitality: a platinum cloche on a gold plate.
      const plate = new THREE.Mesh(new THREE.CylinderGeometry(0.85, 0.75, 0.06, 64), kit.gold({ roughness: 0.18 }));
      add(plate, 0, -0.6, 0);
      const cloche = new THREE.Mesh(new THREE.SphereGeometry(0.62, 64, 32, 0, Math.PI * 2, 0, Math.PI / 2), kit.chrome({ roughness: 0.06, side: THREE.DoubleSide }));
      add(cloche, 0, -0.57, 0);
      const knob = new THREE.Mesh(new THREE.SphereGeometry(0.07, 24, 16), kit.liquidGold());
      knob.position.y = 0.66;
      cloche.add(knob);
    }
    const accents = floaters(kit, [
      ['sphere', -1.1, 0.7, -0.4, 0.09],
      ['ring', 1.05, 0.75, -0.5, 0.12],
      ['cube', 1.1, -0.5, 0.4, 0.13],
    ]);
    group.add(accents.group);
    const dust = new DustField(kit, { count: 90, spread: 3.6, size: 0.018, opacity: 0.5 });
    group.add(dust.points);
    const shadow = kit.contactShadow(1.7, 0.22);
    shadow.position.y = -0.9;
    scene.add(shadow);

    let distance = 6;
    return {
      frame(cam, aspect) {
        distance = fitDistance(cam, 1.25, aspect);
      },
      update(s, dt) {
        const t = s.time;
        parts.forEach((m, i) => {
          if (m.userData.baseY > -0.5) m.position.y = m.userData.baseY + Math.sin(t * 0.8 + i) * 0.03;
        });
        accents.update(t, dt, s.focus * 0.15);
        dust.update(t, dt, null);
        group.rotation.y = -0.35 + Math.sin(t * 0.25) * 0.12 + s.pointer.x * 0.35 + (s.progress - 0.5) * 0.3;
        camOrbit(camera, s, { distance, height: 0.75, look: new THREE.Vector3(0, -0.1, 0), swing: 0.15 });
      },
    };
  },

  /**
   * About page heroes: 3D around each page's photograph, in the same frame
   * as the homepage "Who We Are" visual (Flutter lays the photo out; see
   * [viewPlane]). Each page tells its own story:
   *
   *   who:        three glass layers edged in gold (development, design,
   *               innovation, the disciplines in our story) beside a gold
   *               ribbon rising up the left edge; a gold sphere in orbit.
   *   team:       two gold and three platinum spheres, the leadership and
   *               development teams, linked by gold arcs on a pearl disc.
   *   philosophy: six gold-rimmed glass tiles, one per principle, turning
   *               in an arc down the right edge; a gold compass below left.
   *   process:    meshing gold and platinum gears, steady progress, and a
   *               halo with a sphere travelling round it.
   *
   * Soft contact shadows ground the pieces inside the frame. The pointer
   * sways the camera; scrolling turns the pieces a little further.
   */
  aboutPage(kit, options) {
    const { scene, camera } = kit;
    const distance = 10;
    const at = viewPlane(distance, 1.08);
    const gold = (extra) => kit.lacqueredGold(extra);
    const silver = (extra) => kit.polishedPlatinum(extra);
    const root = new THREE.Group();
    scene.add(root);
    const casters = [];
    const cast = (...meshes) => meshes.forEach((m) => m.traverse((o) => o.isMesh && !o.material.transparent && casters.push(o)));
    // Per-variant motion, called each frame with (t, k): time and scroll (-1..1).
    const motions = [];
    let floorAt = at(0.5, 0.93);

    const variant = options.variant || 'who';
    if (variant === 'who') {
      const ribbonCurve = new THREE.CatmullRomCurve3([
        at(0.02, 0.97, 0.6),
        at(0.06, 0.78, 0.3),
        at(0.03, 0.55, 0),
        at(0.07, 0.3, -0.4),
        at(0.16, 0.08, -0.8),
        at(0.32, 0.02, -1.2),
      ]);
      const ribbonGeo = openRibbonGeometry(ribbonCurve, {
        segments: kit.seg(240),
        width: 0.24,
        thickness: 0.02,
        twist: (u) => Math.sin(u * Math.PI * 1.8) * 1.0,
        taper: (u) => Math.pow(Math.sin(Math.PI * u), 0.45),
      });
      const ribbon = new THREE.Mesh(ribbonGeo, kit.liquidGold({ roughness: 0.07, clearcoat: 0.9, clearcoatRoughness: 0.03, envMapIntensity: 1.4 }));
      root.add(ribbon);
      const ribbonCount = ribbonGeo.index.count;

      // Three glass layers, stacked and slightly fanned.
      const stack = new THREE.Group();
      stack.position.copy(at(0.8, 0.8, 0.8));
      stack.rotation.set(0.5, -0.5, 0);
      stack.scale.setScalar(1.15);
      root.add(stack);
      const layers = [0, 1, 2].map((i) => {
        const layer = new THREE.Group();
        const slab = kit.roundedBox(1.2, 0.06, 0.85, 0.03, kit.clearGlass({ color: 0xfff6e6, opacity: 0.55, envMapIntensity: 2.2 }), 3);
        const rim = new THREE.Mesh(new THREE.TorusGeometry(0.62, 0.022, 8, 4), gold({ roughness: 0.1 }));
        rim.rotation.set(Math.PI / 2, 0, Math.PI / 4);
        rim.scale.set(1, 0.71, 1);
        const gem = new THREE.Mesh(new THREE.SphereGeometry(0.07, 24, 16), i === 1 ? silver() : gold());
        gem.position.set(0.3 - i * 0.3, 0.08, 0);
        layer.add(slab, rim, gem);
        layer.userData.base = i * 0.32;
        stack.add(layer);
        cast(gem, rim);
        return layer;
      });

      const orb = new THREE.Mesh(new THREE.SphereGeometry(0.2, 48, 32), gold({ roughness: 0.04 }));
      const orbit = new THREE.Mesh(new THREE.TorusGeometry(0.42, 0.012, 8, kit.seg(160)), silver({ roughness: 0.05 }));
      const orbGroup = new THREE.Group();
      orbGroup.position.copy(at(0.9, 0.12, -0.5));
      orbit.rotation.set(1.2, 0, 0.3);
      orbGroup.add(orb, orbit);
      root.add(orbGroup);
      cast(orb);

      floorAt = at(0.8, 0.95);
      motions.push((t, k, intro) => {
        ribbonGeo.setDrawRange(0, Math.floor(ribbonCount * intro / 6) * 6);
        layers.forEach((layer, i) => {
          layer.position.y = layer.userData.base * intro + Math.sin(t * 0.7 + i) * 0.03 + Math.max(0, k) * i * 0.08;
          layer.rotation.y = Math.sin(t * 0.3 + i * 1.3) * 0.12;
        });
        stack.rotation.y = -0.5 + k * 0.25;
        orbGroup.position.y = at(0.9, 0.12).y + Math.sin(t * 0.6) * 0.06;
        orbit.rotation.z = 0.3 + t * 0.2;
      });
    } else if (variant === 'team') {
      // Leadership (gold) and developers (platinum), linked to one another.
      const team = new THREE.Group();
      team.position.copy(at(0.76, 0.82, 0.6));
      team.rotation.x = 0.18;
      team.scale.setScalar(1.2);
      root.add(team);
      const disc = new THREE.Mesh(new THREE.CylinderGeometry(0.95, 1.0, 0.08, kit.seg(120)), kit.pearl());
      const discLip = new THREE.Mesh(new THREE.TorusGeometry(0.97, 0.016, 12, kit.seg(160)), gold({ roughness: 0.08 }));
      discLip.rotation.x = Math.PI / 2;
      discLip.position.y = 0.04;
      disc.receiveShadow = true;
      team.add(disc, discLip);
      cast(disc);
      const members = [
        [-0.32, 0.72, 0.1, 0.19, true],
        [0.32, 0.78, -0.1, 0.19, true],
        [-0.55, 0.36, 0.35, 0.14, false],
        [0.02, 0.3, 0.45, 0.14, false],
        [0.58, 0.38, 0.3, 0.14, false],
      ].map(([x, y, z, r, lead]) => {
        const node = new THREE.Mesh(new THREE.SphereGeometry(r, 48, 32), lead ? gold({ roughness: 0.04 }) : silver({ roughness: 0.04 }));
        node.position.set(x, y, z);
        node.userData.base = node.position.clone();
        team.add(node);
        cast(node);
        return node;
      });
      const links = [[0, 1], [0, 2], [0, 3], [1, 3], [1, 4], [2, 3], [3, 4]].map(([a, b]) => {
        const link = new THREE.Mesh(new THREE.BufferGeometry(), gold({ roughness: 0.1 }));
        team.add(link);
        return { link, a, b };
      });
      const mid = new THREE.Vector3();
      const updateLinks = () => {
        for (const { link, a, b } of links) {
          const p = members[a].position;
          const q = members[b].position;
          mid.copy(p).add(q).multiplyScalar(0.5);
          mid.y += 0.12;
          link.geometry.dispose();
          link.geometry = new THREE.TubeGeometry(new THREE.QuadraticBezierCurve3(p, mid.clone(), q), 20, 0.008, 6);
        }
      };
      updateLinks();

      const halo = new THREE.Mesh(new THREE.TorusGeometry(0.48, 0.03, 20, kit.seg(160)), gold({ roughness: 0.06 }));
      halo.position.copy(at(0.08, 0.1, -0.3));
      halo.rotation.set(1.25, 0, 0.1);
      root.add(halo);
      cast(halo);

      floorAt = at(0.76, 0.89);
      let linkClock = 0;
      motions.push((t, k, intro, dt) => {
        members.forEach((node, i) => {
          node.position.copy(node.userData.base);
          node.position.y = node.userData.base.y * (0.6 + 0.4 * intro) + Math.sin(t * 0.8 + i * 1.7) * 0.035;
        });
        // Rebuild the arcs at a modest rate; they follow the floating spheres.
        linkClock += dt;
        if (linkClock > 1 / 20) {
          linkClock = 0;
          updateLinks();
        }
        team.rotation.y = Math.sin(t * 0.25) * 0.2 + k * 0.3;
        halo.position.y = at(0.08, 0.1).y + Math.sin(t * 0.6 + 1) * 0.05;
      });
    } else if (variant === 'philosophy') {
      const tiles = [];
      for (let i = 0; i < 6; i++) {
        const tile = new THREE.Group();
        const u = i / 5;
        tile.position.copy(at(0.94 - Math.sin(u * Math.PI) * 0.06, 0.1 + u * 0.78, -0.3 + Math.sin(u * Math.PI) * 0.6));
        const pane = kit.roundedBox(0.66, 0.66, 0.035, 0.07, kit.clearGlass({ color: 0xfff6e6, opacity: 0.45, envMapIntensity: 2.2 }), 4);
        const rim = new THREE.Mesh(new THREE.TorusGeometry(0.44, 0.018, 8, 4), gold({ roughness: 0.08 }));
        rim.rotation.z = Math.PI / 4;
        const seed = new THREE.Mesh(new THREE.SphereGeometry(0.07, 24, 16), gold({ roughness: 0.05 }));
        tile.add(pane, rim, seed);
        tile.userData.phase = i * 0.9;
        root.add(tile);
        cast(rim, seed);
        tiles.push(tile);
      }
      // A compass: graduated gold ring, platinum needle.
      const compass = new THREE.Group();
      compass.position.copy(at(0.1, 0.86, 0.6));
      compass.rotation.set(1.0, 0, 0.1);
      const ring = new THREE.Mesh(new THREE.TorusGeometry(0.5, 0.035, 20, kit.seg(160)), gold({ roughness: 0.06 }));
      const inner = new THREE.Mesh(new THREE.TorusGeometry(0.4, 0.008, 8, kit.seg(120)), gold({ roughness: 0.12 }));
      const needle = new THREE.Mesh(new THREE.OctahedronGeometry(0.42, 0), gold({ roughness: 0.18 }));
      needle.scale.set(0.12, 1, 0.05);
      needle.rotation.x = Math.PI / 2;
      const pivot = new THREE.Mesh(new THREE.SphereGeometry(0.06, 24, 16), gold());
      const needleGroup = new THREE.Group();
      needleGroup.add(needle);
      compass.add(ring, inner, needleGroup, pivot);
      root.add(compass);
      cast(ring, needle);

      floorAt = at(0.1, 0.95);
      motions.push((t, k, intro) => {
        tiles.forEach((tile, i) => {
          const rise = THREE.MathUtils.clamp(intro * 1.6 - i * 0.12, 0, 1);
          tile.scale.setScalar(0.001 + rise * 0.999);
          tile.rotation.set(Math.sin(t * 0.4 + tile.userData.phase) * 0.25, -0.6 + Math.sin(t * 0.3 + tile.userData.phase) * 0.35 + k * 0.4, 0);
        });
        needleGroup.rotation.y = Math.sin(t * 0.5) * 0.5 + k * 0.6;
        compass.position.y = at(0.1, 0.86).y + Math.sin(t * 0.6) * 0.04;
      });
    } else {
      const gears = new THREE.Group();
      gears.position.copy(at(0.8, 0.82, 0.6));
      gears.rotation.set(-0.75, -0.35, 0);
      root.add(gears);
      const big = new THREE.Mesh(gearGeometry(18, 0.82, 0.7, 0.16, 0.16), gold({ roughness: 0.3, envMapIntensity: 1.8 }));
      const small = new THREE.Mesh(gearGeometry(12, 0.56, 0.45, 0.11, 0.16), silver({ roughness: 0.26, envMapIntensity: 1.8 }));
      const third = new THREE.Mesh(gearGeometry(10, 0.42, 0.33, 0.08, 0.14), gold({ roughness: 0.3, envMapIntensity: 1.8 }));
      big.position.set(-0.55, 0.1, 0);
      small.position.set(0.79, -0.12, 0.02);
      third.position.set(0.38, 0.92, -0.04);
      for (const gear of [big, small, third]) {
        const hub = new THREE.Mesh(new THREE.CylinderGeometry(0.07, 0.07, 0.3, 24), kit.pearl());
        hub.rotation.x = Math.PI / 2;
        gear.add(hub);
      }
      gears.scale.setScalar(0.7);
      gears.add(big, small, third);
      cast(big, small, third);

      const halo = new THREE.Mesh(new THREE.TorusGeometry(0.55, 0.026, 20, kit.seg(160)), gold({ roughness: 0.06 }));
      const traveller = new THREE.Mesh(new THREE.SphereGeometry(0.08, 32, 24), silver({ roughness: 0.04 }));
      const haloGroup = new THREE.Group();
      haloGroup.position.copy(at(0.12, 0.1, -0.4));
      haloGroup.rotation.set(1.15, 0, 0.12);
      haloGroup.add(halo, traveller);
      root.add(haloGroup);
      cast(halo, traveller);

      floorAt = at(0.8, 0.95);
      motions.push((t, k, intro, dt) => {
        const speed = 0.35 * intro;
        big.rotation.z += dt * speed;
        small.rotation.z -= dt * speed * (18 / 12);
        third.rotation.z -= dt * speed * (18 / 10);
        gears.rotation.y = -0.35 + k * 0.25;
        gears.rotation.x = -0.75;
        gears.position.y = at(0.8, 0.82).y + Math.sin(t * 0.5) * 0.04;
        const a = t * 0.6;
        traveller.position.set(Math.cos(a) * 0.55, Math.sin(a) * 0.55, 0);
        haloGroup.position.y = at(0.12, 0.1).y + Math.sin(t * 0.6 + 1) * 0.05;
      });
    }

    // A soft contact shadow rather than a shadow-catching floor: its
    // faded edge stays inside the transparent canvas, where a floor's cast
    // shadow would run off the bottom and end in a hard line.
    const ground = kit.contactShadow(1.1, 0.26, { warm: true });
    ground.position.copy(floorAt);
    ground.scale.set(1, 0.5, 1);
    root.add(ground);
    const dust = new DustField(kit, { count: 120, spread: 6.5, size: 0.03, opacity: 0.55 });
    scene.add(dust.points);

    if (keyLight(kit, scene, 4.5, [4, 7, 5])) for (const m of casters) m.castShadow = true;
    const sweep = new THREE.SpotLight(0xffe2ad, 16, 16, 0.7, 0.8, 1.4);
    sweep.position.set(-5, 4, 2);
    const front = new THREE.PointLight(0xfff6e8, 7, 14, 2);
    front.position.set(0.5, 0.5, 6);
    scene.add(sweep, sweep.target, front);

    const look = new THREE.Vector3();
    return {
      update(s, dt) {
        const t = s.time;
        const intro = s.reduced ? 1 : introCurve(t, 2.4);
        const k = THREE.MathUtils.clamp((s.progress - 0.5) * 2, -1, 1);
        for (const motion of motions) motion(t, k, intro, s.reduced ? 0 : dt);
        dust.points.position.set(s.pointer.x * 0.3, -s.pointer.y * 0.2, 0);
        dust.update(t, dt, null);
        camera.position.set(s.pointer.x * 0.35, -s.pointer.y * 0.22, distance * (1 + k * 0.025));
        camera.lookAt(look);
      },
    };
  },

  /**
   * 3D overlays for the three core pillar cards, composited by Flutter over
   * each card's photograph, in the space where the photo fades to ivory
   * (the right for business and innovation, the left for careers).
   * Rendered to transparent stills (see
   * tool/render_scenes), so a row of cards costs three images, not three
   * live scenes. Each tells its own story; none shares a platform or form:
   *
   *   business:   a floating glass website with a gold header and product
   *               tiles, and a platinum phone beside it.
   *   innovation: a platinum processor with a gold "AI" die and gold
   *               traces fanning out from its pins.
   *   careers:    a gold path rising through glass beads to a gold sphere
   *               ringed in gold: growth, step by step.
   *
   * Shadows fall on an invisible floor, so they land on the photograph.
   */
  overlay(kit, options) {
    const { scene, camera } = kit;
    const distance = 10;
    const at = viewPlane(distance, 1.6); // the cards' 16:10 artwork
    const gold = (extra) => kit.lacqueredGold(extra);
    const silver = (extra) => kit.polishedPlatinum(extra);
    const root = new THREE.Group();
    scene.add(root);
    const casters = [];
    const cast = (...meshes) => meshes.forEach((m) => m.traverse((o) => o.isMesh && !o.material.transparent && casters.push(o)));
    let floorAt = at(0.7, 0.98);

    const variant = options.variant || 'business';
    if (variant === 'business') {
      // A glass browser window: gold frame, header bar and product tiles.
      const site = new THREE.Group();
      site.position.copy(at(0.74, 0.42, 0));
      site.rotation.set(0.06, -0.48, 0.02);
      site.scale.setScalar(0.9);
      const pane = kit.roundedBox(2.7, 1.75, 0.04, 0.07, kit.clearGlass({ opacity: 0.34, envMapIntensity: 2 }), 4);
      const frame = [
        [0, 0.875, 2.7, 0.03], [0, -0.875, 2.7, 0.03],
        [-1.35, 0, 0.03, 1.75], [1.35, 0, 0.03, 1.75],
      ].map(([x, y, w, h]) => {
        const edge = kit.roundedBox(w, h, 0.05, 0.012, gold({ roughness: 0.1 }), 2);
        edge.position.set(x, y, 0);
        return edge;
      });
      const header = kit.roundedBox(2.4, 0.14, 0.03, 0.03, gold({ roughness: 0.14 }), 2);
      header.position.set(0, 0.63, 0.04);
      const hero = kit.roundedBox(1.1, 0.44, 0.03, 0.04, gold({ roughness: 0.22 }), 3);
      hero.position.set(-0.62, 0.22, 0.04);
      const copy = [0.32, 0.2, 0.08].map((y, i) => {
        const line = kit.roundedBox(i === 2 ? 0.6 : 0.95, 0.06, 0.02, 0.02, kit.pearl({ roughness: 0.2 }), 2);
        line.position.set(i === 2 ? 0.32 : 0.5, y, 0.04);
        return line;
      });
      const tiles = [0, 1, 2].map((i) => {
        const tile = kit.roundedBox(0.68, 0.5, 0.04, 0.05, i === 1 ? silver({ roughness: 0.14 }) : gold({ roughness: 0.18 }), 3);
        tile.position.set(-0.8 + i * 0.8, -0.42, 0.05);
        return tile;
      });
      site.add(pane, ...frame, header, hero, ...copy, ...tiles);
      root.add(site);
      cast(...frame, header, hero, ...tiles);

      // A platinum phone standing slightly forward.
      const phone = new THREE.Group();
      phone.position.copy(at(0.91, 0.64, 1.0));
      phone.rotation.set(0.04, -0.6, 0.05);
      phone.scale.setScalar(0.8);
      const body = kit.roundedBox(0.58, 1.18, 0.07, 0.1, silver({ roughness: 0.1 }), 5);
      const face = kit.roundedBox(0.5, 1.08, 0.012, 0.07, kit.pearl({ roughness: 0.14 }), 4);
      face.position.z = 0.04;
      const banner = kit.roundedBox(0.4, 0.3, 0.012, 0.03, gold({ roughness: 0.18 }), 2);
      banner.position.set(0, 0.25, 0.05);
      const rows = [-0.06, -0.2, -0.34].map((y) => {
        const row = kit.roundedBox(0.4, 0.07, 0.01, 0.02, silver({ roughness: 0.2 }), 2);
        row.position.set(0, y, 0.05);
        return row;
      });
      phone.add(body, face, banner, ...rows);
      root.add(phone);
      cast(body);
      floorAt = at(0.82, 0.97);
    } else if (variant === 'innovation') {
      // A processor: platinum package, gold pins, a gold die engraved "AI".
      const chip = new THREE.Group();
      chip.position.copy(at(0.76, 0.5, 0));
      chip.rotation.set(0.78, -0.5, 0);
      chip.scale.setScalar(0.78);
      const pkg = kit.roundedBox(2.0, 0.16, 2.0, 0.06, silver({ roughness: 0.16 }), 4);
      chip.add(pkg);
      const pinGeo = new RoundedBoxGeometry(0.09, 0.04, 0.32, 2, 0.015);
      const pinMat = gold({ roughness: 0.12 });
      for (let side = 0; side < 4; side++) {
        for (let i = 0; i < 9; i++) {
          const pin = new THREE.Mesh(pinGeo, pinMat);
          const along = -0.8 + i * 0.2;
          const out = 1.12;
          const [x, z, rot] = [[along, out, 0], [along, -out, 0], [out, along, Math.PI / 2], [-out, along, Math.PI / 2]][side];
          pin.position.set(x, -0.04, z);
          pin.rotation.y = rot;
          chip.add(pin);
        }
      }
      const engraving = kit.canvasTexture(512, 512, (g, w, h) => {
        const grad = g.createLinearGradient(0, 0, w, h);
        grad.addColorStop(0, '#f1dcac');
        grad.addColorStop(0.5, '#e2c48a');
        grad.addColorStop(1, '#f0d9a6');
        g.fillStyle = grad;
        g.fillRect(0, 0, w, h);
        g.strokeStyle = 'rgba(120,88,40,0.55)';
        g.lineWidth = 10;
        g.strokeRect(34, 34, w - 68, h - 68);
        g.fillStyle = 'rgba(110,80,36,0.9)';
        g.font = `800 230px ${FONT}`;
        g.textAlign = 'center';
        g.textBaseline = 'middle';
        g.fillText('AI', w / 2, h / 2 + 10);
      });
      const dieMats = Array.from({ length: 6 }, (_, i) => (i === 2 ? gold({ color: 0xffffff, map: engraving, roughness: 0.18 }) : gold({ roughness: 0.1 })));
      const die = new THREE.Mesh(new THREE.BoxGeometry(1.1, 0.12, 1.1), dieMats);
      die.position.y = 0.14;
      chip.add(die);
      // Gold traces fanning out from the pins, ending in small pads.
      const traceMat = gold({ roughness: 0.14 });
      const rand = mulberry32(9);
      for (let side = 0; side < 4; side++) {
        for (let i = 0; i < 9; i += 2) {
          const along = -0.8 + i * 0.2;
          const len = 0.5 + rand() * 0.9;
          const trace = new THREE.Mesh(new THREE.BoxGeometry(0.025, 0.012, len), traceMat);
          const pad = new THREE.Mesh(new THREE.CylinderGeometry(0.05, 0.05, 0.014, 16), traceMat);
          const out = 1.28 + len / 2;
          const end = 1.28 + len;
          const [x, z, px, pz, rot] = [
            [along, out, along, end, 0], [along, -out, along, -end, 0],
            [out, along, end, along, Math.PI / 2], [-out, along, -end, along, Math.PI / 2],
          ][side];
          trace.position.set(x, -0.06, z);
          trace.rotation.y = rot;
          pad.position.set(px, -0.06, pz);
          chip.add(trace, pad);
        }
      }
      root.add(chip);
      cast(pkg, die);
      const glow = new THREE.PointLight(0xffd99a, 3, 3, 2);
      glow.position.copy(chip.position).add(new THREE.Vector3(0, 0.9, 0.9));
      scene.add(glow);
      floorAt = at(0.76, 1.0);
    } else {
      // A gold path rising through glass beads to a ringed gold sphere.
      const points = [at(0.03, 0.94, 0.6), at(0.07, 0.76, 0.4), at(0.11, 0.58, 0.1), at(0.14, 0.42, -0.2), at(0.16, 0.28, -0.4)];
      const path = new THREE.CatmullRomCurve3(points);
      const track = new THREE.Mesh(new THREE.TubeGeometry(path, 160, 0.034, 12), gold({ roughness: 0.08 }));
      root.add(track);
      cast(track);
      [[0.2, 0.12], [0.45, 0.15], [0.7, 0.18]].forEach(([u, r]) => {
        const p = path.getPointAt(u);
        const bead = new THREE.Mesh(new THREE.SphereGeometry(r, 48, 32), kit.clearGlass({ opacity: 0.38, envMapIntensity: 2.2 }));
        const seed = new THREE.Mesh(new THREE.SphereGeometry(r * 0.32, 32, 24), gold({ roughness: 0.06 }));
        bead.position.copy(p);
        seed.position.copy(p);
        root.add(bead, seed);
        cast(seed);
      });
      const peak = path.getPointAt(1);
      const summit = new THREE.Mesh(new THREE.SphereGeometry(0.34, 64, 48), gold({ roughness: 0.04 }));
      summit.position.copy(peak);
      const ring = new THREE.Mesh(new THREE.TorusGeometry(0.56, 0.022, 20, kit.seg(160)), silver({ roughness: 0.05 }));
      ring.position.copy(peak);
      ring.rotation.set(1.2, 0.2, 0.3);
      root.add(summit, ring);
      cast(summit, ring);
      floorAt = at(0.1, 1.0);
    }

    const floor = shadowCatcher(8, 4, 0.26);
    floor.position.copy(floorAt).add(new THREE.Vector3(0, 0, -1));
    root.add(floor);
    const dust = new DustField(kit, { count: 50, spread: 6, size: 0.03, opacity: 0.55 });
    scene.add(dust.points);

    if (keyLight(kit, scene, 5, [3, 8, 6])) for (const m of casters) m.castShadow = true;
    const sweep = new THREE.SpotLight(0xffe2ad, 14, 18, 0.7, 0.8, 1.4);
    sweep.position.set(-6, 4, 2);
    const front = new THREE.PointLight(0xfff6e8, 7, 16, 2);
    front.position.set(1.5, 0.8, 6);
    scene.add(sweep, sweep.target, front);

    return {
      update(s, dt) {
        dust.update(s.time, dt, null);
        camera.position.set(s.pointer.x * 0.2, 0, distance);
        camera.lookAt(0, 0, 0);
      },
    };
  },

  /**
   * Portfolio preview: a laptop whose screen shows a real project image
   * (`options.image`, a URL). Used for demonstration-project previews.
   */
  preview(kit, options) {
    const def = SCENES.web(kit, options);
    // Keep the real project screenshot unobstructed.
    def.panel.visible = false;
    if (options.image) {
      const loader = new THREE.TextureLoader();
      loader.load(options.image, (tex) => {
        if (!kit.view.scene) {
          tex.dispose();
          return;
        }
        tex.colorSpace = THREE.SRGBColorSpace;
        tex.anisotropy = 8;
        kit.track(tex);
        const m = def.display.material;
        m.map = m.emissiveMap = tex;
        m.needsUpdate = true;
        kit.view.invalidate();
      });
    }
    return def;
  },
};

function neuralScene(kit, { layers, spread, radius, pulses = 14, wide = false }) {
  const { scene, camera } = kit;
  const group = new THREE.Group();
  scene.add(group);

  const glass = kit.glass({ thickness: radius * 3 });
  const gold = kit.gold();
  const chrome = kit.chrome({ roughness: 0.1 });
  const sphere = new THREE.SphereGeometry(radius, kit.seg(40), kit.seg(28));
  const coreGeo = new THREE.SphereGeometry(radius * 0.35, 16, 12);
  const coreMat = kit.glow(BRAND.softGold, 2.4);

  const nodes = [];
  layers.forEach((count, li) => {
    const x = (li / (layers.length - 1) - 0.5) * spread;
    for (let i = 0; i < count; i++) {
      const a = (i / count) * Math.PI * 2 + li * 0.4;
      const r = 0.25 + count * 0.085;
      const node = new THREE.Mesh(sphere, (i + li) % 5 === 0 ? gold : (i + li) % 4 === 0 ? chrome : glass);
      node.position.set(x, Math.sin(a) * r, Math.cos(a) * r * 0.75);
      if (node.material === glass) {
        const core = new THREE.Mesh(coreGeo, coreMat);
        node.add(core);
      }
      node.userData = { layer: li, base: node.position.clone(), phase: Math.random() * 6 };
      group.add(node);
      nodes.push(node);
    }
  });

  // Connections between adjacent layers.
  const edges = [];
  const rand = mulberry32(3);
  for (const a of nodes) {
    for (const b of nodes) {
      if (b.userData.layer !== a.userData.layer + 1) continue;
      if (rand() < (wide ? 0.42 : 0.55)) edges.push([a, b]);
    }
  }
  const edgePositions = new Float32Array(edges.length * 6);
  const edgeGeo = new THREE.BufferGeometry();
  edgeGeo.setAttribute('position', new THREE.BufferAttribute(edgePositions, 3));
  const edgeLines = new THREE.LineSegments(edgeGeo, new THREE.LineBasicMaterial({ color: BRAND.gold, transparent: true, opacity: 0.22 }));
  group.add(edgeLines);

  // Signals travelling along the edges.
  const pulseGeo = new THREE.SphereGeometry(0.024, 12, 8);
  const pulseList = [];
  for (let i = 0; i < pulses; i++) {
    const m = new THREE.Mesh(pulseGeo, kit.glow(i % 3 ? BRAND.gold : BRAND.softGold, 2.6));
    group.add(m);
    pulseList.push({ mesh: m, edge: edges[Math.floor(rand() * edges.length)], t: rand(), speed: 0.35 + rand() * 0.4 });
  }

  const dust = kit.particles(wide ? 220 : 120, spread * 1.3, BRAND.gold, 0.016);
  group.add(dust);

  const shadow = kit.contactShadow(spread * 0.65, 0.12);
  shadow.position.y = -1.35;
  scene.add(shadow);

  let distance = 6;
  return {
    frame(cam, aspect) {
      distance = fitDistance(cam, spread * 0.62, aspect);
    },
    update(s, dt) {
      const t = s.time;
      for (const n of nodes) {
        const b = n.userData.base;
        n.position.set(b.x, b.y + Math.sin(t * 0.8 + n.userData.phase) * 0.04, b.z + Math.cos(t * 0.6 + n.userData.phase) * 0.03);
      }
      edges.forEach(([a, b], i) => {
        edgePositions.set([a.position.x, a.position.y, a.position.z, b.position.x, b.position.y, b.position.z], i * 6);
      });
      edgeGeo.attributes.position.needsUpdate = true;
      for (const p of pulseList) {
        p.t += dt * p.speed * (1 + s.focus);
        if (p.t >= 1) {
          // Hop to an edge that continues from where this pulse arrived.
          const next = edges.filter(([a]) => a === p.edge[1]);
          p.edge = next.length ? next[Math.floor(rand() * next.length)] : edges[Math.floor(rand() * edges.length)];
          p.t = 0;
        }
        p.mesh.position.lerpVectors(p.edge[0].position, p.edge[1].position, p.t);
      }
      group.rotation.y = Math.sin(t * 0.15) * 0.35 + s.pointer.x * 0.35 + (s.progress - 0.5) * 0.8;
      group.rotation.x = s.pointer.y * 0.15;
      dust.rotation.y = t * 0.03;
      camOrbit(camera, s, { distance, height: 0.3, swing: 0.15 });
    },
  };
}
