import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nido/data/mock_sellers.dart';
import 'package:nido/widgets/item_form.dart';

void main() {
  Future<void> pumpForm(
    WidgetTester tester, {
    required Future<void> Function(ItemFormResult value) onSubmit,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemForm(
            currentSeller: currentMockSeller,
            onSubmit: onSubmit,
          ),
        ),
      ),
    );
  }

  Future<void> fillRequiredFields(
    WidgetTester tester, {
    required String price,
  }) async {
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Body estampado');
    await tester.enterText(fields.at(1), price);
    await tester.enterText(fields.at(2), '3-6m');
    await tester.enterText(fields.at(3), 'Usado pocas veces.');
    await tester.tap(find.byKey(const ValueKey('item-image-option-0')));
    await tester.pump();
  }

  testWidgets('invalid price 0 blocks submit', (tester) async {
    var submitted = false;
    await pumpForm(tester, onSubmit: (_) async => submitted = true);
    await fillRequiredFields(tester, price: '0');

    await tester.tap(find.text('Publicar prenda'));
    await tester.pumpAndSettle();

    expect(find.text('El precio debe ser mayor a 0.'), findsOneWidget);
    expect(submitted, isFalse);
  });

  testWidgets('invalid negative price blocks submit', (tester) async {
    var submitted = false;
    await pumpForm(tester, onSubmit: (_) async => submitted = true);
    await fillRequiredFields(tester, price: '-10');

    await tester.tap(find.text('Publicar prenda'));
    await tester.pumpAndSettle();

    expect(find.text('El precio debe ser mayor a 0.'), findsOneWidget);
    expect(submitted, isFalse);
  });

  testWidgets('invalid text price blocks submit', (tester) async {
    var submitted = false;
    await pumpForm(tester, onSubmit: (_) async => submitted = true);
    await fillRequiredFields(tester, price: 'abc');

    await tester.tap(find.text('Publicar prenda'));
    await tester.pumpAndSettle();

    expect(find.text('Ingresá un precio válido.'), findsOneWidget);
    expect(submitted, isFalse);
  });

  testWidgets('valid price submits form', (tester) async {
    ItemFormResult? submitted;
    await pumpForm(tester, onSubmit: (value) async => submitted = value);
    await fillRequiredFields(tester, price: '650');

    await tester.tap(find.text('Publicar prenda'));
    await tester.pumpAndSettle();

    expect(submitted, isNotNull);
    expect(submitted!.price, 650);
  });

  testWidgets('image error is hidden until submit is attempted', (tester) async {
    await pumpForm(tester, onSubmit: (_) async {});

    expect(find.text('Elegí una foto principal para publicar.'), findsNothing);

    await tester.tap(find.text('Publicar prenda'));
    await tester.pumpAndSettle();

    expect(find.text('Elegí una foto principal para publicar.'), findsOneWidget);
  });
}
