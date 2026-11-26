/// The case-study detail the Portfolio page shows for a sample project, on
/// top of the project's own fields (name, category, overview, features).
/// The device a project is presented on.
enum ProjectDevice { laptop, desktop, tablet, phone }

class ProjectCaseStudy {
  const ProjectCaseStudy({
    required this.industry,
    required this.objective,
    this.device,
    this.faceLeft = false,
    this.photo,
    this.screenCrop,
    required this.problem,
    required this.solution,
    this.technologies = const [],
  });

  /// The sector the demonstration is set in.
  final String industry;

  /// What the demonstration sets out to show.
  final String objective;

  /// The device a working demo's screenshot is shown on (see
  /// `Scene3D.device`); null for concepts, which have no screens to show.
  final ProjectDevice? device;

  /// Turns the device the other way, so neighbouring demos differ.
  final bool faceLeft;

  /// A full-colour photograph (asset base path) for the project's portfolio
  /// image: the setting behind a working demo's device, or a concept's cover
  /// in place of its service-page image.
  final String? photo;

  /// Region of the project image shown on the device screen, as
  /// `crop=x,y,w,h` fractions; null uses the whole image. Used where a
  /// screenshot already frames a phone, so only its screen is shown.
  final String? screenCrop;

  /// The everyday business problem the project addresses.
  final String problem;

  /// How the demonstration answers it.
  final String solution;

  /// Only what the project is actually built with; empty for concepts,
  /// whose stack is chosen during discovery.
  final List<String> technologies;
}

/// Copy for the Portfolio page.
///
/// The projects themselves come from the service pages: every one is a
/// demonstration built by YODYNIX, never client work, and the page says so.
/// Nothing here names a client or claims a business result.
class PortfolioContent {
  PortfolioContent._();

  static const String eyebrow = 'Our Portfolio';
  static const String heading = 'Engineering Digital Experiences That Move Businesses Forward.';
  static const String headingHighlight = 'Move Businesses Forward.';
  static const String lead =
      'Explore a collection of digital experiences, intelligent applications and innovative '
      'solutions designed to demonstrate the capabilities of YODYNIX.';

  /// Portfolio filters: a label and the service ids whose projects it shows
  /// (an empty list shows every project).
  static const List<(String, List<String>)> filters = [
    ('All Projects', []),
    ('Website Development', ['website_development']),
    ('Mobile Applications', ['mobile_app_development']),
    ('Custom Software', ['custom_software_development']),
    ('E-commerce', ['ecommerce_development']),
    ('UI/UX Design', ['ui_ux_design']),
    ('AI & Automation', ['ai_solutions_chatbots', 'business_automation']),
  ];

  static const String disclosure =
      'Projects displayed in this portfolio are YODYNIX demonstrations created to showcase '
      'our capabilities. They are not representations of completed client engagements. '
      'Websites and software built for our clients are on the Our Work page.';

  static const String closingHeading = 'Have a Project in Mind?';
  static const String closingBody =
      'Every demonstration here began with a simple question: how could this work better? '
      'Tell us about your business and we will reply with clear next steps.';

  /// The working demos run inside this Flutter web site.
  static const List<String> _flutterWeb = ['Flutter', 'Dart', 'Flutter Web'];

