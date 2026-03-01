import 'package:flutter/material.dart';

import '../data/items_repository.dart';
import '../models/nido_item.dart';
import '../widgets/polaroid_item_card.dart';
import 'favorites_screen.dart';
import 'item_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ItemsRepository _repository = const ItemsRepository();

  String? _activeTagType;
  String? _activeTagValue;
  String? _activeBadgeOrder;
  String? _activePriceTextOrder;
  num? _activePriceAnchor;
  int _cardResetSignal = 0;

  late final List<NidoItem> _items = _repository.getAllItems();

  int get _favCount => _items.where((item) => item.isFavorite).length;

  List<({String type, String value, int count})> get _tagStats {
    final Map<String, int> counts = {};

    void add(String type, String value) {
      final key = '$type::$value';
      counts[key] = (counts[key] ?? 0) + 1;
    }

    for (final item in _items) {
      add('type', item.type);
      add('age', item.age);
      add('cond', item.condition);
    }

    final rows = counts.entries.map((e) {
      final parts = e.key.split('::');
      return (type: parts[0], value: parts[1], count: e.value);
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
      case 'type':
        return 'Tipo';
      case 'age':
        return 'Edad';
      case 'cond':
        return 'Estado';
      default:
        return type;
    }
  }

  NidoItem? _findItemById(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  void _toggleFavorite(String id) {
    setState(() {
      final idx = _items.indexWhere((item) => item.id == id);
      if (idx == -1) return;
      final current = _items[idx];
      _items[idx] = current.copyWith(isFavorite: !current.isFavorite);
    });
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

  bool _matchesActiveTag(NidoItem item) {
    if (_activeTagType == null || _activeTagValue == null) return false;
    switch (_activeTagType) {
      case 'type':
        return item.type == _activeTagValue;
      case 'age':
        return item.age == _activeTagValue;
      case 'cond':
        return item.condition == _activeTagValue;
      default:
        return false;
    }
  }

  bool _isCardFocused(NidoItem item) {
    if (_activeTagType == null || _activeTagValue == null) return true;
    return _matchesActiveTag(item);
  }

  List<NidoItem> get _visibleItems {
    final list = (_activeTagType == null || _activeTagValue == null)
        ? <NidoItem>[..._items]
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
        final aPrice = _parsePrice(a.price);
        final bPrice = _parsePrice(b.price);
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

  void _openFavorites() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FavoritesScreen(
          items: _items,
          onToggleFavorite: _toggleFavorite,
          onTagTap: (type, value) => _setTagFilter(type: type, value: value),
          activeTagType: _activeTagType,
          activeTagValue: _activeTagValue,
        ),
      ),
    );
  }

  void _openPublish() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Publicar'),
        content:
            const Text('Aquí comenzará el flujo de publicación (Paso 1: Fotos).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  List<NidoItem> _recommendedFor(NidoItem baseItem) {
    final seedRelated = _repository.getRelatedItems(baseItem, limit: 8);
    return seedRelated
        .map((seedItem) => _findItemById(seedItem.id) ?? seedItem)
        .toList();
  }

  NidoItem? _buildItemWithRecommendations(String id) {
    final item = _findItemById(id);
    if (item == null) return null;
    return item.copyWith(recommended: _recommendedFor(item));
  }

  Route _buildDetailRoute(String itemId) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (context, _, __) {
        final item = _buildItemWithRecommendations(itemId);
        if (item == null) {
          return const Scaffold(
            body: SafeArea(
              child: Center(child: Text('Producto no disponible')),
            ),
          );
        }
        return ItemDetailScreen(
          item: item,
          onBack: () => Navigator.of(context).pop(),
          onBackToHome: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
          onBackToImageSelection: (it) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ItemImageSelectionScreen(
                  item: it,
                  onOpenDetail: () => Navigator.of(context).pop(),
                ),
              ),
            );
          },
          onToggleFavorite: _toggleFavorite,
          onChat: (it) {},
          onBuy: (it) {},
          onOpenRecommended: (it) {
            Navigator.of(context).push(_buildDetailRoute(it.id));
          },
          isFavorited: (_findItemById(item.id)?.isFavorite) ?? false,
        );
      },
      transitionsBuilder: (_, animation, __, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return FadeTransition(opacity: curved, child: child);
      },
    );
  }

  Future<void> _openDetailFromImageTap(NidoItem item) async {
    await Navigator.of(context).push(_buildDetailRoute(item.id));
    if (!mounted) return;
    setState(() => _cardResetSignal++);
  }

  @override
  Widget build(BuildContext context) {
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
          builder: (context, c) {
            final w = c.maxWidth;

            final int cols = w < 520 ? 2 : (w < 900 ? 3 : 4);
            final double spacing = w < 520 ? 10 : 12;
            final double aspect = w < 520 ? 0.78 : 0.68;

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

                return PolaroidItemCard(
                  item: item,
                  onFavoriteTap: () => _toggleFavorite(item.id),
                  onBadgeTap: () => _toggleBadgeOrder(item.badge),
                  onPriceTap: () => _togglePriceOrder(item.price),
                  badgeSelected: _activeBadgeOrder == item.badge,
                  priceSelected: _activePriceTextOrder == item.price,
                  isFocused: _isCardFocused(item),
                  backTitle: item.title,
                  backSize: item.size,
                  backInquiries: item.inquiryCount,
                  resetSignal: _cardResetSignal,
                  onOpenDetailFromImageTap: () => _openDetailFromImageTap(item),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
