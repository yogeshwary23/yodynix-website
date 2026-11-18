import 'package:flutter/material.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/content_models.dart';
import '../../shared/widgets/visuals/pillar_visuals.dart' show PillarArt;

class CompanyContent {
  CompanyContent._();

  // ---------------------------------------------------------------- Hero
  static const heroEyebrow = 'Technology. Intelligence. Innovation.';
  // Explicit breaks give the headline its three-line shape at every width.
  static const heroHeadlineLead = 'We Build\n';
  static const heroHeadlineAccent = 'Intelligent';
  static const heroHeadlineTail = ' Digital\nExperiences.';
  static const heroDescription =
      'Transforming ideas into powerful digital products through technology, '
      'intelligence and innovation.';

  // --------------------------------------------------------------- Intro
  static const introHeading = 'Technology That Turns Possibilities Into Progress.';
  static const introLead =
      'Every business has a problem worth solving, and most ideas can become something '
      'real. YODYNIX works in the space between the two.';
  static const introBody =
      'Before recommending any technology, we learn how a business really works: its '
      'customers, its constraints and its goals. That keeps the work practical. Websites '
      'earn trust, applications simplify daily operations and automation gives time back '
      'to the team. Alongside client work, our internships give emerging technologists '
      'real, hands-on experience.';

  static const introBeliefs = [
    'Understand the business challenge before proposing a solution.',
    'Keep solutions practical and free of needless complexity.',
    'Pair engineering discipline with creative thinking.',
    'Give every business a stronger, more credible online presence.',
    'Teach interns by having them build real projects.',
    'Adopt new ideas only when they serve a clear purpose.',
  ];

  static const corePillars = [
    CorePillar(
      title: 'Business Solutions',
      headline: 'We Build Digital Businesses',
      description:
          'Websites, online stores, mobile apps and custom software built to help '
          'businesses grow.',
      icon: Icons.storefront_rounded,
      art: PillarArt.business,
      image: 'assets/images/pillars/business_solutions',
      imageAlt: 'A presenter leading a business meeting with laptops around the table.',
      artwork: 'assets/images/renders/overlay_business',
      artworkAlt: 'A floating glass website with gold product tiles beside a platinum phone.',
      route: AppRoutes.businessSolutions,
      actionLabel: 'Explore More',
    ),
    CorePillar(
      title: 'Technology & Innovation',
      headline: 'Modern Engineering With a Purpose',
      description:
          'AI, automation and Flutter applied to the real problems businesses face '
          'every day.',
      icon: Icons.auto_awesome_rounded,
      art: PillarArt.innovation,
      image: 'assets/images/pillars/technology_innovation',
      imageAlt: 'Software engineers writing code on large monitors.',
      artwork: 'assets/images/renders/overlay_innovation',
      artworkAlt: 'A platinum processor with a gold AI chip and gold circuit traces.',
      route: AppRoutes.technologyInnovation,
      actionLabel: 'Explore More',
    ),
    CorePillar(
      title: 'Internship & Career Opportunities',
      headline: 'Learn by Building Real Projects',
      description:
          'Mentored internships in Flutter, web development, UI/UX, Python, AI and '
          'digital marketing.',
      icon: Icons.rocket_launch_rounded,
      art: PillarArt.careers,
      image: 'assets/images/pillars/internship_careers',
      imageAlt: 'A mentor explaining work to a young intern at a laptop.',
      artwork: 'assets/images/renders/overlay_careers',
      artworkAlt: 'A gold path rising through glass beads to a gold sphere ringed in platinum.',
      artworkOnLeft: true,
      route: AppRoutes.internship,
      actionLabel: 'Explore More',
    ),
  ];

  // --------------------------------------------------------------- About
  /// Illustrative stock photograph (Unsplash) beside the homepage "Who We
  /// Are" copy; not YODYNIX staff, so its description stays generic.
  static const whoWeArePhoto = 'assets/images/about/who_we_are';
  static const whoWeArePhotoAlt = 'Developers working on laptops around a shared table.';
  static const aboutHeading = 'A Studio Built Around Practical Technology.';
  static const aboutStory = [
    'YODYNIX is a digital technology and innovation studio. We bring creativity, modern '
        'engineering and intelligent technology together to build digital products that '
        'help businesses and individuals move forward.',
    'Good digital work sits where three disciplines meet. Development gives a product '
        'structure and reliability. Creativity makes it clear and memorable. Innovation '
        'keeps asking what else is possible. When the three stay in balance, ideas turn '
        'into products people enjoy using.',
  ];
  static const whoWeAreLead =
      'We design, build and support websites, apps and intelligent tools for businesses, '
      'creators and the people who run them.';

