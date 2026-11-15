import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../../models/internship_program.dart';
import '../../models/pillar_page.dart' show PillarStep;

/// Every piece of internship copy in one editable place: landing-page text,
/// the learning model, opportunity types, roadmap, FAQs and the seven
/// programmes. Unconfirmed terms stay `null` (see `ProgramTerms`).
///
/// Project examples are illustrative learning briefs, not completed YODYNIX
/// client work, and are labelled as such wherever they appear.
class InternshipContent {
  InternshipContent._();

  static InternshipProgram? bySlug(String slug) {
    for (final p in programs) {
      if (p.slug == slug) return p;
    }
    return null;
  }

  // ------------------------------------------------------------- Hero
  static const badge = 'Internship & Careers';
  static const heading = 'Start Your Career Journey With YODYNIX.';
  static const description =
      'Explore practical learning opportunities, work on technology-focused projects and '
      'develop skills that help prepare you for the professional world.';
  static const highlights = [
    (Icons.work_outline_rounded, 'Technology-focused project work'),
    (Icons.groups_2_outlined, 'Collaborative, mentor-guided learning'),
    (Icons.trending_up_rounded, 'Professional workflow exposure'),
  ];
  static final heroImage = AssetPaths.internshipCareers('hero');
  static const heroImageAlt = 'A small team discussing project plans together in a modern office.';
  static const bannerImageAlt = 'Two developers reviewing code together on a desktop monitor.';

  /// Shown wherever programme terms appear.
  static const disclaimer =
      'Programme details such as mode, fees, stipend and certificate policy are confirmed '
      'for each opportunity before it begins. Taking part does not guarantee employment or placement.';

  // --------------------------------------------------------- Benefits
  static const benefits = [
    (
      Icons.construction_rounded,
      'Hands-On Project Work',
      'Spend most of your time building: exercises, assignments and a practical project in your chosen domain.',
    ),
    (
      Icons.support_agent_rounded,
      'Guidance When You Need It',
      'Get technical direction, doubt-solving and feedback, with the level of mentoring set by your programme.',
    ),
    (
      Icons.account_tree_outlined,
      'Professional Workflows',
      'Experience how technology teams plan tasks, use version control, review work and iterate.',
    ),
    (
      Icons.folder_special_outlined,
      'Work You Can Show',
      'Finish with project work you can explain and present, built and refined through review.',
    ),
  ];

  // --------------------------------------------------- Learning model
  static const learningModelLead =
      'YODYNIX internships combine two complementary ways of learning. How much of each '
      'you receive depends on the selected programme and the opportunity you join.';

  static final mentorImage = AssetPaths.internshipCareers('mentor_guided');
  static const mentorImageAlt = 'A mentor guiding two learners as they work at their computers.';
  static const mentorTitle = 'Mentor-Guided Learning';
  static const mentorSummary =
      'Structured learning with technical guidance, so you understand not only what to build '
      'but why it is built that way.';
  static const mentorPoints = [
    'Structured learning path for the selected programme',
    'Technical guidance on concepts and tools',
    'Curated learning resources',
    'Doubt-solving and constructive feedback',
    'Progress reviews, according to the selected programme',
  ];

  static final projectImage = AssetPaths.internshipCareers('project_based');
  static const projectImageAlt = 'Three learners working together on a project around a laptop.';
  static const projectTitle = 'Practical Project-Based Learning';
  static const projectSummary =
      'Learning by doing: you apply each concept in practical work and improve it through '
      'review, the way real projects evolve.';
  static const projectPoints = [
    'Hands-on development from the early stages',
    'Practical assignments that build on each other',
    'Realistic project scenarios and requirements',
    'Implementing a complete project',
    'Review, refactoring and improvement',
  ];

  // ---------------------------------------------- Opportunity types
  static const durationTitle = 'Flexible Duration';
  static const durationText =
      'There is no fixed length. The duration depends on the selected programme, your learning '
      'progress and the arrangement agreed for the specific opportunity.';

