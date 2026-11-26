import 'package:flutter/material.dart';

import '../../core/routing/app_routes.dart';

/// How a project on the Our Work page is presented.
enum WorkBadge {
  /// A client's site in everyday use.
  live('Live'),

  /// Built for a client and published as a preview, not yet in full use.
  preview('Client preview'),

  /// Client software behind a sign-in, shown with screenshots only.
  private('Client project'),

  /// A YODYNIX demonstration, not client work.
  ourDemo('YODYNIX demo');

  const WorkBadge(this.label);

  final String label;
}

/// One project on the Our Work page.
class ClientWork {
  const ClientWork({
    required this.id,
    required this.name,
    required this.industry,
    required this.area,
    required this.type,
    required this.summary,
    required this.features,
    required this.badge,
    required this.icon,
    this.location,
    this.image,
    this.url,
    this.route,
  });

  final String id;
  final String name;
  final String industry;

  /// The filter this project appears under (see [OurWorkContent.areas]).
  final String area;

  /// What was built, e.g. "Clinic website".
  final String type;
  final String summary;
  final List<String> features;
  final WorkBadge badge;

  /// Shown in place of a screenshot when [image] is null.
  final IconData icon;
  final String? location;

  /// Full asset path of a screenshot, or null.
  final String? image;

  /// The live site, opened in a new tab.
  final String? url;

  /// An in-site page (for YODYNIX demos).
  final String? route;
}

/// Copy and projects for `/our-work`.
class OurWorkContent {
  OurWorkContent._();

  static const String eyebrow = 'Our Work';
  static const String heading = 'Software That Runs Real Businesses';
  static const String lead =
      'Websites and business software we have designed and built for clients across Maharashtra, '
      'from healthcare and jewellery retail to environmental consulting and fuel stations, alongside '
      'healthcare products of our own that you can try live.';

  static const List<String> areas = ['All', 'Healthcare', 'Retail', 'Consulting', 'Operations'];

  static final List<ClientWork> projects = [
    const ClientWork(
      id: 'v_sea',
      name: 'V-SEA',
      industry: 'Environmental Consulting',
      area: 'Consulting',
      type: 'Business website',
      summary:
          'Website for Varsha Sustainable Earth Advisors, an environmental consultancy offering impact '
          'assessment, clearances and compliance, monitoring, and climate and ESG services.',
      features: ['Service pages', 'Enquiry and WhatsApp contact', 'Responsive design'],
      badge: WorkBadge.live,
      icon: Icons.eco_outlined,
      image: 'assets/images/our_work/v_sea.webp',
      url: 'https://www.v-sea.co.in/',
    ),
    const ClientWork(
      id: 'ekdant',
      name: 'EKDANT Multispeciality Clinic',
      industry: 'Healthcare',
      area: 'Healthcare',
      location: 'Murti, Baramati',
      type: 'Clinic website',
      summary:
          'Medical, Ayurveda and dental care under one roof, with a live OPD token display, a symptom '
          'guide that points patients to the right doctor, and appointment booking.',
      features: ['Live OPD token', 'Symptom guide', 'Doctor schedules', 'English and Marathi'],
      badge: WorkBadge.preview,
      icon: Icons.local_hospital_outlined,
      image: 'assets/images/our_work/ekdant.webp',
      url: 'https://ekdant-care-link.base44.app',
    ),
    const ClientWork(
      id: 'gopika',
      name: 'Gopika Jewellery',
      industry: 'Jewellery Retail',
      area: 'Retail',
      location: 'Sambhajinagar',
      type: 'E-commerce store',
      summary:
          'One gram gold mangalsutras and bridal sets to buy, or to rent for an occasion anywhere in '
          'Maharashtra, with a wishlist, cart and shopping assistant.',
      features: ['Buy or rent', 'Rental deposits and tracking', 'English and Marathi', 'Shopping assistant'],
      badge: WorkBadge.preview,
      icon: Icons.diamond_outlined,
      image: 'assets/images/our_work/gopika.webp',
      url: 'https://gopika-royal-gold.base44.app',
    ),
    const ClientWork(
      id: 'wable_petroleum',
      name: 'Wable Petroleum',
      industry: 'Fuel Station',
      area: 'Operations',
      type: 'Management software',
      summary:
          'Software that runs a petrol pump day to day: fuel sales, credit customer accounts, shift '
          'handovers and reports for the owner.',
      features: ['Sales tracking', 'Credit customers', 'Shift management', 'Reports'],
      badge: WorkBadge.private,
      icon: Icons.local_gas_station_outlined,
    ),
    ClientWork(
      id: 'clinicdesk_hms',
      name: 'ClinicDesk HMS',
      industry: 'Healthcare',
      area: 'Healthcare',
      type: 'Hospital software',
      summary:
          'Our own hospital front-office demo: OPD tokens, a ward bed board for admissions and '
          'discharges, and billing. Try it in your browser.',
      features: const ['OPD token queue', 'Ward bed board', 'Billing'],
      badge: WorkBadge.ourDemo,
      icon: Icons.medical_services_outlined,
      image: 'assets/images/our_work/clinicdesk_hms.webp',
      route: AppRoutes.demo('hospital-management'),
    ),
    const ClientWork(
      id: 'womens_care',
      name: "Women's Care ERP",
      industry: 'Gynecology & Maternity',
      area: 'Healthcare',
      type: 'Hospital ERP',
      summary:
          'A complete hospital workspace for gynecology, pregnancy and maternity teams, from the first '
          'OPD visit to newborn discharge. Sign in with any demo role to explore it.',
      features: ['Pregnancy and ANC tracking', 'Maternity and newborn', 'Gynecology OPD', '8 staff roles'],
      badge: WorkBadge.ourDemo,
      icon: Icons.pregnant_woman_outlined,
      image: 'assets/images/our_work/womens_care.webp',
      url: 'https://fabulous-peony-04c87d.netlify.app',
    ),
    const ClientWork(
      id: 'ivf_care',
      name: 'IVF CARE',
      industry: 'Fertility & Embryology',
      area: 'Healthcare',
      type: 'Clinic ERP',
      summary:
          'Fertility clinic management: couple files and consultations, the embryology lab from oocyte '
          'to blastocyst, and a cryobank down to each straw. Sign in with any demo role to explore it.',
      features: ['Couple files', 'Embryology lab', 'Cryobank', '9 staff roles'],
      badge: WorkBadge.ourDemo,
      icon: Icons.biotech_outlined,
      image: 'assets/images/our_work/ivf_care.webp',
      url: 'https://stunning-monstera-f24514.netlify.app/',
    ),
  ];
}
