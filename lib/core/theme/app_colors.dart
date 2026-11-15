import 'package:flutter/material.dart';

/// YODYNIX design tokens — "Luxury Warm Ivory": warm ivory content sections,
/// soft-white cards, deep charcoal premium bands, and champagne gold kept for
/// primary actions, small icons, labels and fine decorative lines. Every
/// colour on the site resolves through here.
///
/// The semantic roles below describe the default *light* surface. Widgets
/// that also appear on dark bands read their text and line colours from
/// `SurfaceTone` (see `surface_tone.dart`) instead.
class AppColors {
  AppColors._();

  // ── Brand palette ────────────────────────────────────────────────────────
  static const Color warmIvory = Color(0xFFEAE6DD);
  static const Color softWhite = Color(0xFFFAFAF8);
  static const Color white = Color(0xFFFFFFFF);
  static const Color champagneGold = Color(0xFFC6A46A);
  static const Color antiqueGold = Color(0xFFA98245);
  static const Color charcoalNavy = Color(0xFF202735);
  static const Color deepCharcoal = Color(0xFF151B26);
  static const Color softGrey = Color(0xFFA8B0BC);
  static const Color lightGrey = Color(0xFFE8E9EC);
  static const Color mutedText = Color(0xFF687386);

  // Hero accents: a muted champagne, and a steel blue that balances the gold.
  static const Color softChampagne = Color(0xFFD6BD8F);
  static const Color steelBlue = Color(0xFF60758F);

  // Derived tones — shades of the palette above, never new hues.
  static const Color goldInk = Color(0xFF86662F); // gold for text on ivory/white (≥4.3:1)
  static const Color goldWash = Color(0xFFF2EAD9); // pale gold fill on light
  static const Color goldLine = Color(0xFFD8C69F); // fine gold rule / tinted border on light
  static const Color goldTint = Color(0xFFD9BF8C); // gold text on dark bands
  static const Color ivoryLight = Color(0xFFF3F0EA); // alternate ivory band
  static const Color stone = Color(0xFFDCD6CA); // neutral line on ivory
  static const Color slate = Color(0xFF4A5467); // body copy on light (≈6:1)
  static const Color mutedInk = Color(0xFF5E6879); // muted text that holds 4.5:1 on ivory
  static const Color charcoalRaised = Color(0xFF2A3243); // cards on dark bands
  static const Color charcoalLine = Color(0xFF333C4E); // borders on dark bands
  static const Color mist = Color(0xFFD3D7DE); // body copy on dark (≈11:1)

  // ── Cards ───────────────────────────────────────────────────────────────
  // Every content card is a deep-charcoal tile with a fine champagne edge,
  // on ivory sections and dark bands alike.
  static const Color cardSurface = deepCharcoal;
  static const Color cardBorder = champagneGold;
  static const Color cardBorderHover = goldTint; // slightly brighter edge on hover
  static const Color cardHeading = white;
  static const Color cardBody = Color(0xFFD8D8D8); // ≈13:1 on the card
  static const Color cardMuted = softGrey; // ≈8:1 on the card
  static const Color cardAccent = champagneGold; // icons, labels, small accent text
  static const Color cardLine = Color(0x59C6A46A); // subtle gold divider inside a card
  static const Color cardTile = Color(0x1FC6A46A); // gold-tinted icon tile / chip fill
  static const Color cardField = charcoalNavy; // input fill inside a card
  static const Color errorOnCard = Color(0xFFF0938A); // ≈7:1 on the card
  static const Color successOnCard = Color(0xFF7FCFA4); // ≈9:1 on the card

  // Electric blue is no longer a site accent. It is kept only for the client
  // demo mock-ups, which represent other brands.
  static const Color electricBlue = Color(0xFF386BFF);
  static const Color electricBlueDeep = Color(0xFF2346C8);
  static const Color electricBlueTint = Color(0xFF8DA8FF);
  static const Color electricBlueSoft = Color(0xFFEBF0FF);

  // Kept under their original names for existing call sites; they now sit
  // inside the charcoal family rather than navy.
  static const Color midnightNavy = charcoalNavy;
  static const Color deepNavy = deepCharcoal;
  static const Color surfaceNavy = charcoalRaised;
  static const Color blueGrey = softGrey;

