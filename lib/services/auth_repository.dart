import '../models/user.dart';

/// Contract for authentication and user profile data.
/// Screens and providers only talk to this interface so Firebase Auth & Firestore
/// can replace the local implementation in Phase 4 without touching the UI.
abstract class AuthRepository {
  Future<User?> getCurrentUser();

  Future<User> login({
    required String email,
    required String password,
  });

  Future<User> signUp({
    required String name,
    required String email,
    required String studentId,
    required String password,
    String phone = '',
    String iban = '',
  });

  Future<void> updateUser(User user);

  Future<void> logout();
}
