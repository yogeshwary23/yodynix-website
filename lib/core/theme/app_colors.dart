import 'package:flutter/material.dart';

/// YODYNIX design tokens — champagne gold, platinum silver, pearl white,
/// warm beige and charcoal. There is deliberately no blue anywhere in the
/// palette, including the client demo mock-ups; every colour on the site
/// resolves through here, and the 3D scenes in `web/three/yodynix3d.js` use
/// the same values.
///
/// The semantic roles below describe the default *light* surface. Widgets
/// that also appear on dark bands read their text and line colours from
/// `SurfaceTone` (see `surface_tone.dart`) instead.
class AppColors {
  AppColors._();

  // ── Brand palette ────────────────────────────────────────────────────────
  static const Color champagneGold = Color(0xFFC6A46A);
  static const Color platinum = Color(0xFFE4E2DD);
  static const Color pearlWhite = Color(0xFFF8F6F1);
  static const Color warmBeige = Color(0xFFEDE4D6);
  static const Color charcoal = Color(0xFF2A2826);
  static const Color white = Color(0xFFFFFFFF);

  // Tones of the palette above — never new hues.
  static const Color antiqueGold = Color(0xFFA98245);
  static const Color softChampagne = Color(0xFFE3CFA3);
  static const Color deepCharcoal = Color(0xFF1E1C1A);
  static const Color charcoalRaised = Color(0xFF36332F); // cards on dark bands
  static const Color charcoalLine = Color(0xFF47433D); // borders on dark bands
  static const Color platinumDeep = Color(0xFFC9C6BF);
  static const Color taupe = Color(0xFF8A8277);
  static const Color softGrey = Color(0xFFB3ADA3);
  static const Color lightGrey = Color(0xFFE9E6E0);
  static const Color mutedText = Color(0xFF6E685E);

  static const Color warmIvory = pearlWhite;
  static const Color softWhite = white;
  static const Color goldInk = Color(0xFF86662F); // gold for text on pearl/white (≥4.5:1)
  static const Color goldWash = Color(0xFFF4ECDD); // pale gold fill on light
  static const Color goldLine = Color(0xFFE2D4B6); // fine gold rule / tinted border on light
  static const Color goldTint = Color(0xFFD9BF8C); // gold text on dark bands
  static const Color ivoryLight = Color(0xFFF2EEE6); // alternate beige band
  static const Color stone = Color(0xFFE2DDD3); // neutral line on pearl
  static const Color slate = Color(0xFF55504A); // body copy on light (≈7.5:1)
  static const Color mutedInk = Color(0xFF6A645B); // muted text that holds 4.5:1 on beige
  static const Color mist = Color(0xFFDDD8CF); // body copy on dark (≈11:1)

  // ── Header ──────────────────────────────────────────────────────────────
  static const Color topBar = Color(0xFF292722); // top information bar
  static const Color topBarGold = Color(0xFFC6A875); // icons and accents on [topBar]
  static const Color logoCharcoal = Color(0xFF242321); // logo symbol and wordmark on white

  // ── Cards ───────────────────────────────────────────────────────────────
  // Content cards are white tiles with a fine platinum edge and a soft, warm
  // shadow; the edge warms to champagne on hover.
  static const Color cardSurface = white;
  static const Color cardBorder = Color(0xFFE6E1D8);
  static const Color cardBorderHover = goldLine;
  static const Color cardHeading = charcoal;
  static const Color cardBody = slate;
  static const Color cardMuted = mutedInk;
  static const Color cardAccent = goldInk; // icons, labels, small accent text
  static const Color cardLine = Color(0xFFEDE9E1); // divider inside a card
  static const Color cardTile = goldWash; // icon tile / chip fill
  static const Color cardField = Color(0xFFF9F7F3); // input fill inside a card
  static const Color errorOnCard = Color(0xFFB4372A);
  static const Color successOnCard = Color(0xFF3F7A4F);