  static const freeTitle = 'Free Internship Opportunities';
  static const freeText =
      'Learning-focused opportunities offered without a fee, when available. The scope, '
      'mentoring and conditions are shared with you for each opportunity.';
  static const paidTitle = 'Paid Internship Opportunities';
  static const paidText =
      'Opportunities with paid terms, when available. Whether this means a stipend or a programme '
      'fee, and the amount involved, is confirmed for each opportunity before you commit.';
  static const opportunityNote =
      'Availability and conditions depend on the specific opportunity. Nothing is final '
      'until it is confirmed with you directly.';

  // ------------------------------------------------------- Roadmap
  static const roadmap = [
    PillarStep(
      'Introduction & Orientation',
      'Understand the selected technology and the programme expectations.',
      Icons.explore_outlined,
    ),
    PillarStep('Fundamentals', 'Learn the essential concepts and tools.', Icons.menu_book_rounded),
    PillarStep('Guided Practice', 'Complete exercises with appropriate mentor guidance.', Icons.support_agent_rounded),
    PillarStep('Practical Project', 'Build a project based on the selected programme.', Icons.construction_rounded),
    PillarStep('Review & Improvement', 'Review the project and improve implementation quality.', Icons.rate_review_outlined),
    PillarStep('Final Evaluation', 'Present the completed work and receive feedback.', Icons.co_present_outlined),
  ];

  // ----------------------------------------------------------- FAQs
  static const faqs = [
    Faq(
      'Who can apply for a YODYNIX internship?',
      'Students and early-career learners who want practical experience in one of our seven domains. Specific '
          'eligibility for each opportunity is shared when it opens.',
    ),
    Faq(
      'How long does an internship last?',
      'The duration is flexible. It depends on the programme you choose, your learning progress and the arrangement '
          'agreed for that opportunity.',
    ),
    Faq(
      'Are internships free or paid?',
      'Both types may be offered. Whether an opportunity is free or paid, and its exact terms, depends on the specific '
          'opportunity and is confirmed with you before it begins.',
    ),
    Faq(
      'Do I receive a certificate?',
      'Certificate policy is confirmed for each opportunity. We do not promise a certificate until it has been '
          'officially confirmed for your programme.',
    ),
    Faq(
      'Does the internship guarantee a job or placement?',
      'No. Our internships focus on practical learning and project experience. They do not guarantee employment or '
          'placement.',
    ),
    Faq(
      'What happens after I register my interest?',
      'Your details help us understand your goals and preferred programme. When a suitable opportunity is available, '
          'we contact you with its details so you can decide.',
    ),
  ];

  // ------------------------------------------------------- Form text
  static final applicationImage = AssetPaths.internshipCareers('application');
  static const applicationImageAlt = 'A mentor sketching ideas on a whiteboard while a colleague takes notes.';
  static const applicationLead =
      'Tell us about yourself and the programme you are interested in. We use these '
      'details only to respond to you about internship opportunities.';

  static const educationOptions = [
    'Diploma student',
    'Undergraduate student',
    'Postgraduate student',
    'Recent graduate',
    'Working professional',
    'Other',
  ];

