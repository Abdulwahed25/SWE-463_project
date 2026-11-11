import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import 'auth_repository.dart';

/// TEMPORARY local data source for authentication in Phase 3.
/// Saves accounts and the active session on the device using shared_preferences.
/// Designed with the exact same method signatures as FirebaseAuth & Firestore for Phase 4.
class LocalAuthRepository implements AuthRepository {
  static const String _usersKey = 'souq_users_v3';
  static const String _currentUserKey = 'souq_current_user_email_v3';

  // Small delay to simulate network latency and show loading states
  static const Duration _delay = Duration(milliseconds: 500);

  // Default demo student if no accounts are stored yet
  static final User defaultDemoUser = User(
    id: 'kfupm_demo_1',
    name: 'Fname Lname',
    email: 'student@kfupm.edu.sa',
    studentId: '202500123',
    phone: '+966 50 123 4567',
    iban: 'SA0380000000608010167519',
  );
  static const String defaultDemoPassword = 'password123';

  Future<Map<String, dynamic>> _getAllAccounts(SharedPreferences prefs) async {
    final raw = prefs.getString(_usersKey);
    if (raw == null) {
      // Seed initial demo account
      final initial = {
        defaultDemoUser.email.toLowerCase(): {
          'user': defaultDemoUser.toMap(),
          'password': defaultDemoPassword,
        }
      };
      await prefs.setString(_usersKey, jsonEncode(initial));
      return initial;
    }
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    await Future.delayed(_delay);
    final prefs = await SharedPreferences.getInstance();
    final currentEmail = prefs.getString(_currentUserKey);
    if (currentEmail == null) return null;

    final accounts = await _getAllAccounts(prefs);
    final account = accounts[currentEmail.toLowerCase()];
    if (account == null) return null;

    final userMap = account['user'] as Map<String, dynamic>;
    return User.fromMap(userMap);
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(_delay);
    final prefs = await SharedPreferences.getInstance();
    final accounts = await _getAllAccounts(prefs);

    final normalizedEmail = email.trim().toLowerCase();
    final account = accounts[normalizedEmail] as Map<String, dynamic>?;

    if (account == null) {
      throw Exception('No account found for $email. Please sign up first.');
    }

    final storedPassword = account['password'] as String?;
    if (storedPassword != password) {
      throw Exception('Incorrect password. Please try again.');
    }

    final user = User.fromMap(account['user'] as Map<String, dynamic>);
    await prefs.setString(_currentUserKey, normalizedEmail);
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
    await Future.delayed(_delay);
    final prefs = await SharedPreferences.getInstance();
    final accounts = await _getAllAccounts(prefs);

    final normalizedEmail = email.trim().toLowerCase();
    if (accounts.containsKey(normalizedEmail)) {
      throw Exception('An account with this email already exists.');
    }

    final newUser = User(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: normalizedEmail,
      studentId: studentId.trim(),
      phone: phone.trim(),
      iban: iban.trim(),
    );

    accounts[normalizedEmail] = {
      'user': newUser.toMap(),
      'password': password,
    };

    await prefs.setString(_usersKey, jsonEncode(accounts));
    await prefs.setString(_currentUserKey, normalizedEmail);
    return newUser;
  }

  @override
  Future<void> updateUser(User user) async {
    await Future.delayed(_delay);
    final prefs = await SharedPreferences.getInstance();
    final accounts = await _getAllAccounts(prefs);

    final normalizedEmail = user.email.trim().toLowerCase();
    if (!accounts.containsKey(normalizedEmail)) {
      throw Exception('User account not found.');
    }

    accounts[normalizedEmail]['user'] = user.toMap();
    await prefs.setString(_usersKey, jsonEncode(accounts));
  }

  @override
  Future<User?> getUserById(String id) async {
    await Future.delayed(_delay);
    final prefs = await SharedPreferences.getInstance();
    final accounts = await _getAllAccounts(prefs);
    for (final account in accounts.values) {
      final userMap = (account as Map<String, dynamic>)['user'] as Map<String, dynamic>;
      if (userMap['id'] == id) return User.fromMap(userMap);
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }
}
