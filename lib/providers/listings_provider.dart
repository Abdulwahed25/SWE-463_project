import 'package:flutter/foundation.dart';

import '../models/listing.dart';
import '../services/listing_repository.dart';
import '../services/session.dart';

/// The filters chosen in the Home filter sheet.
class ListingFilter {
  const ListingFilter({this.category, this.maxPrice, this.availableOnly = false});

  final String? category; // null means all categories
  final double? maxPrice; // null means no limit
  final bool availableOnly;

  bool get isActive => category != null || maxPrice != null || availableOnly;
}

/// Shared state for listings (Provider + ChangeNotifier).
/// Used by Home, Filter, Post Listing, Listing Detail and My Listings.
class ListingsProvider extends ChangeNotifier {
  ListingsProvider(this._repository);

  final ListingRepository _repository;

  List<Listing> _all = [];
  bool _isLoading = false;
  String? _error;
  String _search = '';
  ListingFilter _filter = const ListingFilter();

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get search => _search;
  ListingFilter get filter => _filter;
  bool get hasLoaded => _all.isNotEmpty;

  /// Listings shown on Home after search and filters, newest first.
  List<Listing> get visibleListings {
    final text = _search.trim().toLowerCase();
    final result = _all.where((l) {
      if (text.isNotEmpty &&
          !l.title.toLowerCase().contains(text) &&
          !l.description.toLowerCase().contains(text)) {
        return false;
      }
      if (_filter.category != null && l.category != _filter.category) return false;
      if (_filter.maxPrice != null && l.price > _filter.maxPrice!) return false;
      if (_filter.availableOnly && l.isSold) return false;
      return true;
    }).toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  /// Listings posted by the current user (My Listings).
  List<Listing> get myListings {
    final mine = _all.where((l) => l.sellerId == Session.currentUserId).toList();
    mine.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return mine;
  }

  Listing? byId(String id) {
    for (final l in _all) {
      if (l.id == id) return l;
    }
    return null;
  }

  bool isMine(Listing listing) => listing.sellerId == Session.currentUserId;

  /// Loads listings from the repository and shows loading / error states.
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _all = await _repository.fetchListings();
    } catch (e) {
      _error = 'Check your connection and try again.';
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Creates a new listing. Throws if saving fails, so the form can show an error.
  Future<Listing> addListing({
    required String title,
    required double price,
    required String category,
    required String condition,
    required String location,
    required String description,
  }) async {
    final listing = Listing(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      price: price,
      category: category,
      condition: condition,
      location: location.trim(),
      description: description.trim(),
      sellerId: Session.currentUserId,
      sellerName: Session.currentUserName,
      createdAt: DateTime.now(),
    );
    await _repository.addListing(listing);
    _all.insert(0, listing);
    notifyListeners();
    return listing;
  }

  /// Seller marks their own listing as sold.
  Future<void> markAsSold(String id) async {
    final listing = byId(id);
    if (listing == null || listing.isSold) return;
    final updated = listing.copyWith(status: ListingStatus.sold);
    await _repository.updateListing(updated);
    _all = [for (final l in _all) l.id == id ? updated : l];
    notifyListeners();
  }

  void setSearch(String text) {
    _search = text;
    notifyListeners();
  }

  void setFilter(ListingFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void clearFilters() {
    _search = '';
    _filter = const ListingFilter();
    notifyListeners();
  }
}
