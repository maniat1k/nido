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

  Future<void> _openDetail(Map<String, dynamic> it) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(
          item: it,
          onToggleFavorite: () => widget.onToggleFavorite(it['id'] as String),
          onTagTap: (t, v) => _setTagFilter(t, v),
          activeTagType: _activeTagType,
          activeTagValue: _activeTagValue,
        ),
      ),
    );

    setState(() {});
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
                      typeText: it['type'] as String,
                      ageText: it['age'] as String,
                      conditionText: it['cond'] as String,
                      typeSelected: _activeTagType == 'type' &&
                          _activeTagValue == (it['type'] as String),
                      ageSelected: _activeTagType == 'age' &&
                          _activeTagValue == (it['age'] as String),
                      conditionSelected: _activeTagType == 'cond' &&
                          _activeTagValue == (it['cond'] as String),
                      onTypeTap: () =>
                          _setTagFilter('type', it['type'] as String),
                      onAgeTap: () => _setTagFilter('age', it['age'] as String),
                      onConditionTap: () =>
                          _setTagFilter('cond', it['cond'] as String),
                      isFocused: _matchesActiveTag(it),
                      onOpen: () => _openDetail(it),
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
              color: Colors.white.withOpacity(0.9),
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
                    size: 44, color: Colors.black.withOpacity(0.55)),
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
                    color: Colors.black.withOpacity(0.7),
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