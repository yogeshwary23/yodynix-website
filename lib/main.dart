import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/yodynix_app.dart';
import 'services/asset_registry.dart';

Future<void> main() async {
  // Clean URLs (/careers) instead of hash URLs (/#/careers): each page gets
  // a URL of its own that search engines can index. web/index.html moves
  // old /#/ links onto the matching path before the app starts.
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  // Fonts are bundled in assets/fonts; never fetch from Google at runtime.
  GoogleFonts.config.allowRuntimeFetching = false;
  // Wait for every bundled weight before the first frame. Otherwise text is
  // laid out in the fallback font and re-wraps when Sora/Inter arrive, which
  // overflows cards whose height was already fixed by an equal-height row.
  await Future.wait([
    AssetRegistry.instance.init(),
    GoogleFonts.pendingFonts([flutter analyze lib/features/our_work lib/repositories/content/our_work_content.dart
      git add -A
      git commit -m "Our Work: add Women's Care ERP and IVF CARE"
      git push
      for (final weight in const [FontWeight.w600, FontWeight.w700, FontWeight.w800]) GoogleFonts.sora(fontWeight: weight),
      for (final weight in const [FontWeight.w400, FontWeight.w500, FontWeight.w600, FontWeight.w700])
        GoogleFonts.inter(fontWeight: weight),
    ]),
  ]);
  runApp(const YodynixApp());
}
