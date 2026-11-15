import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/content_models.dart';

class ServicesContent {
  ServicesContent._();

  static const heading = 'Digital Solutions Built Around Your Vision.';
  static const lead =
      'Ten service areas held to one standard. A single landing page or a complete '
      'digital system, each engagement is planned around your goals and delivered with '
      'care.';

  static const services = [
    ServiceOffering(
      id: 'website_development',
      title: 'Website Development',
      summary:
          'Fast, responsive and search-friendly websites that present your business '
          'with clarity and credibility.',
      description:
          'Your website is often the first conversation a customer has with your '
          'business. We build sites that load quickly, look polished on every screen and '
          'lead visitors to take action. The work ranges from a simple landing page to a '
          'full custom web application, and includes redesigns and ongoing maintenance.',
      capabilities: [
        'Business Websites',
        'Corporate Websites',
        'Portfolio Websites',
        'Landing Pages',
        'Responsive Websites',
        'Custom Web Applications',
        'Website Redesign',
        'SEO-friendly Development',
        'Website Maintenance',
      ],
      icon: Icons.language_rounded,
      color: AppColors.accent,
      imageAlt: 'Modern business website interface displayed on a laptop screen',
    ),
    ServiceOffering(
      id: 'ecommerce_development',
      title: 'E-commerce Development',
      summary:
          'Online stores with smooth product discovery, secure checkout and simple '
          'back-office management.',
      description:
          'An online store should be easy to buy from and easy to run. We build the '
          'product catalogue, cart and checkout, connect payments, and set up inventory '
          'and order management, with every step designed to earn trust and convert.',
      capabilities: [
        'Online Stores',
        'Product Management',
        'Shopping Cart',
        'Checkout',
        'Payment Integration',
        'Inventory Management',
        'Order Management',
      ],
      icon: Icons.shopping_bag_outlined,
      color: AppColors.accent,
      imageAlt: 'Online storefront interface with product cards and a shopping cart',
    ),
    ServiceOffering(
      id: 'mobile_app_development',
      title: 'Mobile Application Development',
      summary:
          'Polished Android and iOS applications that keep your customers and teams '
          'connected on the go.',
      description:
          'Mobile apps should feel natural to use and stay easy to maintain. With '
          'cross-platform tools such as Flutter, we ship Android and iOS apps from one '
          'codebase. Typical uses include bookings, customer engagement and internal '
          'operations, connected to your systems through secure APIs.',
      capabilities: [
        'Android Applications',
        'iOS Applications',
        'Business Applications',
        'Booking Applications',
        'Customer Applications',
        'Cross-platform Apps',
        'API Integrations',
      ],
      icon: Icons.phone_iphone_rounded,
      color: AppColors.violet,
      imageAlt: 'Smartphones displaying modern mobile application screens',
    ),
    ServiceOffering(
      id: 'flutter_development',
      title: 'Flutter Development',
      summary:
          'One Flutter codebase for Android, iOS, web and desktop. Consistent, fast and '
          'easier to maintain.',
      description:
          'Flutter runs one well-structured codebase natively on mobile, web and '
          'desktop. Our Flutter apps use clean architecture, responsive layouts and smooth '
          'animation, and connect to your APIs and backend services. We also extend and '
          'improve existing Flutter projects.',
      capabilities: [
        'Cross-platform Apps',
        'Flutter Web',
        'Flutter Desktop',
        'Responsive UI',
        'State Management',
        'API & Backend Integration',
        'Existing App Improvements',
      ],
      icon: Icons.flutter_dash,
      color: AppColors.accent,
      imageAlt: 'Flutter code editor rendering the same interface on web, phone and desktop',
    ),
    ServiceOffering(
      id: 'custom_software_development',
      title: 'Custom Software Development',
      summary:
          'Tailored business systems, dashboards and portals that fit the way your '
          'organisation really works.',
      description:
          'Off-the-shelf tools rarely fit perfectly. We build CRMs, management systems, '
          'admin dashboards, portals and workflow tools around your own processes, so '
          'manual effort drops and you can see clearly how your operations are running.',
      capabilities: [
        'CRM Systems',
        'Business Management Systems',
        'Admin Dashboards',
        'Custom Portals',
        'Internal Business Applications',
        'Workflow Systems',
      ],
      icon: Icons.developer_board_rounded,
      color: AppColors.primaryDeep,
      imageAlt: 'Software development workspace with code editor and system architecture',
    ),
    ServiceOffering(
      id: 'ai_solutions_chatbots',
      title: 'AI Solutions & Chatbots',
      summary:
          'AI assistants and chatbots that answer questions, guide customers and '
          'support your team around the clock.',
      description:
          'AI earns its place when it is practical. We build chatbots that answer from '
          'your own information, add features such as smart search, summaries and writing '
          'help to your applications, and integrate proven AI APIs. Every assistant is '
          'implemented responsibly, with a clear hand-off to a person.',
      capabilities: [
        'AI Chatbots',
        'Website & WhatsApp Assistants',
        'Knowledge-based Q&A',
        'AI API Integration',
        'Intelligent App Features',
      ],
      icon: Icons.smart_toy_outlined,
      color: AppColors.accent,
      imageAlt: 'AI assistant chat window beside its knowledge sources',
    ),
    ServiceOffering(
      id: 'business_automation',
      title: 'Business Automation',
      summary:
          'Automated workflows that remove repetitive tasks and keep your tools in '
          'sync.',
      description:
          'Hours disappear into copying data, sending reminders and updating '
          'spreadsheets. We map those processes and automate them by connecting your forms, '
          'CRM, email, scheduling and reporting, so the work keeps moving without the manual '
          'effort.',
      capabilities: [
        'Workflow Automation',
        'Email & Notification Flows',
        'CRM & Data Sync',
        'Scheduling Automation',
        'Report Generation',
        'System Integrations',
      ],
      icon: Icons.settings_suggest_outlined,
      color: AppColors.mint,
      imageAlt: 'Automation hub connecting customer chat, scheduling, email and CRM tasks',
    ),
    ServiceOffering(
      id: 'digital_marketing',
      title: 'Digital Marketing',
      summary:
          'Targeted campaigns, SEO and performance analysis that help the right '
          'customers find you.',
      description:
          'A good product still needs to be found. We plan and run campaigns on '
          'Instagram, Facebook and Google, improve your search visibility and build '
          'lead-generation funnels. Performance is reviewed regularly, so the budget goes '
          'where it makes the most difference.',
      capabilities: [
        'Instagram Marketing',
        'Facebook Advertising',
        'Google Advertising',
        'Lead Generation',
        'SEO',
        'Campaign Management',
        'Performance Analysis',
      ],
      icon: Icons.campaign_outlined,
      color: AppColors.rose,
      imageAlt: 'Marketing analytics dashboard with campaign performance charts',
    ),
    ServiceOffering(
      id: 'ui_ux_design',
      title: 'UI/UX Design',
      summary:
          'Research-led interface design that makes digital products intuitive and '
          'enjoyable to use.',
      description:
          'Design is how a product feels to use. We research your users, map their '
          'journeys and turn what we learn into wireframes, interactive prototypes and '
          'finished interfaces. A design system then keeps every future screen consistent.',
      capabilities: ['User Research', 'Wireframes', 'Prototypes', 'Interface Design', 'User Journey', 'Design Systems'],
      icon: Icons.draw_outlined,
      color: AppColors.accent,
      imageAlt: 'Interface design workspace with wireframes, prototypes and colour palette',
    ),
    ServiceOffering(
      id: 'branding_digital_presence',
      title: 'Branding & Digital Presence',
      summary:
          'A distinctive identity and a consistent presence across your website and '
          'social channels.',
      description:
          'A strong brand helps people remember you and trust you. We design logos, '
          'full brand identities and marketing creatives, and set up consistent social '
          'media profiles and content. Clear brand guidelines keep your business looking the '
          'same wherever it appears.',
      capabilities: [
        'Logo Design',
        'Brand Identity',
        'Marketing Creatives',
        'Social Media Profiles & Content',
        'Brand Guidelines',
        'Online Presence Setup',
      ],
      icon: Icons.auto_fix_high_outlined,
      color: AppColors.charcoalNavy,
      imageAlt: 'Brand identity board with colour swatches, typography and stationery',
    ),
  ];

  /// Options for the enquiry form's "Service Required" field.
  static List<String> get enquiryOptions => [...services.map((s) => s.title), internshipEnquiry, 'Other / Not sure yet'];

  static const internshipEnquiry = 'Internship Enquiry';
}
