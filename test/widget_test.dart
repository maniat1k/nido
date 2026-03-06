import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nido/app.dart';
import 'package:nido/repositories/items_repository.dart';

Future<void> _pumpAppWithSize(
  WidgetTester tester, {
  required Size size,
}) async {
  // Simula viewport del dispositivo
  await tester.binding.setSurfaceSize(size);

  // IMPORTANTE: resetear al terminar para no contaminar otros tests
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });

  // Render app (asumiendo que NidoApp ya envuelve MaterialApp)
  ItemsRepository.instance.reset();
  await tester.pumpWidget(const NidoApp());

  // Asentá frames/animaciones iniciales
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('NidoApp renderiza sin excepciones en tablet', (tester) async {
    await _pumpAppWithSize(tester, size: const Size(1024, 768));

    // Verifica que NO se tiró ninguna excepción durante el render
    expect(tester.takeException(), isNull);
  });

  testWidgets('NidoApp renderiza sin excepciones en phone', (tester) async {
    await _pumpAppWithSize(tester, size: const Size(390, 844));

    expect(tester.takeException(), isNull);
  });
}
