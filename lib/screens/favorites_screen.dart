import 'package:flutter/material.dart';

import '../models/item.dart';
import '../repositories/items_repository.dart';
import '../widgets/item_card.dart';
import 'item_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final ItemsRepository repository;

  const FavoritesScreen({
    super.key,
    required this.repository,
  });

  String _formatPrice(double price) {
    if (price <= 0) return 'Consultar';
    final isInt = price == price.roundToDouble();
    return isInt ? '\$ ${price.toInt()}' : '\$ ${price.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) {
        final favorites =
            repository.getAllItems().where((item) => item.isFavorite).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8EFF4),
          appBar: AppBar(title: const Text('Favoritos')),
          body: favorites.isEmpty
              ? const _EmptyFavorites()
              : _ItemsGrid(
                  items: favorites,
                  repository: repository,
                  priceFormatter: _formatPrice,
                ),
        );
      },
    );
  }
}

class _ItemsGrid extends StatefulWidget {
  final List<Item> items;
  final ItemsRepository repository;
  final String Function(double price) priceFormatter;

  const _ItemsGrid({
    required this.items,
    required this.repository,
    required this.priceFormatter,
  });

  @override
  State<_ItemsGrid> createState() => _ItemsGridState();
}

class _ItemsGridState extends State<_ItemsGrid> {
  int _cardResetSignal = 0;

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width < 520 ? 2 : (width < 900 ? 3 : 4);
        final spacing = width < 520 ? 10.0 : 12.0;
        final aspect = width < 520 ? 0.78 : 0.68;

        return GridView.builder(
          padding: EdgeInsets.all(spacing),
          itemCount: widget.items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: aspect,
          ),
          itemBuilder: (context, index) {
            final item = widget.items[index];
            return ItemCard(
              item: item,
              priceLabel: widget.priceFormatter(item.price),
              onFavoriteTap: () => widget.repository.toggleFavorite(item.id),
              isFocused: true,
              resetSignal: _cardResetSignal,
              onOpenDetailFromImageTap: () => _openDetail(item),
            );
          },
        );
      },
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10,
                  offset: Offset(0, 6),
                  color: Color(0x14000000),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 44,
                  color: Colors.black.withValues(alpha: 0.55),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Todavía no tenés favoritos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Marcá con el corazón las prendas que te gustan para encontrarlas rápido después.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Colors.black.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
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
