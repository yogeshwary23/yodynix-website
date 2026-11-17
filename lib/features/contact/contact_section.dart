import 'package:flutter/material.dart';

import '../../core/constants/site_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../repositories/contact_repository.dart';
import '../../models/social_link.dart';
import '../../services/link_service.dart';
import '../../shared/three/scene3d.dart';
import '../../shared/three/scene_widgets.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/section_widgets.dart';
import 'contact_form.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key, this.repository = const ApiContactRepository()});

  final ContactRepository repository;

  @override
  Widget build(BuildContext context) {
    const info = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          eyebrow: 'Contact',
          title: "Let's Start a Conversation.",
          lead:
              'Tell us about your idea, project or question. We read every enquiry and '
              'reply with clear next steps.',
        ),
        SizedBox(height: 32),
        Reveal(child: _ContactChannels()),
      ],
    );

    // The connection network leans towards the cursor anywhere over the section.
    final network = Reveal(
      child: AspectRatio(
        aspectRatio: context.responsive(mobile: 1.6, tablet: 2.4, desktop: 3.2),
        child: const Section3DScene(
          scene: Scene3D.network,
          background: AppColors.surface,
          semanticLabel:
              'A sphere of champagne-gold, platinum and glass nodes linked by fine gold lines, '
              'with light travelling between connections.',
          fallback: SizedBox.shrink(),
        ),
      ),
    );

    final form = Reveal(
      delay: const Duration(milliseconds: 120),
      child: FormCard(
        padding: EdgeInsets.all(context.responsive(mobile: 22.0, desktop: 40.0)),
        radius: 28,
        child: ContactForm(repository: repository),
      ),
    );

    return SectionShell(
      background: AppColors.surface,
      glowAt: const Alignment(0.9, 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          network,
          SizedBox(height: context.responsive(mobile: 16.0, desktop: 24.0)),
          if (context.isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: info),
                const SizedBox(width: 56),
                Expanded(flex: 7, child: form),
              ],
            )
          else ...[info, const SizedBox(height: 40), form],
        ],
      ),
    );
  }
}

class _ContactChannels extends StatelessWidget {
  const _ContactChannels();

  @override
  Widget build(BuildContext context) {
    const email = ContactConfig.email;
    const whatsapp = ContactConfig.whatsappNumber;
    final social = SocialConfig.links;

    final channels = [
      _Channel(
        icon: Icons.mail_outline_rounded,
        label: 'Email',
        lines: [_ChannelLine(email, () => LinkService.email(email, subject: 'Project enquiry'))],
        color: AppColors.accent,
      ),
      _Channel(
        icon: Icons.call_outlined,
        label: 'Phone',
        lines: [for (final phone in ContactConfig.phones) _ChannelLine(phone, () => LinkService.call(phone))],
        color: AppColors.mint,
      ),
      _Channel(
        icon: Icons.chat_outlined,
        label: 'WhatsApp',
        lines: [
          if (whatsapp != null)
            _ChannelLine(
              'Chat with us',
              () => LinkService.whatsapp(whatsapp, message: 'Hello Yodynix, I would like to discuss a project.'),
            ),
        ],
        color: const Color(0xFF25D366),
      ),
      if (social.isEmpty)
        const _Channel(icon: Icons.public_rounded, label: 'Social Media', lines: [], color: AppColors.accent)
      else
        _Channel(
          icon: social.first.platform.icon,
          leading: social.first.platform == SocialPlatform.instagram ? const _InstagramLogo(size: 42) : null,
          label: social.first.platform.label,
          lines: [_ChannelLine(social.first.handle ?? social.first.platform.label, () => LinkService.open(social.first.url))],
          color: AppColors.accent,
          external: true,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResponsiveGrid(minItemWidth: 220, maxColumns: 2, spacing: 14, children: channels),
        const SizedBox(height: 14),
        _Channel(
          icon: Icons.location_on_outlined,
          label: 'Office Address',
          lines: const [_ChannelLine(ContactConfig.address, null, wrap: true)],
          color: AppColors.charcoal,
          action: _ChannelLine('Get Directions', () => LinkService.open(ContactConfig.directionsUrl)),
        ),
      ],
    );
  }
}

/// One line of a contact card; tappable when [onTap] is set.
class _ChannelLine {
  const _ChannelLine(this.text, this.onTap, {this.wrap = false});

