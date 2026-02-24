import 'package:flutter/material.dart';

import '../widgets/polaroid_item_card.dart';
import 'favorites_screen.dart';
import 'item_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ✅ Filtro activo por tag (type / age / cond)
  String? _activeTagType; // 'type' | 'age' | 'cond'
  String? _activeTagValue;
  String? _activeBadgeOrder;
  String? _activePriceTextOrder;
  num? _activePriceAnchor;

  // Seed data (fake)
  late final List<Map<String, dynamic>> _items = [
    {
      'id': 'a1',
      'image':
          'https://images.unsplash.com/photo-1560859259-fcf2b952aed8?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'images': [
        'https://images.unsplash.com/photo-1560859259-fcf2b952aed8?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1519689680058-324335c77eba?q=80&w=1200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      ],
      'price': '—',
      'badge': 'Donación',
      'type': 'Body',
      'age': '0–3m',
      'cond': 'Usado',
      'title': 'Body 0–3m',
      'status': 'Vigente',
      'size': 'RN',
      'color': 'Crema',
      'q': 2,
      'last': 'hace 3 h',
      'fav': false,
      'note': 'Usado pocas veces. Sin manchas. Se retira por Tres Cruces.',
    },
    {
      'id': 'a2',
      'image':
          'https://images.unsplash.com/photo-1559454403-b8fb88521f11?q=80&w=880&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'images': [
        'https://images.unsplash.com/photo-1559454403-b8fb88521f11?q=80&w=880&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      ],
      'price': '\$ 650',
      'badge': 'Venta',
      'type': 'Manta',
      'age': '0–3m',
      'cond': 'Nuevo',
      'title': 'Manta tejida 0–3m',
      'status': 'Vigente',
      'size': 'U',
      'color': 'Beige',
      'q': 9,
      'last': 'hace 40 min',
      'fav': false,
      'note': 'Tejida, súper suave. Ideal para cochecito.',
    },
    {
      'id': 'a3',
      'image':
          'https://images.unsplash.com/photo-1684244160171-97f5dac39204?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'images': [
        'https://images.unsplash.com/photo-1684244160171-97f5dac39204?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1596450514730-b0a52f49c4fa?q=80&w=1200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      ],
      'price': '\$ 520',
      'badge': 'Venta',
      'type': 'Vestido',
      'age': '6–12m',
      'cond': 'Usado',
      'title': 'Vestido 6–12m',
      'status': 'Vigente',
      'size': 'M',
      'color': 'Rosa',
      'q': 1,
      'last': 'ayer',
      'fav': false,
      'note': 'Muy lindo para evento. Tela liviana.',
    },
    {
      'id': 'b1',
      'image':
          'https://plus.unsplash.com/premium_photo-1675183689638-a68fe7048da9?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'images': [
        'https://plus.unsplash.com/premium_photo-1675183689638-a68fe7048da9?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      ],
      'price': '\$ 200',
      'badge': 'Venta simbólica',
      'type': 'Conjunto',
      'age': '3–6m',
      'cond': 'Usado con detalles',
      'title': 'Conjunto 3–6m',
      'status': 'Vigente',
      'size': 'S',
      'color': 'Azul',
      'q': 12,
      'last': 'hace 2 h',
      'fav': false,
      'note': 'Tiene un detalle mínimo (ver foto). Se compensa con precio.',
    },
    {
      'id': 'b2',
      'image':
          'https://images.unsplash.com/photo-1622290291165-d341f1938b8a?q=80&w=1072&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'images': [
        'https://images.unsplash.com/photo-1622290291165-d341f1938b8a?q=80&w=1072&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      ],
      'price': '\$ 710',
      'badge': 'Venta',
      'type': 'Body',
      'age': '0–3m',
      'cond': 'Nuevo',
      'title': 'Body 0–3m',
      'status': 'Vigente',
      'size': 'RN',
      'color': 'Blanco',
      'q': 0,
      'last': 'sin actividad',
      'fav': true,
      'note': 'Nuevo con etiqueta. Nunca usado.',
    },
    {
      'id': 'b3',
      'image':
          'https://images.unsplash.com/photo-1560506840-ec148e82a604?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'images': [
        'https://images.unsplash.com/photo-1560506840-ec148e82a604?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      ],
      'price': '—',
      'badge': 'Trueque',
      'type': 'Campera',
      'age': '12–18m',
      'cond': 'Usado',
      'title': 'Campera 12–18m',
      'status': 'Vigente',
      'size': 'L',
      'color': 'Gris',
      'q': 4,
      'last': 'hace 5 días',
      'fav': false,
      'note': 'Busco cambiar por calzado 18–24m o lote similar.',
    },
    {
      'id': 'c1',
      'image':
          'https://images.unsplash.com/photo-1636905206149-bc3217e6a198?q=80&w=683&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'images': [
        'https://images.unsplash.com/photo-1636905206149-bc3217e6a198?q=80&w=683&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      ],
      'price': '\$ 700',
      'badge': 'Venta',
      'type': 'Pijama',
      'age': '6–12m',
      'cond': 'Usado',
      'title': 'Pijama 6–12m',
      'status': 'Vigente',
      'size': 'M',
      'color': 'Verde',
      'q': 7,
      'last': 'hace 1 h',
      'fav': false,
      'note': 'Súper abrigado para invierno.',
    },
  ];

  int get _favCount => _items.where((x) => x['fav'] == true).length;

  List<({String type, String value, int count})> get _tagStats {
    final Map<String, int> counts = {};

    void add(String type, String value) {
      final key = '$type::$value';
      counts[key] = (counts[key] ?? 0) + 1;
    }

    for (final item in _items) {
      add('type', item['type'] as String);
      add('age', item['age'] as String);
      add('cond', item['cond'] as String);
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

  void _toggleFavorite(String id) {
    setState(() {
      final idx = _items.indexWhere((x) => x['id'] == id);
      if (idx == -1) return;
      _items[idx]['fav'] = !(_items[idx]['fav'] as bool);
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

  List<Map<String, dynamic>> get _visibleItems {
    final List<Map<String, dynamic>> list = (_activeTagType == null || _activeTagValue == null)
        ? [..._items]
        : _items.where(_matchesActiveTag).toList();

    final indexById = <String, int>{
      for (int i = 0; i < _items.length; i++) (_items[i]['id'] as String): i,
    };

    list.sort((a, b) {
      if (_activeBadgeOrder != null) {
        final aFirst = (a['badge'] as String?) == _activeBadgeOrder;
        final bFirst = (b['badge'] as String?) == _activeBadgeOrder;
        if (aFirst != bFirst) return aFirst ? -1 : 1;
      }

      if (_activePriceAnchor != null) {
        final aPrice = _parsePrice(a['price'] as String? ?? '');
        final bPrice = _parsePrice(b['price'] as String? ?? '');
        final aGroup = _priceGroup(aPrice, _activePriceAnchor!);
        final bGroup = _priceGroup(bPrice, _activePriceAnchor!);
        if (aGroup != bGroup) return aGroup.compareTo(bGroup);
        if (aPrice != null && bPrice != null) {
          final byPrice = aPrice.compareTo(bPrice);
          if (byPrice != 0) return byPrice;
        }
      }

      return (indexById[a['id'] as String] ?? 0)
          .compareTo(indexById[b['id'] as String] ?? 0);
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

  List<NidoItem> _recommendedFor(Map<String, dynamic> base) {
    final others = _items.where((x) => x['id'] != base['id']).toList();
    final subset = others.take(8).toList();
    return subset.map((e) => _toNidoItem(e)).toList();
  }

  Route _buildDetailRoute(NidoItem item) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (context, _, __) => ItemDetailScreen(
        item: item,
        onBack: () => Navigator.of(context).pop(),
        onChat: (it) {},
        onBuy: (it) {},
        onOpenRecommended: (it) {
          Navigator.of(context).push(_buildDetailRoute(it));
        },
      ),
      transitionsBuilder: (_, animation, __, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return FadeTransition(opacity: curved, child: child);
      },
    );
  }

  void _openDetailFromBack(Map<String, dynamic> item) {
    final rec = _recommendedFor(item);
    final nidoItem = _toNidoItem(item, recommended: rec);
    Navigator.of(context).push(_buildDetailRoute(nidoItem));
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
        behavior: HitTestBehavior.deferToChild, // ✅ tap “vacío” = limpiar filtro
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
                  imageUrl: item['image'] as String,
                  priceText: item['price'] as String,
                  badgeText: item['badge'] as String?,
                  isFavorited: item['fav'] as bool,
                  onFavoriteTap: () => _toggleFavorite(item['id'] as String),
                  onBadgeTap: () => _toggleBadgeOrder(item['badge'] as String?),
                  onPriceTap: () => _togglePriceOrder(item['price'] as String),
                  badgeSelected: _activeBadgeOrder == (item['badge'] as String?),
                  priceSelected:
                      _activePriceTextOrder == (item['price'] as String),
                  isFocused: _matchesActiveTag(item),
                  backTitle: item['title'] as String?,
                  backSize: item['size'] as String?,
                  backInquiries: item['q'] as int?,
                  onOpenBack: () => _openDetailFromBack(item),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
