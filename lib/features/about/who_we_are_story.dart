import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/surface_tone.dart';
import '../../core/utils/responsive.dart';
import '../../repositories/content/company_content.dart';
import '../../shared/widgets/motion_effects.dart';
import '../../shared/widgets/parallax_photo.dart';
import '../../shared/widgets/premium.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/visuals/illustrated_visual.dart';
import '../../shared/widgets/visuals/visual_kind.dart';

/// "Who We Are": a studio photograph beside our story, then the vision,
/// mission and approach as glass cards; stacked below desktop widths.
class WhoWeAreStory extends StatelessWidget {
  const WhoWeAreStory({super.key});

  static const _photo = 'assets/images/about/studio';

  @override
  Widget build(BuildContext context) {
    final visual = Reveal(
      child: AspectRatio(
        aspectRatio: 560 / 520,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: premiumCardShadow(lifted: true),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ParallaxPhoto(
                  basePath: _photo,
                  semanticLabel: 'A team gathered in a bright, warm studio office.',
                  depth: 16,
                  fallback: IllustratedVisual(VisualKind.about),
                ),
                const IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Color(0x40FFECC8), Color(0x00FFECC8)],
                        stops: [0, 0.5],
                      ),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.white.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final paragraphs = CompanyContent.aboutStory;
    final story = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The opening paragraph leads, beside a gold bar, as on the homepage.
        Reveal(
          child: GoldBarLead(
            text: paragraphs.first,
            style: AppTypography.body(
              fontSize: context.responsive(mobile: 17.0, desktop: 19.0),
              color: AppColors.ink,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 20),
        for (final (i, paragraph) in paragraphs.skip(1).indexed)
          Reveal(
            delay: Duration(milliseconds: 80 * (i + 1)),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(paragraph, style: AppTypography.body(fontSize: 16.5, height: 1.8)),
            ),
          ),
      ],
    );

    final statements = [
      const _Statement(icon: Icons.visibility_outlined, title: 'Our Vision', text: CompanyContent.vision),
      const _Statement(icon: Icons.flag_outlined, title: 'Our Mission', text: CompanyContent.mission),
      const _Statement(icon: Icons.route_outlined, title: 'Our Approach', text: CompanyContent.approach),
    ];
    final cards = context.isDesktop
        ? IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, statement) in statements.indexed) ...[
                  if (i > 0) const SizedBox(width: 20),
                  Expanded(
                    child: Reveal(delay: Duration(milliseconds: 80 * i), child: _StatementCard(statement: statement)),
                  ),
                ],
              ],
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, statement) in statements.indexed) ...[
                if (i > 0) const SizedBox(height: 16),
                Reveal(child: _StatementCard(statement: statement)),
              ],
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (context.isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 5, child: visual),
              const SizedBox(width: 64),
              Expanded(flex: 6, child: story),
            ],
          )
        else ...[
          story,
          const SizedBox(height: 28),
          visual,
        ],
        SizedBox(height: context.responsive(mobile: 40.0, desktop: 64.0)),
        cards,
      ],
    );
  }
}

class _Statement {
  const _Statement({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;
}

/// White glass card with a gold accent along its top edge that lengthens
/// on hover, a gold icon, and a gentle tilt towards the pointer.
class _StatementCard extends StatefulWidget {
  const _StatementCard({required this.statement});

  final _Statement statement;

  @override
  State<_StatementCard> createState() => _StatementCardState();
}

class _StatementCardState extends State<_StatementCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final statement = widget.statement;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Tilt3D(
        radius: AppRadius.xl,
        maxAngle: 4,
        lift: 6,
        child: AnimatedContainer(
          duration: AppMotion.lift,
          curve: AppMotion.ease,
          transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
          decoration: premiumGlassCard(lifted: _hover),
          child: SurfaceTone(
            colors: SurfaceColors.inCard,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 28,
                  child: AnimatedContainer(
                    duration: AppMotion.lift,
                    curve: AppMotion.ease,
                    width: _hover ? 96 : 36,
                    height: 3,
                    decoration: const BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(2)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 30, 28, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GoldIconTile(icon: statement.icon, size: 48),
                      const SizedBox(height: 20),
                      Text(
                        statement.title,
                        style: AppTypography.display(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.cardHeading),
                      ),
                      const SizedBox(height: 10),
                      Text(statement.text, style: AppTypography.body(fontSize: 15.5, height: 1.7, color: AppColors.cardBody)),
                    ],
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
