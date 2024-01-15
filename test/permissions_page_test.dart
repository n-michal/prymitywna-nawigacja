import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigation/permissions_page.dart';

void main() {
  testWidgets('Permissions page smoke test', (widgetTester) async {
    await widgetTester.pumpWidget(
      const MaterialApp(
        home: PermissionsPage(),
      ),
    );
    expect(
      find.text(
        'Do wykorzystania sensorow konieczne sa uprawnienia lokalizacji',
      ),
      findsOneWidget,
    );
    expect(find.text('Przyznaj uprawnienia'), findsOneWidget);
    expect(find.text('Otworz ustawienia'), findsOneWidget);
  });
}
