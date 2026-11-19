// Writes devices.json for render.js from the portfolio content, so the
// working demos' device stills use the same device, pose and screen crop as
// the site.
//
//   dart run tool/render_scenes/export_devices.dart   (from the project root)
import 'dart:convert';
import 'dart:io';

import 'package:yodynix_website/repositories/content/portfolio_content.dart';

void main() {
  final devices = {
    for (final MapEntry(:key, :value) in PortfolioContent.caseStudies.entries)
      if (value.device case final device?)
        key: {'device': device.name, if (value.faceLeft) 'left': true, 'crop': ?value.screenCrop},
  };
  final file = File('tool/render_scenes/devices.json');
  file.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(devices)}\n');
  stdout.writeln('wrote ${devices.length} projects to ${file.path}');
}
