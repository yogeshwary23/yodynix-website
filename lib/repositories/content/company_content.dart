import 'package:flutter/material.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/content_models.dart';
import '../../shared/widgets/visuals/pillar_visuals.dart' show PillarArt;

class CompanyContent {
  CompanyContent._();

  // ---------------------------------------------------------------- Hero
  static const heroEyebrow = 'Digital Technology & Innovation Studio';
  static const heroDescription =
      'From innovative websites and mobile applications to intelligent AI solutions and '
      'business automation, YODYNIX transforms ideas into powerful digital experiences.';

  // --------------------------------------------------------------- Intro
  static const introHeading = 'Technology That Turns Possibilities Into Progress.';
  static const introLead =
      'Every business has a challenge worth solving and every idea has the potential to '
      'become something real. Yodynix exists to close the gap between the two.';
  static const introBody =
      'We take time to understand how a business actually works — its customers, its '
      'constraints and its goals — before recommending any technology. The result is '
      'digital work that is practical rather than decorative: websites that build trust, '
      'applications that simplify everyday operations and automation that saves real time. '
      'Alongside our client work, we offer internships that help emerging technologists '
      'build genuine, hands-on skills.';

  static const introBeliefs = [
    'We listen first and understand the business challenge.',
    'We design practical solutions, not unnecessary complexity.',
    'We combine engineering discipline with creative thinking.',
    'We help businesses build a stronger, more credible online presence.',
    'We help interns learn by building real projects.',
    'We believe in innovation with a clear purpose.',
  ];

  static const corePillars = [
    CorePillar(
      title: 'Business Solutions',
      headline: 'We Build Digital Businesses',
      description:
          'Websites, E-commerce, Mobile Apps and Custom Software that help businesses '
          'grow digitally.',
      icon: Icons.storefront_rounded,
      art: PillarArt.business,
      image: 'assets/images/pillars/business_solutions',
      imageAlt: 'A presenter leading a business meeting with laptops around the table.',
      route: AppRoutes.businessSolutions,
      actionLabel: 'Explore More',
    ),
    CorePillar(
      title: 'Technology & Innovation',
      headline: 'Turning Technology Into Possibilities',
      description:
          'AI, Automation, Flutter and modern engineering solutions for real-world '
          'challenges.',
      icon: Icons.auto_awesome_rounded,
      art: PillarArt.innovation,
      image: 'assets/images/pillars/technology_innovation',
      imageAlt: 'Software engineers writing code on large monitors.',
      route: AppRoutes.technologyInnovation,
      actionLabel: 'Explore More',
    ),
    CorePillar(
      title: 'Internship & Career Opportunities',
      headline: 'Your Journey Into Technology Starts Here',
      description:
          'Practical learning opportunities in Flutter, Web Development, UI/UX, Python, '
          'AI and Digital Marketing.',
      icon: Icons.rocket_launch_rounded,
      art: PillarArt.careers,
      image: 'assets/images/pillars/internship_careers',
      imageAlt: 'A mentor explaining work to a young intern at a laptop.',
      route: AppRoutes.internship,
      actionLabel: 'Explore More',
    ),
  ];

  // --------------------------------------------------------------- About
  static const aboutHeading = 'Building Digital Possibilities Through Technology.';
  static const aboutStory = [
    'YODYNIX is a digital technology and innovation studio focused on building meaningful '
        'digital experiences. We combine creativity, modern engineering and intelligent '
        'technology to help businesses and individuals move forward.',
    'We believe great digital work happens where three disciplines meet. Development '
        'brings reliability and structure. Creativity brings clarity and a memorable '
        'experience. Innovation brings fresh thinking about what is possible. Keeping all '
        'three in balance is how ideas become products people actually enjoy using.',
  ];
  static const whoWeAreLead =
      'A digital technology and innovation studio combining creativity, modern engineering '
      'and intelligent technology to help businesses and individuals move forward.';

  static const teamHeading = 'The People Behind YODYNIX.';
  static const teamLead =
      'Led by our founder and supported by a team that builds, plans and delivers every '
      'project.';

  static const philosophyHeading = 'Principles Behind Every Project';
  static const philosophyLead = 'Six principles that shape every project and every partnership.';

  static const processLead =
      'A clear, collaborative process that keeps you informed from the first conversation to '
      'long after launch.';

  static const vision =
      'To create meaningful digital experiences and make modern technology accessible to '
      'businesses, creators and emerging talent.';
  static const mission =
      'To transform ideas into reliable, scalable and impactful digital solutions through '
      'engineering, creativity and continuous learning.';

  static const approach =
      'We listen first, plan carefully and build iteratively — pairing thoughtful design with '
      'clean engineering and honest communication, so every solution is practical, scalable '
      'and ready to grow.';

