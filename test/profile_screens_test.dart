import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:souq/models/user.dart';
import 'package:souq/providers/auth_provider.dart';
import 'package:souq/providers/listings_provider.dart';
import 'package:souq/screens/edit_profile_screen.dart';
import 'package:souq/screens/profile_screen.dart';
import 'package:souq/widgets/iban_field.dart';
import 'package:souq/widgets/phone_field.dart';
import 'package:souq/widgets/seller_payment_sheet.dart';

import 'fake_auth_repository.dart';
import 'fake_listing_repository.dart';

const _validIban = 'SA0380000000608010167519';

const _ayman = User(
  id: 'u_ayman',
  name: 'Ayman Musalli',
  email: 'ayman@kfupm.edu.sa',
  studentId: '202270440',
  phone: '0501234567',
);

/// Builds the app around [home] with logged-in providers.
/// [home] is opened from a start page so Navigator.pop has somewhere to go back to.
Future<(FakeAuthRepository, AuthProvider)> _pumpApp(
  WidgetTester tester,
  Widget home, {
  User user = _ayman,
  ListingsProvider? listings,
}) async {
  final repo = FakeAuthRepository(currentUser: user);
  final auth = AuthProvider(repo);
  await auth.loadSession();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: listings ?? ListingsProvider(FakeListingRepository())),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => home)),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return (repo, auth);
}

final _phoneInput = find.descendant(of: find.byType(PhoneField), matching: find.byType(EditableText));
final _ibanInput = find.descendant(of: find.byType(IbanField), matching: find.byType(EditableText));

/// Scrolls the Save button into view (the test screen is short) and taps it.
Future<void> _tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save changes'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Save changes'));
  await tester.pumpAndSettle();
}

