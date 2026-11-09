import '../models/user.dart';

/// Active user session information.
/// Listings posted in the app are tagged with this seller.
class Session {
  Session._();

  static User? currentUser;

  static String get currentUserId => currentUser?.id ?? 'me';
  static String get currentUserName => currentUser?.name ?? 'You';

  static void setUser(User? user) {
    currentUser = user;
  }
}