  // ------------------------------------------------------- Programmes
  static const programs = <InternshipProgram>[
    // ------------------------------------------------------- Flutter
    InternshipProgram(
      slug: 'flutter-development',
      title: 'Flutter Development Internship',
      shortTitle: 'Flutter Development',
      icon: Icons.flutter_dash_rounded,
      description: 'Learn to build modern cross-platform mobile and web applications using Flutter.',
      introduction: [
        'Flutter lets one Dart codebase run on Android, iOS and the web. In this programme you learn how '
            'real Flutter apps are structured, from composing widgets to managing state and talking to APIs.',
        'You move from small widget exercises to a complete app, learning to turn designs into responsive '
            'screens and to keep your code organised as the app grows.',
      ],
      imageAlt: 'A developer writing Flutter code on a laptop.',
      skills: [
        'Dart Programming',
        'Flutter Widgets',
        'UI Development',
        'State Management',
        'API Integration',
        'Responsive Layouts',
      ],
      learnTopics: [
        LearningTopic(
          'Dart Essentials',
          'Variables, types, null safety, classes and async code with Futures and Streams.',
          Icons.code_rounded,
        ),
        LearningTopic(
          'Widgets & Layout',
          'Compose screens with rows, columns, stacks and lists that adapt to any size.',
          Icons.dashboard_customize_outlined,
        ),
        LearningTopic(
          'State Management',
          'Keep UI and data in sync, starting with setState and moving to structured patterns.',
          Icons.sync_alt_rounded,
        ),
        LearningTopic(
          'APIs & Data',
          'Fetch JSON from REST APIs, parse it into models and handle loading and errors.',
          Icons.cloud_sync_outlined,
        ),
        LearningTopic('Navigation', 'Move between screens, pass data and structure multi-page apps.', Icons.alt_route_rounded),
        LearningTopic(
          'Polish & Testing',
          'Theming, form validation and simple widget tests for confidence in your app.',
          Icons.verified_outlined,
        ),
      ],
      technologies: [
        'Dart',
        'Flutter SDK',
        'Material Design',
        'REST APIs',
        'Firebase Basics',
        'Git & GitHub',
        'VS Code / Android Studio',
      ],
      mentorFocus: [
        'Reviewing how you structure widgets and folders',
        'Explaining state management choices for your app',
        'Helping debug layout overflows and API errors',
      ],
      projectFocus: [
        'Build screens from a design mock-up',
        'Connect a list screen to a REST API',
        'Add form validation and error handling',
      ],
      roadmapFocus: [
        'Set up Flutter and run your first app on an emulator or browser.',
        'Learn Dart syntax and the core layout widgets.',
        'Build small screens: a profile page, a product grid, a login form.',
        'Create a complete app such as a booking or shopping app.',
        'Refactor state handling and improve responsiveness.',
        'Demo the app and walk through your code decisions.',
      ],
      projects: [
        SampleLearningProject(
          'Shopping Application',
          'Product listing, product details, a cart with quantities and an order summary.',
          Icons.shopping_bag_outlined,
        ),
        SampleLearningProject(
          'Booking Application',
          'Pick a service, choose an available time slot and manage upcoming bookings.',
          Icons.event_available_outlined,
        ),
        SampleLearningProject(
          'Business Mobile Application',
          'A small-business app with services, contact options and an enquiry form.',
          Icons.storefront_outlined,
        ),
      ],
      whoCanApply: [
        'Students interested in mobile or cross-platform app development',
        'Learners with basic programming knowledge in any language',
        'Web developers who want to start building mobile apps',
      ],
      faqs: [
        Faq(
          'Do I need to know Dart before applying?',
          'No. Basic programming knowledge in any language helps; Dart fundamentals are covered early in the programme.',
        ),
        Faq(
          'Will I build for Android, iOS or the web?',
          'Flutter targets all three. Most practice runs on Android emulators or in the browser, so you do not need a Mac.',
        ),
        Faq(
          'What computer do I need?',
          'A laptop or desktop that can run Flutter and an editor comfortably. Exact requirements are shared with each opportunity.',
        ),
      ],
    ),

    // ----------------------------------------------------------- Web
    InternshipProgram(
      slug: 'web-development',
      title: 'Web Development Internship',
      shortTitle: 'Web Development',
      icon: Icons.language_rounded,
      description: 'Learn to design and develop modern, responsive and functional websites.',
      introduction: [
        'Websites are often the first thing people see of a business. This programme teaches you to build '
            'sites that look right on every screen, load quickly and are easy to maintain.',
        'You start with semantic HTML and modern CSS, add interactivity with JavaScript, and learn the version '
            'control and deployment steps used to put a site live.',
      ],
      imageAlt: 'A web developer coding at a desk with two monitors.',
      skills: ['HTML', 'CSS', 'JavaScript', 'Responsive Web Design', 'Git and Version Control', 'Website Deployment'],
      learnTopics: [
        LearningTopic(
          'Semantic HTML',
          'Structure pages with meaningful elements for accessibility and search engines.',
          Icons.html_rounded,
        ),
        LearningTopic('Modern CSS', 'Flexbox, Grid, custom properties and clean, reusable styles.', Icons.css_rounded),
        LearningTopic(
          'Responsive Design',
          'Mobile-first layouts and breakpoints that adapt to every screen.',
          Icons.devices_rounded,
        ),
        LearningTopic(
          'JavaScript Basics',
          'DOM manipulation, events, form handling and fetching data.',
          Icons.javascript_rounded,
        ),
        LearningTopic(
          'Git Workflow',
          'Commits, branches and pull requests to track and share your work.',
          Icons.merge_type_rounded,
        ),
        LearningTopic('Deployment', 'Publish a site, connect a domain and ship updates safely.', Icons.rocket_launch_outlined),
      ],
      technologies: [
        'HTML5',
        'CSS3',
        'JavaScript (ES6+)',
        'Flexbox & Grid',
        'Git & GitHub',
        'Static Hosting',
        'Browser DevTools',
      ],
      mentorFocus: [
        'Reviewing markup structure and accessibility',
        'Untangling CSS layout and specificity problems',
        'Guiding your first Git branches and pull requests',
      ],
      projectFocus: [
        'Convert a design into a responsive page',
        'Add interactive sections with JavaScript',
        'Deploy the site and publish an update',
      ],
      roadmapFocus: [
        'Set up your editor, browser tools and a GitHub account.',
        'Learn HTML structure, CSS styling and layout systems.',
        'Rebuild sample sections: a hero, a pricing table, a contact form.',
        'Build a complete business website or landing page.',
        'Improve performance, accessibility and mobile layouts.',
        'Present the live site and explain your approach.',
      ],
      projects: [
        SampleLearningProject(
          'Business Website',
          'A multi-section site for a local business with services, about and contact pages.',
          Icons.business_outlined,
        ),
        SampleLearningProject(
          'Portfolio Website',
          'A personal portfolio presenting projects, skills and a contact form.',
          Icons.person_outline_rounded,
        ),
        SampleLearningProject(
          'Landing Page',
          'A focused, conversion-oriented page for a product or event launch.',
          Icons.web_rounded,
        ),
      ],
      whoCanApply: [
        'Beginners who want to start a career in web development',
        'Students who know some HTML and CSS and want structured practice',
        'Designers who want to turn their designs into working pages',
      ],
      faqs: [
        Faq(
          'Is this front-end only?',
          'Yes, the focus is front-end web development. The Full Stack programme covers servers and databases.',
        ),
        Faq(
          'Do I need prior coding experience?',
          'No prior experience is strictly required, though comfort using a computer and curiosity about how websites work help.',
        ),
        Faq(
          'Will my website be published online?',
          'You learn deployment as part of the programme, so you can publish your project site yourself.',
        ),
      ],
    ),

    // --------------------------------------------------------- UI/UX
    InternshipProgram(
      slug: 'ui-ux-design',
      title: 'UI/UX Design Internship',
      shortTitle: 'UI/UX Design',
      icon: Icons.draw_outlined,
      description: 'Learn to create user-friendly and visually appealing digital experiences.',
      introduction: [
        'Good design starts with understanding people. In this programme you learn to research user needs, '
            'map journeys and turn insights into clear, attractive interfaces.',
        'You work mainly in Figma, moving from rough wireframes to polished, clickable prototypes, and learn how '
            'design systems keep products consistent.',
      ],
      imageAlt: 'A designer sketching wireframes on a tablet with a stylus.',
      skills: ['Figma', 'User Research', 'Wireframing', 'Prototyping', 'UI Design', 'Design Systems'],
      learnTopics: [
        LearningTopic(
          'User Research',
          'Interviews, surveys and personas that capture real user needs.',
          Icons.record_voice_over_outlined,
        ),
        LearningTopic(
          'Information Architecture',
          'User flows and site maps that make content easy to find.',
          Icons.account_tree_outlined,
        ),
        LearningTopic(
          'Wireframing',
          'Low-fidelity layouts to explore ideas quickly before visual design.',
          Icons.grid_view_rounded,
        ),
        LearningTopic(
          'Visual UI Design',
          'Typography, colour, spacing and hierarchy for clear interfaces.',
          Icons.palette_outlined,
        ),
        LearningTopic('Prototyping', 'Clickable Figma prototypes to test flows with real people.', Icons.touch_app_outlined),
        LearningTopic('Design Systems', 'Reusable components, styles and documentation for consistency.', Icons.widgets_outlined),
      ],
      technologies: ['Figma', 'FigJam', 'Auto Layout', 'Components & Variants', 'Usability Testing', 'Accessibility Guidelines'],
      mentorFocus: [
        'Critiquing layouts, hierarchy and visual consistency',
        'Helping plan and interpret user research',
        'Reviewing component structure in your Figma files',
      ],
      projectFocus: [
        'Research and define a target user',
        'Design a complete flow from wireframe to UI',
        'Test a prototype and iterate on feedback',
      ],
      roadmapFocus: [
        'Get set up in Figma and learn the design process.',
        'Learn layout, typography, colour and research basics.',
        'Redesign individual screens with guided critiques.',
        'Design a full app or website experience with a prototype.',
        'Run quick usability tests and refine the design.',
        'Present your case study: problem, process and solution.',
      ],
      projects: [
        SampleLearningProject(
          'E-commerce App Design',
          'Browse, product detail, cart and checkout screens for a shopping app.',
          Icons.shopping_cart_outlined,
        ),
        SampleLearningProject(
          'Business Website UI',
          'A responsive website design for a services business, desktop and mobile.',
          Icons.desktop_windows_outlined,
        ),
        SampleLearningProject(
          'Mobile Application Prototype',
          'A clickable prototype of a mobile app flow, ready for user testing.',
          Icons.phone_iphone_rounded,
        ),
      ],
      whoCanApply: [
        'Students interested in design, psychology or product thinking',
        'Graphic designers moving into digital product design',
        'Developers who want to understand UX and interface design',
      ],
      faqs: [
        Faq(
          'Do I need drawing skills?',
          'No. UI/UX design is about solving problems for users; Figma provides the tools to create clean interfaces.',
        ),
        Faq('Which design tool will I use?', 'The programme mainly uses Figma, which runs in the browser and has a free plan.'),
        Faq('Will I learn to code?', 'Coding is not required. You will learn how designs are handed over to developers.'),
      ],
    ),

    // -------------------------------------------------------- Python
    InternshipProgram(
      slug: 'python-development',
      title: 'Python Development Internship',
      shortTitle: 'Python Development',
      icon: Icons.data_object_rounded,
      description: 'Develop programming skills and learn to build useful applications using Python.',
      introduction: [
        'Python is used for automation, data work and back-end services because it is readable and powerful. '
            'This programme builds strong programming fundamentals and problem-solving habits.',
        'You apply what you learn to practical scripts and small applications: reading files, processing data, '
            'calling APIs and organising code so others can understand it.',
      ],
      imageAlt: 'A developer wearing headphones writing code at a desktop computer.',
      skills: [
        'Python Fundamentals',
        'Programming Logic',
        'Scripting',
        'Data Handling',
        'API Integration',
        'Basic Backend Concepts',
      ],
      learnTopics: [
        LearningTopic(
          'Core Python',
          'Data types, control flow, functions and modules written in a clean style.',
          Icons.terminal_rounded,
        ),
        LearningTopic(
          'Problem Solving',
          'Break problems into steps and turn them into working logic.',
          Icons.psychology_outlined,
        ),
        LearningTopic(
          'Files & Data',
          'Read and write CSV and JSON files and transform data reliably.',
          Icons.table_chart_outlined,
        ),
        LearningTopic(
          'Automation Scripts',
          'Automate repetitive tasks such as renaming files or generating reports.',
          Icons.auto_mode_rounded,
        ),
        LearningTopic('Working With APIs', 'Call web APIs, handle responses and deal with errors gracefully.', Icons.api_rounded),
        LearningTopic('Backend Basics', 'How simple web services and databases fit together.', Icons.dns_outlined),
      ],
      technologies: [
        'Python 3',
        'pip & Virtual Environments',
        'CSV / JSON',
        'Requests',
        'SQLite',
        'Flask Basics',
        'Git & GitHub',
      ],
      mentorFocus: [
        'Reviewing logic and helping you think through problems',
        'Encouraging readable, well-structured code',
        'Helping debug errors and read tracebacks',
      ],
      projectFocus: [
        'Write scripts that solve concrete tasks',
        'Process and summarise a real-world style dataset',
        'Build a small tool others can use',
      ],
      roadmapFocus: [
        'Install Python, set up an editor and run your first scripts.',
        'Learn data types, loops, functions and modules.',
        'Solve guided exercises and small automation tasks.',
        'Build a data tool, automation script or Python application.',
        'Refactor for readability and add basic tests.',
        'Demonstrate the tool and explain how it works.',
      ],
      projects: [
        SampleLearningProject(
          'Data Management Tool',
          'Import records from CSV, search and update them, and export clean reports.',
          Icons.storage_rounded,
        ),
        SampleLearningProject(
          'Automation Script',
          'A script that automates a repetitive office task end to end.',
          Icons.auto_mode_rounded,
        ),
        SampleLearningProject(
          'Python-based Application',
          'A small application with a simple interface or API around useful logic.',
          Icons.apps_rounded,
        ),
      ],
      whoCanApply: [
        'Beginners looking for a strong first programming language',
        'Students interested in automation, data or back-end development',
        'Learners preparing for AI and data-focused programmes',
      ],
      faqs: [
        Faq(
          'Is Python good for beginners?',
          'Yes. Python has readable syntax, which makes it a common first language while still being used professionally.',
        ),
        Faq(
          'Does this cover data science or AI?',
          'The focus is programming fundamentals and practical applications. The AI & Automation programme covers AI tools.',
        ),
        Faq('Which Python version is used?', 'Modern Python 3. Setup instructions are shared at orientation.'),
      ],
    ),

    // ---------------------------------------------- Digital Marketing
    InternshipProgram(
      slug: 'digital-marketing',
      title: 'Digital Marketing Internship',
      shortTitle: 'Digital Marketing',
      icon: Icons.campaign_outlined,
      description: 'Understand how businesses grow through digital platforms, content and online campaigns.',
      introduction: [
        'Digital marketing connects businesses with the right people online. This programme explains how '
            'brands plan content, reach audiences and measure what works.',
        'You learn social media strategy, SEO and advertising fundamentals, then bring them together in a '
            'campaign plan backed by data.',
      ],
      imageAlt: 'A marketer reviewing a social media page on a laptop and a smartphone.',
      skills: [
        'Social Media Strategy',
        'Content Planning',
        'SEO Fundamentals',
        'Digital Advertising',
        'Campaign Planning',
        'Performance Analytics',
      ],
      learnTopics: [
        LearningTopic(
          'Marketing Foundations',
          'Audiences, positioning and the customer journey online.',
          Icons.lightbulb_outline_rounded,
        ),
        LearningTopic(
          'Social Media Strategy',
          'Choose platforms, define tone and plan consistent posting.',
          Icons.forum_outlined,
        ),
        LearningTopic(
          'Content Planning',
          'Content pillars and calendars that keep a brand active.',
          Icons.calendar_month_outlined,
        ),
        LearningTopic('SEO Fundamentals', 'Keywords, on-page optimisation and technical basics.', Icons.travel_explore_rounded),
        LearningTopic(
          'Digital Advertising',
          'How paid campaigns are targeted, budgeted and structured.',
          Icons.ads_click_rounded,
        ),
        LearningTopic('Analytics & Reporting', 'Track performance and turn numbers into decisions.', Icons.insights_rounded),
      ],
      technologies: [
        'Meta Business Suite',
        'Google Analytics',
        'Google Search Console',
        'Canva',
        'Keyword Research Tools',
        'Spreadsheets',
      ],
      mentorFocus: [
        'Reviewing content plans and post ideas',
        'Explaining how to read analytics and reports',
        'Feedback on campaign structure and targeting',
      ],
      projectFocus: [
        'Plan a month of content for a sample brand',
        'Audit a website for SEO improvements',
        'Build a campaign plan with goals and metrics',
      ],
      roadmapFocus: [
        'Understand the digital marketing landscape and key platforms.',
        'Learn social, content, SEO and advertising fundamentals.',
        'Create content calendars and practise keyword research.',
        'Develop a complete campaign or digital marketing plan.',
        'Refine the plan using performance assumptions and feedback.',
        'Present your strategy and the metrics you would track.',
      ],
      projects: [
        SampleLearningProject(
          'Social Media Campaign',
          'A themed campaign with content calendar, post concepts and success metrics.',
          Icons.campaign_outlined,
        ),
        SampleLearningProject(
          'Business Digital Marketing Plan',
          'A channel-by-channel plan for a local business, with goals and budget split.',
          Icons.assignment_outlined,
        ),
        SampleLearningProject(
          'SEO Audit Project',
          'A structured audit of a website with prioritised recommendations.',
          Icons.manage_search_rounded,
        ),
      ],
      whoCanApply: [
        'Students interested in marketing, media or business',
        'Content creators who want a structured, data-driven approach',
        'Entrepreneurs who want to understand online growth',
      ],
      faqs: [
        Faq(
          'Do I need a technical background?',
          'No. The programme is accessible to non-technical learners; comfort with social platforms and spreadsheets helps.',
        ),
        Faq(
          'Will I run paid ads with real money?',
          'Advertising is taught through planning and simulated budgets. Any live spend would be agreed separately for a specific opportunity.',
        ),
        Faq(
          'Does this include graphic design?',
          'Basic creative production with tools like Canva is covered, but the focus is strategy and performance.',
        ),
      ],
    ),

    // ------------------------------------------------ AI & Automation
    InternshipProgram(
      slug: 'ai-automation',
      title: 'AI & Automation Internship',
      shortTitle: 'AI & Automation',
      icon: Icons.smart_toy_outlined,
      description: 'Explore practical AI tools and automation techniques to solve real business problems.',
      introduction: [
        'AI and automation can remove repetitive work and help businesses respond faster. This programme focuses on '
            'practical, responsible use of these tools rather than theory alone.',
        'You learn how AI APIs and chatbots work, how to write and evaluate prompts, and how to connect tools into '
            'automated workflows, always checking the output for accuracy.',
      ],
      imageAlt: 'An engineer working on a laptop in an automation and robotics lab.',
      skills: [
        'AI APIs',
        'Prompt Engineering',
        'Chatbots',
        'Workflow Automation',
        'AI Tool Integration',
        'Business Process Automation',
      ],
      learnTopics: [
        LearningTopic(
          'How AI Models Work',
          'What language models can and cannot do, and where they make mistakes.',
          Icons.psychology_alt_outlined,
        ),
        LearningTopic('Prompt Engineering', 'Write, test and improve prompts for reliable results.', Icons.edit_note_rounded),
        LearningTopic('Working With AI APIs', 'Send requests, handle responses and manage cost and limits.', Icons.api_rounded),
        LearningTopic('Chatbot Design', 'Conversation flows, fallbacks and hand-off to a human.', Icons.chat_outlined),
        LearningTopic(
          'Workflow Automation',
          'Connect forms, sheets, email and apps into automated flows.',
          Icons.account_tree_outlined,
        ),
        LearningTopic('Responsible AI', 'Privacy, accuracy checks and clear disclosure when AI is used.', Icons.shield_outlined),
      ],
      technologies: [
        'AI Language-Model APIs',
        'Prompt Testing',
        'Python or JavaScript',
        'No-code Automation Platforms',
        'Webhooks',
        'Spreadsheets & Forms',
      ],
      mentorFocus: [
        'Reviewing prompts and how you evaluate AI output',
        'Guidance on designing safe chatbot conversations',
        'Helping you map business processes before automating',
      ],
      projectFocus: [
        'Prototype a chatbot for common questions',
        'Automate a multi-step enquiry workflow',
        'Measure accuracy and document limitations',
      ],
      roadmapFocus: [
        'Explore AI tools, use cases and responsible-use principles.',
        'Learn prompt design, API basics and automation concepts.',
        'Build small prompt experiments and single-step automations.',
        'Create a chatbot or automated workflow for a business scenario.',
        'Test edge cases, improve accuracy and add safeguards.',
        'Demonstrate the solution, including its limitations.',
      ],
      projects: [
        SampleLearningProject(
          'AI Customer Support Chatbot',
          'A chatbot that answers common questions and hands complex cases to a person.',
          Icons.support_agent_rounded,
        ),
        SampleLearningProject(
          'Automated Inquiry Workflow',
          'A flow that saves enquiries, replies automatically and notifies a team.',
          Icons.mark_email_read_outlined,
        ),
        SampleLearningProject(
          'AI-powered Business Assistant',
          'An assistant that drafts summaries and replies for staff to review.',
          Icons.assistant_outlined,
        ),
      ],
      whoCanApply: [
        'Students curious about practical uses of AI',
        'Learners with basic programming or spreadsheet skills',
        'Professionals who want to automate repetitive work',
      ],
      faqs: [
        Faq(
          'Do I need machine-learning knowledge?',
          'No. The programme uses existing AI tools and APIs rather than training models from scratch.',
        ),
        Faq('Is coding required?', 'Basic programming helps for API work, but some automation is taught with no-code tools.'),
        Faq(
          'Will I use paid AI services?',
          'Many tools offer free tiers for learning. Any paid tools needed are discussed before an opportunity begins.',
        ),
      ],
    ),

    // --------------------------------------------------- Full Stack
    InternshipProgram(
      slug: 'full-stack-development',
      title: 'Full Stack Development Internship',
      shortTitle: 'Full Stack Development',
      icon: Icons.layers_outlined,
      description:
          'Learn to develop complete web applications by connecting frontend interfaces, backend services and databases.',
      introduction: [
        'Full stack developers understand how every part of a web application fits together. This programme '
            'takes you from the interface in the browser to the server and the database behind it.',
        'You build REST APIs with Node.js, design database tables and connect everything to a working front end, '
            'learning to debug problems wherever they occur.',
      ],
      imageAlt: 'A developer wearing headphones working across multiple monitors of code.',
      skills: ['Frontend Development', 'Backend Development', 'JavaScript', 'Node.js', 'REST APIs', 'Database Fundamentals'],
      learnTopics: [
        LearningTopic('Front-End Foundations', 'Components, forms and calling APIs from the browser.', Icons.web_rounded),
        LearningTopic(
          'JavaScript Deep Dive',
          'Modern JavaScript, async/await and modules on client and server.',
          Icons.javascript_rounded,
        ),
        LearningTopic('Node.js & Express', 'Build servers, routes and middleware for real features.', Icons.dns_outlined),
        LearningTopic('REST API Design', 'Clear endpoints, status codes, validation and documentation.', Icons.api_rounded),
        LearningTopic('Databases', 'Model data, write queries and relate tables or collections.', Icons.storage_rounded),
        LearningTopic(
          'Auth & Security Basics',
          'Login, sessions or tokens, and protecting user data.',
          Icons.lock_outline_rounded,
        ),
      ],
      technologies: ['JavaScript', 'Node.js', 'Express', 'REST APIs', 'MySQL / PostgreSQL / MongoDB', 'Postman', 'Git & GitHub'],
      mentorFocus: [
        'Reviewing API design and project structure',
        'Helping trace bugs across front end, server and database',
        'Guidance on data modelling decisions',
      ],
      projectFocus: [
        'Build a feature from database to UI',
        'Design and document REST endpoints',
        'Add authentication and input validation',
      ],
      roadmapFocus: [
        'Understand how browsers, servers and databases work together.',
        'Learn JavaScript, Node.js basics and database fundamentals.',
        'Build API endpoints and connect them to simple pages.',
        'Develop a complete full stack application.',
        'Improve structure, validation, security and error handling.',
        'Demo the application and explain its architecture.',
      ],
      projects: [
        SampleLearningProject(
          'Business Management System',
          'Manage customers, orders and staff with role-based access.',
          Icons.business_center_outlined,
        ),
        SampleLearningProject(
          'Admin Dashboard',
          'A dashboard with charts, tables and CRUD screens over a REST API.',
          Icons.space_dashboard_outlined,
        ),
        SampleLearningProject(
          'Full Stack Web Application',
          'A complete app with sign-up, data entry and search, end to end.',
          Icons.layers_outlined,
        ),
      ],
      whoCanApply: [
        'Learners comfortable with HTML, CSS and basic JavaScript',
        'Front-end developers who want to learn back-end skills',
        'Computer science and IT students preparing for development roles',
      ],
      faqs: [
        Faq(
          'Should I know web development first?',
          'Basic HTML, CSS and JavaScript help a lot. Complete beginners may find the Web Development programme a better starting point.',
        ),
        Faq(
          'Which database will I use?',
          'You learn database fundamentals that apply broadly; the specific database used is shared at orientation.',
        ),
        Faq('Will I deploy my application?', 'Deployment concepts are covered so you understand how a full stack app goes live.'),
      ],
    ),
  ];
}
