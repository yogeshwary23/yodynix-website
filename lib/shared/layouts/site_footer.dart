import 'package:flutter/material.dart';

import '../../core/constants/site_config.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/utils/responsive.dart';
import '../../models/site_section.dart';
import '../../repositories/content/internship_content.dart';
import '../../repositories/content/services_content.dart';
import '../../services/link_service.dart';
import '../widgets/brand_logo.dart';
import '../widgets/gold_dust.dart';
import '../widgets/section_widgets.dart';
import 'navigation_actions.dart';

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final columns = <Widget>[
      _FooterColumn(
        title: 'Quick Links',
        links: [
          for (final s in const [
            SiteSection.home,
            SiteSection.about,
            SiteSection.services,
            SiteSection.expertise,
            SiteSection.internship,
            SiteSection.contact,
          ])
            _FooterLink(s.navLabel!, () => s == SiteSection.internship ? openInternshipPage(context) : goToSection(context, s)),
          for (final page in SitePage.values) _FooterLink(page.label, () => openSitePage(context, page)),
        ],
      ),
      _FooterColumn(
        title: 'Services',
        links: [
          for (final service in ServicesContent.services.take(6))
            _FooterLink(service.title, () => openServicePage(context, service)),
        ],
      ),
      _FooterColumn(
        title: 'Careers',
        links: [
          _FooterLink('Internship Programs', () => openInternshipPage(context)),
          for (final p in InternshipContent.programs.take(3))
            _FooterLink(p.shortTitle, () => openInternshipPage(context, slug: p.slug)),
          _FooterLink('Register Interest', () => openInternshipPage(context, apply: true)),
        ],
      ),
      _FooterColumn(title: 'Contact', links: _contactLinks(context)),
    ];

    return Semantics(
      container: true,
      label: 'Footer',
      child: SurfaceTone(
        colors: SurfaceColors.dark,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.deepCharcoal,
            border: Border(top: BorderSide(color: AppColors.champagneGold.withValues(alpha: 0.45))),
          ),
          child: GoldDust(
            child: MaxWidth(
              child: Padding(
                padding: EdgeInsets.only(top: context.responsive(mobile: 56.0, desktop: 80.0), bottom: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (context.isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(flex: 4, child: _BrandBlock()),
                          const SizedBox(width: 40),
                          for (final column in columns) Expanded(flex: 2, child: column),
                        ],
                      )
                    else ...[
                      const _BrandBlock(),
                      const SizedBox(height: 40),
                      ResponsiveGrid(
                        minItemWidth: 220,
                        maxColumns: 2,
                        spacing: 24,
                        runSpacing: 32,
                        equalHeight: false,
                        children: columns,
                      ),
                    ],
                    const SizedBox(height: 48),
                    const Divider(color: AppColors.darkBorder),
                    const SizedBox(height: 22),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 20,
                        runSpacing: 8,
                        children: [
                          _FooterLink('Privacy Policy', () => Navigator.of(context).pushNamed(AppRoutes.privacy), compact: true),
                          _FooterLink(
                            'Terms & Conditions',
                            () => Navigator.of(context).pushNamed(AppRoutes.terms),
                            compact: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // The year follows the visitor's clock, so it never needs editing.
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        '© ${DateTime.now().year} ${SiteConfig.brandName}. All Rights Reserved.',
                        textAlign: TextAlign.center,
                        style: AppTypography.body(fontSize: 13.5, color: AppColors.onDarkMuted, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: Text.rich(
                        TextSpan(
                          text: 'Designed & Developed by ',
                          children: [
                            TextSpan(
                              text: SiteConfig.brandName,
                              style: AppTypography.body(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onDark,
                                height: 1.5,
                              ).copyWith(letterSpacing: 0.6),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        style: AppTypography.body(fontSize: 12.5, color: AppColors.onDarkMuted, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _contactLinks(BuildContext context) {
    final links = <Widget>[];
    const email = ContactConfig.email;
    const whatsapp = ContactConfig.whatsappNumber;
    links.add(_FooterLink(email, () => LinkService.email(email)));
    for (final phone in ContactConfig.phones) {
      links.add(_FooterLink(phone, () => LinkService.call(phone)));
    }
    links.add(_FooterLink(ContactConfig.address, () => LinkService.open(ContactConfig.directionsUrl)));
    if (whatsapp != null) links.add(_FooterLink('WhatsApp', () => LinkService.whatsapp(whatsapp)));
    links.add(_FooterLink('Send an Enquiry', () => goToSection(context, SiteSection.contact)));
    links.add(_FooterLink('Client Login', () => showClientLoginDialog(context)));
    return links;
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BrandLogo(height: 48, showCategory: true),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Text(SiteConfig.shortDescription, style: AppTypography.body(fontSize: 14.5, color: AppColors.onDarkBody)),
        ),
        const SizedBox(height: 22),
        if (SocialConfig.links.isEmpty)
          Text('Social profiles coming soon.', style: AppTypography.body(fontSize: 13, color: AppColors.onDarkMuted))
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final link in SocialConfig.links)
                Tooltip(
                  message: link.platform.label,
                  child: Material(
                    color: AppColors.charcoal,
                    shape: const CircleBorder(side: BorderSide(color: AppColors.darkBorder)),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => LinkService.open(link.url),
                      child: SizedBox(width: 40, height: 40, child: Icon(link.platform.icon, size: 16, color: AppColors.onDark)),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({required this.title, required this.links});

  final String title;
  final List<Widget> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.display(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onDark),
        ),
        const SizedBox(height: 18),
        ...links,
      ],
    );
  }
}

class _FooterLink extends StatefulWidget {
  const _FooterLink(this.label, this.onTap, {this.compact = false});

  final String label;
  final VoidCallback onTap;
  final bool compact;

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.compact ? 0 : 12),
      child: Semantics(
        link: true,
        label: widget.label,
        excludeSemantics: true,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: AppTypography.body(
                fontSize: widget.compact ? 13.5 : 14.5,
                color: _hover ? AppColors.primaryTint : AppColors.onDarkBody,
                height: 1.4,
              ),
              child: Text(widget.label),
            ),
          ),
        ),
      ),
    );
  }
}
