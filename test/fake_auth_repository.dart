import 'package:souq/models/user.dart';
import 'package:souq/services/auth_repository.dart';

/// In-memory auth repository used by tests.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.currentUser, this.shouldFail = false});

  User? currentUser;
  final Map<String, User> users = {};

  /// When true, updateUser and getUserById throw (to test error states).
  bool shouldFail;

  @override
  Future<User?> getCurrentUser() async => currentUser;

  @override
  Future<User> login({required String email, required String password}) async {
    final user = users[email.toLowerCase()] ?? currentUser;
    if (user == null) throw Exception('User not found');
    currentUser = user;
    return user;
  }

  @override
  Future<User> signUp({
    required String name,
    required String email,
    required String studentId,
    required String password,
    String phone = '',
    String iban = '',
  }) async {
    final user = User(
      id: 'test_u_${users.length}',
      name: name,
      email: email,
      studentId: studentId,
      phone: phone,
      iban: iban,
    );
    users[email.toLowerCase()] = user;
    currentUser = user;
    return user;
  }

  @override
  Future<void> updateUser(User user) async {
    if (shouldFail) throw Exception('No connection');
    users[user.email.toLowerCase()] = user;
    if (currentUser?.email.toLowerCase() == user.email.toLowerCase()) {
      currentUser = user;
    }
  }

  @override
  Future<User?> getUserById(String id) async {
    if (shouldFail) throw Exception('No connection');
    final all = [...users.values];
    if (currentUser != null) all.add(currentUser!);
    for (final user in all) {
      if (user.id == id) return user;
    }
    return null;
  }

  @override
  Future<void> logout() async {
    currentUser = null;
  }
}
