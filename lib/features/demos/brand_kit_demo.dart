import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import 'demo_kit.dart';

/// Branding demo: type a business name, pick a palette and a font pairing,
/// and see a logo mark, business card and social post update together.
class BrandKitDemo extends StatefulWidget {
  const BrandKitDemo({super.key});

  @override
  State<BrandKitDemo> createState() => _BrandKitDemoState();
}

class _Palette {
  const _Palette(this.name, this.primary, this.secondary, this.dark);

  final String name;
  final Color primary;
  final Color secondary;
  final Color dark;
}

class _BrandKitDemoState extends State<BrandKitDemo> {
  static const _palettes = [
    _Palette('Electric', AppColors.electricBlue, AppColors.cyan, AppColors.midnightNavy),
    _Palette('Glacier', AppColors.iceBlue, AppColors.lightGrey, AppColors.surfaceNavy),
    _Palette('Midnight', AppColors.cyan, AppColors.iceBlue, AppColors.deepNavy),
  ];

  // Heading/body pairings, both already used by the site (no new fonts).
  static const _pairings = ['Sora + Inter', 'Inter + Sora', 'Sora + Sora'];

  final _name = TextEditingController(text: 'Northwind Tea');
  int _palette = 0;
  int _pairing = 0;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  String get _brand => _name.text.trim().isEmpty ? 'Your Brand' : _name.text.trim();

  String get _initials {
    final words = _brand.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }

  TextStyle _heading(double size, Color color) {
    final sora = _pairing != 1;
    return (sora ? GoogleFonts.sora : GoogleFonts.inter)(fontSize: size, fontWeight: FontWeight.w700, color: color, height: 1.2);
  }

  TextStyle _bodyText(double size, Color color) {
    final inter = _pairing == 0;
    return (inter ? GoogleFonts.inter : GoogleFonts.sora)(
      fontSize: size,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.45,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _palettes[_palette];
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 800;
        final controls = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Brand Kit Builder', style: AppTypography.display(fontSize: 22, color: DemoColors.ink, height: 1.2)),
            const SizedBox(height: 16),
            DemoField(label: 'Business name', controller: _name),
            const SizedBox(height: 18),
            _label('Palette'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < _palettes.length; i++)
                  Semantics(
                    button: true,
                    selected: i == _palette,
                    label: '${_palettes[i].name} palette',
                    child: InkWell(
                      onTap: () => setState(() => _palette = i),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: i == _palette ? AppColors.electricBlue : DemoColors.line,
                            width: i == _palette ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (final c in [_palettes[i].primary, _palettes[i].secondary, _palettes[i].dark])
                                  Container(width: 22, height: 22, color: c),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _palettes[i].name,
                              style: AppTypography.body(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: DemoColors.text,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            _label('Font pairing (heading + body)'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < _pairings.length; i++)
                  DemoChip(label: _pairings[i], selected: i == _pairing, onTap: () => setState(() => _pairing = i)),
              ],
            ),
          ],
        );

        final previews = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _label('Logo'),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: DemoColors.panel, borderRadius: BorderRadius.circular(AppRadius.md)),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [p.primary, p.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(_initials, style: _heading(22, p.dark)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(_brand, maxLines: 2, overflow: TextOverflow.ellipsis, style: _heading(24, p.dark)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _label('Business card & social post'),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                Container(
                  width: 280,
                  height: 160,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: p.dark, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_brand, maxLines: 1, overflow: TextOverflow.ellipsis, style: _heading(17, AppColors.white)),
                      Container(width: 36, height: 3, margin: const EdgeInsets.symmetric(vertical: 8), color: p.secondary),
                      const Spacer(),
                      Text('Asha Kulkarni · Founder', style: _bodyText(12.5, AppColors.white)),
                      Text('hello@yourbrand.example', style: _bodyText(12, p.secondary)),
                    ],
                  ),
                ),
                Container(
                  width: 160,
                  height: 160,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [p.primary, p.dark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NEW', style: _bodyText(11, p.secondary)),
                      const Spacer(),
                      Text('Fresh this season', style: _heading(16, AppColors.white)),
                      const SizedBox(height: 4),
                      Text(_brand, maxLines: 1, overflow: TextOverflow.ellipsis, style: _bodyText(11.5, AppColors.white)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _label('Colour tokens'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final (name, c) in [('Primary', p.primary), ('Accent', p.secondary), ('Ink', p.dark)])
                  Container(
                    width: 136,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: DemoColors.panel, borderRadius: BorderRadius.circular(AppRadius.sm)),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(8)),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: AppTypography.body(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: DemoColors.ink,
                                height: 1.2,
                              ),
                            ),
                            Text(_hex(c), style: AppTypography.body(fontSize: 11.5, color: DemoColors.muted, height: 1.3)),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        );

        return Padding(
          padding: EdgeInsets.all(wide ? 28 : 16),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: controls),
                    const SizedBox(width: 28),
                    Expanded(flex: 6, child: previews),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [controls, const SizedBox(height: 24), previews],
                ),
        );
      },
    );
  }

  static String _hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text.toUpperCase(),
      style: AppTypography.body(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: DemoColors.muted,
        letterSpacing: 1.2,
        height: 1.2,
      ),
    ),
  );
}
