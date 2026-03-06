import 'package:flutter/material.dart';

import '../data/mock_sellers.dart';
import '../models/item.dart';
import '../repositories/items_repository.dart';
import '../widgets/item_card.dart';
import 'item_detail_screen.dart';

class MyItemsScreen extends StatefulWidget {
  final ItemsRepository repository;

  const MyItemsScreen({
    super.key,
    required this.repository,
  });

  @override
  State<MyItemsScreen> createState() => _MyItemsScreenState();
}

class _MyItemsScreenState extends State<MyItemsScreen> {
  int _cardResetSignal = 0;

  String _formatPrice(double price) {
    if (price <= 0) return 'Consultar';
    final isInt = price == price.roundToDouble();
    return isInt ? '\$ ${price.toInt()}' : '\$ ${price.toStringAsFixed(2)}';
  }

  Future<void> _openDetail(Item item) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(
          itemId: item.id,
          repository: widget.repository,
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _cardResetSignal++);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.repository,
      builder: (context, _) {
        final items = widget.repository.getItemsBySeller(currentMockSeller.id);

        return Scaffold(
          backgroundColor: const Color(0xFFF8EFF4),
          appBar: AppBar(
            title: const Text('Mis publicaciones'),
          ),
          body: items.isEmpty
              ? const _EmptyMyItems()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final columns = width < 520 ? 2 : (width < 900 ? 3 : 4);
                    final spacing = width < 520 ? 10.0 : 12.0;
                    final aspect = width < 520 ? 0.78 : 0.68;

                    return GridView.builder(
                      padding: EdgeInsets.all(spacing),
                      itemCount: items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: aspect,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ItemCard(
                          item: item,
                          priceLabel: _formatPrice(item.price),
                          onFavoriteTap: () =>
                              widget.repository.toggleFavorite(item.id),
                          isFocused: true,
                          resetSignal: _cardResetSignal,
                          onOpenDetailFromImageTap: () => _openDetail(item),
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}

class _EmptyMyItems extends StatelessWidget {
  const _EmptyMyItems();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            'Todavía no publicaste nada.\nCuando cargues una prenda desde Publicar, va a aparecer acá.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
