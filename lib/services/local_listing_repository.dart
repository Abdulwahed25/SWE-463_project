import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/listing.dart';
import 'listing_repository.dart';

/// TEMPORARY data source for Phase 3.
/// Saves listings on the device with shared_preferences as a JSON list.
/// It will be replaced by Firestore in Phase 4.
class LocalListingRepository implements ListingRepository {
  static const String _key = 'souq_listings_v1';

  // Small delay so the loading state can be seen, like a real network call.
  static const Duration _delay = Duration(milliseconds: 600);

  @override
  Future<List<Listing>> fetchListings() async {
    await Future.delayed(_delay);
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == null) {
      // First run: start with a few sample listings.
      final samples = sampleListings();
      await _save(prefs, samples);
      return samples;
    }
    final list = jsonDecode(saved) as List<dynamic>;
    return list.map((e) => Listing.fromMap(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> addListing(Listing listing) async {
    await Future.delayed(_delay);
    final prefs = await SharedPreferences.getInstance();
    final all = await _read(prefs);
    all.insert(0, listing);
    await _save(prefs, all);
  }

  @override
  Future<void> updateListing(Listing listing) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await _read(prefs);
    final index = all.indexWhere((l) => l.id == listing.id);
    if (index == -1) throw Exception('Listing not found');
    all[index] = listing;
    await _save(prefs, all);
  }

  Future<List<Listing>> _read(SharedPreferences prefs) async {
    final saved = prefs.getString(_key);
    if (saved == null) return sampleListings();
    final list = jsonDecode(saved) as List<dynamic>;
    return list.map((e) => Listing.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> _save(SharedPreferences prefs, List<Listing> listings) {
    return prefs.setString(_key, jsonEncode(listings.map((l) => l.toMap()).toList()));
  }
}

/// Sample data shown the first time the app opens.
List<Listing> sampleListings() {
  final now = DateTime.now();
  Listing item(String id, String title, double price, String category, String condition,
      String location, String seller, int hoursAgo, {bool sold = false}) {
    return Listing(
      id: id,
      title: title,
      price: price,
      category: category,
      condition: condition,
      location: location,
      description: '$title in $condition condition. Message me if you are interested.',
      sellerId: 'sample_${seller.toLowerCase()}',
      sellerName: seller,
      createdAt: now.subtract(Duration(hours: hoursAgo)),
      status: sold ? ListingStatus.sold : ListingStatus.available,
    );
  }

  return [
    item('s1', 'Calculus textbook', 60, 'Books', 'Used', 'Building 22', 'Omar', 2),
    item('s2', 'Desk lamp', 35, 'Furniture', 'Like new', 'Building 58', 'Faisal', 5),
    item('s3', 'Scientific calculator', 80, 'Electronics', 'Like new', 'Building 24', 'Khalid', 9),
    item('s4', 'Office chair', 150, 'Furniture', 'Used', 'Building 57', 'Saud', 20, sold: true),
    item('s5', 'Wireless mouse', 45, 'Electronics', 'New', 'Building 59', 'Yousef', 30),
    item('s6', 'Lab coat', 25, 'Clothes', 'Used', 'Building 4', 'Ali', 48),
  ];
}
