import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nido/data/mock_sellers.dart';
import 'package:nido/widgets/item_form.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpForm(
    WidgetTester tester, {
    required Future<void> Function(ItemFormResult value) onSubmit,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ItemForm(
                currentSeller: currentMockSeller,
                onSubmit: onSubmit,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
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
    await tester.pumpAndSettle();
  }

  Future<void> tapSubmit(WidgetTester tester) async {
    final submitButton = find.widgetWithText(ElevatedButton, 'Publicar prenda');
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
  }

  testWidgets('invalid price 0 blocks submit', (tester) async {
    var submitted = false;
    await pumpForm(tester, onSubmit: (_) async => submitted = true);
    await fillRequiredFields(tester, price: '0');

    await tapSubmit(tester);

    expect(find.text('El precio debe ser mayor a 0.'), findsOneWidget);
    expect(submitted, isFalse);
  });

  testWidgets('invalid negative price blocks submit', (tester) async {
    var submitted = false;
    await pumpForm(tester, onSubmit: (_) async => submitted = true);
    await fillRequiredFields(tester, price: '-10');

    await tapSubmit(tester);

    expect(find.text('El precio debe ser mayor a 0.'), findsOneWidget);
    expect(submitted, isFalse);
  });

  testWidgets('invalid text price blocks submit', (tester) async {
    var submitted = false;
    await pumpForm(tester, onSubmit: (_) async => submitted = true);
    await fillRequiredFields(tester, price: 'abc');

    await tapSubmit(tester);

    expect(find.text('Ingresá un precio válido.'), findsOneWidget);
    expect(submitted, isFalse);
  });

  testWidgets('valid price submits form', (tester) async {
    ItemFormResult? submitted;
    await pumpForm(tester, onSubmit: (value) async => submitted = value);
    await fillRequiredFields(tester, price: '650');

    await tapSubmit(tester);

    expect(submitted, isNotNull);
    expect(submitted!.price, 650);
  });

  testWidgets('image error is hidden until submit is attempted', (tester) async {
    await pumpForm(tester, onSubmit: (_) async {});

    expect(find.text('Elegí una foto principal para publicar.'), findsNothing);

    await tapSubmit(tester);

    expect(find.text('Elegí una foto principal para publicar.'), findsOneWidget);
  });
}
