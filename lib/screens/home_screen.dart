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

  // Seed data (fake)
  late final List<Map<String, dynamic>> _items = [
    {
      'id': 'a1',
      'image':
          'https://images.unsplash.com/photo-1560859259-fcf2b952aed8?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'price': '—',
      'badge': 'Donación',
      'type': 'Body',
      'age': '0–3m',
      'cond': 'Usado',
      'title': 'Body 0–3m',
      'status': 'Vigente',
      'size': 'RN',
      'q': 2,
      'last': 'hace 3 h',
      'fav': false,
      'note': 'Usado pocas veces. Sin manchas. Se retira por Tres Cruces.',
    },
    {
      'id': 'a2',
      'image':
          'https://images.unsplash.com/photo-1559454403-b8fb88521f11?q=80&w=880&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'price': '\$ 650',
      'badge': 'Venta',
      'type': 'Manta',
      'age': '0–3m',
      'cond': 'Nuevo',
      'title': 'Manta tejida 0–3m',
      'status': 'Vigente',
      'size': 'U',
      'q': 9,
      'last': 'hace 40 min',
      'fav': false,
      'note': 'Tejida, súper suave. Ideal para cochecito.',
    },
    {
      'id': 'a3',
      'image':
          'https://images.unsplash.com/photo-1684244160171-97f5dac39204?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'price': '\$ 520',
      'badge': 'Venta',
      'type': 'Vestido',
      'age': '6–12m',
      'cond': 'Usado',
      'title': 'Vestido 6–12m',
      'status': 'Vigente',
      'size': 'M',
      'q': 1,
      'last': 'ayer',
      'fav': false,
      'note': 'Muy lindo para evento. Tela liviana.',
    },
    {
      'id': 'b1',
      'image':
          'https://plus.unsplash.com/premium_photo-1675183689638-a68fe7048da9?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'price': '\$ 200',
      'badge': 'Venta simbólica',
      'type': 'Conjunto',
      'age': '3–6m',
      'cond': 'Usado con detalles',
      'title': 'Conjunto 3–6m',
      'status': 'Vigente',
      'size': 'S',
      'q': 12,
      'last': 'hace 2 h',
      'fav': false,
      'note': 'Tiene un detalle mínimo (ver foto). Se compensa con precio.',
    },
    {
      'id': 'b2',
      'image':
          'https://images.unsplash.com/photo-1622290291165-d341f1938b8a?q=80&w=1072&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'price': '\$ 710',
      'badge': 'Venta',
      'type': 'Body',
      'age': '0–3m',
      'cond': 'Nuevo',
      'title': 'Body 0–3m',
      'status': 'Vigente',
      'size': 'RN',
      'q': 0,
      'last': 'sin actividad',
      'fav': true,
      'note': 'Nuevo con etiqueta. Nunca usado.',
    },
    {
      'id': 'b3',
      'image':
          'https://images.unsplash.com/photo-1560506840-ec148e82a604?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'price': '—',
      'badge': 'Trueque',
      'type': 'Campera',
      'age': '12–18m',
      'cond': 'Usado',
      'title': 'Campera 12–18m',
      'status': 'Vigente',
      'size': 'L',
      'q': 4,
      'last': 'hace 5 días',
      'fav': false,
      'note': 'Busco cambiar por calzado 18–24m o lote similar.',
    },
    {
      'id': 'c1',
      'image':
          'https://images.unsplash.com/photo-1636905206149-bc3217e6a198?q=80&w=683&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'price': '\$ 700',
      'badge': 'Venta',
      'type': 'Pijama',
      'age': '6–12m',
      'cond': 'Usado',
      'title': 'Pijama 6–12m',
      'status': 'Vigente',
      'size': 'M',
      'q': 7,
      'last': 'hace 1 h',
      'fav': false,
      'note': 'Súper abrigado para invierno.',
    },
  ];

  int get _favCount => _items.where((x) => x['fav'] == true).length;

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
    if (_activeTagType == null || _activeTagValue == null) return [..._items];
    return _items.where(_matchesActiveTag).toList();
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

  void _openDetail(Map<String, dynamic> item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(
          item: item,
          onToggleFavorite: () => _toggleFavorite(item['id'] as String),
          onTagTap: (type, value) => _setTagFilter(type: type, value: value),
          activeTagType: _activeTagType,
          activeTagValue: _activeTagValue,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _visibleItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF8EFF4),
      appBar: AppBar(
        title: const Text('Nido'),
        actions: [
          if (_activeTagType != null && _activeTagValue != null)
            IconButton(
              tooltip: 'Quitar filtro',
              icon: const Icon(Icons.filter_alt_off),
              onPressed: _clearFilterIfActive,
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
                  typeText: item['type'] as String,
                  ageText: item['age'] as String,
                  conditionText: item['cond'] as String,
                  typeSelected: _activeTagType == 'type' &&
                      _activeTagValue == (item['type'] as String),
                  ageSelected: _activeTagType == 'age' &&
                      _activeTagValue == (item['age'] as String),
                  conditionSelected: _activeTagType == 'cond' &&
                      _activeTagValue == (item['cond'] as String),
                  onTypeTap: () => _setTagFilter(
                      type: 'type', value: item['type'] as String),
                  onAgeTap: () => _setTagFilter(
                      type: 'age', value: item['age'] as String),
                  onConditionTap: () => _setTagFilter(
                      type: 'cond', value: item['cond'] as String),
                  isFocused: _matchesActiveTag(item),
                  onOpen: () => _openDetail(item),
                );
              },
            );
          },
        ),
      ),
    );
  }
}