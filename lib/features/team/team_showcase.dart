import 'package:flutter/material.dart';

import '../../core/constants/site_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../models/team_member.dart';
import '../../shared/widgets/reveal.dart';

/// Two-row team layout: the leadership pair first, then the development
/// team. Every card within a row shares one size and one structure.
///
/// Desktop shows 2 + 3 across, tablets 2 across, phones one card per row.
/// Every fact and photo comes from [TeamConfig]; photos are the people's own,
/// cropped by layout only.
class TeamShowcase extends StatelessWidget {
  const TeamShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final gap = context.responsive(mobile: 20.0, desktop: 24.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Reveal(child: _GroupHeading('Leadership Team')),
        SizedBox(height: context.responsive(mobile: 24.0, desktop: 32.0)),
        _CenteredGrid(
          columns: context.responsive(mobile: 1, desktop: 2),
          spacing: gap,
          children: [
            for (final (i, m) in TeamConfig.leadership.indexed)
              Reveal(
                delay: Duration(milliseconds: 100 * i),
                child: _LeaderCard(member: m),
              ),
          ],
        ),
        SizedBox(height: context.responsive(mobile: 64.0, desktop: 88.0)),
        const Reveal(child: _GroupHeading('Development Team')),
        SizedBox(height: context.responsive(mobile: 24.0, desktop: 32.0)),
        _CenteredGrid(
          columns: context.responsive(mobile: 1, tablet: 2, desktop: 3),
          spacing: gap,
          children: [
            for (final (i, m) in TeamConfig.development.indexed)
              Reveal(
                delay: Duration(milliseconds: 100 * i),
                child: _DeveloperCard(member: m),
              ),
          ],
        ),
      ],
    );
  }
}

/// Rows of equal-width, equal-height cards; an incomplete last row keeps the
/// same card width and sits centred instead of hugging the left edge.
class _CenteredGrid extends StatelessWidget {
  const _CenteredGrid({required this.columns, required this.spacing, required this.children});

  final int columns;
  final double spacing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += columns) {
          final rowChildren = children.sublist(i, (i + columns).clamp(0, children.length));
          // A fixed row width with Expanded cards keeps IntrinsicHeight's
          // measurement exact, so every card in the row matches the tallest.
          rows.add(
            Center(
              child: SizedBox(
                width: itemWidth * rowChildren.length + spacing * (rowChildren.length - 1),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (c, child) in rowChildren.indexed) ...[
                        if (c > 0) SizedBox(width: spacing),
                        Expanded(child: child),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
          if (i + columns < children.length) rows.add(SizedBox(height: spacing));
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
      },
    );
  }
}

/// Centred uppercase group title between two fading rules.
class _GroupHeading extends StatelessWidget {
  const _GroupHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    Widget rule(Alignment from) => Expanded(
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: from, end: -from, colors: [Colors.transparent, AppColors.cyan.withValues(alpha: 0.55)]),
        ),
      ),
    );

    return Row(
      children: [
        rule(Alignment.centerLeft),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Semantics(
            header: true,
            child: Text(
              text.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppTypography.display(
                fontSize: context.responsive(mobile: 15.0, desktop: 17.0),
                fontWeight: FontWeight.w700,
                color: AppColors.cyan,
                letterSpacing: 3,
                height: 1.3,
              ),
            ),
          ),
        ),
        rule(Alignment.centerRight),
      ],
    );
  }
}

// ---------------------------------------------------------------- Leaders

/// Founder and Partner share this card exactly: portrait beside the details
/// on wide screens, portrait above them on narrower ones.
class _LeaderCard extends StatelessWidget {
  const _LeaderCard({required this.member});

  final TeamMember member;

  /// Below this the text column gets too narrow for the longer introductions.
  static const double _sideBySide = 1200;

  @override
  Widget build(BuildContext context) {
    final sideBySide = context.screenWidth >= _sideBySide;
    return _CardShell(
      builder: (hover) {
        final portrait = _Portrait(member: member, aspectRatio: sideBySide ? 4 / 5 : 4 / 3, active: hover);
        final details = _Details(member: member, nameSize: context.responsive(mobile: 22.0, desktop: 24.0));
        // Stretched: the portrait is at least 4:5 and grows with the text, so
        // both leader cards (equal height) keep identical portraits.
        return sideBySide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 5, child: portrait),
                  const SizedBox(width: 26),
                  Expanded(
                    flex: 7,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: details),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  portrait,
                  Padding(padding: const EdgeInsets.fromLTRB(6, 22, 6, 6), child: details),
                ],
              );
      },
    );
  }
}

