import 'package:flutter/material.dart';

import '../widgets/polaroid_item_card.dart';
import 'item_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final void Function(String id) onToggleFavorite;

  /// Callback global (Home) para fijar / toggle del filtro activo
  final void Function(String type, String value) onTagTap;

  /// Estado inicial del filtro activo (para reflejar selección al entrar)
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
  String? _activeTagType;
  String? _activeTagValue;
  int _cardResetSignal = 0;

  @override
  void initState() {
    super.initState();
    _activeTagType = widget.activeTagType;
    _activeTagValue = widget.activeTagValue;
  }

  List<Map<String, dynamic>> _favsNow() {
    return widget.items.where((e) => (e['fav'] as bool?) == true).toList();
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

    // ✅ persistir en Home (filtro global)
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

    // ✅ limpiar también el filtro global (Home) toggleando el mismo valor
    widget.onTagTap(oldType, oldValue);
  }

  bool _matchesActiveTag(Map<String, dynamic> item) {
    if (_activeTagType == null || _activeTagValue == null) return false;
    switch (_activeTagType) {
      case 'type':
        return item['type'] == _activeTagValue;
      case 'age':
        return item['age'] == _activeTagValue;
      case 'cond':
        return item['cond'] == _activeTagValue;
      default:
        return false;
    }
  }

  bool _isCardFocused(Map<String, dynamic> item) {
    if (_activeTagType == null || _activeTagValue == null) return true;
    return _matchesActiveTag(item);
  }

  NidoItem _toNidoItem(Map<String, dynamic> it,
      {List<NidoItem> recommended = const []}) {
    return NidoItem(
      id: it['id'] as String,
      title: it['title'] as String?,
      price: (it['price'] as String?) ?? '—',
      size: (it['size'] as String?) ?? '—',
      color: (it['color'] as String?) ?? '—',
      note: (it['note'] as String?) ?? '',
      imageUrls: (it['images'] as List<dynamic>?)?.cast<String>() ??
          [(it['image'] as String?) ?? ''],
      inquiryCount: (it['q'] as int?) ?? 0,
      recommended: recommended,
    );
  }

  Map<String, dynamic>? _findItemById(String id) {
    for (final item in widget.items) {
      if (item['id'] == id) return item;
    }
    return null;
  }

  List<NidoItem> _recommendedFor(String baseId) {
    final others = widget.items.where((x) => x['id'] != baseId).toList();
    final subset = others.take(8).toList();
    return subset.map((e) => _toNidoItem(e)).toList();
  }

  NidoItem? _buildItemWithRecommendations(String id) {
    final raw = _findItemById(id);
    if (raw == null) return null;
    final recommended = _recommendedFor(id);
    return _toNidoItem(raw, recommended: recommended);
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
          isFavorited: (_findItemById(item.id)?['fav'] as bool?) ?? false,
        );
      },
      transitionsBuilder: (_, animation, __, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return FadeTransition(opacity: curved, child: child);
      },
    );
  }

  Future<void> _openDetailFromImageTap(Map<String, dynamic> it) async {
    final itemId = it['id'] as String;
    await Navigator.of(context).push(_buildDetailRoute(itemId));
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
                    final it = favs[i];

                    return PolaroidItemCard(
                      imageUrl: it['image'] as String,
                      priceText: it['price'] as String,
                      badgeText: it['badge'] as String?,
                      isFavorited: (it['fav'] as bool?) == true,
                      onFavoriteTap: () =>
                          _toggleFavAndRefresh(it['id'] as String),
                      isFocused: _isCardFocused(it),
                      backTitle: it['title'] as String?,
                      backSize: it['size'] as String?,
                      backInquiries: it['q'] as int?,
                      resetSignal: _cardResetSignal,
                      onOpenDetailFromImageTap: () =>
                          _openDetailFromImageTap(it),
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
              //color: Colors.white.withOpacity(0.9),
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
                Icon(Icons.favorite_border,
                    size: 44, color: Colors.black.withValues(alpha: 0.55)),
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