  static const teamHeading = 'The People Behind YODYNIX.';
  static const teamLead = 'Our founder leads the team that plans, builds and delivers every YODYNIX project.';

  static const philosophyHeading = 'Principles Behind Every Project';
  static const philosophyLead = 'Six principles that guide how we build, communicate and work with clients.';

  static const processLead =
      'A clear, collaborative process that keeps you informed from the first conversation '
      'until well after launch.';

  static const vision =
      'To create meaningful digital experiences and make modern technology accessible to '
      'businesses, creators and emerging talent.';
  static const mission =
      'To transform ideas into reliable, scalable and impactful digital solutions through '
      'engineering, creativity and continuous learning.';

  static const approach =
      'We listen first, plan carefully and build in small iterations. Thoughtful design, '
      'clean engineering and honest communication keep each solution practical, scalable '
      'and ready to grow.';

  static const philosophy = [
    FeaturePoint(
      title: 'Innovation with Purpose',
      description: 'We adopt new technology when it solves a real problem, not because it is new.',
      icon: Icons.lightbulb_outline_rounded,
      image: 'assets/images/about/philosophy_innovation',
      imageAlt: 'A software engineer writing code across two screens.',
    ),
    FeaturePoint(
      title: 'Quality Over Shortcuts',
      description: 'Clean code, thoughtful design and careful testing, including the parts no one sees.',
      icon: Icons.verified_outlined,
      image: 'assets/images/about/philosophy_quality',
      imageAlt: 'Two developers reviewing code together on a laptop.',
    ),
    FeaturePoint(
      title: 'Transparent Communication',
      description: 'Clear timelines, honest updates and plain-language explanations at every stage.',
      icon: Icons.forum_outlined,
      image: 'assets/images/about/philosophy_communication',
      imageAlt: 'A technology team meeting with a client around a conference table.',
    ),
    FeaturePoint(
      title: 'Practical Problem Solving',
      description: 'Solutions shaped around how people really work, not around a template.',
      icon: Icons.handyman_outlined,
      image: 'assets/images/about/philosophy_problem_solving',
      imageAlt: 'A development team collaborating on a project at a shared table.',
    ),
    FeaturePoint(
      title: 'Continuous Learning',
      description: 'Technology changes quickly. We keep learning so our clients and students benefit.',
      icon: Icons.auto_stories_outlined,
      image: 'assets/images/about/philosophy_learning',
      imageAlt: 'Two people learning together at a laptop in a bright workspace.',
    ),
    FeaturePoint(
      title: 'Long-Term Partnerships',
      description: 'We aim to stay a dependable technology partner long after launch day.',
      icon: Icons.handshake_outlined,
      image: 'assets/images/about/philosophy_partnerships',
      imageAlt: 'Two professionals shaking hands across a desk after a meeting.',
    ),
  ];