void main() {
  group('Profile screen', () {
    testWidgets('shows user details and activity stats', (tester) async {
      final listings = ListingsProvider(
        FakeListingRepository(
          initial: [
            testListing('1', 'Calculus book', 50, 'Books', sellerId: _ayman.id),
            testListing('2', 'Desk lamp', 30, 'Furniture', sellerId: _ayman.id, sold: true),
            testListing('3', 'Someone else', 10, 'Books'),
          ],
        ),
      );
      await _pumpApp(tester, const ProfileScreen(), listings: listings);
      await listings.load();
      await tester.pumpAndSettle();

      expect(find.text('Ayman Musalli'), findsOneWidget);
      expect(find.text('AM'), findsOneWidget); // initials avatar
      expect(find.text('202270440'), findsOneWidget);
      expect(find.text('+966 50-123-4567'), findsOneWidget); // saved as 0501234567, shown formatted

      // Posted 2, Sold 1, Saved 0
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);

      // No IBAN yet, so the reminder is shown
      expect(find.text('Add your IBAN'), findsOneWidget);
    });

    testWidgets('shows the IBAN in groups of 4 after it is saved', (tester) async {
      final (_, auth) = await _pumpApp(tester, const ProfileScreen());

      await auth.updateProfile(_ayman.copyWith(iban: _validIban));
      await tester.pumpAndSettle();

      expect(find.text('SA03 8000 0000 6080 1016 7519'), findsOneWidget);
      expect(find.text('Add your IBAN'), findsNothing);
    });
  });

  group('Edit Profile screen', () {
    testWidgets('Save is disabled until something changes', (tester) async {
      await _pumpApp(tester, const EditProfileScreen());

      FilledButton saveButton() => tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Save changes'));
      expect(saveButton().onPressed, isNull);

      await tester.enterText(find.widgetWithText(TextFormField, 'Ayman Musalli'), 'Ayman M');
      await tester.pump();
      expect(saveButton().onPressed, isNotNull);
    });

    testWidgets('invalid input shows errors and is not saved', (tester) async {
      final (repo, _) = await _pumpApp(tester, const EditProfileScreen());

      await tester.enterText(find.widgetWithText(TextFormField, 'Ayman Musalli'), '');
      await tester.enterText(_phoneInput, '534');
      await tester.enterText(_ibanInput, '12');
      await _tapSave(tester);

      expect(find.text('Name cannot be empty.'), findsOneWidget);
      expect(find.text('Enter 9 digits (you entered 3).'), findsOneWidget);
      expect(find.text('Enter the 22 digits after SA (you entered 2).'), findsOneWidget);
      expect(repo.currentUser?.name, 'Ayman Musalli'); // nothing saved
    });

    testWidgets('valid input is saved and the screen closes', (tester) async {
      final (repo, auth) = await _pumpApp(tester, const EditProfileScreen());

      await tester.enterText(find.widgetWithText(TextFormField, 'Ayman Musalli'), 'Ayman M');
      await tester.enterText(_ibanInput, 'sa03 8000 0000 6080 1016 7519');
      await _tapSave(tester);

      expect(find.text('Profile updated successfully!'), findsOneWidget);
      expect(find.byType(EditProfileScreen), findsNothing); // popped back
      expect(auth.user?.name, 'Ayman M');
      expect(repo.currentUser?.iban, _validIban); // saved without spaces, uppercase
    });

    testWidgets('a failed save shows an error and stays on the screen', (tester) async {
      final (repo, _) = await _pumpApp(tester, const EditProfileScreen());
      repo.shouldFail = true;

      await tester.enterText(find.widgetWithText(TextFormField, 'Ayman Musalli'), 'Ayman M');
      await _tapSave(tester);

      expect(find.text('No connection'), findsOneWidget);
      expect(find.byType(EditProfileScreen), findsOneWidget);
    });

    testWidgets('phone and IBAN are formatted while typing and letters are ignored', (tester) async {
      await _pumpApp(tester, const EditProfileScreen());

      // Existing phone "0501234567" is shown without the 0, next to +966
      expect(find.text('50-123-4567'), findsOneWidget);
      expect(find.text('+966'), findsOneWidget);

      await tester.enterText(_phoneInput, '0530344226abc');
      await tester.enterText(_ibanInput, 'SA0380000000608010167519');
      await tester.pump();

      expect(find.text('53-034-4226'), findsOneWidget);
      expect(find.text('03 8000 0000 6080 1016 7519'), findsOneWidget);
    });

    testWidgets('picking another country code saves it with the number', (tester) async {
      final (repo, _) = await _pumpApp(tester, const EditProfileScreen());

      await tester.tap(find.text('+966'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kuwait'));
      await tester.pumpAndSettle();
      expect(find.text('+965'), findsOneWidget);

      await tester.enterText(_phoneInput, '98765432');
      await _tapSave(tester);

      expect(repo.currentUser?.phone, '+96598765432');
    });

    testWidgets('going back with unsaved changes asks to discard', (tester) async {
      await _pumpApp(tester, const EditProfileScreen());

      await tester.enterText(find.widgetWithText(TextFormField, 'Ayman Musalli'), 'Ayman M');
      await tester.pump();
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.byType(EditProfileScreen), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(find.byType(EditProfileScreen), findsNothing);
    });
  });

  group('Seller payment sheet', () {
    testWidgets("shows the seller's IBAN", (tester) async {
      final (repo, _) = await _pumpApp(tester, const Scaffold());
      repo.users['seller@kfupm.edu.sa'] = const User(
        id: 'seller_1',
        name: 'Hady',
        email: 'seller@kfupm.edu.sa',
        studentId: '202279620',
        iban: _validIban,
      );

      showSellerPaymentSheet(
        tester.element(find.byType(Scaffold).last),
        testListing('1', 'Book', 20, 'Books', sellerId: 'seller_1'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pay by bank transfer'), findsOneWidget);
      expect(find.text('SA03 8000 0000 6080 1016 7519'), findsOneWidget);
    });

    testWidgets('shows an empty state when the seller has no IBAN', (tester) async {
      await _pumpApp(tester, const Scaffold());

      showSellerPaymentSheet(
        tester.element(find.byType(Scaffold).last),
        testListing('1', 'Book', 20, 'Books', sellerId: 'nobody'),
      );
      await tester.pumpAndSettle();

      expect(find.text('No IBAN yet'), findsOneWidget);
    });

    testWidgets('shows an error with Retry when loading fails', (tester) async {
      final (repo, _) = await _pumpApp(tester, const Scaffold());
      repo.shouldFail = true;

      showSellerPaymentSheet(
        tester.element(find.byType(Scaffold).last),
        testListing('1', 'Book', 20, 'Books', sellerId: 'seller_1'),
      );
      await tester.pumpAndSettle();

      expect(find.text("Couldn't load payment details"), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