  // ── Semantic roles ───────────────────────────────────────────────────────
  /// Fills, buttons, active markers and fine lines.
  static const Color primary = champagneGold;
  static const Color primaryDeep = antiqueGold; // hover / pressed
  static const Color onPrimary = deepCharcoal; // text and icons on gold fills
  static const Color primarySoft = goldWash;
  static const Color primaryTint = goldTint;

  /// Gold for text, links and icons on light surfaces — a deeper shade of the
  /// champagne so small type stays readable.
  static const Color accent = goldInk;
  static const Color accentDeep = Color(0xFF6E5226);
  static const Color accentSoft = goldWash;

  // Supporting tones for per-item variety (icons, chart dots). Muted and
  // warm so lists don't collapse into one colour without adding new hues.
  static const Color violet = slate;
  static const Color mint = Color(0xFF557367);
  static const Color rose = Color(0xFF8E6450);

  // ── Surfaces ────────────────────────────────────────────────────────────
  // Content sections sit on ivory; consecutive sections alternate with a
  // lighter ivory band. Soft white is kept for cards and inner panels.
  static const Color background = warmIvory;
  static const Color surface = ivoryLight; // alternate section band
  static const Color card = softWhite;
  static const Color cardRaised = softWhite;
  static const Color skeleton = stone;

  // ── Text & lines (light surfaces) ───────────────────────────────────────
  static const Color ink = charcoalNavy; // headings, primary text
  static const Color body = slate;
  static const Color muted = mutedInk;
  static const Color border = stone;
  static const Color divider = goldLine;

  // ── Text & lines (dark bands) ───────────────────────────────────────────
  static const Color onDark = white;
  static const Color onDarkBody = mist;
  static const Color onDarkMuted = softGrey;
  static const Color darkBorder = charcoalLine;

  static const Color success = Color(0xFF2F7D5B);
  static const Color error = Color(0xFFC0392B);

  // ── Gradients ───────────────────────────────────────────────────────────
  // Brushed rather than metallic: two close shades of the same gold.
  static const LinearGradient brandGradient = LinearGradient(
    colors: [antiqueGold, champagneGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [champagneGold, antiqueGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient signatureGradient = LinearGradient(
    colors: [charcoalLine, champagneGold, charcoalLine],
    stops: [0, 0.5, 1],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Headline highlight on dark bands.
  static const LinearGradient headlineGradient = LinearGradient(
    colors: [champagneGold, goldTint],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Headline highlight on ivory — deeper gold so large type keeps contrast.
  static const LinearGradient headlineGradientLight = LinearGradient(
    colors: [goldInk, antiqueGold],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Card fill on light surfaces.
  static const LinearGradient glassGradient = LinearGradient(
    colors: [softWhite, Color(0xFFF6F4EF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Card fill on dark bands.
  static const LinearGradient darkGlassGradient = LinearGradient(
    colors: [charcoalRaised, charcoalNavy],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Background of the dark hero band at the top of each sub-page.
  static const LinearGradient darkBandGradient = LinearGradient(
    colors: [deepCharcoal, charcoalNavy],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Faint warm light pooling from [center]; used on dark bands.
  static RadialGradient glow({Alignment center = Alignment.center, double radius = 0.8, double strength = 1}) => RadialGradient(
    center: center,
    radius: radius,
    colors: [
      champagneGold.withValues(alpha: 0.08 * strength),
      Colors.transparent,
    ],
  );

  /// Very soft, neutral elevation for cards on ivory.
  static List<BoxShadow> softShadow([double strength = 1]) => [
    BoxShadow(
      color: charcoalNavy.withValues(alpha: 0.06 * strength.clamp(0, 1.5)),
      blurRadius: 28 * strength,
      offset: Offset(0, 12 * strength),
    ),
    BoxShadow(
      color: charcoalNavy.withValues(alpha: 0.03 * strength.clamp(0, 1.5)),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  /// Subtle halo for focused or hovered elements.
  static List<BoxShadow> glowShadow([double strength = 1, Color color = champagneGold]) => [
    BoxShadow(
      color: color.withValues(alpha: 0.14 * strength),
      blurRadius: 24 * strength,
      spreadRadius: -6,
    ),
  ];
}
