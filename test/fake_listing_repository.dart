import 'package:souq/models/listing.dart';
import 'package:souq/services/listing_repository.dart';

/// In-memory listing repository used only by tests (no Firebase, no delay).
class FakeListingRepository implements ListingRepository {
  FakeListingRepository({List<Listing>? initial, this.shouldFail = false})
    : _items = [...?initial];

  final List<Listing> _items;
  bool shouldFail;

  @override
  Future<List<Listing>> fetchListings() async {
    if (shouldFail) throw Exception('No connection');
    return [..._items];
  }

  @override
  Future<void> addListing(Listing listing) async {
    if (shouldFail) throw Exception('No connection');
    _items.insert(0, listing);
  }

  @override
  Future<void> updateListing(Listing listing) async {
    final i = _items.indexWhere((l) => l.id == listing.id);
    _items[i] = listing;
  }

  /// Favorites per user id.
  final Map<String, Set<String>> favoritesByUser = {};

  Set<String> savedFavorites([String userId = 'me']) => {
    ...?favoritesByUser[userId],
  };

  @override
  Future<Set<String>> fetchFavoriteIds(String userId) async =>
      savedFavorites(userId);

  @override
  Future<void> saveFavoriteIds(String userId, Set<String> ids) async {
    if (shouldFail) throw Exception('No connection');
    favoritesByUser[userId] = {...ids};
  }
}

Listing testListing(
  String id,
  String title,
  double price,
  String category, {
  String sellerId = 'other',
  bool sold = false,
}) {
  return Listing(
    id: id,
    title: title,
    price: price,
    category: category,
    condition: 'Used',
    location: 'Building 57',
    description: 'Test item description',
    sellerId: sellerId,
    sellerName: 'Tester',
    createdAt: DateTime(2026, 11, 1),
    status: sold ? ListingStatus.sold : ListingStatus.available,
  );
}
