import 'package:flutter/material.dart';

import '../models/item.dart';
import '../repositories/items_repository.dart';
import '../widgets/item_card.dart';
import 'create_item_screen.dart';
import 'favorites_screen.dart';
import 'item_detail_screen.dart';
import 'my_items_screen.dart';

class HomeScreen extends StatefulWidget {
  final ItemsRepository repository;

  const HomeScreen({
    super.key,
    required this.repository,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _activeTagType;
  String? _activeTagValue;
  String? _activeBadgeOrder;
  String? _activePriceTextOrder;
  num? _activePriceAnchor;
  int _cardResetSignal = 0;

  List<Item> get _items => widget.repository.getAllItems();

  int get _favCount => _items.where((item) => item.isFavorite).length;

  String _formatPrice(double price) {
    if (price <= 0) return 'Consultar';
    final isInt = price == price.roundToDouble();
    return isInt ? '\$ ${price.toInt()}' : '\$ ${price.toStringAsFixed(2)}';
  }

  List<({String type, String value, int count})> get _tagStats {
    final counts = <String, int>{};

    void add(String type, String value) {
      final key = '$type::$value';
      counts[key] = (counts[key] ?? 0) + 1;
    }

    for (final item in _items) {
      add('category', item.category);
      if (item.ageSuggested != null && item.ageSuggested!.isNotEmpty) {
        add('age', item.ageSuggested!);
      }
      add('condition', item.condition);
    }

    final rows = counts.entries.map((entry) {
      final parts = entry.key.split('::');
      return (type: parts[0], value: parts[1], count: entry.value);
    }).toList();

    rows.sort((a, b) {
      final byCount = b.count.compareTo(a.count);
      if (byCount != 0) return byCount;
      return a.value.compareTo(b.value);
    });

    return rows;
  }

  String _tagTypeLabel(String type) {
    switch (type) {
      case 'category':
        return 'Categoría';
      case 'age':
        return 'Edad';
      case 'condition':
        return 'Estado';
      default:
        return type;
    }
  }

  void _setTagFilter({required String type, required String value}) {
    setState(() {
      if (_activeTagType == type && _activeTagValue == value) {
        _activeTagType = null;
        _activeTagValue = null;
      } else {
        _activeTagType = type;
        _activeTagValue = value;
      }
    });
  }

  void _clearFilterIfActive() {
    if (_activeTagType == null || _activeTagValue == null) return;
    setState(() {
      _activeTagType = null;
      _activeTagValue = null;
    });
  }

  void _toggleBadgeOrder(String? badge) {
    if (badge == null || badge.trim().isEmpty) return;
    final value = badge.trim();
    setState(() {
      _activeBadgeOrder = _activeBadgeOrder == value ? null : value;
    });
  }

  num? _parsePrice(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9,\.]'), '');
    if (cleaned.isEmpty) return null;
    final normalized = cleaned.replaceAll('.', '').replaceAll(',', '.');
    return num.tryParse(normalized);
  }

  void _togglePriceOrder(String rawPrice) {
    final parsed = _parsePrice(rawPrice);
    if (parsed == null) return;

    setState(() {
      if (_activePriceTextOrder == rawPrice) {
        _activePriceTextOrder = null;
        _activePriceAnchor = null;
      } else {
        _activePriceTextOrder = rawPrice;
        _activePriceAnchor = parsed;
      }
    });
  }

  int _priceGroup(num? price, num anchor) {
    if (price == null) return 2;
    if (price >= anchor) return 0;
    return 1;
  }

  void _clearOrderIfActive() {
    if (_activeBadgeOrder == null && _activePriceAnchor == null) return;
    setState(() {
      _activeBadgeOrder = null;
      _activePriceTextOrder = null;
      _activePriceAnchor = null;
    });
  }

  bool _matchesActiveTag(Item item) {
    if (_activeTagType == null || _activeTagValue == null) return false;
    switch (_activeTagType) {
      case 'category':
        return item.category == _activeTagValue;
      case 'age':
        return item.ageSuggested == _activeTagValue;
      case 'condition':
        return item.condition == _activeTagValue;
      default:
        return false;
    }
  }

  bool _isCardFocused(Item item) {
    if (_activeTagType == null || _activeTagValue == null) return true;
    return _matchesActiveTag(item);
  }

  List<Item> get _visibleItems {
    final list = (_activeTagType == null || _activeTagValue == null)
        ? <Item>[..._items]
        : _items.where(_matchesActiveTag).toList();

    final indexById = <String, int>{
      for (int i = 0; i < _items.length; i++) _items[i].id: i,
    };

    list.sort((a, b) {
      if (_activeBadgeOrder != null) {
        final aFirst = a.badge == _activeBadgeOrder;
        final bFirst = b.badge == _activeBadgeOrder;
        if (aFirst != bFirst) return aFirst ? -1 : 1;
      }

      if (_activePriceAnchor != null) {
        final aPrice = _parsePrice(_formatPrice(a.price));
        final bPrice = _parsePrice(_formatPrice(b.price));
        final aGroup = _priceGroup(aPrice, _activePriceAnchor!);
        final bGroup = _priceGroup(bPrice, _activePriceAnchor!);
        if (aGroup != bGroup) return aGroup.compareTo(bGroup);
        if (aPrice != null && bPrice != null) {
          final byPrice = aPrice.compareTo(bPrice);
          if (byPrice != 0) return byPrice;
        }
      }

      return (indexById[a.id] ?? 0).compareTo(indexById[b.id] ?? 0);
    });

    return list;
  }

  Future<void> _openFavorites() {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FavoritesScreen(repository: widget.repository),
      ),
    );
  }

  Future<void> _openMyItems() {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MyItemsScreen(repository: widget.repository),
      ),
    );
  }

  Future<void> _openPublish() async {
    final itemId = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => CreateItemScreen(repository: widget.repository),
      ),
    );

    if (!mounted || itemId == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(
          itemId: itemId,
          repository: widget.repository,
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _cardResetSignal++);
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
        final items = _visibleItems;

        return Scaffold(
          backgroundColor: const Color(0xFFF8EFF4),
          appBar: AppBar(
            title: PopupMenuButton<(String, String)>(
              tooltip: 'Filtrar por etiquetas',
              onSelected: (value) {
                _setTagFilter(type: value.$1, value: value.$2);
              },
              itemBuilder: (context) {
                return _tagStats
                    .map(
                      (tag) => PopupMenuItem<(String, String)>(
                        value: (tag.type, tag.value),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${tag.value} · ${_tagTypeLabel(tag.type)}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${tag.count}',
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (_activeTagType == tag.type &&
                                _activeTagValue == tag.value) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.check, size: 18),
                            ],
                          ],
                        ),
                      ),
                    )
                    .toList();
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Nido',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.expand_more, size: 20),
                ],
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Mis publicaciones',
                onPressed: _openMyItems,
                icon: const Icon(Icons.checkroom_outlined),
              ),
              if (_activeTagType != null && _activeTagValue != null)
                IconButton(
                  tooltip: 'Quitar filtro',
                  icon: const Icon(Icons.filter_alt_off),
                  onPressed: _clearFilterIfActive,
                ),
              if (_activeBadgeOrder != null || _activePriceAnchor != null)
                IconButton(
                  tooltip: 'Quitar orden',
                  icon: const Icon(Icons.sort),
                  onPressed: _clearOrderIfActive,
                ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton.icon(
                  onPressed: _openFavorites,
                  icon: const Icon(Icons.favorite_border),
                  label: Text('($_favCount)'),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openPublish,
            icon: const Icon(Icons.add),
            label: const Text('Publicar'),
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onTap: _clearFilterIfActive,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final cols = w < 520 ? 2 : (w < 900 ? 3 : 4);
                final spacing = w < 520 ? 10.0 : 12.0;
                final aspect = w < 520 ? 0.78 : 0.68;

                return GridView.builder(
                  padding: EdgeInsets.all(spacing),
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    childAspectRatio: aspect,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final priceLabel = _formatPrice(item.price);

                    return ItemCard(
                      item: item,
                      priceLabel: priceLabel,
                      onFavoriteTap: () => widget.repository.toggleFavorite(item.id),
                      onBadgeTap: () => _toggleBadgeOrder(item.badge),
                      onPriceTap: () => _togglePriceOrder(priceLabel),
                      badgeSelected: _activeBadgeOrder == item.badge,
                      priceSelected: _activePriceTextOrder == priceLabel,
                      isFocused: _isCardFocused(item),
                      resetSignal: _cardResetSignal,
                      onOpenDetailFromImageTap: () => _openDetail(item),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
