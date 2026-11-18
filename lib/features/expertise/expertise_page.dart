import 'package:flutter/material.dart';

import '../../shared/layouts/subpage_scaffold.dart';
import 'expertise_section.dart';

/// `/expertise`: our work in AI and the technologies behind it, opened from
/// the Expertise menu item and the hero's "Explore Our Expertise".
class ExpertisePage extends StatelessWidget {
  const ExpertisePage({super.key});

  @override
  Widget build(BuildContext context) => const SubpageScaffold(title: 'Expertise', child: ExpertiseSection());
}
