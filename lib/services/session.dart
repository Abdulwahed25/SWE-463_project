/// TEMPORARY current user for Phase 3.
/// Listings posted in the app are saved with this seller.
/// It will be replaced by the signed-in user from AuthProvider.
class Session {
  Session._();

  static const String currentUserId = 'me';
  static const String currentUserName = 'You';
}
