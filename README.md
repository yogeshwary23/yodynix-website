# YODYNIX — Official Website

**Digital Technology & Innovation Studio** · *Turning Ideas Into Powerful Digital Experiences.*

Flutter Web homepage. Premium midnight-navy theme with electric-blue actions and cyan
light, defined once in `lib/core/theme/` (colours, typography, ThemeData) and shared by
every section and page. Firebase-ready architecture; no backend yet.

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
  features/                 home, about, founder, services, expertise, portfolio,
                            process, students, internship, contact
  shared/
    layouts/                navbar, mobile drawer, footer, sub-page scaffold
    widgets/                buttons, cards, reveal, smart image, dialogs
      visuals/              illustrated placeholder compositions
assets/
  images/{brand,hero,about,services,portfolio,team,students,internship,contact}
  fonts/                    Inter & Sora (SIL OFL) — no runtime font fetching
```

## Backend (next phase)

`ContactForm` submits through `ContactRepository`. The current
`PendingBackendContactRepository` validates the full flow but sends nothing and tells
the visitor so. Implement a Firebase repository and pass it to `ContactSection` —
no UI changes required. `ContactEnquiry.toMap()` is ready for Firestore.
