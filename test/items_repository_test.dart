import 'package:flutter_test/flutter_test.dart';
import 'package:nido/data/mock_sellers.dart';
import 'package:nido/models/item.dart';
import 'package:nido/repositories/items_repository.dart';

void main() {
  late ItemsRepository repository;

  setUp(() {
    repository = ItemsRepository();
    repository.reset();
  });

  test('getAllItems returns seeded items', () {
    final items = repository.getAllItems();
    expect(items, isNotEmpty);
  });

  test('getById returns matching item', () {
    final item = repository.getById('a1');
    expect(item, isNotNull);
    expect(item!.id, 'a1');
  });

  test('addItem inserts item and allows finding it', () {
    final item = Item(
      id: 'test-item',
      title: 'Body rosa',
      description: 'Publicación de prueba',
      price: 350,
      category: 'Bodies',
      size: '3-6m',
      condition: 'Muy buen estado',
      sellerId: currentMockSeller.id,
      imageUrls: const ['https://example.com/item.jpg'],
      isFavorite: false,
    );

    repository.addItem(item);

    expect(repository.getById('test-item'), isNotNull);
    expect(repository.getAllItems().first.id, 'test-item');
    expect(repository.getById('test-item')!.sellerId, currentMockSeller.id);
  });

  test('toggleFavorite updates stored item', () {
    final before = repository.getById('a1')!;

    repository.toggleFavorite('a1');

    final after = repository.getById('a1')!;
    expect(after.isFavorite, isNot(before.isFavorite));
  });

  test('getItemsBySeller returns matching publications', () {
    final nataliaItems = repository.getItemsBySeller('natalia');

    expect(nataliaItems, isNotEmpty);
    expect(nataliaItems.every((item) => item.sellerId == 'natalia'), isTrue);
  });

  test('current user items only include newly created publications', () {
    final before = repository.getItemsBySeller(currentMockSeller.id);
    expect(before, isEmpty);

    repository.addItem(
      Item(
        id: 'mine',
        title: 'Mi conjunto',
        description: 'Alta mock propia',
        price: 420,
        category: 'Conjuntos',
        size: '6-9m',
        condition: 'Como nuevo',
        sellerId: currentMockSeller.id,
        imageUrls: const ['https://example.com/mine.jpg'],
        isFavorite: false,
      ),
    );

    final mine = repository.getItemsBySeller(currentMockSeller.id);
    expect(mine, hasLength(1));
    expect(mine.first.id, 'mine');
  });
}
