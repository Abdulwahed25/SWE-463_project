import 'package:flutter_test/flutter_test.dart';
import 'package:souq/models/user.dart';
import 'package:souq/providers/auth_provider.dart';

import 'fake_auth_repository.dart';

void main() {
  group('AuthProvider', () {
    test('logs in successfully and sets user state', () async {
      final repo = FakeAuthRepository(
        currentUser: const User(
          id: 'u1',
          name: 'Ahmed',
          email: 'ahmed@kfupm.edu.sa',
          studentId: '202100000',
        ),
      );
      final auth = AuthProvider(repo);

      expect(auth.isAuthenticated, isFalse);

      final ok = await auth.login(email: 'ahmed@kfupm.edu.sa', password: 'password123');

      expect(ok, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.user?.name, 'Ahmed');
      expect(auth.errorMessage, isNull);
    });

    test('signs up and logs in automatically', () async {
      final repo = FakeAuthRepository();
      final auth = AuthProvider(repo);

      final ok = await auth.signUp(
        name: 'Saud',
        email: 'saud@kfupm.edu.sa',
        studentId: '202200000',
        password: 'password123',
      );

      expect(ok, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.user?.name, 'Saud');
    });

    test('logs out and clears session', () async {
      final repo = FakeAuthRepository(
        currentUser: const User(
          id: 'u1',
          name: 'Ahmed',
          email: 'ahmed@kfupm.edu.sa',
          studentId: '202100000',
        ),
      );
      final auth = AuthProvider(repo);
      await auth.login(email: 'ahmed@kfupm.edu.sa', password: 'password123');
      expect(auth.isAuthenticated, isTrue);

      await auth.logout();
      expect(auth.isAuthenticated, isFalse);
      expect(auth.user, isNull);
    });
  });
}
