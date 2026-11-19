import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';

/// One sector on the Industries page.
class IndustryProfile {
  const IndustryProfile({
    required this.id,
    required this.name,
    required this.icon,
    required this.summary,
    required this.solutions,
    required this.serviceIds,
    required this.sceneLabel,
    required this.photoAlt,
  });

  /// Also the `industries` scene variant, its still render name and the
  /// photograph's file name in `assets/images/industries/`.
  final String id;
  final String name;
  final IconData icon;
  final String summary;
  final List<String> solutions;

  /// Services most relevant to the sector, by `ServiceOffering.id`.
  final List<String> serviceIds;

  /// Describes the 3D arrangement for screen readers.
  final String sceneLabel;
  final String photoAlt;

  String get photo => AssetPaths.industry(id);
}

/// Copy for the Industries page. The solution lists describe the kinds of
/// systems YODYNIX builds for each sector, not delivered client work.
class IndustriesContent {
  IndustriesContent._();

  static const String eyebrow = 'Industries We Serve';
  static const String heading = 'Technology That Understands Your Industry.';
  static const String headingHighlight = 'Understands Your Industry.';
  static const String lead =
      'Every industry has unique challenges. YODYNIX combines modern technology, intelligent '
      'automation and thoughtful digital experiences to help businesses simplify operations, '
      'improve customer experiences and build for the future.';

  /// The hero's 3D: the eight sectors linked around one hub.
  static const String networkSceneLabel =
      'Eight small gold, platinum and glass emblems, one for each industry, orbiting a '
      'liquid-gold hub and linked to it by fine gold lines carrying points of light.';

  static const List<IndustryProfile> industries = [
    IndustryProfile(
      id: 'finance',
      name: 'Financial Services',
      icon: Icons.account_balance_outlined,
      summary:
          'Build secure, efficient and user-friendly digital experiences for financial '
          'institutions and financial service businesses.',
      solutions: [
        'Customer portals and dashboards',
        'Financial management software',
        'Secure enquiry and onboarding workflows',
        'Business process automation',
        'Data visualization and reporting',
      ],
      serviceIds: ['custom_software_development', 'website_development', 'business_automation'],
      sceneLabel: 'Stacks of gold coins beside rising glass bars and a floating chrome ring.',
      photoAlt: 'A modern financial building lobby with marble floors and a reception desk.',
    ),
    IndustryProfile(
      id: 'oilgas',
      name: 'Oil & Gas',
      icon: Icons.oil_barrel_outlined,
      summary:
          'Support oil and gas businesses with digital tools that improve operational '
          'visibility, workforce coordination and business efficiency.',
      solutions: [
        'Fuel station management systems',
        'Inventory and stock management',
        'Employee and shift management',
        'Sales and operational reporting',
        'Business automation dashboards',
      ],
      serviceIds: ['custom_software_development', 'business_automation', 'mobile_app_development'],
      sceneLabel: 'A chrome refinery column and gold-banded storage tanks beside a liquid-gold drop.',
      photoAlt: 'An oil refinery with storage tanks and pipework under a warm golden sky.',
    ),
    IndustryProfile(
      id: 'logistics',
      name: 'Retail & Logistics',
      icon: Icons.local_shipping_outlined,
      summary:
          'Connect retail operations and logistics workflows with digital platforms designed to '
          'improve inventory visibility, order management and operational coordination.',
      solutions: [
        'Inventory management',
        'Order management systems',
        'Delivery and logistics tracking',
        'Retail business dashboards',
        'Customer management systems',
      ],
      serviceIds: ['custom_software_development', 'mobile_app_development', 'business_automation'],
      sceneLabel: 'Stacked champagne-gold and glass crates beside a platinum delivery van on a porcelain route.',
      photoAlt: 'A long distribution-centre aisle between tall shelves stacked with cartons.',
    ),
    IndustryProfile(
      id: 'ecommerce',
      name: 'E-commerce',
      icon: Icons.shopping_bag_outlined,
      summary:
          'Create modern online shopping experiences that help businesses showcase products, '
          'manage orders and connect with customers.',
      solutions: [
        'E-commerce website development',
        'Online product catalogues',
        'Shopping cart and checkout experiences',
        'Payment gateway integration',
        'Order and inventory management',
      ],
      serviceIds: ['ecommerce_development', 'website_development', 'digital_marketing'],
      sceneLabel: 'A champagne-gold shopping bag with platinum handles beside a glass gift box tied in gold.',
      photoAlt: 'A seller packing an online order into a cardboard box beside a laptop.',
    ),
    IndustryProfile(
      id: 'healthcare',
      name: 'Healthcare & Clinics',
      icon: Icons.local_hospital_outlined,
      summary:
          'Help healthcare providers simplify patient interactions and everyday administration '
          'through practical digital solutions.',
      solutions: [
        'Clinic websites',
        'Appointment booking systems',
        'Patient enquiry management',
        'Healthcare dashboards',
        'Administrative automation',
      ],
      serviceIds: ['website_development', 'mobile_app_development', 'business_automation'],
      sceneLabel: 'A glass capsule filled with liquid gold beside a polished platinum cross.',
      photoAlt: 'A doctor working at a computer in a bright, modern clinic office.',
    ),
    IndustryProfile(
      id: 'education',
      name: 'Education & Training',
      icon: Icons.school_outlined,
      summary:
          'Make learning and training more accessible through engaging digital platforms and '
          'structured management systems.',
      solutions: [
        'Educational websites',
        'Learning management platforms',
        'Student management systems',
        'Online registration',
        'Training and course portals',
      ],
      serviceIds: ['website_development', 'custom_software_development', 'mobile_app_development'],
      sceneLabel: 'A stack of porcelain, gold and charcoal books beneath a graduation cap with a gold tassel.',
      photoAlt: 'A training session in a modern classroom, with learners facing a presentation screen.',
    ),
    IndustryProfile(
      id: 'realestate',
      name: 'Real Estate & Construction',
      icon: Icons.apartment_outlined,
      summary:
          'Give real estate and construction businesses better digital tools to present '
          'projects, manage enquiries and coordinate operations.',
      solutions: [
        'Real estate websites',
        'Property listing platforms',
        'Project showcase websites',
        'Lead management systems',
        'Construction project dashboards',
      ],
      serviceIds: ['website_development', 'custom_software_development', 'ui_ux_design'],
      sceneLabel: 'Glass and chrome towers on a porcelain site plan, one capped in gold.',
      photoAlt: 'The steel frame of a new building rising beside tower cranes.',
    ),
    IndustryProfile(
      id: 'hospitality',
      name: 'Hospitality & Food',
      icon: Icons.restaurant_outlined,
      summary:
          'Help hospitality and food businesses improve customer experiences with modern '
          'websites, digital ordering and business management solutions.',
      solutions: [
        'Restaurant websites',
        'Online ordering systems',
        'Table reservation experiences',
        'Menu management',
        'Customer enquiry automation',
      ],
      serviceIds: ['website_development', 'ecommerce_development', 'business_automation'],
      sceneLabel: 'A polished platinum cloche with a gold knob on a gold plate.',
      photoAlt: 'An elegant restaurant dining room with set tables and warm wooden shelving.',
    ),
  ];
}