  final String text;
  final VoidCallback? onTap;
  final bool wrap;
}

class _Channel extends StatelessWidget {
  const _Channel({
    required this.icon,
    required this.label,
    required this.lines,
    required this.color,
    this.action,
    this.leading,
    this.external = false,
  });

  final IconData icon;

  /// Replaces the icon badge, e.g. with a platform's own logo.
  final Widget? leading;

  /// Marks a card that opens another site with an outward arrow.
  final bool external;
  final String label;

  /// Empty until configured in [ContactConfig] / [SocialConfig].
  final List<_ChannelLine> lines;
  final Color color;
  final _ChannelLine? action;

  @override
  Widget build(BuildContext context) {
    // A single link makes the whole card the tap target; several links
    // (e.g. two phone numbers) are tapped individually.
    final cardTap = lines.length == 1 && action == null ? lines.first.onTap : null;
    return HoverCard(
      padding: const EdgeInsets.all(18),
      radius: 18,
      onTap: cardTap,
      child: Row(
        crossAxisAlignment: lines.length > 1 || action != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          leading ?? IconBadge(icon: icon, color: color, size: 42),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.body(fontSize: 12.5, color: AppColors.cardMuted, height: 1.3)),
                const SizedBox(height: 3),
                if (lines.isEmpty)
                  Text('Coming soon', style: _valueStyle(AppColors.cardMuted))
                else
                  for (final line in lines)
                    cardTap != null || line.onTap == null
                        ? Text(
                            line.text,
                            maxLines: line.wrap ? null : 1,
                            overflow: line.wrap ? null : TextOverflow.ellipsis,
                            style: _valueStyle(AppColors.cardHeading),
                          )
                        : _LineLink(line: line, color: AppColors.cardHeading),
                if (action != null) ...[
                  const SizedBox(height: 8),
                  _LineLink(line: action!, color: AppColors.cardAccent, icon: Icons.north_east_rounded),
                ],
              ],
            ),
          ),
          if (external) ...[
            const SizedBox(width: 8),
            Icon(Icons.north_east_rounded, size: 16, color: AppColors.cardAccent.withValues(alpha: 0.85)),
          ],
        ],
      ),
    );
  }
}

TextStyle _valueStyle(Color color) => AppTypography.body(fontSize: 14.5, fontWeight: FontWeight.w600, color: color, height: 1.45);

class _LineLink extends StatefulWidget {
  const _LineLink({required this.line, required this.color, this.icon});

  final _ChannelLine line;
  final Color color;
  final IconData? icon;

  @override
  State<_LineLink> createState() => _LineLinkState();
}

class _LineLinkState extends State<_LineLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final color = _hover ? AppColors.cardAccent : widget.color;
    return Semantics(
      link: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.line.onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(widget.line.text, maxLines: 1, overflow: TextOverflow.ellipsis, style: _valueStyle(color)),
              ),
              if (widget.icon != null) ...[const SizedBox(width: 4), Icon(widget.icon, size: 15, color: color)],
            ],
          ),
        ),
      ),
    );
  }
}

/// The Instagram glyph — camera outline on the brand gradient — drawn in
/// code so no third-party icon package or image asset is needed.
class _InstagramLogo extends StatelessWidget {
  const _InstagramLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: const RadialGradient(
          center: Alignment(-0.7, 1.15),
          radius: 1.45,
          // Champagne rather than Instagram's own gradient, which runs into
          // blue: the site palette has no blue.
          colors: [
            Color(0xFFF1E2BF),
            Color(0xFFD9BC82),
            Color(0xFFC6A46A),
            Color(0xFFA98245),
            Color(0xFF7A5A28),
          ],
          stops: [0, 0.25, 0.5, 0.75, 1],
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFFA98245).withValues(alpha: 0.28), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: CustomPaint(painter: _InstagramGlyphPainter()),
    );
  }
}

class _InstagramGlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.075;
    final body = Rect.fromLTWH(s * 0.22, s * 0.22, s * 0.56, s * 0.56);
    canvas.drawRRect(RRect.fromRectAndRadius(body, Radius.circular(s * 0.16)), stroke);
    canvas.drawCircle(Offset(s / 2, s / 2), s * 0.13, stroke);
    canvas.drawCircle(Offset(s * 0.665, s * 0.335), s * 0.04, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
