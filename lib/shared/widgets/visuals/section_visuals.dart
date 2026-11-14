import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'visual_primitives.dart';

// --------------------------------------------------------------- About

class AboutVisual extends StatelessWidget {
  const AboutVisual({super.key});

  @override
  Widget build(BuildContext context) {
    return VisualCanvas(
      designSize: const Size(560, 480),
      child: Stack(
        children: [
          const Positioned(
            left: 170,
            top: 130,
            child: SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(painter: RingsPainter(color: AppColors.primary)),
            ),
          ),
          const Positioned.fill(
            child: CustomPaint(painter: _FlowArrows(color: AppColors.primary)),
          ),
          Positioned(
            left: 240,
            top: 200,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.signatureGradient,
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 30)],
              ),
              child: const Icon(Icons.all_inclusive_rounded, color: AppColors.white, size: 36),
            ),
          ),
          Positioned(
            left: 30,
            top: 50,
            child: _stage(Icons.lightbulb_outline_rounded, 'Idea', 'Understand the possibility', AppColors.sun, 0.25),
          ),
          Positioned(
            left: 320,
            top: 50,
            child: _stage(Icons.draw_outlined, 'Design', 'Shape the experience', AppColors.sky, 0.5),
          ),
          Positioned(
            left: 320,
            top: 340,
            child: _stage(Icons.code_rounded, 'Build', 'Engineer with care', AppColors.primary, 0.75),
          ),
          Positioned(
            left: 30,
            top: 340,
            child: _stage(Icons.rocket_launch_outlined, 'Grow', 'Launch and improve', AppColors.accent, 1),
          ),
        ],
      ),
    );
  }

  Widget _stage(IconData icon, String title, String subtitle, Color color, double progress) {
    return Floating(
      phase: progress,
      amplitude: 4,
      child: Panel(
        width: 210,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBubble(icon: icon, color: color, size: 36, filled: true),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      vLabel(title, size: 14, weight: FontWeight.w700),
                      const SizedBox(height: 3),
                      vLabel(subtitle, size: 10, color: AppColors.muted, weight: FontWeight.w500),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: progress, minHeight: 5, color: color, backgroundColor: AppColors.skeleton),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowArrows extends CustomPainter {
  const _FlowArrows({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = color.withValues(alpha: 0.35);
    ArrowPainter(from: const Offset(245, 90), to: const Offset(312, 90), color: c, curve: -18).paint(canvas, size);
    ArrowPainter(from: const Offset(425, 140), to: const Offset(425, 330), color: c, curve: 0).paint(canvas, size);
    ArrowPainter(from: const Offset(315, 385), to: const Offset(248, 385), color: c, curve: 18).paint(canvas, size);
    ArrowPainter(from: const Offset(135, 330), to: const Offset(135, 140), color: c, curve: 0).paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant _FlowArrows oldDelegate) => false;
}

// ---------------------------------------------------------- Internship

class InternshipVisual extends StatelessWidget {
  const InternshipVisual({super.key});

  @override
  Widget build(BuildContext context) {
    return VisualCanvas(
      designSize: const Size(560, 420),
      tones: const [Color(0x00FFFFFF), Color(0x00FFFFFF)],
      blobs: const [],
      showGrid: false,
      fit: BoxFit.contain,
      child: Stack(
        children: [
          const Positioned(
            left: 80,
            top: 10,
            child: SizedBox(
              width: 400,
              height: 400,
              child: CustomPaint(painter: RingsPainter(color: AppColors.primary, count: 3)),
            ),
          ),
          Positioned(
            left: 130,
            top: 110,
            child: Panel(
              width: 300,
              height: 200,
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            vLabel('Sprint board', size: 11, weight: FontWeight.w700),
                            const SizedBox(height: 10),
                            for (final c in const [AppColors.primary, AppColors.accent, AppColors.mint, AppColors.violet])
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      c == AppColors.violet ? Icons.radio_button_unchecked : Icons.check_circle_rounded,
                                      size: 12,
                                      color: c == AppColors.violet ? AppColors.muted : AppColors.success,
                                    ),
                                    const SizedBox(width: 6),
                                    Skel(width: 70, height: 5, color: c.withValues(alpha: 0.5)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 130,
                      color: AppColors.cardRaised,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          vLabel('</> review', size: 10, color: AppColors.primary),
                          const SizedBox(height: 10),
                          for (final w in const [80.0, 60.0, 90.0, 50.0, 70.0])
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Skel(width: w, height: 5, color: const Color(0xFF2E3D63)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          for (final a in const [
            (Offset(96, 70), AppColors.primary),
            (Offset(440, 80), AppColors.accent),
            (Offset(70, 300), AppColors.violet),
            (Offset(450, 300), AppColors.mint),
            (Offset(262, 334), AppColors.sky),
          ])
            Positioned(
              left: a.$1.dx,
              top: a.$1.dy,
              child: Floating(
                phase: a.$1.dx / 500,
                amplitude: 4,
                child: Avatar(color: a.$2, size: 44),
              ),
            ),
          Positioned(left: 180, top: 40, child: Floating(phase: 0.2, child: _tag('Flutter', AppColors.primary))),
          Positioned(left: 330, top: 50, child: Floating(phase: 0.6, child: _tag('UI/UX', AppColors.sky))),
          Positioned(left: 20, top: 190, child: Floating(phase: 0.4, child: _tag('Python', AppColors.violet))),
          Positioned(left: 450, top: 200, child: Floating(phase: 0.8, child: _tag('AI', AppColors.mint))),
          Positioned(left: 150, top: 350, child: Floating(phase: 0.1, child: _tag('Marketing', AppColors.rose))),
          Positioned(left: 340, top: 370, child: Floating(phase: 0.9, child: _tag('Full Stack', AppColors.accent))),
        ],
      ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardRaised,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        boxShadow: AppColors.softShadow(0.6),
      ),
      child: vLabel(label, size: 11, color: color, weight: FontWeight.w700),
    );
  }
}
