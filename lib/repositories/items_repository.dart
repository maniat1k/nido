import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock_items.dart';
import '../data/mock_sellers.dart';
import '../models/item.dart';

class ItemsRepository extends ChangeNotifier {
  ItemsRepository._internal() : _items = List<Item>.from(mockItems);

  static final ItemsRepository instance = ItemsRepository._internal();
  static const String _createdItemsStorageKey = 'created_items';

  final List<Item> _items;
  bool _isInitialized = false;
  Future<void>? _initializationFuture;

  factory ItemsRepository() => instance;

  Future<void> initialize() {
    return _initializationFuture ??= _loadPersistedItems();
  }

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

  Future<Item> addItem(Item item) async {
    _items.insert(0, item);
    await _persistCreatedItems();
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
    _isInitialized = false;
    _initializationFuture = null;
    notifyListeners();
  }

  Future<void> _loadPersistedItems() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final rawItems = prefs.getStringList(_createdItemsStorageKey) ?? const <String>[];
    final persistedItems = <Item>[];

    for (final raw in rawItems) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        persistedItems.add(Item.fromJson(decoded));
      } catch (_) {
        // Ignore malformed persisted items and keep loading the rest.
      }
    }

    _items
      ..clear()
      ..addAll(persistedItems)
      ..addAll(mockItems);

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _persistCreatedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final createdItems = _items
        .where((item) => item.sellerId == currentMockSeller.id)
        .map((item) => jsonEncode(item.toJson()))
        .toList(growable: false);
    await prefs.setStringList(_createdItemsStorageKey, createdItems);
  }
}
