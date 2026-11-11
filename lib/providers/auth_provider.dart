import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/auth_repository.dart';
import '../services/session.dart';

/// Manages authentication state, user session, and error handling for the app.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository);

  final AuthRepository _repository;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Checks if a session already exists on device startup.
  Future<void> loadSession() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final existingUser = await _repository.getCurrentUser();
      _user = existingUser;
      Session.setUser(existingUser);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Attempts to log in with KFUPM credentials.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _repository.login(
        email: email,
        password: password,
      );
      _user = user;
      Session.setUser(user);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Registers a new student account.
  Future<bool> signUp({
    required String name,
    required String email,
    required String studentId,
    required String password,
    String phone = '',
    String iban = '',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newUser = await _repository.signUp(
        name: name,
        email: email,
        studentId: studentId,
        password: password,
        phone: phone,
        iban: iban,
      );
      _user = newUser;
      Session.setUser(newUser);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Updates profile information (phone, IBAN, etc.).
  Future<bool> updateProfile(User updated) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateUser(updated);
      _user = updated;
      Session.setUser(updated);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Looks up another user's public profile (used to show a seller's IBAN).
  /// Does not change the signed-in user or the loading flag, so the caller
  /// shows its own loading / error state. Throws if the lookup fails.
  Future<User?> fetchUser(String id) => _repository.getUserById(id);

  /// Signs the student out and clears their active session.
  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    Session.setUser(null);
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
