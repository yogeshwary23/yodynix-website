import 'package:flutter/material.dart';

import '../../shared/layouts/subpage_scaffold.dart';
import 'services_section.dart';

/// `/services`: every service, opened from the Services menu and its
/// "View all services" link.
class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) => const SubpageScaffold(title: 'Services', child: ServicesSection());
}
