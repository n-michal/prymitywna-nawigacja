import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigation/map_page.dart';

void main() {
  testWidgets('Map page smoke test', (widgetTester) async {
    await widgetTester.pumpWidget(
      const MaterialApp(
        home: MapPage(),
      ),
    );
    expect(find.text('Prymitywna nawigacja'), findsOneWidget);
    expect(find.byIcon(Icons.undo), findsOneWidget);
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.text('Start Nawigacji'), findsOneWidget);
  });

  testWidgets('Test Startu nawigacji', (widgetTester) async {
    await widgetTester.pumpWidget(
      const MaterialApp(
        home: MapPage(),
      ),
    );

    await widgetTester.tap(find.text('Start Nawigacji'));
    await widgetTester.pump();

    expect(find.text('Start Nawigacji'), findsNothing);
    expect(find.text('Zatrzymaj Nawigacje'), findsOne);
  });
}
