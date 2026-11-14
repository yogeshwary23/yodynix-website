import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../models/site_section.dart';
import '../../providers/section_navigator.dart';
import '../../repositories/content/company_content.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';
import '../../shared/widgets/visuals/visual_primitives.dart';

class FinalCtaSection extends StatelessWidget {
  const FinalCtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = SectionNavigatorScope.read(context);
    final mobile = context.isMobile;

    return SectionShell(
      background: AppColors.background,
      glowAt: Alignment.center,
      glowStrength: 0.8,
      child: Reveal(
        child: Container(
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            gradient: AppColors.signatureGradient,
            borderRadius: BorderRadius.circular(34),
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 70, spreadRadius: -10)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32.5),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F1E4A), Color(0xFF0D1631), Color(0xFF072A44)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  const Positioned(
                    left: -120,
                    top: -120,
                    child: SizedBox(
                      width: 320,
                      height: 320,
                      child: CustomPaint(painter: RingsPainter(color: AppColors.primary)),
                    ),
                  ),
                  const Positioned(
                    right: -140,
                    bottom: -140,
                    child: SizedBox(
                      width: 360,
                      height: 360,
                      child: CustomPaint(painter: RingsPainter(color: AppColors.iceBlue)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: mobile ? 24 : 64, vertical: mobile ? 48 : 80),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: AppColors.warmGradient,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withValues(alpha: 0.3),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.white, size: 32),
                            ),
                            const SizedBox(height: 28),
                            Semantics(
                              header: true,
                              child: Text(
                                CompanyContent.ctaHeading,
                                textAlign: TextAlign.center,
                                style: AppTypography.display(
                                  fontSize: context.responsive(mobile: 30.0, tablet: 40.0, desktop: 48.0),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              CompanyContent.ctaDescription,
                              textAlign: TextAlign.center,
                              style: AppTypography.body(fontSize: mobile ? 16 : 18),
                            ),
                            const SizedBox(height: 36),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 14,
                              runSpacing: 14,
                              children: [
                                PrimaryButton(
                                  label: 'Start Your Project',
                                  size: ButtonSize.large,
                                  onPressed: () => nav.startEnquiry(),
                                ),
                                SecondaryButton(
                                  label: 'Contact Us',
                                  icon: Icons.chat_bubble_outline_rounded,
                                  size: ButtonSize.large,
                                  onPressed: () => nav.scrollTo(SiteSection.contact),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
