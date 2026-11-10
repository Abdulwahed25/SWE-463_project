import 'package:flutter_test/flutter_test.dart';
import 'package:souq/models/user.dart';
import 'package:souq/providers/auth_provider.dart';
import 'package:souq/services/session.dart';

import 'fake_auth_repository.dart';

const _ayman = User(id: 'u_ayman', name: 'Ayman Musalli', email: 'ayman@kfupm.edu.sa', studentId: '202270440');

void main() {
  group('AuthProvider profile', () {
    test('updateProfile saves the change and updates the shared user', () async {
      final repo = FakeAuthRepository(currentUser: _ayman);
      final auth = AuthProvider(repo);
      await auth.loadSession();

      var notified = 0;
      auth.addListener(() => notified++);

      final ok = await auth.updateProfile(_ayman.copyWith(name: 'Ayman M.', iban: 'SA0380000000608010167519'));

      expect(ok, isTrue);
      expect(auth.user?.name, 'Ayman M.');
      expect(auth.user?.iban, 'SA0380000000608010167519');
      expect(repo.currentUser?.name, 'Ayman M.'); // saved in the repository
      expect(Session.currentUserName, 'Ayman M.'); // new listings use the new name
      expect(notified, greaterThan(0)); // screens watching the provider rebuild
    });

    test('updateProfile failure keeps the old user and shows an error', () async {
      final repo = FakeAuthRepository(currentUser: _ayman);
      final auth = AuthProvider(repo);
      await auth.loadSession();
      repo.shouldFail = true;

      final ok = await auth.updateProfile(_ayman.copyWith(name: 'Changed'));

      expect(ok, isFalse);
      expect(auth.user?.name, 'Ayman Musalli');
      expect(auth.errorMessage, 'No connection');
      expect(auth.isLoading, isFalse);
    });

    test('fetchUser finds a seller by id, or returns null', () async {
      final repo = FakeAuthRepository();
      repo.users['seller@kfupm.edu.sa'] = const User(
        id: 'seller_1',
        name: 'Seller',
        email: 'seller@kfupm.edu.sa',
        studentId: '202000000',
        iban: 'SA0380000000608010167519',
      );
      final auth = AuthProvider(repo);

      expect((await auth.fetchUser('seller_1'))?.iban, 'SA0380000000608010167519');
      expect(await auth.fetchUser('unknown'), isNull);
    });
  });
}
