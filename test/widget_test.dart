// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in this test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures, and you can use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manga_travel/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MangaTravelApp());

    // Verify that our app title is displayed.
    expect(find.text('漫游记'), findsOneWidget);
  });
}
