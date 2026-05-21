import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cooksnap/main.dart';

void main() {
  testWidgets('CookSnap app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CookSnapApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);

    // Let splash auto-navigation timer finish so no pending timers remain.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
  });
}
