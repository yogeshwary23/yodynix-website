import 'package:flutter/material.dart';

import '../../core/routing/app_routes.dart';
import '../../models/content_models.dart';
import '../../models/pillar_page.dart' show PillarStep;
import '../../models/service_page.dart';
import 'services_content.dart';

/// Detail content for each service page, keyed by [ServiceOffering.id].
///
/// Sample projects are YODYNIX demos and concepts — not client work. Only
/// projects with a `demoRoute` link to a working demo inside this site.
class ServicePagesContent {
  ServicePagesContent._();

  static ServiceOffering? bySlug(String slug) {
    for (final s in ServicesContent.services) {
      if (s.slug == slug) return s;
    }
    return null;
  }

  static ServicePageContent of(ServiceOffering service) => _pages[service.id]!;

  /// Every sample project across all services, in page order.
  static List<SampleProject> get allProjects => [for (final p in _pages.values) ...p.projects];

  /// The project whose page is at `/portfolio/<slug>`, if any.
  static SampleProject? projectBySlug(String slug) {
    for (final p in allProjects) {
      if (p.slug == slug) return p;
    }
    return null;
  }

  /// The service a project belongs to.
  static ServiceOffering serviceOf(SampleProject project) =>
      ServicesContent.services.firstWhere((s) => _pages[s.id]!.projects.contains(project));