// ------------------------------------------------------------- Developers

class _DeveloperCard extends StatelessWidget {
  const _DeveloperCard({required this.member});

  final TeamMember member;

  @override
  Widget build(BuildContext context) {
    final photoSize = context.responsive(mobile: 150.0, tablet: 160.0, desktop: 176.0);
    return _CardShell(
      builder: (hover) => Padding(
        padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
        child: Column(
          children: [
            SizedBox.square(
              dimension: photoSize,
              child: _Portrait(member: member, aspectRatio: 1, active: hover),
            ),
            const SizedBox(height: 22),
            _Details(member: member, nameSize: 20, centered: true),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------- Shared

/// Navy card with a cyan border that lifts and glows on hover.
class _CardShell extends StatefulWidget {
  const _CardShell({required this.builder});

  final Widget Function(bool hover) builder;

  @override
  State<_CardShell> createState() => _CardShellState();
}

class _CardShellState extends State<_CardShell> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: AppMotion.lift,
        curve: AppMotion.ease,
        transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
        padding: EdgeInsets.all(context.responsive(mobile: 14.0, desktop: 16.0)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          gradient: const LinearGradient(
            colors: [Color(0xFF17264F), AppColors.midnightNavy, AppColors.deepNavy],
            stops: [0, 0.6, 1],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.cyan.withValues(alpha: _hover ? 0.7 : 0.28), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: (_hover ? AppColors.cyan : AppColors.electricBlue).withValues(alpha: _hover ? 0.24 : 0.10),
              blurRadius: _hover ? 52 : 36,
              spreadRadius: -8,
              offset: const Offset(0, 18),
            ),
            ...AppColors.softShadow(0.6),
          ],
        ),
        child: widget.builder(_hover),
      ),
    );
  }
}

/// A supplied portrait, cropped by the member's photo alignment only. A
/// gentle zoom on hover is the only motion; colour and content are untouched.
class _Portrait extends StatelessWidget {
  const _Portrait({required this.member, required this.aspectRatio, required this.active});

  final TeamMember member;
  final double aspectRatio;
  final bool active;

  @override
  Widget build(BuildContext context) {
    const radius = AppRadius.lg;
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: AppColors.cyan.withValues(alpha: active ? 0.55 : 0.22)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius - 1),
          child: AnimatedScale(
            duration: AppMotion.lift,
            curve: AppMotion.ease,
            scale: member.photoZoom * (active ? 1.03 : 1),
            alignment: member.photoAlignment,
            child: Image.asset(
              member.photoPath,
              fit: BoxFit.cover,
              alignment: member.photoAlignment,
              width: double.infinity,
              height: double.infinity,
              filterQuality: FilterQuality.high,
              semanticLabel: 'Portrait of ${member.name}, ${member.designation}',
            ),
          ),
        ),
      ),
    );
  }
}

/// Name, designation pill and introduction — identical for every card.
class _Details extends StatelessWidget {
  const _Details({required this.member, required this.nameSize, this.centered = false});

  final TeamMember member;
  final double nameSize;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final textAlign = centered ? TextAlign.center : TextAlign.start;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          member.name,
          textAlign: textAlign,
          style: AppTypography.display(fontSize: nameSize, fontWeight: FontWeight.w700, height: 1.25),
        ),
        const SizedBox(height: 12),
        _DesignationPill(member.designation),
        const SizedBox(height: 16),
        Container(
          width: 40,
          height: 2,
          decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(AppRadius.pill)),
        ),
        const SizedBox(height: 16),
        Text(member.introduction, textAlign: textAlign, style: AppTypography.body(fontSize: 15, height: 1.7)),
      ],
    );
  }
}

class _DesignationPill extends StatelessWidget {
  const _DesignationPill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.electricBlue.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.4)),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.body(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: AppColors.iceBlue,
          letterSpacing: 1.2,
          height: 1.2,
        ),
      ),
    );
  }
}
