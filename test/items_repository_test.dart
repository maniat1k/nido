import 'package:flutter_test/flutter_test.dart';
import 'package:nido/data/items_repository.dart';

void main() {
  const repository = ItemsRepository();

  test('getAllItems returns seeded items', () {
    final items = repository.getAllItems();
    expect(items, isNotEmpty);
  });

  test('getById returns matching item', () {
    final item = repository.getById('a1');
    expect(item, isNotNull);
    expect(item!.id, 'a1');
  });

  test('getRelatedItems excludes current item and applies limit', () {
    final current = repository.getById('a1')!;
    final related = repository.getRelatedItems(current, limit: 3);

    expect(related.length, 3);
    expect(related.any((it) => it.id == current.id), isFalse);
  });
}
