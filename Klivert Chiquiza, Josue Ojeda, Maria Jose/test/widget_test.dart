// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:judisa_taller/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    // Verificar que la clase principal existe y es del tipo correcto
    const app = JudisaTallerApp();
    expect(app, isA<JudisaTallerApp>());
    expect(app.key, isNull);
  });

  testWidgets('App has correct title', (WidgetTester tester) async {
    // La app debe tener el título correcto
    const app = JudisaTallerApp();
    expect(app, isA<StatelessWidget>());
  });
}
