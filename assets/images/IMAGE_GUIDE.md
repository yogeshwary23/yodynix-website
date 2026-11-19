# YODYNIX — Image Guide

Every section currently shows a **topic-specific illustrated placeholder** built
in Flutter (no stock or AI imagery). To replace one with a real photograph,
save a file with the exact base name below into the listed folder, using any
of `.webp` (preferred), `.jpg`, `.jpeg` or `.png`, then restart the app.
No code change is needed; the site detects the file automatically and lazy-loads it.

Recommended: WebP, sRGB, quality ~80, under ~250 KB each. Keep the stated
aspect ratio so cropping stays clean. Never reuse a photo in two places.

## Supplied (in use)

| File | Status |
|---|---|
| `brand/yodynix_logo.png` | ✅ Official logo, used unmodified |
| `team/founder.png`, `partner.png`, `akash.jpeg`, `yogiraj.jpeg`, `ankita.jpeg` | ✅ Team members' own photographs, cropped by layout only |

## Missing photographs (placeholders active)

| Folder / base name | Ratio | What the image should show |
|---|---|---|
| `hero/hero_visual` | 620:560 (≈1.1:1), transparent PNG/WebP ideal | Premium abstract digital-technology visual: connected systems, software interfaces, innovation |
| `about/about_visual` | 560:480 (≈7:6) | ✅ Supplied — see PHOTO_CREDITS.md |
| `services/<service_id>` | 3:2 | ✅ Supplied for all ten services — see PHOTO_CREDITS.md |
| `internship/internship_banner` | 4:3 | ✅ Supplied — see PHOTO_CREDITS.md (homepage Internship banner) |

## Service sample projects

Each service page shows four sample projects from
`service_projects/<project_id>` (16:10). Concept projects use photographs
(see PHOTO_CREDITS.md); live-demo projects use screenshots of the working demo
at `/demos/<slug>`. Project ids are defined in
`lib/repositories/content/service_pages_content.dart`.

## Core pillars & detail pages (photographs supplied)

The three pillar cards and the `/business-solutions` and `/technology-innovation`
pages use real photographs in `pillars/`, `business/` and `technology/`. Sources and
licence are listed in `PHOTO_CREDITS.md`.

## Internship pages (photographs supplied)

The `/internship` landing page and the seven `/internship/<slug>` programme pages
use `internship_careers/`: `hero`, `mentor_guided`, `project_based`, `application`
and one photo per programme, named after its slug with `_` for `-`
(e.g. `ui_ux_design` for `/internship/ui-ux-design`). Programme cards show the
photo at 16:9 and programme heroes at 4:3, so keep the subject centred. Never
reuse a photo for two programmes. Programme content and terms are edited in
`lib/repositories/content/internship_content.dart` and `InternshipConfig`.

## Industries page (photographs supplied)

Each sector section on `/industries` uses `industries/<id>` (ids in
`lib/repositories/content/industries_content.dart`), shown at about 4:3 with the
sector's 3D panel set into a lower corner, so keep the subject away from that
corner. Never reuse a photo for two sectors. The hero's 3D still is
`renders/industries_network.jpg` (re-render with `node render.js industries_network`).

## Portfolio page (photographs supplied)

- `portfolio/<id>_scene` — the full-colour setting behind each working demo's
  device (set by `ProjectCaseStudy.photo`). Any landscape photo, ≥1600px wide.
- `portfolio/<id>_cover` — optional cover replacing a concept's service-page
  image on the Portfolio only.
- `project_devices/<id>.webp` — each working demo's real screenshot on its 3D
  device, rendered by `dart run tool/render_scenes/export_devices.dart` then
  `node render.js devices` in `tool/render_scenes`. Never edit by hand.
- Project images are shown ungraded: no tints, filters or overlays.
