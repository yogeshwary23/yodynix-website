import 'package:flutter/widgets.dart';

import 'hero_visual.dart';
import 'section_visuals.dart';
import 'visual_kind.dart';

/// Builds the illustrated composition for a [VisualKind].
class IllustratedVisual extends StatelessWidget {
  const IllustratedVisual(this.kind, {super.key});

  final VisualKind kind;

  @override
  Widget build(BuildContext context) {
    return switch (kind) {
      VisualKind.hero => const HeroVisual(),
      VisualKind.about => const AboutVisual(),
      VisualKind.internship => const InternshipVisual(),
    };
  }
}
