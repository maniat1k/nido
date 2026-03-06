import 'package:flutter/foundation.dart';

import '../data/mock_items.dart';
import '../models/item.dart';

class ItemsRepository extends ChangeNotifier {
  ItemsRepository._internal() : _items = List<Item>.from(mockItems);

  static final ItemsRepository instance = ItemsRepository._internal();

  final List<Item> _items;

  factory ItemsRepository() => instance;

  List<Item> getAllItems() => List<Item>.unmodifiable(_items);

  Item? getById(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  List<Item> getRelatedItems(Item current, {int limit = 6}) {
    final sameCategory = _items
        .where(
          (item) => item.id != current.id && item.category == current.category,
        )
        .toList();
    final otherItems = _items
        .where(
          (item) => item.id != current.id && item.category != current.category,
        )
        .toList();

    return [...sameCategory, ...otherItems].take(limit).toList();
  }

  Item? toggleFavorite(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return null;

    final updated = _items[index].copyWith(
      isFavorite: !_items[index].isFavorite,
    );
    _items[index] = updated;
    notifyListeners();
    return updated;
  }

  Item addItem(Item item) {
    _items.insert(0, item);
    notifyListeners();
    return item;
  }

  List<Item> getItemsBySeller(String sellerId) {
    return _items.where((item) => item.sellerId == sellerId).toList();
  }

  @visibleForTesting
  void reset() {
    _items
      ..clear()
      ..addAll(mockItems);
    notifyListeners();
  }
}
