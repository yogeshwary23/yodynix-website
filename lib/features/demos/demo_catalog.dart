import 'package:flutter/widgets.dart';

import '../../core/routing/app_routes.dart';
import '../../models/content_models.dart';
import '../../models/service_page.dart';
import '../../repositories/content/service_pages_content.dart';
import '../../repositories/content/services_content.dart';
import 'app_prototype_demo.dart';
import 'brand_kit_demo.dart';
import 'campaign_planner_demo.dart';
import 'class_booking_demo.dart';
import 'clinic_website_demo.dart';
import 'enquiry_automation_demo.dart';
import 'handloom_store_demo.dart';
import 'hospital_demo.dart';
import 'mini_crm_demo.dart';
import 'support_assistant_demo.dart';
import 'task_board_demo.dart';

/// One working demo, reachable at `/demos/<slug>`.
class DemoEntry {
  const DemoEntry({
    required this.slug,
    required this.serviceId,
    required this.windowTitle,
    required this.builder,
    this.light = true,
  });

  final String slug;
  final String serviceId;

  /// Address-bar style label in the demo window.
  final String windowTitle;
  final WidgetBuilder builder;

  /// Light body for client-style demos; dark for tool-style demos.
  final bool light;

  String get route => AppRoutes.demo(slug);

  ServiceOffering get service => ServicesContent.services.firstWhere((s) => s.id == serviceId);

  /// The sample project this demo belongs to.
  SampleProject get project => ServicePagesContent.of(service).projects.firstWhere((p) => p.demoRoute == route);
}

class DemoCatalog {
  DemoCatalog._();

  static DemoEntry? byRoute(String route) {
    for (final d in demos) {
      if (d.route == route) return d;
    }
    return null;
  }

  static final List<DemoEntry> demos = [
    DemoEntry(
      slug: 'clinic-website',
      serviceId: 'website_development',
      windowTitle: 'lumen-dental.demo',
      builder: (_) => const ClinicWebsiteDemo(),
    ),
    DemoEntry(
      slug: 'handloom-store',
      serviceId: 'ecommerce_development',
      windowTitle: 'weave-and-co.demo/shop',
      builder: (_) => const HandloomStoreDemo(),
    ),
    DemoEntry(
      slug: 'class-booking-app',
      serviceId: 'mobile_app_development',
      windowTitle: 'FitSlot · mobile app preview',
      light: false,
      builder: (_) => const ClassBookingDemo(),
    ),
    DemoEntry(
      slug: 'responsive-task-board',
      serviceId: 'mobile_app_development',
      windowTitle: 'TaskFlow · responsive preview',
      light: false,
      builder: (_) => const TaskBoardDemo(),
    ),
    DemoEntry(
      slug: 'mini-crm',
      serviceId: 'custom_software_development',
      windowTitle: 'leaddesk.demo/leads',
      builder: (_) => const MiniCrmDemo(),
    ),
    DemoEntry(
      slug: 'hospital-management',
      serviceId: 'custom_software_development',
      windowTitle: 'clinicdesk.demo/front-office',
      builder: (_) => const HospitalDemo(),
    ),
    DemoEntry(
      slug: 'support-assistant',
      serviceId: 'ai_solutions_chatbots',
      windowTitle: 'HelpDesk Assistant · scripted demo',
      builder: (_) => const SupportAssistantDemo(),
    ),
    DemoEntry(
      slug: 'enquiry-automation',
      serviceId: 'business_automation',
      windowTitle: 'FlowRunner · workflow simulation',
      light: false,
      builder: (_) => const EnquiryAutomationDemo(),
    ),
    DemoEntry(
      slug: 'campaign-planner',
      serviceId: 'digital_marketing',
      windowTitle: 'Campaign ROI Planner',
      builder: (_) => const CampaignPlannerDemo(),
    ),
    DemoEntry(
      slug: 'app-prototype',
      serviceId: 'ui_ux_design',
      windowTitle: 'Bookly · clickable prototype',
      light: false,
      builder: (_) => const AppPrototypeDemo(),
    ),
    DemoEntry(
      slug: 'brand-kit-builder',
      serviceId: 'branding_digital_presence',
      windowTitle: 'Brand Kit Builder',
      builder: (_) => const BrandKitDemo(),
    ),
  ];
}
