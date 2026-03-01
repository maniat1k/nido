import 'package:flutter/material.dart';

import '../data/items_repository.dart';
import '../models/nido_item.dart';
import '../widgets/polaroid_item_card.dart';
import 'item_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final List<NidoItem> items;
  final void Function(String id) onToggleFavorite;
  final void Function(String type, String value) onTagTap;
  final String? activeTagType;
  final String? activeTagValue;

  const FavoritesScreen({
    super.key,
    required this.items,
    required this.onToggleFavorite,
    required this.onTagTap,
    this.activeTagType,
    this.activeTagValue,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ItemsRepository _repository = const ItemsRepository();

  String? _activeTagType;
  String? _activeTagValue;
  int _cardResetSignal = 0;

  @override
  void initState() {
    super.initState();
    _activeTagType = widget.activeTagType;
    _activeTagValue = widget.activeTagValue;
  }

  List<NidoItem> _favsNow() {
    return widget.items.where((item) => item.isFavorite).toList();
  }

  NidoItem? _findItemById(String id) {
    for (final item in widget.items) {
      if (item.id == id) return item;
    }
    return null;
  }

  void _toggleFavAndRefresh(String id) {
    widget.onToggleFavorite(id);
    setState(() {});
  }

  void _setTagFilter(String type, String value) {
    setState(() {
      if (_activeTagType == type && _activeTagValue == value) {
        _activeTagType = null;
        _activeTagValue = null;
      } else {
        _activeTagType = type;
        _activeTagValue = value;
      }
    });

    widget.onTagTap(type, value);
  }

  void _clearFilterIfActive() {
    if (_activeTagType == null || _activeTagValue == null) return;
    final oldType = _activeTagType!;
    final oldValue = _activeTagValue!;

    setState(() {
      _activeTagType = null;
      _activeTagValue = null;
    });

    widget.onTagTap(oldType, oldValue);
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
          onToggleFavorite: (id) {
            widget.onToggleFavorite(id);
            setState(() {});
          },
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
    final favs = _favsNow();

    return Scaffold(
      backgroundColor: const Color(0xFFF8EFF4),
      appBar: AppBar(
        title: const Text('Favoritos'),
        actions: [
          if (_activeTagType != null && _activeTagValue != null)
            IconButton(
              tooltip: 'Quitar filtro',
              icon: const Icon(Icons.filter_alt_off),
              onPressed: _clearFilterIfActive,
            ),
        ],
      ),
      body: favs.isEmpty
          ? const _EmptyFavorites()
          : LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final int cols = w < 520 ? 2 : (w < 900 ? 3 : 4);
                final double spacing = w < 520 ? 10 : 12;
                final double aspect = w < 520 ? 0.78 : 0.68;

                return GridView.builder(
                  padding: EdgeInsets.all(spacing),
                  itemCount: favs.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    childAspectRatio: aspect,
                  ),
                  itemBuilder: (context, i) {
                    final item = favs[i];

                    return PolaroidItemCard(
                      item: item,
                      onFavoriteTap: () => _toggleFavAndRefresh(item.id),
                      isFocused: _isCardFocused(item),
                      backTitle: item.title,
                      backSize: item.size,
                      backInquiries: item.inquiryCount,
                      resetSignal: _cardResetSignal,
                      onOpenDetailFromImageTap: () =>
                          _openDetailFromImageTap(item),
                    );
                  },
                );
              },
            ),
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
                )
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
                  'Marcá con el corazón las prendas que te gustan\npara encontrarlas rápido después 💜',
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
