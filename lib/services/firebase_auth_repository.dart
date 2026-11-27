import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../models/user.dart';
import 'auth_repository.dart';

/// Accounts with Firebase Authentication (email and password).
/// Each student's profile (name, student ID, phone, IBAN) is saved in
/// Firestore at users/{uid}.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({fb.FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? fb.FirebaseAuth.instance,
      _db = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  @override
  Future<User?> getCurrentUser() async {
    // Waits until Firebase has restored the saved login (or found none).
    final firebaseUser = await _auth.authStateChanges().first;
    if (firebaseUser == null) return null;
    return _loadProfile(firebaseUser);
  }

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _loadProfile(result.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(_friendlyMessage(e.code));
    }
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
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = User(
        id: result.user!.uid,
        name: name.trim(),
        email: email.trim(),
        studentId: studentId.trim(),
        phone: phone,
        iban: iban,
      );
      await _users.doc(user.id).set(user.toMap());
      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(_friendlyMessage(e.code));
    }
  }

  @override
  Future<void> updateUser(User user) {
    return _users.doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  @override
  Future<User?> getUserById(String id) async {
    final doc = await _users.doc(id).get();
    if (!doc.exists) return null;
    return User.fromMap({...doc.data()!, 'id': doc.id});
  }

  @override
  Future<void> logout() => _auth.signOut();

  /// Reads users/{uid}. If the profile is missing, a basic one is made from
  /// the login email so the app can still open.
  Future<User> _loadProfile(fb.User firebaseUser) async {
    final saved = await getUserById(firebaseUser.uid);
    if (saved != null) return saved;
    final email = firebaseUser.email ?? '';
    final basic = User(
      id: firebaseUser.uid,
      name: email.split('@').first,
      email: email,
      studentId: '',
    );
    await _users.doc(basic.id).set(basic.toMap());
    return basic;
  }

  /// Turns Firebase error codes into short messages for the user.
  static String _friendlyMessage(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account with this email already exists. Please log in.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a minute and try again.';
      case 'network-request-failed':
        return 'No internet connection. Check your connection and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
