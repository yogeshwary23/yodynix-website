import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/routing/app_routes.dart';
import '../../models/pillar_page.dart';

/// Content for the Business Solutions and Technology & Innovation pillar
/// pages. Copy describes what YODYNIX offers and how it works — no figures
/// or guarantees are stated here. Careers has its own page
/// (`CareersContent`).
class PillarPagesContent {
  PillarPagesContent._();

  static const otherOption = 'Other / Not sure yet';

  static final pages = [business, technology];

  static PillarPageContent? byRoute(String route) {
    for (final page in pages) {
      if (page.route == route) return page;
    }
    return null;
  }

  // ------------------------------------------------- Business Solutions
  static final business = PillarPageContent(
    route: AppRoutes.businessSolutions,
    title: 'Business Solutions',
    eyebrow: 'Business Solutions',
    heroHeading: 'Digital Solutions That Move Your Business Forward.',
    heroLead:
        'Whether you need a first website, custom software or automated workflows, we plan, '
        'design and build around how your business really operates, so the technology '
        'supports your goals instead of getting in the way.',
    heroImage: AssetPaths.business('hero'),
    heroImageAlt: 'Business professionals discussing a digital project around a meeting table.',
    highlights: const [
      (Icons.travel_explore_rounded, 'Requirements understood before any build begins'),
      (Icons.devices_rounded, 'Responsive, maintainable and secure by design'),
      (Icons.support_agent_rounded, 'Clear communication from planning to launch'),
    ],
    offeringsEyebrow: 'What We Build',
    offeringsHeading: 'Six Ways to Grow Your Business Digitally',
    offeringsLead:
        'Each engagement starts with your goals and your customers. Choose a single '
        'service or combine several into one connected digital solution.',
    primaryLabel: 'Key Features',
    secondaryLabel: 'Business Benefits',
    ctaPrefix: 'Enquire About',
    offerings: [
      PillarOffering(
        title: 'Website Development',
        tagline: 'A credible online home for your business.',
        description:
            'We design and develop fast, responsive websites that explain what you do, '
            'build trust with visitors and make it easy for them to contact you. Content '
            'structure, page speed and search-friendly markup are planned from the start.',
        icon: Icons.language_rounded,
        image: AssetPaths.business('website_development'),
        imageAlt: 'A website displayed on a tablet beside a monitor and smartphone on a desk.',
        primaryPoints: const [
          'Responsive layouts for mobile, tablet and desktop',
          'SEO-friendly structure and metadata',
          'Contact forms, maps and enquiry flows',
          'Content that is easy to update',
        ],
        secondaryPoints: const [
          'A professional first impression for new customers',
          'Clear information that answers common questions',
          'A foundation for marketing and future growth',
        ],
      ),
      PillarOffering(
        title: 'E-commerce Development',
        tagline: 'Online stores that are simple to shop and manage.',
        description:
            'We build online stores with clear product pages, smooth checkout and '
            'integrations with established payment gateways. The store is set up so your team '
            'can manage products, orders and stock without technical help.',
        icon: Icons.shopping_bag_outlined,
        image: AssetPaths.business('ecommerce_development'),
        imageAlt: 'A customer holding a payment card while shopping online on a laptop.',
        primaryPoints: const [
          'Product catalogue, categories and search',
          'Cart and checkout with payment gateway integration',
          'Order, inventory and customer management',
          'Mobile-first shopping experience',
        ],
        secondaryPoints: const [
          'Sell to customers beyond your physical location',
          'Less manual order handling for your team',
          'A store structure that can grow with your range',
        ],
      ),
      PillarOffering(
        title: 'Mobile Application Development',
        tagline: 'Apps your customers and teams will actually use.',
        description:
            'We design and develop mobile applications for Android and iOS, often with '
            'Flutter so one codebase serves both platforms. We focus on intuitive navigation, '
            'reliable performance and connections to the services your business already uses.',
        icon: Icons.phone_iphone_rounded,
        image: AssetPaths.business('mobile_app_development'),
        imageAlt: 'A hand holding a smartphone showing a clean mobile app dashboard.',
        primaryPoints: const [
          'Android and iOS from a shared codebase',
          'User-friendly interface and navigation',
          'API, database and authentication integration',
          'Support for app store publishing',
        ],
        secondaryPoints: const [
          'Reach customers directly on their phones',
          'Streamline field work and internal tasks',
          'Lower maintenance with a single codebase',
        ],
      ),
      PillarOffering(
        title: 'Custom Software Development',
        tagline: 'Software shaped around your process, not a template.',
        description:
            'When off-the-shelf tools do not fit, we build web-based software tailored to '
            'your workflow: dashboards, management systems, portals and internal tools that '
            'bring scattered information into one place.',
        icon: Icons.integration_instructions_outlined,
        image: AssetPaths.business('custom_software_development'),
        imageAlt: 'Software developers working at their computers in a bright office.',
        primaryPoints: const [
          'Requirement analysis and solution design',
          'Role-based access for different users',
          'Dashboards and reports for decision-making',
          'Scalable, maintainable architecture',
        ],
        secondaryPoints: const [
          'Tools that match how your team already works',
          'Fewer spreadsheets and disconnected systems',
          'Clear visibility of day-to-day operations',
        ],
      ),
      PillarOffering(
        title: 'Business Automation',
        tagline: 'Let software handle the repetitive work.',
        description:
            'We identify repetitive, rule-based tasks such as data entry, notifications, '
            'reports and follow-ups, and automate them by connecting the tools you already use. '
            'Every automation is mapped and tested with your team before it goes live.',
        icon: Icons.settings_suggest_outlined,
        image: AssetPaths.business('business_automation'),
        imageAlt: 'A laptop showing a business analytics dashboard with charts.',
        primaryPoints: const [
          'Workflow mapping and automation planning',
          'Automated emails, alerts and reminders',
          'Data sync between business tools',
          'Scheduled reports and summaries',
        ],
        secondaryPoints: const [
          'More time for work that needs people',
          'Fewer manual errors in routine tasks',
          'Consistent processes, even as you grow',
        ],
      ),
      PillarOffering(
        title: 'Digital Transformation',
        tagline: 'A practical roadmap from manual to digital.',
        description:
            'Together we review how work happens today, find where digital tools will make '
            'the biggest difference and get there step by step. That means choosing the right '
            'technology, planning the rollout and supporting your team through the change.',
        icon: Icons.transform_rounded,
        image: AssetPaths.business('digital_transformation'),
        imageAlt: 'A team discussing digital plans in a meeting with laptops open.',
        primaryPoints: const [
          'Review of current processes and tools',
          'Prioritised, phased digital roadmap',
          'Technology selection guidance',
          'Team onboarding and handover',
        ],
        secondaryPoints: const [
          'Investment focused where it matters most',
          'Change introduced at a manageable pace',
          'A connected foundation for future tools',
        ],
      ),
    ],
    stepsEyebrow: 'How We Work',
    stepsHeading: 'A Clear Path From Enquiry To Launch',
    stepsLead:
        'Every business project follows the same transparent process, so you always know '
        'what is happening and what comes next.',
    steps: const [
      PillarStep('Discover', 'We learn about your business, customers and goals.', Icons.travel_explore_rounded),
      PillarStep('Plan', 'We agree on scope, technology and milestones.', Icons.insights_rounded),
      PillarStep('Build', 'We design and develop with regular progress reviews.', Icons.code_rounded),
      PillarStep('Launch & Support', 'We test, deploy and help you after launch.', Icons.rocket_launch_rounded),
    ],
    form: PillarFormConfig(
      kind: 'business_enquiry',
      title: 'Project Enquiry',
      lead:
          'Tell us about your business and what you would like to build. We will review the '
          'details and suggest a practical next step.',
      optionLabel: 'Service Required *',
      extraFieldLabel: 'Business Name',
      extraFieldIcon: Icons.business_outlined,
      messageLabel: 'Project Details *',
      messageHint: 'Your goals, audience, timeline and any references you like.',
      submitLabel: 'Send Project Enquiry',
      image: AssetPaths.business('enquiry'),
      imageAlt: 'Two people planning a project on paper beside their laptops.',
    ),
  );

