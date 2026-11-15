import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/utils/responsive.dart';
import '../../models/about_page.dart';
import '../../models/site_section.dart';
import '../../repositories/content/company_content.dart';
import '../../shared/layouts/navigation_actions.dart';
import '../../shared/layouts/subpage_scaffold.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';
import '../../shared/widgets/tinted_photo.dart';
import '../process/process_timeline.dart';
import '../team/team_showcase.dart';
import 'philosophy_grid.dart';
import 'who_we_are_story.dart';

/// One About page: a compact hero with tabs to the sibling pages, the page's
/// own content, then links to the other three pages.
class AboutPageView extends StatelessWidget {
  const AboutPageView({super.key, required this.page});

  final AboutPage page;

  @override
  Widget build(BuildContext context) {
    final (heading, lead, Widget body) = switch (page) {
      AboutPage.whoWeAre => (CompanyContent.aboutHeading, CompanyContent.whoWeAreLead, const WhoWeAreStory()),
      AboutPage.team => (CompanyContent.teamHeading, CompanyContent.teamLead, const TeamShowcase()),
      AboutPage.philosophy => (CompanyContent.philosophyHeading, CompanyContent.philosophyLead, const PhilosophyGrid()),
      AboutPage.howWeWork => (CompanyContent.processHeading, CompanyContent.processLead, const ProcessTimeline()),
    };

    return SubpageScaffold(
      title: page.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Hero(page: page, heading: heading, lead: lead),
          SectionShell(
            background: AppColors.background,
            topPadding: context.responsive(mobile: 48.0, desktop: 72.0),
            glowAt: const Alignment(1.1, -0.6),
            glowStrength: 0.7,
            child: body,
          ),
          _MoreAbout(current: page),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ Hero

class _Hero extends StatelessWidget {
  const _Hero({required this.page, required this.heading, required this.lead});

  final AboutPage page;
  final String heading;
  final String lead;

  @override
  Widget build(BuildContext context) {
    const tone = SurfaceColors.dark;
    return SectionShell(
      topPadding: context.responsive(mobile: 28.0, desktop: 44.0),
      bottomPadding: context.responsive(mobile: 40.0, desktop: 56.0),
      tone: tone,
      gradient: AppColors.darkBandGradient,
      glowAt: const Alignment(0, -1.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _Breadcrumb(current: page),
          ),
          SizedBox(height: context.responsive(mobile: 24.0, desktop: 32.0)),
          SectionHeader(
            eyebrow: page.title,
            title: heading,
            lead: lead,
            centered: true,
            titleSize: context.responsive(mobile: 32.0, tablet: 42.0, desktop: 50.0),
          ),
          SizedBox(height: context.responsive(mobile: 32.0, desktop: 40.0)),
          Reveal(child: AboutPageTabs(current: page)),
        ],
      ),
    );
  }
}

/// Home › About › current page.
class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.current});

  final AboutPage current;

  @override
  Widget build(BuildContext context) {
    Widget link(String label, IconData icon, VoidCallback onTap) => TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: context.tone.body,
        textStyle: AppTypography.body(fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        minimumSize: const Size(0, 36),
      ),
    );
    final separator = Icon(Icons.chevron_right_rounded, size: 16, color: context.tone.muted);

    return Semantics(
      container: true,
      label: 'Breadcrumb',
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2,
        runSpacing: 4,
        children: [
          link('Home', Icons.home_outlined, () => goToSection(context, SiteSection.home)),
          separator,
          link('About', Icons.info_outline_rounded, () => goToSection(context, SiteSection.about)),
          separator,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              current.title,
              style: AppTypography.body(fontSize: 13.5, fontWeight: FontWeight.w600, color: context.tone.accent, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill tabs linking the four About pages, with [current] highlighted.
/// Scrolls sideways on phones instead of wrapping onto several lines.
class AboutPageTabs extends StatelessWidget {
  const AboutPageTabs({super.key, required this.current});

  final AboutPage current;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      for (final page in AboutPage.values) _Tab(page: page, active: page == current, onTap: () => openAboutPage(context, page)),
    ];
    return Semantics(
      container: true,
      label: 'About pages',
      child: context.isMobile
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final (i, tab) in tabs.indexed) ...[if (i > 0) const SizedBox(width: 8), tab],
                ],
              ),
            )
          : Wrap(alignment: WrapAlignment.center, spacing: 10, runSpacing: 10, children: tabs),
    );
  }
}

class _Tab extends StatefulWidget {
  const _Tab({required this.page, required this.active, required this.onTap});

  final AboutPage page;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_Tab> createState() => _TabState();
}

class _TabState extends State<_Tab> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final tone = context.tone;
    final color = active ? AppColors.onPrimary : (_hover ? tone.ink : tone.body);
    return Semantics(
      button: true,
      selected: active,
      label: widget.page.title,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: active ? MouseCursor.defer : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: AppMotion.hover,
            curve: AppMotion.ease,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : (_hover ? tone.ghostHoverFill : tone.ghostFill),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: active ? AppColors.primary : tone.ghostBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.page.icon, size: 17, color: color),
                const SizedBox(width: 8),
                Text(
                  widget.page.title,
                  style: AppTypography.body(
                    fontSize: 14,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                    color: color,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ More about

class _MoreAbout extends StatelessWidget {
  const _MoreAbout({required this.current});

  final AboutPage current;

  @override
  Widget build(BuildContext context) {
    final others = AboutPage.values.where((p) => p != current).toList();
    return SectionShell(
      background: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(eyebrow: 'Keep Exploring', title: 'More About YODYNIX', centered: true),
          const SizedBox(height: 44),
          ResponsiveGrid(
            minItemWidth: 260,
            maxColumns: 3,
            spacing: 20,
            children: [
              for (final (i, page) in others.indexed)
                Reveal(
                  delay: Duration(milliseconds: 80 * i),
                  child: AboutPageCard(page: page),
                ),
            ],
          ),
          const SizedBox(height: 48),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                PrimaryButton(label: 'Start a Project', onPressed: () => goToSection(context, SiteSection.contact)),
                SecondaryButton(
                  label: 'Back to Home',
                  icon: Icons.home_outlined,
                  onPressed: () => goToSection(context, SiteSection.home),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Photo card linking to an About page; used on the homepage overview and
/// at the foot of each About page.
class AboutPageCard extends StatefulWidget {
  const AboutPageCard({super.key, required this.page});

  final AboutPage page;

  @override
  State<AboutPageCard> createState() => _AboutPageCardState();
}

class _AboutPageCardState extends State<AboutPageCard> {
  bool _hover = false;

  void _open() => openAboutPage(context, widget.page);

  @override
  Widget build(BuildContext context) {
    final page = widget.page;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: HoverCard(
        padding: const EdgeInsets.all(10),
        onTap: _open,
        semanticLabel: page.title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: TintedPhoto(basePath: page.image, semanticLabel: page.imageAlt, active: _hover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 18, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(page.icon, size: 18, color: AppColors.cardAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          page.title,
                          style: AppTypography.display(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                            color: AppColors.cardHeading,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(page.summary, style: AppTypography.body(fontSize: 14, height: 1.6, color: AppColors.cardBody)),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
              child: ArrowLink(label: 'Explore', color: AppColors.cardAccent, onPressed: _open),
            ),
          ],
        ),
      ),
    );
  }
}
