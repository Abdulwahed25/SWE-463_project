import 'package:flutter_test/flutter_test.dart';

import 'package:souq/main.dart';

void main() {
  testWidgets('App opens on the Login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SouqApp());
    expect(find.text('Souq - Login'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });
}
