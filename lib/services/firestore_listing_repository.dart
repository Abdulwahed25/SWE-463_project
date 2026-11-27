import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/listing.dart';
import 'listing_repository.dart';

/// Listings saved in Cloud Firestore at listings/{id}.
/// Favorites are saved on the student's profile as users/{uid}.favoriteIds.
class FirestoreListingRepository implements ListingRepository {
  FirestoreListingRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _listings => _db.collection('listings');

  @override
  Future<List<Listing>> fetchListings() async {
    final snapshot = await _listings.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => Listing.fromMap({...doc.data(), 'id': doc.id})).toList();
  }

  @override
  Future<void> addListing(Listing listing) {
    return _listings.doc(listing.id).set(listing.toMap());
  }

  @override
  Future<void> updateListing(Listing listing) {
    return _listings.doc(listing.id).update(listing.toMap());
  }

  @override
  Future<Set<String>> fetchFavoriteIds(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    final ids = doc.data()?['favoriteIds'] as List<dynamic>? ?? [];
    return ids.map((id) => id.toString()).toSet();
  }

  @override
  Future<void> saveFavoriteIds(String userId, Set<String> ids) {
    return _db
        .collection('users')
        .doc(userId)
        .set({'favoriteIds': ids.toList()}, SetOptions(merge: true));
  }
}
