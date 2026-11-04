import '../models/listing.dart';

/// The app only talks to listings through this class.
/// Phase 3 uses LocalListingRepository (saved on the device).
/// Phase 4 will add a FirestoreListingRepository with the same methods,
/// so the screens and the provider do not need to change.
abstract class ListingRepository {
  Future<List<Listing>> fetchListings();

  Future<void> addListing(Listing listing);

  Future<void> updateListing(Listing listing);
}
