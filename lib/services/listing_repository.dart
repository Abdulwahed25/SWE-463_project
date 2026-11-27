import '../models/listing.dart';

/// The app only talks to listings through this class.
/// The app uses FirestoreListingRepository; tests use a fake with the same
/// methods, so the screens and the provider do not depend on Firestore.
abstract class ListingRepository {
  Future<List<Listing>> fetchListings();

  Future<void> addListing(Listing listing);

  Future<void> updateListing(Listing listing);

  /// Ids of the listings [userId] saved with the heart button.
  Future<Set<String>> fetchFavoriteIds(String userId);

  Future<void> saveFavoriteIds(String userId, Set<String> ids);
}
