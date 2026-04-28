// This is a basic Flutter widget test for F1 Strategy App.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:f1_strategy_app/main.dart';

void main() {
  testWidgets('F1 Strategy App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const F1StrategyApp());

    // Verify that app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // The splash screen should be displayed initially
    await tester.pumpAndSettle();
    
    // Basic verification that the app structure exists
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
