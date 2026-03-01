import '../models/nido_item.dart';

class ItemsRepository {
  const ItemsRepository();

  List<NidoItem> getAllItems() => List<NidoItem>.from(_seedItems);

  NidoItem? getById(String id) {
    for (final item in _seedItems) {
      if (item.id == id) return item;
    }
    return null;
  }

  List<NidoItem> getRelatedItems(NidoItem current, {int limit = 6}) {
    final related = _seedItems.where((item) => item.id != current.id).toList();
    if (related.length > limit) {
      return related.take(limit).toList();
    }
    return related;
  }
}

const List<NidoItem> _seedItems = [
  NidoItem(
    id: 'a1',
    imageUrl:
        'https://images.unsplash.com/photo-1560859259-fcf2b952aed8?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    imageUrls: [
      'https://images.unsplash.com/photo-1560859259-fcf2b952aed8?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://images.unsplash.com/photo-1519689680058-324335c77eba?q=80&w=1200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ],
    price: '—',
    badge: 'Donación',
    type: 'Body',
    age: '0–3m',
    condition: 'Usado',
    title: 'Body 0–3m',
    status: 'Vigente',
    size: 'RN',
    color: 'Crema',
    inquiryCount: 2,
    lastActivity: 'hace 3 h',
    isFavorite: false,
    note: 'Usado pocas veces. Sin manchas. Se retira por Tres Cruces.',
  ),
  NidoItem(
    id: 'a2',
    imageUrl:
        'https://images.unsplash.com/photo-1559454403-b8fb88521f11?q=80&w=880&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    imageUrls: [
      'https://images.unsplash.com/photo-1559454403-b8fb88521f11?q=80&w=880&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ],
    price: '\$ 650',
    badge: 'Venta',
    type: 'Manta',
    age: '0–3m',
    condition: 'Nuevo',
    title: 'Manta tejida 0–3m',
    status: 'Vigente',
    size: 'U',
    color: 'Beige',
    inquiryCount: 9,
    lastActivity: 'hace 40 min',
    isFavorite: false,
    note: 'Tejida, súper suave. Ideal para cochecito.',
  ),
  NidoItem(
    id: 'a3',
    imageUrl:
        'https://images.unsplash.com/photo-1684244160171-97f5dac39204?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    imageUrls: [
      'https://images.unsplash.com/photo-1684244160171-97f5dac39204?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://images.unsplash.com/photo-1596450514730-b0a52f49c4fa?q=80&w=1200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ],
    price: '\$ 520',
    badge: 'Venta',
    type: 'Vestido',
    age: '6–12m',
    condition: 'Usado',
    title: 'Vestido 6–12m',
    status: 'Vigente',
    size: 'M',
    color: 'Rosa',
    inquiryCount: 1,
    lastActivity: 'ayer',
    isFavorite: false,
    note: 'Muy lindo para evento. Tela liviana.',
  ),
  NidoItem(
    id: 'b1',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1675183689638-a68fe7048da9?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    imageUrls: [
      'https://plus.unsplash.com/premium_photo-1675183689638-a68fe7048da9?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ],
    price: '\$ 200',
    badge: 'Venta simbólica',
    type: 'Conjunto',
    age: '3–6m',
    condition: 'Usado con detalles',
    title: 'Conjunto 3–6m',
    status: 'Vigente',
    size: 'S',
    color: 'Azul',
    inquiryCount: 12,
    lastActivity: 'hace 2 h',
    isFavorite: false,
    note: 'Tiene un detalle mínimo (ver foto). Se compensa con precio.',
  ),
  NidoItem(
    id: 'b2',
    imageUrl:
        'https://images.unsplash.com/photo-1622290291165-d341f1938b8a?q=80&w=1072&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    imageUrls: [
      'https://images.unsplash.com/photo-1622290291165-d341f1938b8a?q=80&w=1072&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ],
    price: '\$ 710',
    badge: 'Venta',
    type: 'Body',
    age: '0–3m',
    condition: 'Nuevo',
    title: 'Body 0–3m',
    status: 'Vigente',
    size: 'RN',
    color: 'Blanco',
    inquiryCount: 0,
    lastActivity: 'sin actividad',
    isFavorite: true,
    note: 'Nuevo con etiqueta. Nunca usado.',
  ),
  NidoItem(
    id: 'b3',
    imageUrl:
        'https://images.unsplash.com/photo-1560506840-ec148e82a604?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    imageUrls: [
      'https://images.unsplash.com/photo-1560506840-ec148e82a604?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ],
    price: '—',
    badge: 'Trueque',
    type: 'Campera',
    age: '12–18m',
    condition: 'Usado',
    title: 'Campera 12–18m',
    status: 'Vigente',
    size: 'L',
    color: 'Gris',
    inquiryCount: 4,
    lastActivity: 'hace 5 días',
    isFavorite: false,
    note: 'Busco cambiar por calzado 18–24m o lote similar.',
  ),
  NidoItem(
    id: 'c1',
    imageUrl:
        'https://images.unsplash.com/photo-1636905206149-bc3217e6a198?q=80&w=683&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    imageUrls: [
      'https://images.unsplash.com/photo-1636905206149-bc3217e6a198?q=80&w=683&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ],
    price: '\$ 700',
    badge: 'Venta',
    type: 'Pijama',
    age: '6–12m',
    condition: 'Usado',
    title: 'Pijama 6–12m',
    status: 'Vigente',
    size: 'M',
    color: 'Verde',
    inquiryCount: 7,
    lastActivity: 'hace 1 h',
    isFavorite: false,
    note: 'Súper abrigado para invierno.',
  ),
];
