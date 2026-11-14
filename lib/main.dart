import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/yodynix_app.dart';
import 'services/asset_registry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fonts are bundled in assets/fonts; never fetch from Google at runtime.
  GoogleFonts.config.allowRuntimeFetching = false;
  // Wait for every bundled weight before the first frame. Otherwise text is
  // laid out in the fallback font and re-wraps when Sora/Inter arrive, which
  // overflows cards whose height was already fixed by an equal-height row.
  await Future.wait([
    AssetRegistry.instance.init(),
    GoogleFonts.pendingFonts([
      for (final weight in const [FontWeight.w600, FontWeight.w700, FontWeight.w800]) GoogleFonts.sora(fontWeight: weight),
      for (final weight in const [FontWeight.w400, FontWeight.w500, FontWeight.w600, FontWeight.w700])
        GoogleFonts.inter(fontWeight: weight),
    ]),
  ]);
  runApp(const YodynixApp());
}