  // ------------------------------------------------------------- Process
  static const processHeading = 'From First Idea To Final Experience.';
  static const processSteps = [
    ProcessStep(
      number: '01',
      title: 'Discover',
      description: 'Learn how your business works, what you need and what success looks like.',
      icon: Icons.travel_explore_rounded,
      activities: ['Goal workshops', 'Audience understanding', 'Requirement mapping'],
      image: 'assets/images/about/process_discover',
      imageAlt: 'Two colleagues discussing goals beside a laptop in a modern office.',
    ),
    ProcessStep(
      number: '02',
      title: 'Plan',
      description: 'Agree the scope, choose the technology and set a realistic roadmap.',
      icon: Icons.insights_rounded,
      activities: ['Technology selection', 'Scope & milestones', 'Architecture planning'],
      image: 'assets/images/about/process_plan',
      imageAlt: 'A team organising a roadmap with sticky notes on a glass wall.',
    ),
    ProcessStep(
      number: '03',
      title: 'Design',
      description: 'Shape the user journeys and interfaces before any code is written.',
      icon: Icons.design_services_rounded,
      activities: ['User journeys', 'Wireframes', 'Visual design & prototypes'],
      image: 'assets/images/about/process_design',
      imageAlt: 'Hand-drawn mobile app wireframes being sketched on paper.',
    ),
    ProcessStep(
      number: '04',
      title: 'Develop',
      description: 'Build in short cycles, with working progress you can review.',
      icon: Icons.code_rounded,
      activities: ['Iterative builds', 'Integrations', 'Regular progress demos'],
      image: 'assets/images/about/process_develop',
      imageAlt: "Application source code on a developer's screen.",
    ),
    ProcessStep(
      number: '05',
      title: 'Test',
      description: 'Check features, performance and usability across real devices.',
      icon: Icons.fact_check_rounded,
      activities: ['Functional testing', 'Device checks', 'Performance review'],
      image: 'assets/images/about/process_test',
      imageAlt: 'An engineer checking test output across several monitors.',
    ),
    ProcessStep(
      number: '06',
      title: 'Launch',
      description: 'Release with final checks complete and your team ready to take over.',
      icon: Icons.rocket_launch_rounded,
      activities: ['Deployment', 'Final checks', 'Handover & training'],
      image: 'assets/images/about/process_launch',
      imageAlt: 'A presenter walking colleagues through a finished project.',
    ),
    ProcessStep(
      number: '07',
      title: 'Support',
      description: 'Keep the product secure, up to date and improving after launch.',
      icon: Icons.support_agent_rounded,
      activities: ['Maintenance', 'Updates', 'Ongoing improvements'],
    ),
  ];

  // ---------------------------------------------------------- Why choose
  static const whyChooseHeading = 'More Than Development. A Technology Partnership.';
  static const whyChoose = [
    FeaturePoint(
      title: 'Modern Technology',
      description:
          'Flutter, modern web frameworks and proven AI APIs: current, well-supported '
          'tools that give your product a solid foundation.',
      icon: Icons.memory_rounded,
      color: AppColors.accent,
      image: 'assets/images/why_choose/modern_technology',
      imageAlt: 'Software developers working at modern computers in a bright open-plan office.',
    ),
    FeaturePoint(
      title: 'Creative Problem Solving',
      description:
          'The problem comes first and the technology second. We explore the options '
          'until the solution fits the way you work.',
      icon: Icons.psychology_alt_outlined,
      color: AppColors.accent,
      image: 'assets/images/why_choose/creative_problem_solving',
      imageAlt: 'Two developers discussing a technical solution in front of code on their screens.',
    ),
    FeaturePoint(
      title: 'User-Focused Design',
      description:
          'Interfaces are designed around real users, so they stay clear, accessible '
          'and easy to use on any screen size.',
      icon: Icons.touch_app_outlined,
      color: AppColors.charcoal,
      image: 'assets/images/why_choose/user_focused_design',
      imageAlt: 'A designer sketching interface wireframes beside a laptop showing a design.',
    ),
    FeaturePoint(
      title: 'Scalable Solutions',
      description:
          'Clean architecture and maintainable code leave room for new features, more '
          'users and further integrations.',
      icon: Icons.stacked_line_chart_rounded,
      color: AppColors.accent,
      image: 'assets/images/why_choose/scalable_solutions',
      imageAlt: 'Engineers mapping out a system diagram on a whiteboard.',
    ),
    FeaturePoint(
      title: 'Practical Innovation',
      description:
          'AI and automation go where they remove real work or solve a genuine '
          'problem, and nowhere else.',
      icon: Icons.lightbulb_outline_rounded,
      color: AppColors.accent,
      image: 'assets/images/why_choose/practical_innovation',
      imageAlt: 'An engineering team reviewing work on a laptop beside automation equipment.',
    ),
    FeaturePoint(
      title: 'End-to-End Development',
      description:
          'One team stays with your project through discovery, design, development, '
          'launch and support.',
      icon: Icons.all_inclusive_rounded,
      color: AppColors.charcoal,
      image: 'assets/images/why_choose/end_to_end_development',
      imageAlt: 'A project team working at laptops in front of a planning board of sticky notes.',
    ),
  ];

  // ----------------------------------------------------------- Final CTA
  static const ctaHeading = "Have an Idea? Let's Build Something Powerful.";
  static const ctaDescription = "Tell us what you have in mind and we'll help shape it into a working product.";
}
