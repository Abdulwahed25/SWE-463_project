import 'package:souq/models/user.dart';
import 'package:souq/services/auth_repository.dart';

/// In-memory auth repository used by tests.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.currentUser});

  User? currentUser;
  final Map<String, User> users = {};

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
    users[user.email.toLowerCase()] = user;
    if (currentUser?.email.toLowerCase() == user.email.toLowerCase()) {
      currentUser = user;
    }
  }

  @override
  Future<void> logout() async {
    currentUser = null;
  }
}