  // -------------------------------------------- Technology & Innovation
  static final technology = PillarPageContent(
    route: AppRoutes.technologyInnovation,
    title: 'Technology & Innovation',
    eyebrow: 'Technology & Innovation',
    heroHeading: 'Building Smarter Solutions Through Technology.',
    heroLead:
        'AI services, Flutter, web frameworks, automation platforms and APIs are applied '
        'only where they solve a real problem, and the trade-offs are explained in plain '
        'language before anything is built.',
    heroImage: AssetPaths.technology('hero'),
    heroImageAlt: 'A technology team discussing work around desks in a modern office.',
    highlights: const [
      (Icons.lightbulb_outline_rounded, 'Innovation with a clear purpose'),
      (Icons.verified_outlined, 'Proven, well-supported technologies'),
      (Icons.forum_outlined, 'Honest advice on what each tool can and cannot do'),
    ],
    offeringsEyebrow: 'Technology Areas',
    offeringsHeading: 'Where We Apply Modern Technology',
    offeringsLead:
        'Each area below includes realistic use cases and the benefits you can expect. '
        'We recommend technology only after understanding the problem it needs to solve.',
    primaryLabel: 'Practical Use Cases',
    secondaryLabel: 'Benefits',
    ctaPrefix: 'Discuss',
    offerings: [
      PillarOffering(
        title: 'AI Solutions & Chatbots',
        tagline: 'Helpful assistants built on established AI services.',
        description:
            'We integrate established AI language-model APIs into websites, apps and '
            'internal tools. A typical example is a chatbot that answers common customer '
            'questions from your own approved content. We design a clear hand-off to a human and review '
            'responses carefully, because AI output can be wrong and needs sensible limits.',
        icon: Icons.smart_toy_outlined,
        image: AssetPaths.technology('ai_chatbots'),
        imageAlt: 'A hand holding a smartphone with a chat conversation open.',
        primaryPoints: const [
          'Website assistant for frequently asked questions',
          'Summarising long documents or enquiries',
          'Drafting replies for staff to review',
          'Searching internal knowledge in plain language',
        ],
        secondaryPoints: const [
          'Faster answers to routine questions',
          'Staff time freed for complex requests',
          'Responses grounded in your own content',
        ],
      ),
      PillarOffering(
        title: 'Flutter Development',
        tagline: 'One codebase for mobile, web and desktop.',
        description:
            'Flutter is Google\'s open-source UI toolkit for building natively compiled '
            'apps from a single codebase. We use it to deliver consistent, polished interfaces '
            'on Android, iOS and the web while keeping development and maintenance efficient.',
        icon: Icons.flutter_dash_rounded,
        image: AssetPaths.technology('flutter_development'),
        imageAlt: 'A smartphone showing a learning app in front of a computer screen with code.',
        primaryPoints: const [
          'Customer-facing mobile apps',
          'Cross-platform internal tools',
          'Responsive web apps and dashboards',
          'Prototypes to validate an idea quickly',
        ],
        secondaryPoints: const [
          'Consistent design across platforms',
          'Shared code reduces build and update effort',
          'Smooth, responsive user interfaces',
        ],
      ),
      PillarOffering(
        title: 'Web Application Development',
        tagline: 'Browser-based software, available anywhere.',
        description:
            'We build interactive web applications, including portals, booking systems, '
            'dashboards and admin panels, with secure authentication, well-structured data and interfaces '
            'that work on any modern browser without installation.',
        icon: Icons.web_rounded,
        image: AssetPaths.technology('web_applications'),
        imageAlt: 'A laptop screen showing source code for a web application.',
        primaryPoints: const [
          'Customer and partner portals',
          'Booking and scheduling systems',
          'Admin panels and operational dashboards',
          'Data entry and reporting tools',
        ],
        secondaryPoints: const [
          'Access from any device with a browser',
          'Instant updates for every user',
          'Centralised, secure data',
        ],
      ),
      PillarOffering(
        title: 'Business Process Automation',
        tagline: 'Connected workflows that run reliably.',
        description:
            'We map a process step by step, decide which parts benefit from automation '
            'and build workflows using scripts, automation platforms or custom services. Each '
            'workflow includes logging and alerts so you can see what ran and when.',
        icon: Icons.account_tree_outlined,
        image: AssetPaths.technology('process_automation'),
        imageAlt: 'Monitoring dashboards showing performance metrics on a screen.',
        primaryPoints: const [
          'Lead capture routed to the right person',
          'Invoice and payment reminders',
          'Automated report generation',
          'Form submissions synced to spreadsheets or CRMs',
        ],
        secondaryPoints: const [
          'Reduced repetitive manual effort',
          'Fewer missed follow-ups',
          'Transparent, monitored processes',
        ],
      ),
      PillarOffering(
        title: 'API Integration',
        tagline: 'Make your systems talk to each other.',
        description:
            'APIs allow separate systems to share data securely. We connect websites and '
            'apps with payment gateways, messaging services, maps, CRMs and other third-party '
            'platforms, with careful handling of authentication, errors and data mapping.',
        icon: Icons.hub_outlined,
        image: AssetPaths.technology('api_integration'),
        imageAlt: 'Network cables connected to server equipment in a data centre.',
        primaryPoints: const [
          'Payment gateway integration',
          'SMS, email and messaging notifications',
          'CRM and accounting system sync',
          'Custom APIs for your own apps',
        ],
        secondaryPoints: const [
          'No more copying data between systems',
          'Real-time information across tools',
          'Reuse services instead of rebuilding them',
        ],
      ),
      PillarOffering(
        title: 'Custom Technology Solutions',
        tagline: 'For problems that do not fit a standard category.',
        description:
            'Some challenges need a combination of technologies. We study the problem, '
            'explore options, build a small proof of concept where useful and recommend a '
            'solution only when it is practical to build and maintain.',
        icon: Icons.tune_rounded,
        image: AssetPaths.technology('custom_solutions'),
        imageAlt: 'Rows of people working on computers in a large open-plan technology office.',
        primaryPoints: const [
          'Technical feasibility studies',
          'Proof-of-concept builds',
          'Combining web, mobile, AI and automation',
          'Modernising outdated tools',
        ],
        secondaryPoints: const [
          'Lower risk before a large investment',
          'Solutions designed around your constraints',
          'Clear recommendations you can act on',
        ],
      ),
    ],
    stepsEyebrow: 'Our Approach',
    stepsHeading: 'Responsible, Practical Innovation',
    stepsLead:
        'Technology choices have long-term consequences. These principles guide every '
        'recommendation we make.',
    steps: const [
      PillarStep('Problem First', 'We define the problem before choosing any tool.', Icons.psychology_alt_outlined),
      PillarStep('Proven Tools', 'We prefer mature, documented, well-supported technology.', Icons.verified_outlined),
      PillarStep('Prototype & Test', 'We validate ideas early with small, testable builds.', Icons.science_outlined),
      PillarStep('Maintainable', 'We write code your team can understand and extend.', Icons.build_circle_outlined),
    ],
    stepsImage: AssetPaths.technology('approach'),
    stepsImageAlt: 'A team working together on laptops around a shared table.',
    note:
        'We describe technology honestly. AI tools can make mistakes, automation needs '
        'monitoring and every integration depends on third-party services. We explain these '
        'limits up front and design around them.',
    noteIcon: Icons.info_outline_rounded,
    form: PillarFormConfig(
      kind: 'technology_enquiry',
      title: 'Technology Enquiry',
      lead:
          'Describe the problem you want to solve or the idea you want to explore. We will '
          'reply with practical options.',
      optionLabel: 'Technology Area *',
      extraFieldLabel: 'Company / Organisation',
      extraFieldIcon: Icons.apartment_rounded,
      messageLabel: 'What would you like to achieve? *',
      messageHint: 'The problem, the people affected and any tools you already use.',
      submitLabel: 'Send Technology Enquiry',
      image: AssetPaths.technology('approach'),
      imageAlt: 'A team working together on laptops around a shared table.',
    ),
  );
}
