# YODYNIX — Official Website

**Digital Technology & Innovation Studio** · *Turning Ideas Into Powerful Digital Experiences.*

Flutter Web site in champagne gold, platinum silver, pearl white, warm beige and
charcoal — with **no blue anywhere**, including the demo mock-ups and the 3D scenes.
Colours are defined once in `lib/core/theme/app_colors.dart` (mirrored by `BRAND` in
`web/three/yodynix3d.js`) and shared by every section and page. Photorealistic 3D scenes
(liquid gold, platinum chrome and glass) run on WebGL through Three.js. Firebase-ready
architecture; no backend yet.

The site uses a champagne-gold / platinum variant of the logo
(`assets/images/brand/yodynix_logo_gold.png`, also the favicon and app icons), made from
the original mark by `tool/recolor_logo`; the original `yodynix_logo.png` is unchanged.

## Run

```bash
flutter pub get
flutter run -d chrome          # development
flutter build web --release    # production bundle in build/web
flutter analyze && flutter test
```

Shareable section links work out of the box, e.g. `/#/services`, `/#/internship`,
`/#/contact`, and case studies at `/#/portfolio/<project_id>`.

## Configure (no invented details)

All business details live in **`lib/core/constants/site_config.dart`**. Anything left `null`
displays as "Coming soon" / "To be announced".

| What | Where |
|---|---|
| Email, phone, WhatsApp, address, budget ranges | `ContactConfig` |
| Social media profiles (only configured ones are shown) | `SocialConfig.links` |
| Founder name, designation, introduction, message, links | `FounderConfig.profile` |
| Internship duration, mode, stipend, certificate, applications open | `InternshipConfig` |
| Show "YODYNIX" text beside the logo | `SiteConfig.showWordmarkBesideLogo` |

Site copy lives in `lib/repositories/content/` (services, expertise, portfolio, programmes, company).

## Images

The logo and founder photo are used **unmodified**. Every other section shows a
topic-specific illustrated placeholder until a real photo is added — see
[`assets/images/IMAGE_GUIDE.md`](assets/images/IMAGE_GUIDE.md) for the exact file names.
Dropping a correctly named file into its folder replaces the placeholder automatically.

## Structure

```
lib/
  main.dart                 bootstrap (bundled fonts, asset registry)
  app/                      MaterialApp + navigation scope
  core/
    constants/              site_config.dart (editable), asset_paths.dart
    theme/                  colours, typography (Sora + Inter), ThemeData
    routing/                routes, deep links, case-study routes
    utils/                  responsive breakpoints & helpers
  models/                   content, portfolio, enquiry, founder, sections
  repositories/             content data + ContactRepository (backend seam)
  services/                 asset registry, link launcher
  providers/                SectionNavigator (scroll, active nav, CTA prefill)
  features/                 home, about, services, expertise, portfolio, industries,
                            pillars, process, demos, internship, contact
  shared/
    layouts/                navbar, mobile drawer, footer, sub-page scaffold
    widgets/                buttons, cards, reveal, smart image, dialogs,
                            motion effects (magnetic, 3D tilt), footer gold dust
      visuals/              illustrated placeholder compositions
    three/                  3D widgets and the bridge to the WebGL engine
web/
  three/yodynix3d.js        the 3D engine and every scene (procedural, PBR)
  vendor/three/             Three.js r170 (MIT), vendored — no CDN at runtime
tool/render_scenes/         renders the scenes to assets/images/renders/ (render.js) and
                            captures the demo screenshots (demos.js)
tool/recolor_logo/          makes the gold / platinum logo and icon variants
assets/
  images/{brand,hero,about,services,portfolio,team,students,internship,contact}
  fonts/                    Inter & Sora (SIL OFL) — no runtime font fetching
```

## 3D

**Architecture.** Flutter stays in charge of layout, text, navigation and accessibility.
Each 3D visual is an `HtmlElementView` hosting a plain `<canvas>`; one shared
`WebGLRenderer` (`web/three/yodynix3d.js`) renders every visible scene and copies it into
that view's canvas, so the page only ever holds one WebGL context, and all scenes share
one studio environment map. Pointer events pass through to Flutter, so scrolling and
clicking over a scene behave normally.