  static const _pages = <String, ServicePageContent>{
    // ------------------------------------------------------------ Website
    'website_development': ServicePageContent(
      heroHeading: 'Websites That Earn Trust In Seconds.',
      heroLead:
          'Fast, responsive and search-friendly websites that explain what you do, '
          'build credibility and turn visitors into enquiries.',
      overview: [
        'A website is usually the first place a customer checks before they call, visit or buy. '
            'We plan the structure around the questions your customers actually ask, write clear '
            'calls to action and build pages that load quickly on every device.',
        'Every site is easy to update, search-friendly from the first line of code and ready '
            'to grow, whether it starts as a single landing page or a full custom web application.',
      ],
      idealFor: [
        'Businesses launching or replacing a website',
        'Clinics, studios and professional services',
        'Campaign and product landing pages',
        'Teams that need a custom web application',
      ],
      offers: [
        ServiceFeature(
          'Business Websites',
          'Clear, credible sites that explain your services and capture enquiries.',
          Icons.storefront_outlined,
        ),
        ServiceFeature(
          'Corporate Websites',
          'Structured multi-page sites for established organisations and teams.',
          Icons.apartment_rounded,
        ),
        ServiceFeature(
          'Portfolio Websites',
          'Visual showcases for creative studios, architects and makers.',
          Icons.collections_outlined,
        ),
        ServiceFeature('Landing Pages', 'Focused single pages built to convert a campaign or launch.', Icons.ads_click_rounded),
        ServiceFeature('Responsive Websites', 'Layouts that adapt cleanly from phones to wide desktops.', Icons.devices_rounded),
        ServiceFeature(
          'Custom Web Applications',
          'Interactive tools, portals and dashboards that run in the browser.',
          Icons.web_rounded,
        ),
        ServiceFeature(
          'Website Redesign',
          'A modern refresh of an existing site without losing what works.',
          Icons.autorenew_rounded,
        ),
        ServiceFeature(
          'SEO-friendly Development',
          'Semantic markup, speed and metadata that search engines understand.',
          Icons.travel_explore_rounded,
        ),
        ServiceFeature(
          'Website Maintenance',
          'Updates, backups and fixes so the site stays fast and secure.',
          Icons.build_circle_outlined,
        ),
      ],
      process: [
        PillarStep('Discover', 'Understand your audience, goals and the pages they need.', Icons.travel_explore_rounded),
        PillarStep('Structure', 'Plan the sitemap, content and calls to action.', Icons.account_tree_outlined),
        PillarStep('Design', 'Create responsive layouts that match your brand.', Icons.draw_outlined),
        PillarStep('Build', 'Develop fast, accessible and search-friendly pages.', Icons.code_rounded),
        PillarStep('Launch & Care', 'Test, publish and keep the site maintained.', Icons.rocket_launch_outlined),
      ],
      projects: [
        SampleProject(
          id: 'lumen_dental',
          name: 'Lumen Dental Care',
          category: 'Clinic website',
          summary:
              'A calm, responsive clinic website with treatments, opening hours and an '
              'appointment request form.',
          overview:
              'A one-page website for a neighbourhood dental clinic. Visitors can browse '
              'treatments, check opening hours and send an appointment request with validated '
              'fields. It shows the core of a small-business website in one working page.',
          features: [
            'Responsive one-page layout',
            'Treatment cards',
            'Opening hours panel',
            'Validated appointment request form',
          ],
          imageAlt: 'Screenshot of the Lumen Dental Care demo website.',
          demoRoute: '${AppRoutes.demoPrefix}clinic-website',
        ),
        SampleProject(
          id: 'northfield_architects',
          name: 'Northfield Architects',
          category: 'Portfolio website',
          summary:
              'A project-led portfolio site for an architecture practice, with filterable '
              'case studies.',
          overview:
              'Concept for an architecture practice that wants its projects to speak first. '
              'Large imagery, a filterable project index and a short studio story lead visitors '
              'to a simple enquiry page.',
          features: ['Filterable project index', 'Full-width image galleries', 'Studio and team pages', 'Enquiry page'],
          imageAlt: 'An architect drawing building plans by hand.',
        ),
        SampleProject(
          id: 'saffron_table',
          name: 'Saffron Table',
          category: 'Restaurant website',
          summary:
              'A warm restaurant website with menus, table reservations and event '
              'announcements.',
          overview:
              'Concept for an independent restaurant: a mobile-first menu, opening times, '
              'a table-reservation request and a simple way for staff to post seasonal specials.',
          features: ['Mobile-first menu', 'Reservation request', 'Seasonal specials', 'Location and hours'],
          imageAlt: 'A warmly lit restaurant dining room with set tables.',
        ),
        SampleProject(
          id: 'peak_realty',
          name: 'Peak Realty',
          category: 'Real-estate listings site',
          summary:
              'A property listings website with search filters, gallery pages and '
              'viewing requests.',
          overview:
              'Concept for a real-estate agency: searchable listings filtered by location, '
              'price and size, detailed property pages with galleries and a viewing-request form '
              'that goes straight to the agent.',
          features: ['Listing search and filters', 'Property gallery pages', 'Viewing requests', 'Agent profiles'],
          imageAlt: 'A modern white villa with a swimming pool.',
        ),
      ],
    ),

    // --------------------------------------------------------- E-commerce
    'ecommerce_development': ServicePageContent(
      heroHeading: 'Online Stores Built For Easy Buying.',
      heroLead:
          'Storefronts with smooth product discovery, a clear cart and checkout, and '
          'back-office tools that make running the shop simple.',
      overview: [
        'Good e-commerce feels effortless for the customer and manageable for the owner. We '
            'design product pages that answer buying questions, carts that never surprise and '
            'checkouts that build trust.',
        'Behind the storefront we set up product, inventory and order management so you can '
            'run day-to-day operations without technical help.',
      ],
      idealFor: [
        'Retailers taking their shop online',
        'Makers and D2C brands',
        'Grocery and local delivery businesses',
        'Stores outgrowing a basic template',
      ],
      offers: [
        ServiceFeature('Online Stores', 'Complete, branded storefronts built around your catalogue.', Icons.storefront_rounded),
        ServiceFeature(
          'Product Management',
          'Easy tools to add products, variants, prices and images.',
          Icons.inventory_2_outlined,
        ),
        ServiceFeature('Shopping Cart', 'A clear cart with quantities, totals and saved items.', Icons.shopping_cart_outlined),
        ServiceFeature('Checkout', 'Short, trustworthy checkout flows that reduce drop-off.', Icons.fact_check_outlined),
        ServiceFeature('Payment Integration', 'Secure payment gateways for cards, UPI and wallets.', Icons.credit_card_rounded),
        ServiceFeature('Inventory Management', 'Stock tracking and low-stock alerts across products.', Icons.warehouse_outlined),
        ServiceFeature('Order Management', 'Track orders from payment to dispatch and delivery.', Icons.local_shipping_outlined),
      ],
      process: [
        PillarStep('Plan the Catalogue', 'Map products, categories and variants.', Icons.category_outlined),
        PillarStep('Design the Journey', 'Shape browsing, cart and checkout around buyers.', Icons.route_outlined),
        PillarStep(
          'Build & Integrate',
          'Develop the store and connect payments and shipping.',
          Icons.integration_instructions_outlined,
        ),
        PillarStep('Test Orders', 'Run end-to-end test orders on every device.', Icons.fact_check_outlined),
        PillarStep('Launch & Grow', 'Go live and improve with real sales data.', Icons.trending_up_rounded),
      ],
      projects: [
        SampleProject(
          id: 'weave_and_co',
          name: 'Weave & Co. Handloom Store',
          category: 'Online store',
          summary:
              'A working storefront with category filters, a live cart and a mock '
              'checkout confirmation.',
          overview:
              'A handloom textile store demo. Shoppers filter products by category, add '
              'items to the cart, change quantities and see totals update instantly, then '
              'complete a mock checkout. No real payment is taken.',
          features: [
            'Category filters',
            'Add-to-cart with quantities',
            'Live totals and delivery fee',
            'Mock checkout confirmation',
          ],
          imageAlt: 'Screenshot of the Weave & Co. demo online store.',
          demoRoute: '${AppRoutes.demoPrefix}handloom-store',
        ),
        SampleProject(
          id: 'freshcart',
          name: 'FreshCart',
          category: 'Grocery delivery store',
          summary: 'A grocery store with delivery slots, repeat orders and substitutions.',
          overview:
              'Concept for a neighbourhood grocer: quick re-ordering of regular items, '
              'delivery-slot selection at checkout and substitution preferences for items that '
              'run out.',
          features: ['Delivery slot picker', 'One-tap repeat orders', 'Substitution preferences', 'Stock-aware catalogue'],
          imageAlt: 'A paper grocery bag filled with fresh fruit and vegetables.',
        ),
        SampleProject(
          id: 'studio_sole',
          name: 'Studio Sole',
          category: 'Footwear store',
          summary: 'A sneaker store with size-aware filters, wishlists and drop alerts.',
          overview:
              'Concept for a footwear retailer where size availability matters most: '
              'filters that hide out-of-stock sizes, wishlists and email alerts when a '
              'limited release goes live.',
          features: ['Size-aware filtering', 'Wishlists', 'Release-drop alerts', 'Size guide'],
          imageAlt: 'A wall display of colourful sneakers in a shop.',
        ),
        SampleProject(
          id: 'bloom_box',
          name: 'Bloom Box',
          category: 'Florist store',
          summary: 'A florist store with scheduled delivery dates and gift messages.',
          overview:
              'Concept for a florist: bouquets ordered for a chosen delivery date, a gift '
              'message at checkout and an order board that shows the team what to prepare '
              'each morning.',
          features: ['Scheduled delivery dates', 'Gift messages', 'Daily preparation board', 'Occasion collections'],
          imageAlt: 'A flower shop full of fresh bouquets and plants.',
        ),
      ],
    ),

    // ------------------------------------------------------------- Mobile
    'mobile_app_development': ServicePageContent(
      heroHeading: 'Mobile Apps People Enjoy Using.',
      heroLead:
          'Polished Android and iOS applications that keep customers engaged and '
          'teams productive, built from one maintainable codebase.',
      overview: [
        'A good app earns its place on a home screen by saving people time. We focus on the '
            'few journeys that matter most, such as booking, ordering and tracking, and make '
            'them fast and obvious.',
        'Using cross-platform technology such as Flutter, we ship to Android and iOS together, '
            'with secure API integrations and a codebase that stays easy to extend.',
      ],
      idealFor: [
        'Service businesses taking bookings',
        'Brands building customer loyalty',
        'Field and delivery teams',
        'Start-ups validating an app idea',
      ],
      offers: [
        ServiceFeature('Android Applications', 'Native-quality Android apps ready for the Play Store.', Icons.android_rounded),
        ServiceFeature('iOS Applications', 'Polished iPhone apps ready for the App Store.', Icons.phone_iphone_rounded),
        ServiceFeature(
          'Business Applications',
          'Internal apps that simplify everyday operations.',
          Icons.business_center_outlined,
        ),
        ServiceFeature(
          'Booking Applications',
          'Slots, calendars and confirmations in a few taps.',
          Icons.event_available_outlined,
        ),
        ServiceFeature(
          'Customer Applications',
          'Loyalty, ordering and account apps for your customers.',
          Icons.people_outline_rounded,
        ),
        ServiceFeature(
          'Cross-platform Flutter Apps',
          'One Flutter codebase for Android and iOS, maintained together.',
          Icons.devices_other_rounded,
        ),
        ServiceFeature('API Integrations', 'Secure connections to your backend and third-party services.', Icons.api_rounded),
      ],
      process: [
        PillarStep('Define', 'Agree the core journeys and success measures.', Icons.flag_outlined),
        PillarStep('Prototype', 'Click through key screens before code is written.', Icons.touch_app_outlined),
        PillarStep('Develop', 'Build features in short, reviewable sprints.', Icons.code_rounded),
        PillarStep('Test on Devices', 'Check performance on real Android and iOS phones.', Icons.phonelink_setup_rounded),
        PillarStep('Publish & Support', 'Release to the stores and keep improving.', Icons.rocket_launch_outlined),
      ],
      projects: [
        SampleProject(
          id: 'fitslot',
          name: 'FitSlot',
          category: 'Class booking app',
          summary:
              'A working gym-class booking app: pick a day and slot, confirm and manage '
              'your bookings.',
          overview:
              'A mobile booking demo shown in a phone frame. Members choose a day, pick a '
              'class with live seat counts, confirm the booking and cancel it from "My Bookings". '
              'That is the core loop of any booking app.',
          features: ['Day picker', 'Classes with live seat counts', 'Booking confirmation', 'My Bookings with cancel'],
          imageAlt: 'Screenshot of the FitSlot demo booking app.',
          demoRoute: '${AppRoutes.demoPrefix}class-booking-app',
        ),
        SampleProject(
          id: 'careconnect',
          name: 'CareConnect',
          category: 'Clinic appointment app',
          summary: 'A patient app for booking appointments, reminders and visit history.',
          overview:
              'Concept for a multi-doctor clinic: patients book with a preferred doctor, '
              'receive reminders and see past visits and prescriptions in one place.',
          features: ['Doctor and slot selection', 'Appointment reminders', 'Visit history', 'Secure patient login'],
          imageAlt: 'Two doctors reviewing information on a tablet.',
        ),
        SampleProject(
          id: 'quickserve',
          name: 'QuickServe',
          category: 'Food ordering app',
          summary: 'A restaurant ordering app with live order status and saved favourites.',
          overview:
              'Concept for a restaurant group: customers order ahead, pay in the app, '
              'follow live order status and reorder favourites in one tap.',
          features: ['Menu with customisation', 'In-app payment', 'Live order status', 'Saved favourites'],
          imageAlt: 'A hand holding a phone showing a food ordering app.',
        ),
        SampleProject(
          id: 'droprun',
          name: 'DropRun',
          category: 'Delivery partner app',
          summary: 'A courier app with route lists, proof of delivery and earnings.',
          overview:
              'Concept for a local delivery business: riders see the day’s drops in '
              'order, capture proof of delivery with a photo and track their earnings.',
          features: ['Ordered drop list', 'Proof-of-delivery photos', 'Earnings summary', 'Offline-friendly'],
          imageAlt: 'A delivery rider handing a bag of fruit to a customer.',
        ),
        SampleProject(
          id: 'taskflow',
          name: 'TaskFlow Board',
          category: 'Responsive Flutter app',
          summary:
              'A working task board that adapts between phone, tablet and desktop '
              'layouts from one codebase.',
          overview:
              'A Flutter demo that shows the same app re-flowing for different screens. '
              'Switch between phone, tablet and desktop previews, add tasks and move them '
              'across To Do, In Progress and Done.',
          features: [
            'Phone / tablet / desktop preview',
            'Add tasks',
            'Move tasks between columns',
            'Adaptive layout from one codebase',
          ],
          imageAlt: 'Screenshot of the TaskFlow responsive task board demo.',
          demoRoute: '${AppRoutes.demoPrefix}responsive-task-board',
        ),
      ],
    ),

    // ----------------------------------------------------- Custom software
    'custom_software_development': ServicePageContent(
      heroHeading: 'Software Shaped Around How You Work.',
      heroLead:
          'Tailored CRMs, dashboards, portals and workflow tools that remove manual '
          'effort and give you clear visibility of your operations.',
      overview: [
        'Off-the-shelf software makes you adapt your process to the tool. Custom software does '
            'the opposite: it follows the way your team already works and removes the steps '
            'that waste time.',
        'We start with the workflow that causes the most friction, deliver it quickly and '
            'extend the system from there, with secure access, clean data and reliable reports.',
      ],
      idealFor: [
        'Teams running on spreadsheets',
        'Operations with unique workflows',
        'Businesses needing client or staff portals',
        'Managers who need clear dashboards',
      ],
      offers: [
        ServiceFeature('CRM Systems', 'Track leads, customers and follow-ups in one place.', Icons.contacts_outlined),
        ServiceFeature(
          'Business Management Systems',
          'Operations, staff and billing tools built for you.',
          Icons.business_rounded,
        ),
        ServiceFeature('Admin Dashboards', 'Live numbers and controls for managers.', Icons.space_dashboard_outlined),
        ServiceFeature('Custom Portals', 'Secure portals for clients, vendors or staff.', Icons.door_front_door_outlined),
        ServiceFeature('Internal Business Applications', 'Purpose-built tools for everyday tasks.', Icons.widgets_outlined),
        ServiceFeature('Workflow Systems', 'Approvals, assignments and status tracking.', Icons.account_tree_outlined),
      ],
      process: [
        PillarStep('Map the Workflow', 'Document how work moves today.', Icons.schema_outlined),
        PillarStep('Prioritise', 'Pick the highest-value first release.', Icons.low_priority_rounded),
        PillarStep('Build Iteratively', 'Deliver working modules every few weeks.', Icons.view_module_outlined),
        PillarStep('Migrate & Train', 'Move data across and train the team.', Icons.school_outlined),
        PillarStep('Support & Extend', 'Maintain and grow the system with you.', Icons.support_agent_rounded),
      ],
      projects: [
        SampleProject(
          id: 'leaddesk_crm',
          name: 'LeadDesk CRM',
          category: 'CRM system',
          summary:
              'A working mini CRM with a searchable lead table, status filters, a '
              'pipeline summary and an add-lead form.',
          overview:
              'A compact CRM demo. Search leads, filter by status, add a new lead with '
              'validation and update a lead’s stage, and the pipeline counts and value change '
              'immediately. Data stays in your browser session only.',
          features: ['Searchable lead table', 'Status filters', 'Pipeline summary', 'Add and update leads'],
          imageAlt: 'Screenshot of the LeadDesk CRM demo.',
          demoRoute: '${AppRoutes.demoPrefix}mini-crm',
        ),
        SampleProject(
          id: 'stockwise',
          name: 'StockWise',
          category: 'Inventory management system',
          summary: 'Warehouse inventory with barcode scanning, stock moves and low-stock alerts.',
          overview:
              'Concept for a distributor: staff scan items in and out on a tablet, '
              'managers see stock levels by location and the system raises low-stock alerts '
              'before shelves run empty.',
          features: ['Barcode scanning', 'Stock by location', 'Low-stock alerts', 'Movement history'],
          imageAlt: 'Two warehouse staff walking between tall storage shelves.',
        ),
        SampleProject(
          id: 'clinicdesk',
          name: 'ClinicDesk',
          category: 'Clinic management system',
          summary: 'Front-desk software for appointments, patient records and billing.',
          overview:
              'Concept for a clinic front desk: a day view of appointments, quick patient '
              'look-up, visit notes and simple billing, with role-based access for doctors '
              'and reception staff.',
          features: ['Appointment day view', 'Patient records', 'Billing and receipts', 'Role-based access'],
          imageAlt: 'Clinic staff working together at a reception desk.',
        ),
        SampleProject(
          id: 'fleetboard',
          name: 'FleetBoard',
          category: 'Fleet operations dashboard',
          summary: 'A dashboard for vehicle schedules, maintenance and driver assignments.',
          overview:
              'Concept for a logistics operator: see every vehicle’s schedule, plan '
              'maintenance before it is due and assign drivers to routes from one dashboard.',
          features: ['Vehicle schedule board', 'Maintenance planner', 'Driver assignments', 'Utilisation reports'],
          imageAlt: 'A row of white delivery vans parked in a lot.',
        ),
      ],
    ),

    // ------------------------------------------------------------------ AI
    'ai_solutions_chatbots': ServicePageContent(
      heroHeading: 'Practical AI That Helps Real People.',
      heroLead:
          'Chatbots and AI features that answer questions, guide customers and support '
          'your team, with a person always available when the answer needs one.',
      overview: [
        'AI pays off when it targets a specific problem: answering the same questions all '
            'day, finding information in documents or summarising feedback. We define that '
            'problem first and choose the technology after.',
        'Assistants answer from your own approved information, show when they are unsure and '
            'hand over to your team when a person is needed.',
      ],
      idealFor: [
        'Teams answering repetitive questions',
        'Businesses selling over WhatsApp or chat',
        'Organisations with large document libraries',
        'Products adding smart features',
      ],
      offers: [
        ServiceFeature('AI Chatbots', 'Assistants that answer customer questions around the clock.', Icons.smart_toy_outlined),
        ServiceFeature('Website & WhatsApp Assistants', 'Chat where your customers already are.', Icons.chat_outlined),
        ServiceFeature('Knowledge-based Q&A', 'Answers drawn from your own documents and policies.', Icons.menu_book_outlined),
        ServiceFeature('AI API Integration', 'Proven AI services connected securely to your systems.', Icons.api_rounded),
        ServiceFeature(
          'Intelligent App Features',
          'Smart search, summaries and content assistance.',
          Icons.auto_awesome_outlined,
        ),
      ],
      process: [
        PillarStep('Pick the Problem', 'Choose questions or tasks worth automating.', Icons.help_outline_rounded),
        PillarStep('Gather Knowledge', 'Collect and approve the source information.', Icons.library_books_outlined),
        PillarStep('Design Conversations', 'Plan answers, tone and hand-off rules.', Icons.forum_outlined),
        PillarStep('Build & Evaluate', 'Test answers against real questions.', Icons.fact_check_outlined),
        PillarStep('Launch & Monitor', 'Go live and review conversations regularly.', Icons.monitor_heart_outlined),
      ],
      projects: [
        SampleProject(
          id: 'helpdesk_assistant',
          name: 'HelpDesk Assistant',
          category: 'Support chatbot',
          summary:
              'A working support assistant that answers common questions and offers a '
              'hand-off to a person.',
          overview:
              'A scripted chatbot demo for a software company’s help desk. It recognises '
              'questions about pricing, hours, refunds and support, suggests follow-up topics '
              'and offers to connect a person when it cannot help. This demo uses keyword '
              'matching; no AI model is connected.',
          features: ['Suggested questions', 'Topic recognition', 'Typing indicator', 'Hand-off to a person'],
          imageAlt: 'Screenshot of the HelpDesk Assistant demo chatbot.',
          demoRoute: '${AppRoutes.demoPrefix}support-assistant',
        ),
        SampleProject(
          id: 'order_assistant',
          name: 'Chat Order Assistant',
          category: 'WhatsApp assistant',
          summary: 'A messaging assistant that takes orders and answers product questions.',
          overview:
              'Concept for a retailer selling over chat: the assistant answers stock and '
              'price questions, builds an order through the conversation and passes it to '
              'staff for confirmation.',
          features: ['Product questions', 'Conversational ordering', 'Staff confirmation', 'Order summaries'],
          imageAlt: 'A person typing a message on a smartphone.',
        ),
        SampleProject(
          id: 'docsearch',
          name: 'DocSearch',
          category: 'Knowledge-base Q&A',
          summary: 'Ask questions of policies and manuals and get answers with sources.',
          overview:
              'Concept for an organisation with large document libraries: staff ask '
              'questions in plain language and get short answers linked to the exact source '
              'pages.',
          features: ['Plain-language questions', 'Answers with sources', 'Access by role', 'Document upload'],
          imageAlt: 'Shelves of colourful ring binders in an office.',
        ),
        SampleProject(
          id: 'review_insights',
          name: 'Review Insights',
          category: 'AI summarisation',
          summary: 'Summarises guest reviews into themes, trends and suggested replies.',
          overview:
              'Concept for a hotel: incoming reviews are grouped into themes such as '
              'cleanliness or check-in, trends are tracked month to month and staff get '
              'draft replies to approve.',
          features: ['Theme detection', 'Monthly trends', 'Draft replies for approval', 'Alerts for urgent issues'],
          imageAlt: 'A modern hotel lobby with a reception desk.',
        ),
      ],
    ),

    // ---------------------------------------------------------- Automation
    'business_automation': ServicePageContent(
      heroHeading: 'Let Routine Work Run Itself.',
      heroLead:
          'Automated workflows that remove repetitive tasks, keep your tools in sync '
          'and make sure nothing falls through the cracks.',
      overview: [
        'Hours disappear into copying data between tools, chasing reminders and building the '
            'same reports. We map those routines and automate them so work moves forward on '
            'its own.',
        'Every automation is logged and easy to follow, so your team always knows what ran, '
            'when and why.',
      ],
      idealFor: [
        'Teams copying data between tools',
        'Businesses chasing payments or follow-ups',
        'Appointment-based services',
        'Managers building reports by hand',
      ],
      offers: [
        ServiceFeature('Workflow Automation', 'Multi-step processes that run on a trigger.', Icons.account_tree_outlined),
        ServiceFeature(
          'Email & Notification Flows',
          'The right message to the right person, on time.',
          Icons.mark_email_read_outlined,
        ),
        ServiceFeature('CRM & Data Sync', 'Keep contacts and records identical across tools.', Icons.sync_rounded),
        ServiceFeature(
          'Scheduling Automation',
          'Bookings, reminders and follow-ups handled for you.',
          Icons.event_repeat_outlined,
        ),
        ServiceFeature('Report Generation', 'Daily and weekly reports delivered automatically.', Icons.summarize_outlined),
        ServiceFeature('System Integrations', 'Connect forms, CRMs, email and spreadsheets.', Icons.hub_outlined),
      ],
      process: [
        PillarStep('Audit Routines', 'List repetitive tasks and their cost.', Icons.checklist_rounded),
        PillarStep('Design Flows', 'Define triggers, steps and exceptions.', Icons.schema_outlined),
        PillarStep('Connect Tools', 'Integrate the systems involved.', Icons.hub_outlined),
        PillarStep('Test Safely', 'Run with test data before going live.', Icons.science_outlined),
        PillarStep('Monitor', 'Watch logs and refine over time.', Icons.monitor_heart_outlined),
      ],
      projects: [
        SampleProject(
          id: 'flowrunner',
          name: 'FlowRunner',
          category: 'Workflow automation',
          summary:
              'A working simulation of an enquiry workflow covering the CRM record, emails, '
              'team alert and follow-up, with a live run log.',
          overview:
              'Submit a sample website enquiry and watch the workflow run step by step: '
              'the lead is saved to the CRM, a confirmation email is queued, the sales team is '
              'notified and a follow-up task is scheduled. This is a simulation; no emails are '
              'actually sent.',
          features: ['Trigger from a form', 'Step-by-step run', 'Live run log', 'Toggle steps on and off'],
          imageAlt: 'Screenshot of the FlowRunner workflow automation demo.',
          demoRoute: '${AppRoutes.demoPrefix}enquiry-automation',
        ),
        SampleProject(
          id: 'invoice_reminders',
          name: 'Invoice Reminder Flow',
          category: 'Payment follow-up',
          summary: 'Polite, scheduled reminders for unpaid invoices with status tracking.',
          overview:
              'Concept for a service business: invoices due in seven days, today and '
              'overdue each trigger a different reminder, and payments automatically stop '
              'the sequence.',
          features: ['Scheduled reminders', 'Stop on payment', 'Overdue summary', 'Accounting sync'],
          imageAlt: 'A person reviewing invoices and forms with a calculator.',
        ),
        SampleProject(
          id: 'salon_reminders',
          name: 'Salon Booking Reminders',
          category: 'Scheduling automation',
          summary: 'Appointment confirmations, reminders and rebooking prompts for a salon.',
          overview:
              'Concept for a salon: every booking sends a confirmation, a reminder the '
              'day before and a rebooking prompt a few weeks after the visit.',
          features: ['Booking confirmations', 'Day-before reminders', 'Rebooking prompts', 'No-show tracking'],
          imageAlt: 'A stylist washing a client’s hair at a salon basin.',
        ),
        SampleProject(
          id: 'daily_sales_report',
          name: 'Daily Sales Digest',
          category: 'Report generation',
          summary: 'A daily summary of sales, top items and refunds sent every evening.',
          overview:
              'Concept for a retail shop: point-of-sale data is collected at closing time '
              'and a clear one-page digest is emailed to the owner every evening.',
          features: ['Automatic data collection', 'Top items and refunds', 'Evening email digest', 'Weekly comparisons'],
          imageAlt: 'A card payment terminal printing a long receipt.',
        ),
      ],
    ),

    // ----------------------------------------------------------- Marketing
    'digital_marketing': ServicePageContent(
      heroHeading: 'Get Found By The Right Customers.',
      heroLead:
          'Targeted campaigns, search visibility and honest performance analysis that '
          'help your budget work harder.',
      overview: [
        'Marketing works best when every rupee can be traced to a result. Each campaign is '
            'planned around one clear goal, whether calls, bookings or sales, and tracking is '
            'in place before the first advert goes live.',
        'Across Instagram, Facebook and Google we test, measure and refine, with simple '
            'reports that show what is working and what to change next.',
      ],
      idealFor: [
        'Local businesses building awareness',
        'Brands launching a product or location',
        'Service businesses needing leads',
        'Teams unsure where budget is going',
      ],
      offers: [
        ServiceFeature('Instagram Marketing', 'Content and campaigns that build a loyal following.', Icons.photo_camera_outlined),
        ServiceFeature('Facebook Advertising', 'Targeted ads that reach the right local audience.', Icons.thumb_up_alt_outlined),
        ServiceFeature('Google Advertising', 'Search and display ads for people ready to act.', Icons.search_rounded),
        ServiceFeature('Lead Generation', 'Funnels and forms that turn interest into enquiries.', Icons.filter_alt_outlined),
        ServiceFeature('SEO', 'Technical and content improvements for organic visibility.', Icons.travel_explore_rounded),
        ServiceFeature('Campaign Management', 'Planning, launching and optimising campaigns.', Icons.campaign_outlined),
        ServiceFeature('Performance Analysis', 'Clear reports with honest, actionable insights.', Icons.insights_rounded),
      ],
      process: [
        PillarStep('Set the Goal', 'Agree the result that matters and how to measure it.', Icons.flag_outlined),
        PillarStep('Research', 'Understand audience, competitors and keywords.', Icons.manage_search_rounded),
        PillarStep('Plan & Create', 'Build the campaign plan and creatives.', Icons.edit_calendar_outlined),
        PillarStep('Launch & Test', 'Go live and test variations.', Icons.science_outlined),
        PillarStep('Report & Refine', 'Review results and move budget to what works.', Icons.insights_rounded),
      ],
      projects: [
        SampleProject(
          id: 'campaign_planner',
          name: 'Campaign ROI Planner',
          category: 'Marketing planning tool',
          summary:
              'A working planner that estimates clicks, leads, sales and return from a '
              'budget and channel assumptions.',
          overview:
              'Adjust budget, cost per click, conversion rates and order value, and the '
              'planner estimates clicks, leads, customers, revenue and return on ad spend. '
              'Figures are illustrative estimates for planning, not guaranteed results.',
          features: ['Channel presets', 'Live funnel estimates', 'Return on ad spend', 'Break-even check'],
          imageAlt: 'Screenshot of the Campaign ROI Planner demo.',
          demoRoute: '${AppRoutes.demoPrefix}campaign-planner',
        ),
        SampleProject(
          id: 'cafe_social',
          name: 'Brew Lane Social Launch',
          category: 'Instagram campaign',
          summary: 'A content calendar and local ads plan for a new café opening.',
          overview:
              'Concept for a new café: a four-week content calendar, behind-the-scenes '
              'reels, a local awareness campaign and an opening-week offer tracked through to '
              'in-store redemptions.',
          features: ['Four-week content calendar', 'Local awareness ads', 'Opening offer tracking', 'Weekly reporting'],
          imageAlt: 'The counter and espresso machines of a modern coffee shop.',
        ),
        SampleProject(
          id: 'fitness_launch',
          name: 'CoreFit Membership Drive',
          category: 'Lead generation',
          summary: 'A trial-class funnel with landing page, ads and follow-up sequence.',
          overview:
              'Concept for a fitness studio: ads lead to a free trial-class landing page, '
              'sign-ups receive reminders and the studio tracks trial-to-member conversion.',
          features: ['Trial-class landing page', 'Facebook and Instagram ads', 'Reminder sequence', 'Conversion tracking'],
          imageAlt: 'A bright gym with dumbbell racks and training equipment.',
        ),
        SampleProject(
          id: 'interior_leads',
          name: 'Habitat Interiors SEO',
          category: 'SEO & search ads',
          summary: 'Local SEO and search ads plan for an interior design studio.',
          overview:
              'Concept for an interior design studio: service pages optimised for local '
              'searches, a Google Business Profile refresh and a small search campaign for '
              'high-intent keywords.',
          features: ['Local keyword research', 'Service page optimisation', 'Business Profile refresh', 'Search ads for intent'],
          imageAlt: 'A styled modern living room with a grey sofa.',
        ),
      ],
    ),

    // --------------------------------------------------------------- UI/UX
    'ui_ux_design': ServicePageContent(
      heroHeading: 'Design That Feels Obvious To Use.',
      heroLead:
          'Research-led interface design that moves from user journeys and wireframes '
          'to interactive prototypes and polished, consistent screens.',
      overview: [
        'Good design removes doubt. We learn how your users think, map the journeys that '
            'matter and test ideas as wireframes and prototypes before anything is built.',
        'The final interfaces come with a design system of colours, type, components and '
            'usage rules, so every future screen stays consistent.',
      ],
      idealFor: [
        'New products before development',
        'Apps with confusing journeys',
        'Teams needing a design system',
        'Redesigns that must keep users happy',
      ],
      offers: [
        ServiceFeature('User Research', 'Interviews and testing that reveal real needs.', Icons.record_voice_over_outlined),
        ServiceFeature('Wireframes', 'Fast low-fidelity layouts to agree structure.', Icons.dashboard_outlined),
        ServiceFeature('Prototypes', 'Clickable flows to test before building.', Icons.touch_app_outlined),
        ServiceFeature('Interface Design', 'Polished, accessible screens for every device.', Icons.brush_outlined),
        ServiceFeature('User Journey', 'Maps of how people move through your product.', Icons.route_outlined),
        ServiceFeature('Design Systems', 'Reusable components and rules for consistency.', Icons.dashboard_customize_outlined),
      ],
      process: [
        PillarStep('Research', 'Understand users, goals and pain points.', Icons.record_voice_over_outlined),
        PillarStep('Map Journeys', 'Chart the key tasks step by step.', Icons.route_outlined),
        PillarStep('Wireframe', 'Agree structure in low fidelity.', Icons.dashboard_outlined),
        PillarStep('Prototype & Test', 'Click through flows with real users.', Icons.touch_app_outlined),
        PillarStep('Design & Hand Off', 'Final UI and a design system for developers.', Icons.brush_outlined),
      ],
      projects: [
        SampleProject(
          id: 'bookly_prototype',
          name: 'Bookly Prototype',
          category: 'Interactive prototype',
          summary:
              'A working prototype that switches between wireframe and final UI, with a '
              'clickable three-screen flow.',
          overview:
              'A reading-app prototype that shows how design moves from structure to '
              'polish. Toggle between wireframe and high-fidelity views of the same screens '
              'and click through browse, detail and confirmation steps.',
          features: ['Wireframe / UI toggle', 'Clickable three-step flow', 'Shared component styles', 'Annotated design notes'],
          imageAlt: 'Screenshot of the Bookly interactive prototype demo.',
          demoRoute: '${AppRoutes.demoPrefix}app-prototype',
        ),
        SampleProject(
          id: 'banking_redesign',
          name: 'Purse Banking Redesign',
          category: 'Mobile app redesign',
          summary: 'A simpler money-transfer and spending-insights journey for a banking app.',
          overview:
              'Concept redesign of a banking app’s most used tasks: sending money in '
              'three steps, clearer spending insights and reassuring confirmation screens.',
          features: ['Three-step transfer flow', 'Spending insights', 'Accessible contrast and type', 'Usability test plan'],
          imageAlt: 'A person using a finance app on a smartphone.',
        ),
        SampleProject(
          id: 'travel_journey',
          name: 'Wayfarer Trip Planner',
          category: 'User journey design',
          summary: 'Journey mapping and wireframes for a multi-city trip planner.',
          overview:
              'Concept for a travel start-up: research with frequent travellers, a '
              'journey map from inspiration to booking and wireframes for building a '
              'multi-city itinerary.',
          features: ['Traveller interviews', 'Journey map', 'Itinerary builder wireframes', 'Prototype for testing'],
          imageAlt: 'A hand tracing a route on a paper city map.',
        ),
        SampleProject(
          id: 'saas_design_system',
          name: 'Metric UI Kit',
          category: 'Design system',
          summary: 'A component library and guidelines for a growing SaaS dashboard.',
          overview:
              'Concept for a SaaS team whose screens had drifted apart: an audit, a '
              'token-based design system and documented components for forms, tables and '
              'charts.',
          features: ['Interface audit', 'Design tokens', 'Component library', 'Usage guidelines'],
          imageAlt: 'A designer sketching interface layouts beside a keyboard.',
        ),
      ],
    ),

    // ------------------------------------------------------------ Branding
    'branding_digital_presence': ServicePageContent(
      heroHeading: 'A Brand People Recognise Everywhere.',
      heroLead:
          'Distinctive identities and a consistent presence across your website, social '
          'channels and everything you print.',
      overview: [
        'Recognition starts with knowing what sets you apart. We define what makes your '
            'business different and express it in a logo, colours, type and tone of voice.',
        'We then apply it wherever customers meet you, from the website and social profiles '
            'to marketing creatives and stationery, and record it in clear brand guidelines.',
      ],
      idealFor: [
        'New businesses building an identity',
        'Brands that look different on every channel',
        'Rebrands and refreshes',
        'Teams needing ready-to-use templates',
      ],
      offers: [
        ServiceFeature('Logo Design', 'Memorable marks that work at every size.', Icons.auto_fix_high_outlined),
        ServiceFeature('Brand Identity', 'Colours, typography and visual language.', Icons.palette_outlined),
        ServiceFeature('Marketing Creatives', 'Posters, ads and brochures on brand.', Icons.image_outlined),
        ServiceFeature('Social Media Profiles & Content', 'Consistent profiles and post templates.', Icons.share_outlined),
        ServiceFeature('Brand Guidelines', 'A clear guide so everyone applies the brand correctly.', Icons.menu_book_outlined),
        ServiceFeature('Online Presence Setup', 'Website, Business Profile and social channels aligned.', Icons.public_rounded),
      ],
      process: [
        PillarStep('Discover', 'Learn your story, audience and competitors.', Icons.travel_explore_rounded),
        PillarStep('Define', 'Agree personality, values and positioning.', Icons.psychology_alt_outlined),
        PillarStep('Design', 'Explore logo and identity directions.', Icons.brush_outlined),
        PillarStep('Apply', 'Roll out across web, social and print.', Icons.layers_outlined),
        PillarStep('Document', 'Deliver guidelines and templates.', Icons.menu_book_outlined),
      ],
      projects: [
        SampleProject(
          id: 'brand_kit_builder',
          name: 'Brand Kit Builder',
          category: 'Identity exploration tool',
          summary:
              'A working tool that previews a brand name with different palettes and font '
              'pairings on a logo, card and social post.',
          overview:
              'Type a business name, choose a colour palette and a font pairing, and see '
              'the identity applied instantly to a logo lockup, a business card and a social '
              'post. It mirrors how we explore directions with clients.',
          features: ['Live name input', 'Palette presets', 'Font pairings', 'Logo, card and social previews'],
          imageAlt: 'Screenshot of the Brand Kit Builder demo.',
          demoRoute: '${AppRoutes.demoPrefix}brand-kit-builder',
        ),
        SampleProject(
          id: 'tea_identity',
          name: 'Leaf & Ember Tea',
          category: 'Packaging identity',
          summary: 'A bold identity and pouch packaging system for a specialty tea brand.',
          overview:
              'Concept for a specialty tea brand: a confident wordmark, a colour code for '
              'each blend and a packaging system that stands out on crowded shelves.',
          features: ['Wordmark', 'Colour-coded blends', 'Pouch packaging system', 'Social launch templates'],
          imageAlt: 'A colourful tea pouch surrounded by loose tea leaves.',
        ),
        SampleProject(
          id: 'bakery_rebrand',
          name: 'Crumb & Co. Bakery',
          category: 'Rebrand',
          summary: 'A warm rebrand for a neighbourhood bakery, from signage to boxes.',
          overview:
              'Concept rebrand for a family bakery: a hand-drawn logo, a warm palette, '
              'shopfront signage, pastry boxes and a matching Instagram grid.',
          features: ['Hand-drawn logo', 'Shopfront signage', 'Pastry box design', 'Instagram grid templates'],
          imageAlt: 'Fresh breads and pastries on bakery shelves.',
        ),
        SampleProject(
          id: 'cowork_identity',
          name: 'Commons Workspace',
          category: 'Space identity',
          summary: 'Identity, wayfinding and membership materials for a coworking space.',
          overview:
              'Concept for a coworking space: a modular identity, wayfinding signage for '
              'floors and rooms, membership cards and a website style guide.',
          features: ['Modular logo system', 'Wayfinding signage', 'Membership cards', 'Website style guide'],
          imageAlt: 'A bright coworking lounge with plants and seating.',
        ),
      ],
    ),
  };
}