  /// Case-study detail by `SampleProject.id`.
  static const Map<String, ProjectCaseStudy> caseStudies = {
    // ---------------------------------------------------------- Websites
    'lumen_dental': ProjectCaseStudy(
      industry: 'Healthcare & Clinics',
      objective: 'Show how a small clinic can answer everyday questions online and turn visits into appointment requests.',
      device: ProjectDevice.laptop,
      photo: 'assets/images/portfolio/lumen_dental_scene',
      problem:
          'Small clinics often rely on phone calls for every question, so staff spend the day '
          'repeating opening hours and treatment details while appointment requests get lost.',
      solution:
          'A clear one-page website that answers the common questions up front and collects '
          'appointment requests through a validated form, ready for the front desk to confirm.',
      technologies: _flutterWeb,
    ),
    'northfield_architects': ProjectCaseStudy(
      industry: 'Real Estate & Construction',
      objective: 'Present an architecture practice through its projects first, with a clear path to enquire.',
      photo: 'assets/images/portfolio/northfield_architects_cover',
      problem:
          'Architecture practices are judged on their work, yet many sites bury projects under '
          'text and make it hard to find relevant examples.',
      solution:
          'A project-first website where imagery leads, a filterable index surfaces relevant '
          'work quickly and every page ends in a simple enquiry.',
    ),
    'saffron_table': ProjectCaseStudy(
      industry: 'Hospitality & Food',
      objective: 'Give a restaurant a menu and reservation experience that works on any screen and stays current.',
      problem:
          'Restaurant menus are often shared as PDFs that are hard to read on phones and '
          'quickly go out of date, and reservations depend on someone answering the phone.',
      solution:
          'A mobile-first site with a readable menu, a reservation request and a simple way '
          'for staff to update seasonal specials themselves.',
    ),
    'peak_realty': ProjectCaseStudy(
      industry: 'Real Estate & Construction',
      objective: 'Help buyers find suitable properties quickly and send agents well-qualified viewing requests.',
      problem:
          'Buyers want to narrow listings quickly, while agents want serious viewing requests '
          'rather than vague enquiries.',
      solution:
          'Searchable listings with practical filters, gallery-led property pages and a '
          'viewing-request form that reaches the right agent directly.',
    ),

    // ------------------------------------------------------- E-commerce
    'weave_and_co': ProjectCaseStudy(
      industry: 'E-commerce',
      objective: 'Demonstrate a complete, trustworthy buying journey for an independent online store.',
      device: ProjectDevice.laptop,
      faceLeft: true,
      photo: 'assets/images/portfolio/weave_and_co_scene',
      problem:
          'Independent makers need an online store that feels trustworthy and makes buying '
          'easy, without the complexity of a large marketplace.',
      solution:
          'A focused storefront with category filters, a live cart that recalculates totals '
          'instantly and a clear checkout confirmation. Payment is simulated in the demo.',
      technologies: _flutterWeb,
    ),
    'freshcart': ProjectCaseStudy(
      industry: 'E-commerce',
      objective: 'Make weekly grocery orders fast to repeat and predictable to deliver.',
      problem:
          'Grocery customers buy the same items every week, and out-of-stock products cause '
          'frustrating substitutions at delivery.',
      solution:
          'Quick re-ordering of regular items, delivery-slot selection at checkout and '
          'substitution preferences captured before the order is packed.',
    ),
    'studio_sole': ProjectCaseStudy(
      industry: 'E-commerce',
      objective: 'Show only what shoppers can actually buy in their size, and bring them back for new releases.',
      problem:
          'Footwear shoppers abandon stores when their size turns out to be unavailable after '
          'they have already chosen a product.',
      solution:
          'Size-aware filtering that only shows what can be bought, with wishlists and alerts '
          'for limited releases.',
    ),
    'bloom_box': ProjectCaseStudy(
      industry: 'E-commerce',
      objective: 'Capture date-specific gift orders accurately and organise the florist’s daily preparation.',
      problem:
          'Florists receive orders for specific dates and occasions, and missed details turn a '
          'gift into a disappointment.',
      solution:
          'Ordering by delivery date with a gift message at checkout, plus a daily board that '
          'shows the team exactly what to prepare each morning.',
    ),

    // ----------------------------------------------------------- Mobile
    'fitslot': ProjectCaseStudy(
      industry: 'Health & Fitness',
      objective: 'Demonstrate the core booking loop of a mobile app: choose, confirm and manage a class.',
      device: ProjectDevice.phone,
      photo: 'assets/images/portfolio/fitslot_scene',
      screenCrop: 'crop=0.3725,0.088,0.255,0.848',
      problem:
          'Studios that take class bookings by message struggle with overbooked sessions and '
          'members who forget what they have reserved.',
      solution:
          'A booking app with a day picker, live seat counts, instant confirmation and a '
          '"My Bookings" list where members can cancel and free their place.',
      technologies: _flutterWeb,
    ),
    'careconnect': ProjectCaseStudy(
      industry: 'Healthcare & Clinics',
      objective: 'Give patients one place to book, be reminded and review their care.',
      problem:
          'Patients of multi-doctor clinics juggle calls, paper slips and missed reminders, and '
          'rarely have their visit history to hand.',
      solution:
          'A patient app for booking with a preferred doctor, receiving reminders and viewing '
          'past visits and prescriptions behind a secure login.',
    ),
    'quickserve': ProjectCaseStudy(
      industry: 'Hospitality & Food',
      objective: 'Let customers order ahead and follow their order without calling the restaurant.',
      problem:
          'Busy restaurants lose time taking phone orders, and customers are left guessing when '
          'their food will be ready.',
      solution:
          'Order-ahead with menu customisation, in-app payment, live order status and one-tap '
          'reordering of favourites.',
    ),
    'droprun': ProjectCaseStudy(
      industry: 'Retail & Logistics',
      objective: 'Give delivery riders a clear daily route and a reliable record of every drop.',
      problem:
          'Local delivery teams coordinate routes over calls and chat, with no reliable proof '
          'that each drop was completed.',
      solution:
          'A courier app with an ordered drop list, photo proof of delivery, an earnings '
          'summary and offline-friendly behaviour for patchy coverage.',
    ),
    'taskflow': ProjectCaseStudy(
      industry: 'Business Operations',
      objective: 'Show one Flutter codebase adapting naturally to phone, tablet and desktop screens.',
      device: ProjectDevice.tablet,
      photo: 'assets/images/portfolio/taskflow_scene',
      problem:
          'Teams switch between phones, tablets and desktops through the day, and tools that '
          'only work well on one screen slow them down.',
      solution:
          'A task board built once that re-flows for phone, tablet and desktop, with tasks '
          'moving between To Do, In Progress and Done.',
      technologies: _flutterWeb,
    ),

    // -------------------------------------------------- Custom software
    'leaddesk_crm': ProjectCaseStudy(
      industry: 'Business Operations',
      objective: 'Demonstrate how a lightweight CRM keeps every lead and its stage visible in one place.',
      device: ProjectDevice.desktop,
      photo: 'assets/images/portfolio/leaddesk_crm_scene',
      problem:
          'Growing businesses track leads in spreadsheets and inboxes, so follow-ups slip and '
          'nobody can see the pipeline at a glance.',
      solution:
          'A compact CRM with a searchable lead table, status filters, validated lead entry and '
          'a pipeline summary that updates as stages change.',
      technologies: _flutterWeb,
    ),
    'stockwise': ProjectCaseStudy(
      industry: 'Retail & Logistics',
      objective: 'Keep stock levels accurate in real time and warn staff before items run out.',
      problem:
          'Distributors discover stock shortages only when shelves are empty, because counts '
          'live on paper or in out-of-date sheets.',
      solution:
          'Barcode-based stock movements on a tablet, stock levels by location and low-stock '
          'alerts raised before an item runs out.',
    ),
    'clinicdesk': ProjectCaseStudy(
      industry: 'Healthcare & Hospitals',
      objective: 'Show how one front-office system keeps OPD, beds and billing in step across a hospital.',
      problem:
          'Hospital front desks juggle token slips, a bed register and separate billing, so '
          'queues stall, free beds go unnoticed and charges are missed at discharge.',
      solution:
          'A single front-office tool with an OPD token queue, a ward bed board for admission and '
          'discharge, and billing raised automatically from each consultation and stay.',
      technologies: _flutterWeb,
    ),
    'fleetboard': ProjectCaseStudy(
      industry: 'Retail & Logistics',
      objective: 'Help a logistics operator plan vehicles, maintenance and drivers without conflicts.',
      problem:
          'Fleet operators plan vehicles, maintenance and drivers in separate places, so '
          'conflicts are found too late.',
      solution:
          'A single dashboard for vehicle schedules, upcoming maintenance and driver '
          'assignments, with utilisation reports.',
    ),

    // --------------------------------------------------------------- AI
    'helpdesk_assistant': ProjectCaseStudy(
      industry: 'Business Operations',
      objective: 'Show how a support assistant handles routine questions and hands complex ones to a person.',
      device: ProjectDevice.desktop,
      faceLeft: true,
      photo: 'assets/images/portfolio/helpdesk_assistant_scene',
      problem:
          'Support teams answer the same pricing, hours and refund questions all day, leaving '
          'less time for customers who need a person.',
      solution:
          'A support assistant that recognises common topics, suggests follow-up questions and '
          'offers a hand-off to a person. The demo uses keyword matching, not an AI model.',
      technologies: _flutterWeb,
    ),
    'order_assistant': ProjectCaseStudy(
      industry: 'E-commerce',
      objective: 'Turn chat conversations into confirmed orders without manual copying.',
      problem:
          'Retailers selling over chat spend hours answering stock and price questions and '
          'piecing orders together from messages.',
      solution:
          'A messaging assistant that answers product questions, builds the order in the '
          'conversation and passes it to staff to confirm.',
    ),
    'docsearch': ProjectCaseStudy(
      industry: 'Business Operations',
      objective: 'Let staff find reliable answers in their own documents, with the source always visible.',
      problem:
          'Staff waste time searching long policies and manuals, and answers given from memory '
          'are not always right.',
      solution:
          'Plain-language questions answered from the organisation’s own documents, with links '
          'to the exact source pages and access by role.',
    ),
    'review_insights': ProjectCaseStudy(
      industry: 'Hospitality & Food',
      objective: 'Turn a steady flow of guest reviews into clear themes and timely replies.',
      problem:
          'Hotels receive more guest reviews than anyone can read closely, so recurring issues '
          'are noticed late.',
      solution:
          'Reviews grouped into themes, trends tracked month to month and draft replies '
          'prepared for staff to approve.',
    ),

    // -------------------------------------------------------- Automation
    'flowrunner': ProjectCaseStudy(
      industry: 'Business Operations',
      objective: 'Make an automated enquiry workflow visible, step by step, from form to follow-up.',
      device: ProjectDevice.laptop,
      photo: 'assets/images/portfolio/flowrunner_scene',
      problem:
          'Website enquiries are copied by hand into a CRM, emails and team chats, and the '
          'follow-up depends on someone remembering.',
      solution:
          'An automated enquiry workflow that saves the lead, queues a confirmation, alerts the '
          'team and schedules a follow-up, shown step by step. The demo is a simulation.',
      technologies: _flutterWeb,
    ),
    'invoice_reminders': ProjectCaseStudy(
      industry: 'Financial Services',
      objective: 'Follow up unpaid invoices consistently and politely without manual chasing.',
      problem:
          'Service businesses chase unpaid invoices manually, which is awkward, inconsistent '
          'and easy to postpone.',
      solution:
          'Polite reminders sent before, on and after the due date, stopped automatically once '
          'a payment is recorded.',
    ),
    'salon_reminders': ProjectCaseStudy(
      industry: 'Beauty & Wellness',
      objective: 'Reduce missed appointments and encourage clients to rebook at the right time.',
      problem:
          'Salons lose revenue to no-shows and to clients who simply forget to rebook.',
      solution:
          'Booking confirmations, day-before reminders and a rebooking prompt a few weeks after '
          'each visit, with no-show tracking.',
    ),
    'daily_sales_report': ProjectCaseStudy(
      industry: 'Retail & Logistics',
      objective: 'Give a shop owner a clear picture of each day’s trading without manual reporting.',
      problem:
          'Shop owners piece together the day’s performance from the till and receipts, often '
          'late at night.',
      solution:
          'Point-of-sale data collected at closing and a one-page digest of sales, top items and '
          'refunds emailed every evening.',
    ),

    // --------------------------------------------------------- Marketing
    'campaign_planner': ProjectCaseStudy(
      industry: 'Business Operations',
      objective: 'Help businesses plan advertising budgets around realistic, illustrative outcomes.',
      device: ProjectDevice.laptop,
      faceLeft: true,
      photo: 'assets/images/portfolio/campaign_planner_scene',
      problem:
          'Businesses set advertising budgets without a clear view of how many leads or sales '
          'the spend would need to produce.',
      solution:
          'A planner that turns budget and conversion assumptions into estimated clicks, leads, '
          'revenue and return on ad spend. Figures are illustrative estimates.',
      technologies: _flutterWeb,
    ),
    'cafe_social': ProjectCaseStudy(
      industry: 'Hospitality & Food',
      objective: 'Build local awareness for a new café and connect online activity to in-store visits.',
      problem:
          'A new café needs local awareness before opening day, but posting without a plan '
          'rarely builds momentum.',
      solution:
          'A four-week content calendar, local awareness ads and an opening offer tracked '
          'through to in-store redemptions.',
    ),
    'fitness_launch': ProjectCaseStudy(
      industry: 'Health & Fitness',
      objective: 'Turn advertising interest into trial classes, and trial classes into memberships.',
      problem:
          'Fitness studios attract trial sign-ups that never turn up, and cannot see which ads '
          'bring members who stay.',
      solution:
          'A trial-class landing page fed by targeted ads, with reminders for sign-ups and '
          'tracking from trial to membership.',
    ),
    'interior_leads': ProjectCaseStudy(
      industry: 'Real Estate & Construction',
      objective: 'Help an interior studio appear for the local searches its customers actually make.',
      problem:
          'Interior studios depend on local searches, yet their service pages rarely match what '
          'people actually search for.',
      solution:
          'Local keyword research, optimised service pages, a refreshed business profile and a '
          'small search campaign for high-intent queries.',
    ),

    // ------------------------------------------------------------- UI/UX
    'bookly_prototype': ProjectCaseStudy(
      industry: 'Education & Training',
      objective: 'Show how a design moves from structure to polished interface before development begins.',
      device: ProjectDevice.phone,
      faceLeft: true,
      photo: 'assets/images/portfolio/bookly_prototype_scene',
      screenCrop: 'crop=0.381,0.176,0.238,0.771',
      problem:
          'Teams often jump from an idea to polished screens without testing the structure, and '
          'expensive changes surface late.',
      solution:
          'A clickable prototype that switches between wireframe and final interface for the '
          'same three-step flow, with shared component styles.',
      technologies: _flutterWeb,
    ),
    'banking_redesign': ProjectCaseStudy(
      industry: 'Financial Services',
      objective: 'Make everyday money tasks simpler and more reassuring for app users.',
      problem:
          'Everyday banking tasks such as sending money can feel complicated and uncertain, '
          'which erodes confidence.',
      solution:
          'A three-step transfer flow, clearer spending insights and reassuring confirmation '
          'screens, with accessible contrast and type.',
    ),
    'travel_journey': ProjectCaseStudy(
      industry: 'Travel & Tourism',
      objective: 'Bring every step of a multi-city trip into one clear, connected plan.',
      problem:
          'Planning a multi-city trip means juggling many tabs, and travellers lose track of '
          'how the pieces fit together.',
      solution:
          'Traveller research, a journey map from inspiration to booking and wireframes for '
          'building an itinerary in one place.',
    ),
    'saas_design_system': ProjectCaseStudy(
      industry: 'Business Operations',
      objective: 'Give a growing software product a consistent, documented interface language.',
      problem:
          'As software products grow, screens drift apart in style and behaviour, slowing both '
          'designers and developers.',
      solution:
          'An interface audit, design tokens and a documented component library for forms, '
          'tables and charts.',
    ),

    // ---------------------------------------------------------- Branding
    'brand_kit_builder': ProjectCaseStudy(
      industry: 'Business Operations',
      objective: 'Let businesses see a brand direction applied before committing to it.',
      device: ProjectDevice.desktop,
      photo: 'assets/images/portfolio/brand_kit_builder_scene',
      problem:
          'Choosing colours and typefaces in the abstract is hard; businesses need to see a '
          'direction applied before committing.',
      solution:
          'A tool that applies a business name, palette and font pairing instantly to a logo '
          'lockup, business card and social post.',
      technologies: _flutterWeb,
    ),
    'tea_identity': ProjectCaseStudy(
      industry: 'E-commerce',
      objective: 'Give a specialty tea brand a packaging system that stands out on the shelf and online.',
      problem:
          'Specialty products disappear on crowded shelves and product pages when the '
          'packaging lacks a clear system.',
      solution:
          'A confident wordmark, a colour code for each blend and a pouch packaging system with '
          'matching launch templates.',
    ),
    'bakery_rebrand': ProjectCaseStudy(
      industry: 'Hospitality & Food',
      objective: 'Refresh a neighbourhood bakery’s identity while keeping its warmth.',
      problem:
          'Long-standing neighbourhood businesses can look dated next to newer competitors, '
          'even when their product is excellent.',
      solution:
          'A warm rebrand carried from the logo to shopfront signage, pastry boxes and a '
          'matching social media grid.',
    ),
    'cowork_identity': ProjectCaseStudy(
      industry: 'Real Estate & Construction',
      objective: 'Give a coworking space an identity that guides members and works across every touchpoint.',
      problem:
          'Shared workspaces need an identity that works on signs, cards and screens, and '
          'helps members find their way around.',
      solution:
          'A modular identity with wayfinding signage, membership cards and a website style '
          'guide.',
    ),
  };

  static ProjectCaseStudy? of(String projectId) => caseStudies[projectId];
}
