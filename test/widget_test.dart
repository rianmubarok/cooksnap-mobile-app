import 'package:flutter_test/flutter_test.dart';

import 'package:cooksnap_mobile_app/main.dart';

void main() {
  testWidgets('CookSnap app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CookSnapApp());

    // Verify that splash screen renders
    expect(find.text('CookSnap'), findsOneWidget);
  });
}