  static const philosophy = [
    FeaturePoint(
      title: 'Innovation with Purpose',
      description: 'New technology is adopted when it solves a real problem — never just for novelty.',
      icon: Icons.lightbulb_outline_rounded,
      image: 'assets/images/about/philosophy_innovation',
      imageAlt: 'A software engineer writing code across two screens.',
    ),
    FeaturePoint(
      title: 'Quality Over Shortcuts',
      description: 'Clean code, thoughtful design and careful testing, even when no one is watching.',
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
      description: 'Technology evolves quickly; we keep learning so our clients and students benefit.',
      icon: Icons.auto_stories_outlined,
      image: 'assets/images/about/philosophy_learning',
      imageAlt: 'Two people learning together at a laptop in a bright workspace.',
    ),
    FeaturePoint(
      title: 'Long-Term Partnerships',
      description: 'We aim to remain a dependable technology partner long after launch day.',
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
      description: "Understand the client's goals, business and requirements.",
      icon: Icons.travel_explore_rounded,
      activities: ['Goal workshops', 'Audience understanding', 'Requirement mapping'],
      image: 'assets/images/about/process_discover',
      imageAlt: 'Two colleagues discussing goals beside a laptop in a modern office.',
    ),
    ProcessStep(
      number: '02',
      title: 'Plan',
      description: 'Choose the right technology, scope and project roadmap.',
      icon: Icons.insights_rounded,
      activities: ['Technology selection', 'Scope & milestones', 'Architecture planning'],
      image: 'assets/images/about/process_plan',
      imageAlt: 'A team organising a roadmap with sticky notes on a glass wall.',
    ),
    ProcessStep(
      number: '03',
      title: 'Design',
      description: 'Create intuitive interfaces and user experiences.',
      icon: Icons.design_services_rounded,
      activities: ['User journeys', 'Wireframes', 'Visual design & prototypes'],
      image: 'assets/images/about/process_design',
      imageAlt: 'Hand-drawn mobile app wireframes being sketched on paper.',
    ),
    ProcessStep(
      number: '04',
      title: 'Develop',
      description: 'Build reliable and scalable digital solutions.',
      icon: Icons.code_rounded,
      activities: ['Iterative builds', 'Integrations', 'Regular progress demos'],
      image: 'assets/images/about/process_develop',
      imageAlt: "Application source code on a developer's screen.",
    ),
    ProcessStep(
      number: '05',
      title: 'Test',
      description: 'Validate functionality, performance and usability.',
      icon: Icons.fact_check_rounded,
      activities: ['Functional testing', 'Device checks', 'Performance review'],
      image: 'assets/images/about/process_test',
      imageAlt: 'An engineer checking test output across several monitors.',
    ),
    ProcessStep(
      number: '06',
      title: 'Launch',
      description: 'Deploy confidently with a smooth, well-prepared release.',
      icon: Icons.rocket_launch_rounded,
      activities: ['Deployment', 'Final checks', 'Handover & training'],
      image: 'assets/images/about/process_launch',
      imageAlt: 'A presenter walking colleagues through a finished project.',
    ),
    ProcessStep(
      number: '07',
      title: 'Support',
      description: 'Keep the product secure, updated and improving after launch.',
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
          'We build with current, well-supported tools such as Flutter, modern web '
          'frameworks and proven AI APIs, so your product starts on solid ground.',
      icon: Icons.memory_rounded,
      color: AppColors.primary,
      image: 'assets/images/why_choose/modern_technology',
      imageAlt: 'Software developers working at modern computers in a bright open-plan office.',
    ),
    FeaturePoint(
      title: 'Creative Problem Solving',
      description:
          'We start with the problem, not the technology, and explore options until '
          'the solution genuinely fits the way you work.',
      icon: Icons.psychology_alt_outlined,
      color: AppColors.accent,
      image: 'assets/images/why_choose/creative_problem_solving',
      imageAlt: 'Two developers discussing a technical solution in front of code on their screens.',
    ),
    FeaturePoint(
      title: 'User-Focused Design',
      description:
          'Interfaces are shaped around real users — clear, accessible and pleasant '
          'to use on every screen size.',
      icon: Icons.touch_app_outlined,
      color: AppColors.iceBlue,
      image: 'assets/images/why_choose/user_focused_design',
      imageAlt: 'A designer sketching interface wireframes beside a laptop showing a design.',
    ),
    FeaturePoint(
      title: 'Scalable Solutions',
      description:
          'Clean architecture and maintainable code mean your product can grow with '
          'new features, users and integrations over time.',
      icon: Icons.stacked_line_chart_rounded,
      color: AppColors.primary,
      image: 'assets/images/why_choose/scalable_solutions',
      imageAlt: 'Engineers mapping out a system diagram on a whiteboard.',
    ),
    FeaturePoint(
      title: 'Practical Innovation',
      description:
          'New ideas such as AI and automation are adopted where they solve a real '
          'problem — never just for novelty.',
      icon: Icons.lightbulb_outline_rounded,
      color: AppColors.accent,
      image: 'assets/images/why_choose/practical_innovation',
      imageAlt: 'An engineering team reviewing work on a laptop beside automation equipment.',
    ),
    FeaturePoint(
      title: 'End-to-End Development',
      description:
          'From discovery and design to development, launch and support, one team '
          'stays with your project throughout.',
      icon: Icons.all_inclusive_rounded,
      color: AppColors.iceBlue,
      image: 'assets/images/why_choose/end_to_end_development',
      imageAlt: 'A project team working at laptops in front of a planning board of sticky notes.',
    ),
  ];

  // ----------------------------------------------------------- Final CTA
  static const ctaHeading = "Have an Idea? Let's Build Something Powerful.";
  static const ctaDescription = "Let's turn your next idea into a meaningful digital experience.";
}