  // The client demo mock-ups represent other businesses; they use a bronze
  // accent so they stay distinct from the site's champagne without any blue.
  static const Color demoAccent = Color(0xFF8C6239);
  static const Color demoAccentDeep = Color(0xFF6B4826);
  static const Color demoAccentTint = Color(0xFFD2B48F);
  static const Color demoAccentSoft = Color(0xFFF5EDE3);

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

  // Supporting tones for per-item variety (icons, chart dots). Warm and
  // muted so lists don't collapse into one colour without adding new hues.
  static const Color violet = slate;
  static const Color mint = Color(0xFF6F7A5A); // olive
  static const Color rose = Color(0xFF9A6650); // terracotta

  // ── Surfaces ────────────────────────────────────────────────────────────
  // Content sections sit on pearl white; consecutive sections alternate with
  // a warm-beige band. White is kept for cards and inner panels.
  static const Color background = pearlWhite;
  static const Color surface = ivoryLight; // alternate section band
  static const Color card = white;
  static const Color cardRaised = white;
  static const Color skeleton = stone;

  // ── Text & lines (light surfaces) ───────────────────────────────────────
  static const Color ink = charcoal; // headings, primary text
  static const Color body = slate;
  static const Color muted = mutedInk;
  static const Color border = stone;
  static const Color divider = goldLine;

  // ── Text & lines (dark bands) ───────────────────────────────────────────
  static const Color onDark = white;
  static const Color onDarkBody = mist;
  static const Color onDarkMuted = softGrey;
  static const Color darkBorder = charcoalLine;

  static const Color success = Color(0xFF3F7A4F);
  static const Color error = Color(0xFFB4372A);

  // ── Gradients ───────────────────────────────────────────────────────────
  // Brushed rather than mirror: two close shades of the same gold.
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

  /// Headline highlight on light surfaces — deeper gold so large type keeps contrast.
  static const LinearGradient headlineGradientLight = LinearGradient(
    colors: [goldInk, antiqueGold],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Liquid-gold headline highlight: polished highlights between deeper tones.
  static const LinearGradient liquidGold = LinearGradient(
    colors: [Color(0xFF7A5A28), antiqueGold, Color(0xFFD9BC82), antiqueGold, Color(0xFF7A5A28)],
    stops: [0, 0.3, 0.5, 0.7, 1],
  );

  /// Fill of the primary gold button, and its deeper hover state.
  static const LinearGradient buttonGold = LinearGradient(
    colors: [Color(0xFFDDC08A), champagneGold, Color(0xFFB08D52)],
    stops: [0, 0.45, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGoldHover = LinearGradient(
    colors: [Color(0xFFCDAE74), Color(0xFFB8945A), antiqueGold],
    stops: [0, 0.45, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Polished metallic gold for large display type and figures on light
  /// surfaces: deep enough at the edges to keep contrast on ivory.
  static const LinearGradient metallicGoldText = LinearGradient(
    colors: [Color(0xFF8E6B30), Color(0xFFB48E4E), Color(0xFFCFAE6E), Color(0xFFA9823F), Color(0xFF8A672C)],
    stops: [0, 0.3, 0.5, 0.72, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Card fill on light surfaces.
  static const LinearGradient glassGradient = LinearGradient(
    colors: [white, Color(0xFFFAF8F4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Card fill on dark bands.
  static const LinearGradient darkGlassGradient = LinearGradient(
    colors: [charcoalRaised, charcoal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Background of a dark charcoal band.
  static const LinearGradient darkBandGradient = LinearGradient(
    colors: [deepCharcoal, charcoal],
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

  /// Very soft, warm elevation for cards on pearl.
  static List<BoxShadow> softShadow([double strength = 1]) => [
    BoxShadow(
      color: charcoal.withValues(alpha: 0.06 * strength.clamp(0, 1.5)),
      blurRadius: 28 * strength,
      offset: Offset(0, 12 * strength),
    ),
    BoxShadow(
      color: charcoal.withValues(alpha: 0.03 * strength.clamp(0, 1.5)),
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
