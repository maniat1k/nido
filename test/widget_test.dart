import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nido/app.dart';

void main() {
  Future<void> _pumpAppWithSize(
    WidgetTester tester, {
    required Size size,
  }) async {
    // Simula el tamaño de pantalla (viewport) del dispositivo.
    await tester.binding.setSurfaceSize(size);

    // IMPORTANTE: al terminar, volver a null para no contaminar otros tests.
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    // Build de la app completa.
    await tester.pumpWidget(const NidoApp());

    // Deja que se asienten frames/animaciones iniciales.
    await tester.pumpAndSettle();
  }

  testWidgets('NidoApp renderiza sin excepciones en teléfono', (tester) async {
    // Ejemplo teléfono (logical px). Podés cambiarlo por el que uses.
    await _pumpAppWithSize(tester, size: const Size(390, 844)); // iPhone 12/13

    // Si hubo overflow/layout exception, aparece acá.
    expect(tester.takeException(), isNull);
  });

  testWidgets('NidoApp renderiza sin excepciones en tablet', (tester) async {
    // Ejemplo tablet
    await _pumpAppWithSize(tester, size: const Size(1024, 768)); // iPad landscape

    expect(tester.takeException(), isNull);
  });
}
