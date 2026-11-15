import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/content_models.dart';

class ExpertiseContent {
  ExpertiseContent._();

  static const heading = 'Technology Meets Creative Thinking.';
  static const lead =
      'A focused, modern toolkit we use and offer, chosen for reliability, '
      'maintainability and a great end-user experience.';

  // Icons use theme colours (not each product's brand colour) so the
  // section stays within the site palette: gold tones on the charcoal band.
  static const _a = AppColors.champagneGold;
  static const _b = AppColors.goldTint;
  static const _c = AppColors.onDarkBody;

  static final categories = [
    TechCategory(
      name: 'Flutter',
      description: 'One codebase for mobile, web and desktop.',
      icon: Icons.flutter_dash,
      items: [
        const TechItem('Flutter Mobile', Icons.flutter_dash, _a),
        const TechItem('Flutter Web', Icons.web_rounded, _b),
        const TechItem('Flutter Desktop', Icons.desktop_windows_outlined, _c),
      ],
    ),
    const TechCategory(
      name: 'Dart',
      description: 'The modern, type-safe language behind Flutter.',
      icon: Icons.code_rounded,
      items: [
        TechItem('Null-safe Dart', Icons.verified_outlined, _a),
        TechItem('Async & Streams', Icons.sync_alt_rounded, _b),
        TechItem('Clean Architecture', Icons.account_tree_outlined, _c),
      ],
    ),
    TechCategory(
      name: 'Web Development',
      description: 'Fast, responsive and search-friendly websites.',
      icon: Icons.language_rounded,
      items: [
        const TechItem('HTML', Icons.html_rounded, _a),
        const TechItem('CSS', Icons.css_rounded, _b),
        const TechItem('SEO-friendly Builds', Icons.travel_explore_rounded, _c),
      ],
    ),
    TechCategory(
      name: 'Frontend',
      description: 'Interactive interfaces that feel effortless.',
      icon: Icons.web_rounded,
      items: [
        const TechItem('JavaScript', Icons.javascript_rounded, _a),
        const TechItem('React', Icons.code_rounded, _b),
        const TechItem('Responsive Layouts', Icons.devices_rounded, _c),
      ],
    ),
    TechCategory(
      name: 'Backend',
      description: 'Secure services and data behind the scenes.',
      icon: Icons.dns_outlined,
      items: [
        const TechItem('Node.js', Icons.dns_rounded, _a),
        const TechItem('Firebase', Icons.local_fire_department_outlined, _b),
        const TechItem('MySQL & PostgreSQL', Icons.storage_rounded, _c),
      ],
    ),
    const TechCategory(
      name: 'AI Integration',
      description: 'Practical intelligence inside everyday tools.',
      icon: Icons.psychology_outlined,
      items: [
        TechItem('AI APIs', Icons.auto_awesome_rounded, _a),
        TechItem('Chatbots & Assistants', Icons.smart_toy_outlined, _b),
        TechItem('Smart App Features', Icons.lightbulb_outline_rounded, _c),
      ],
    ),
    const TechCategory(
      name: 'Automation',
      description: 'Repetitive work handled reliably.',
      icon: Icons.settings_suggest_outlined,
      items: [
        TechItem('Workflow Automation', Icons.account_tree_outlined, _a),
        TechItem('Email & Notifications', Icons.mark_email_read_outlined, _b),
        TechItem('Data Sync', Icons.sync_rounded, _c),
      ],
    ),
    const TechCategory(
      name: 'API Integration',
      description: 'Connecting your product to the services it needs.',
      icon: Icons.api_rounded,
      items: [
        TechItem('REST APIs', Icons.api_rounded, _a),
        TechItem('Payment Gateways', Icons.credit_card_rounded, _b),
        TechItem('Third-party Services', Icons.extension_outlined, _c),
      ],
    ),
    TechCategory(
      name: 'UI/UX',
      description: 'Interfaces designed before they are built.',
      icon: Icons.brush_outlined,
      items: [
        const TechItem('Figma', Icons.design_services_outlined, _a),
        const TechItem('Interactive Prototypes', Icons.touch_app_outlined, _b),
        const TechItem('Design Systems', Icons.dashboard_customize_outlined, _c),
      ],
    ),
    TechCategory(
      name: 'Cloud & Deployment',
      description: 'Reliable hosting, releases and monitoring.',
      icon: Icons.cloud_outlined,
      items: [
        const TechItem('Cloud Hosting', Icons.cloud_done_outlined, _a),
        const TechItem('Git & Version Control', Icons.commit_rounded, _b),
        const TechItem('Deployment & Monitoring', Icons.monitor_heart_outlined, _c),
      ],
    ),
  ];
}