| Widget (`lib/shared/three/`) | Use |
|---|---|
| `Interactive3DObject` | Base widget: lazy load, lifecycle, scroll / pointer / focus, fallbacks |
| `Hero3DScene` | Homepage sculpture (live on every device) |
| `Service3DVisual` | Service concept by service id (`sceneFor`, `variantFor`) |
| `Portfolio3DPreview` | A demo project's real screenshot on a 3D laptop |
| `Section3DScene` | Section scenes: technology `ecosystem`, process `workflow`, contact `network`, `industries` (variant per sector) |
| `ScrollAnimationController` | Scroll progress / visibility for any widget; never hijacks scrolling |
| `Mobile3DFallback` | Still render of a scene, else the widget's own fallback |

**Animation systems** (shared by the scenes in `yodynix3d.js`):

- `LiquidRibbon` — ribbons whose surface ripples every frame (travelling swell and
  ripple waves along the curve), so highlights slide across like poured metal.
- `morphGeometry` / `morphWeights` — a GPU morph from sphere to soft octahedron, rounded
  cube and bloom. The targets are superellipsoids, so edges never tear into facets. The
  hero core morphs as the page scrolls.
- `DustField` — gold motes that drift and part around the cursor, then spring back.
- `floaters` — chrome spheres, glass cubes and metal rings, each on its own rhythm.
- Hero camera: a cinematic dolly-in on load, mouse parallax, then a zoom and lift as you
  scroll. Nearer layers (accents, dust) shift further with the pointer than the sculpture,
  for depth.
- Hero rings each spin about their own axis at their own speed and direction.

**Lighting and materials.** Every scene reflects `studioEnvironment()`, a procedural
product studio (overhead softbox, strip lights, warm bounce, dark flags) pre-filtered as
the environment map. It is all warm-neutral: no coloured light. Tone mapping is Khronos
PBR Neutral, which keeps the gold hue true. Gold is bare polished metal; glass has no
thin-film iridescence, because that produces blue and cyan fringes. Above low quality, the
hero's key light casts soft blurred (VSM) shadows onto an invisible floor, and fog matched
to the backdrop gives distant pieces atmospheric depth.

**Interface motion** (`lib/shared/widgets/motion_effects.dart`, all off under reduced
motion and for touch): magnetic primary/secondary buttons, 3D tilt with a champagne sheen
on every `HoverCard`, a light sweep, gold halo and press on primary buttons, a liquid-gold
active indicator and hover lift in the navbar, staggered count-up statistics, cinematic page
transitions (`AppRouter`), and rising gold dust in the footer (`GoldDust`, Flutter-drawn,
only ticks while on screen).

**Performance.** The engine module (~750 KB uncompressed) is imported only when a scene
nears the viewport; pages without 3D never load it. Off-screen scenes stop rendering;
scenes more than 2.5 viewports away are disposed (geometry, materials, textures,
observers), and the renderer itself is released 4 s after the last scene goes. Render
resolution drops automatically if frames run long, and pauses while the tab is hidden.

**Devices.** Desktop: full quality. Tablet: medium. Phones: the hero runs live at low
quality; supporting visuals use still renders. Reduced motion: scenes render a single
still frame that changes only on scroll. No WebGL, or a lost context: still renders.

**Still renders.** `assets/images/renders/` holds JPEG stills made with the same engine.
After changing a scene, regenerate them:

```bash
cd tool/render_scenes && npm install && npm run render     # all, or: node render.js hero network
```

**Demo screenshots.** The project images for the ten working demos are captures of the
demos themselves. After changing a demo's look, rebuild and recapture:

```bash
flutter build web --release
cd tool/render_scenes && npm run demos                     # all, or: node demos.js fitslot
```

## Placeholder copy

`/portfolio` and `/industries` are built, but their introductions and the industry
descriptions are placeholder text (marked `[Placeholder]` and shown with a visible
"Placeholder copy" badge). Replace the text in
`lib/repositories/content/industries_content.dart`, then set `isPlaceholder = false` on
`IndustriesContent` and `PortfolioContent` to remove the badges. Every project on the
Portfolio page is a YODYNIX demonstration project and is labelled as such. There is no
client work on the site.

## Backend (next phase)

`ContactForm` submits through `ContactRepository`. The current
`PendingBackendContactRepository` validates the full flow but sends nothing and tells
the visitor so. Implement a Firebase repository and pass it to `ContactSection` —
no UI changes required. `ContactEnquiry.toMap()` is ready for Firestore.
