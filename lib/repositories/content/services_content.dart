import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/content_models.dart';

class ServicesContent {
  ServicesContent._();

  static const heading = 'Digital Solutions Built Around Your Vision.';
  static const lead =
      'Ten focused service areas, one consistent standard. Whether you need a single '
      'landing page or a complete digital system, every engagement is planned around your '
      'goals and delivered with care.';

  static const services = [
    ServiceOffering(
      id: 'website_development',
      title: 'Website Development',
      summary:
          'Fast, responsive and search-friendly websites that present your business '
          'with clarity and credibility.',
      description:
          'Your website is often the first conversation a customer has with your '
          'business. We design and build websites that load quickly, look polished on every '
          'screen and guide visitors toward meaningful action — from a simple landing page to '
          'a complete custom web application, plus redesigns and ongoing maintenance.',
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
      color: AppColors.primary,
      imageAlt: 'Modern business website interface displayed on a laptop screen',
    ),
    ServiceOffering(
      id: 'ecommerce_development',
      title: 'E-commerce Development',
      summary:
          'Online stores with smooth product discovery, secure checkout and simple '
          'back-office management.',
      description:
          'We build online stores that make buying easy for customers and running '
          'the shop easy for you. From product catalogues and carts to payment integration, '
          'inventory and order management, every part of the storefront is designed for '
          'trust and conversion.',
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
          'We create mobile applications that feel natural to use and are built to '
          'last. Using cross-platform technology such as Flutter, we deliver Android and iOS '
          'apps from a single, maintainable codebase — for bookings, customer engagement, '
          'internal operations and more, with secure API integrations.',
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
          'One Flutter codebase for Android, iOS, web and desktop — consistent, fast '
          'and easier to maintain.',
      description:
          'Flutter lets a single, well-structured codebase run natively on mobile, '
          'web and desktop. We build Flutter applications with clean architecture, '
          'responsive layouts and smooth animations, integrate them with your APIs and '
          'backend services, and help you extend or improve existing Flutter projects.',
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
      color: AppColors.sky,
      imageAlt: 'Flutter code editor rendering the same interface on web, phone and desktop',
    ),
    ServiceOffering(
      id: 'custom_software_development',
      title: 'Custom Software Development',
      summary:
          'Tailored business systems, dashboards and portals that fit the way your '
          'organisation really works.',
      description:
          'Off-the-shelf tools rarely fit perfectly. We design and develop custom '
          'software — CRMs, management systems, admin dashboards, portals and workflow tools — '
          'that match your processes, reduce manual effort and give you clear visibility of '
          'your operations.',
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
          'Artificial intelligence is most valuable when it is practical. We build '
          'AI chatbots that answer from your own information, add intelligent features such '
          'as smart search, summaries and content assistance to your applications, and '
          'integrate proven AI APIs — implemented responsibly, with a clear hand-off to a person.',
      capabilities: [
        'AI Chatbots',
        'Website & WhatsApp Assistants',
        'Knowledge-based Q&A',
        'AI API Integration',
        'Intelligent App Features',
      ],
      icon: Icons.smart_toy_outlined,
      color: AppColors.primary,
      imageAlt: 'AI assistant chat window beside its knowledge sources',
    ),
    ServiceOffering(
      id: 'business_automation',
      title: 'Business Automation',
      summary:
          'Automated workflows that remove repetitive tasks and keep your tools in '
          'sync.',
      description:
          'Many hours are lost to copying data, sending reminders and updating '
          'spreadsheets. We map your processes and automate them — connecting forms, CRMs, '
          'email, scheduling and reporting — so work moves forward reliably with less '
          'manual effort.',
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
          'Great products deserve to be discovered. We plan and manage campaigns '
          'across Instagram, Facebook and Google, strengthen your search visibility and build '
          'lead-generation funnels — then review performance data regularly so budgets are '
          'spent where they make the most difference.',
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
          'Good design is how a product feels to use. We research your users, map '
          'their journeys and turn insights into wireframes, interactive prototypes and '
          'polished interfaces — supported by design systems that keep every future screen '
          'consistent.',
      capabilities: ['User Research', 'Wireframes', 'Prototypes', 'Interface Design', 'User Journey', 'Design Systems'],
      icon: Icons.draw_outlined,
      color: AppColors.sky,
      imageAlt: 'Interface design workspace with wireframes, prototypes and colour palette',
    ),
    ServiceOffering(
      id: 'branding_digital_presence',
      title: 'Branding & Digital Presence',
      summary:
          'A distinctive identity and a consistent presence across your website and '
          'social channels.',
      description:
          'A strong brand helps people remember you and trust you. We create logos '
          'and complete brand identities, design marketing creatives, and set up consistent '
          'social media profiles and content — documented in clear brand guidelines so your '
          'business looks the same everywhere it appears.',
      capabilities: [
        'Logo Design',
        'Brand Identity',
        'Marketing Creatives',
        'Social Media Profiles & Content',
        'Brand Guidelines',
        'Online Presence Setup',
      ],
      icon: Icons.auto_fix_high_outlined,
      color: AppColors.sun,
      imageAlt: 'Brand identity board with colour swatches, typography and stationery',
    ),
  ];

  /// Options for the enquiry form's "Service Required" field.
  static List<String> get enquiryOptions => [...services.map((s) => s.title), internshipEnquiry, 'Other / Not sure yet'];

  static const internshipEnquiry = 'Internship Enquiry';
}
