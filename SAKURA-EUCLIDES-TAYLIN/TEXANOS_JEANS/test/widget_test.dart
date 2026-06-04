// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart'; // Asegúrate que este nombre coincida con tu proyecto

void main() {
  testWidgets('Texanos Jeans render test', (WidgetTester tester) async {
    // Construye nuestra app y dispara un frame.
    await tester.pumpWidget(const TexanosJeansApp());

    // Verifica que el título de la marca aparezca en pantalla
    expect(find.text('TEXANOS JEANS'), findsOneWidget);
  });
}
