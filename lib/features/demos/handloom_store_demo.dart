import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import 'demo_kit.dart';

/// E-commerce demo: a small handloom store with category filters, a cart
/// with quantities, a free-delivery threshold and a mock checkout.
class HandloomStoreDemo extends StatefulWidget {
  const HandloomStoreDemo({super.key});

  @override
  State<HandloomStoreDemo> createState() => _HandloomStoreDemoState();
}

class _Product {
  const _Product(this.name, this.category, this.price, this.colors);

  final String name;
  final String category;
  final int price;

  /// Two-tone swatch standing in for a product photo.
  final List<Color> colors;
}

class _HandloomStoreDemoState extends State<HandloomStoreDemo> {
  static const _freeDeliveryAt = 2000;
  static const _deliveryFee = 99;
  static const _categories = ['All', 'Sarees', 'Stoles', 'Home'];
  static const _products = [
    _Product('Indigo Cotton Saree', 'Sarees', 2450, [AppColors.demoAccent, AppColors.charcoal]),
    _Product('Ivory-Gold Chanderi Saree', 'Sarees', 3200, [AppColors.demoAccentTint, AppColors.demoAccent]),
    _Product('Handwoven Silk Stole', 'Stoles', 1150, [AppColors.demoAccent, AppColors.charcoalRaised]),
    _Product('Khadi Check Stole', 'Stoles', 690, [AppColors.lightGrey, AppColors.softGrey]),
    _Product('Ikat Cushion Cover', 'Home', 540, [AppColors.softGrey, AppColors.charcoal]),
    _Product('Woven Table Runner', 'Home', 820, [AppColors.demoAccentTint, AppColors.charcoalRaised]),
  ];

  String _category = 'All';
  final Map<_Product, int> _cart = {};
  bool _ordered = false;

  int get _items => _cart.values.fold(0, (a, b) => a + b);
  int get _subtotal => _cart.entries.fold(0, (sum, e) => sum + e.key.price * e.value);
  int get _delivery => _subtotal == 0 || _subtotal >= _freeDeliveryAt ? 0 : _deliveryFee;

  void _change(_Product p, int delta) {
    setState(() {
      _ordered = false;
      final next = (_cart[p] ?? 0) + delta;
      if (next <= 0) {
        _cart.remove(p);
      } else {
        _cart[p] = next;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _category == 'All' ? _products : _products.where((p) => p.category == _category).toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 820;
        final pad = wide ? 32.0 : 16.0;
        final gridWidth = wide ? constraints.maxWidth * 0.64 - pad : constraints.maxWidth - pad * 2;
        final columns = gridWidth >= 520 ? 3 : 2;
        final tileWidth = (gridWidth - (columns - 1) * 14) / columns;

        final catalogue = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in _categories)
                  DemoChip(label: c, selected: c == _category, onTap: () => setState(() => _category = c)),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final p in visible)
                  SizedBox(
                    width: tileWidth,
                    child: _ProductTile(product: p, inCart: _cart[p] ?? 0, onAdd: () => _change(p, 1)),
                  ),
              ],
            ),
          ],
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: pad, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: DemoColors.line)),
              ),
              child: Row(
                children: [
                  Text('Weave & Co.', style: AppTypography.display(fontSize: 20, color: DemoColors.ink, height: 1.2)),
                  const SizedBox(width: 10),
                  if (wide)
                    Text(
                      'Handloom, made slowly',
                      style: AppTypography.body(fontSize: 13.5, color: DemoColors.muted, height: 1.2),
                    ),
                  const Spacer(),
                  Badge(
                    isLabelVisible: _items > 0,
                    backgroundColor: AppColors.demoAccent,
                    label: Text('$_items'),
                    child: const Icon(Icons.shopping_bag_outlined, color: DemoColors.ink),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(pad),
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: gridWidth, child: catalogue),
                        SizedBox(width: pad),
                        Expanded(child: _cartPanel()),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [catalogue, const SizedBox(height: 24), _cartPanel()],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _cartPanel() {
    final remaining = _freeDeliveryAt - _subtotal;
    TextStyle line([bool strong = false]) => AppTypography.body(
      fontSize: 14,
      fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
      color: DemoColors.ink,
      height: 1.3,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DemoColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: DemoColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Your Cart', style: AppTypography.display(fontSize: 20, color: DemoColors.ink, height: 1.2)),
          const SizedBox(height: 14),
          if (_ordered)
            Column(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.demoAccent, size: 44),
                const SizedBox(height: 10),
                Text('Order placed (demo)', style: AppTypography.display(fontSize: 18, color: DemoColors.ink, height: 1.3)),
                const SizedBox(height: 6),
                Text(
                  'No payment was taken. A real store would continue to a payment gateway here.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body(fontSize: 13.5, color: DemoColors.text, height: 1.55),
                ),
              ],
            )
          else if (_cart.isEmpty)
            Text(
              'Your cart is empty. Add something you love.',
              style: AppTypography.body(fontSize: 14, color: DemoColors.muted, height: 1.5),
            )
          else ...[
            for (final e in _cart.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.key.name, style: line(true)),
                          Text(
                            rupees(e.key.price),
                            style: AppTypography.body(fontSize: 13, color: DemoColors.muted, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    _QtyButton(icon: Icons.remove_rounded, label: 'Remove one ${e.key.name}', onTap: () => _change(e.key, -1)),
                    SizedBox(
                      width: 30,
                      child: Text('${e.value}', textAlign: TextAlign.center, style: line(true)),
                    ),
                    _QtyButton(icon: Icons.add_rounded, label: 'Add one ${e.key.name}', onTap: () => _change(e.key, 1)),
                  ],
                ),
              ),
            const Divider(color: DemoColors.line, height: 20),
            _row('Subtotal', rupees(_subtotal), line()),
            _row('Delivery', _delivery == 0 ? 'Free' : rupees(_delivery), line()),
            const SizedBox(height: 4),
            _row('Total', rupees(_subtotal + _delivery), line(true)),
            const SizedBox(height: 12),
            Text(
              remaining > 0 ? 'Add ${rupees(remaining)} more for free delivery.' : 'You have unlocked free delivery.',
              style: AppTypography.body(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.demoAccent, height: 1.4),
            ),
            const SizedBox(height: 16),
            DemoButton(
              label: 'Checkout',
              icon: Icons.lock_outline_rounded,
              expand: true,
              onPressed: () => setState(() {
                _cart.clear();
                _ordered = true;
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value, TextStyle style) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    ),
  );
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.inCart, required this.onAdd});

  final _Product product;
  final int inCart;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DemoColors.page,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: DemoColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: product.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: CustomPaint(painter: _WeavePainter()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  style: AppTypography.body(fontSize: 14, fontWeight: FontWeight.w700, color: DemoColors.ink, height: 1.3),
                ),
                const SizedBox(height: 4),
                Text(rupees(product.price), style: AppTypography.body(fontSize: 14, color: DemoColors.text, height: 1.3)),
                const SizedBox(height: 10),
                DemoButton(
                  label: inCart > 0 ? 'Add more ($inCart)' : 'Add to cart',
                  expand: true,
                  outlined: inCart > 0,
                  onPressed: onAdd,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fine diagonal threads so swatches read as woven fabric.
class _WeavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (double x = -size.height; x < size.width; x += 9) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), paint);
    }
    for (double y = 0; y < size.height; y += 14) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: label,
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      color: DemoColors.ink,
      style: IconButton.styleFrom(
        backgroundColor: DemoColors.page,
        side: const BorderSide(color: DemoColors.line),
        minimumSize: const Size(32, 32),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
