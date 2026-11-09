import 'package:flutter_test/flutter_test.dart';
import 'package:souq/main.dart';

import 'fake_auth_repository.dart';
import 'fake_listing_repository.dart';

void main() {
  testWidgets('App opens on the Login screen', (WidgetTester tester) async {
    await tester.pumpWidget(SouqApp(
      repository: FakeListingRepository(),
      authRepository: FakeAuthRepository(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Souq - Login'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });
}
