import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../models/site_section.dart';
import '../../repositories/content/industries_content.dart';
import '../../repositories/content/services_content.dart';
import '../../shared/layouts/navigation_actions.dart';
import '../../shared/layouts/subpage_scaffold.dart';
import '../../shared/three/scene3d.dart';
import '../../shared/three/scene_widgets.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';

/// `/industries`: one sector per row, each with its own 3D scene, the kinds
/// of solutions that fit it and links to the relevant services.
class IndustriesPage extends StatelessWidget {
  const IndustriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    const industries = IndustriesContent.industries;
    return SubpageScaffold(
      title: 'Industries',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionShell(
            background: AppColors.pearlWhite,
            topPadding: context.responsive(mobile: 36.0, desktop: 64.0),
            bottomPadding: context.responsive(mobile: 32.0, desktop: 48.0),
            glowAt: const Alignment(0.8, -0.6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(
                  eyebrow: 'Industries',
                  title: IndustriesContent.heading,
                  lead: IndustriesContent.lead,
                  centered: true,
                ),
                if (IndustriesContent.isPlaceholder) ...[const SizedBox(height: 20), const Center(child: PlaceholderNotice())],
                const SizedBox(height: 32),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final i in industries)
                      Chip(
                        avatar: Icon(i.icon, size: 16, color: AppColors.accent),
                        label: Text(i.name),
                        backgroundColor: AppColors.white,
                        side: const BorderSide(color: AppColors.cardBorder),
                      ),
                  ],
                ),
              ],
            ),
          ),
          for (final (index, industry) in industries.indexed)
            SectionShell(
              background: index.isEven ? AppColors.surface : AppColors.pearlWhite,
              topPadding: context.responsive(mobile: 40.0, desktop: 64.0),
              bottomPadding: context.responsive(mobile: 40.0, desktop: 64.0),
              child: _IndustryRow(
                industry: industry,
                sceneLeft: index.isEven,
                background: index.isEven ? AppColors.surface : AppColors.pearlWhite,
              ),
            ),
          SectionShell(
            background: AppColors.pearlWhite,
            child: Column(
              children: [
                const SectionHeader(
                  eyebrow: 'Your Sector',
                  title: "Don't See Your Industry?",
                  lead: 'Tell us about your business and what you want to achieve. We will reply with clear next steps.',
                  centered: true,
                ),
                const SizedBox(height: 28),
                PrimaryButton(label: 'Start a Conversation', onPressed: () => goToSection(context, SiteSection.contact)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IndustryRow extends StatelessWidget {
  const _IndustryRow({required this.industry, required this.sceneLeft, required this.background});

  final IndustryProfile industry;
  final bool sceneLeft;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final services = [for (final id in industry.serviceIds) ...ServicesContent.services.where((s) => s.id == id)];
    final scene = Reveal(
      child: AspectRatio(
        aspectRatio: context.isDesktop ? 1.25 : 1.4,
        child: Section3DScene(
          scene: Scene3D.industries,
          variant: industry.id,
          background: background,
          semanticLabel: industry.sceneLabel,
          fallback: Center(
            child: IconBadge(icon: industry.icon, color: AppColors.primary, size: 72, gradient: true),
          ),
        ),
      ),
    );
    final copy = Reveal(
      delay: const Duration(milliseconds: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: industry.icon, color: AppColors.primary, size: 40, gradient: true),
              const SizedBox(width: 14),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    industry.name,
                    style: AppTypography.display(fontSize: context.responsive(mobile: 24.0, desktop: 30.0), color: AppColors.ink),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(industry.summary, style: AppTypography.body(fontSize: 16, height: 1.7, color: AppColors.body)),
          const SizedBox(height: 20),
          for (final solution in industry.solutions)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      solution,
                      style: AppTypography.body(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 18),
          Text(
            'Related services',
            style: AppTypography.body(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in services)
                ActionChip(
                  label: Text(s.title),
                  onPressed: () => openServicePage(context, s),
                  backgroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.goldLine),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                ),
            ],
          ),
        ],
      ),
    );

    if (!context.isDesktop) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [scene, const SizedBox(height: 24), copy]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 5, child: sceneLeft ? scene : copy),
        const SizedBox(width: 56),
        Expanded(flex: 5, child: sceneLeft ? copy : scene),
      ],
    );
  }
}

/// Visible marker on pages whose copy is still placeholder text.
class PlaceholderNotice extends StatelessWidget {
  const PlaceholderNotice({super.key, this.text = 'Placeholder copy: replace before launch'});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.goldWash,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.goldLine),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.edit_note_rounded, size: 16, color: AppColors.accent),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: AppTypography.body(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}
