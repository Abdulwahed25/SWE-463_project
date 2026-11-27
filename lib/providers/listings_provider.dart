import 'package:flutter/foundation.dart';

import '../models/listing.dart';
import '../services/listing_repository.dart';
import '../services/session.dart';

/// The filters chosen in the Home filter sheet.
class ListingFilter {
  const ListingFilter({
    this.category,
    this.maxPrice,
    this.availableOnly = false,
  });

  final String? category; // null means all categories
  final double? maxPrice; // null means no limit
  final bool availableOnly;

  bool get isActive => category != null || maxPrice != null || availableOnly;
}

/// Shared state for listings (Provider + ChangeNotifier).
/// Used by Home, Filter, Post Listing, Listing Detail, My Listings and Profile.
class ListingsProvider extends ChangeNotifier {
  ListingsProvider(this._repository);

  final ListingRepository _repository;

  /// The signed-in student, or null for a guest. Set by main.dart.
  String? _userId;

  List<Listing> _all = [];
  bool _isLoading = false;
  String? _error;
  String _search = '';
  ListingFilter _filter = const ListingFilter();
  Set<String> _favoriteIds = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get search => _search;
  ListingFilter get filter => _filter;
  bool get hasLoaded => _all.isNotEmpty;

  bool isFavorite(String id) => _favoriteIds.contains(id);

  /// Saved listings, newest first.
  List<Listing> get favorites {
    final saved = _all.where((l) => _favoriteIds.contains(l.id)).toList();
    saved.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return saved;
  }

  /// Listings shown on Home after search and filters, newest first.
  List<Listing> get visibleListings {
    final text = _search.trim().toLowerCase();
    final result = _all.where((l) {
      if (text.isNotEmpty &&
          !l.title.toLowerCase().contains(text) &&
          !l.description.toLowerCase().contains(text)) {
        return false;
      }
      if (_filter.category != null && l.category != _filter.category)
        return false;
      if (_filter.maxPrice != null && l.price > _filter.maxPrice!) return false;
      if (_filter.availableOnly && l.isSold) return false;
      return true;
    }).toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  /// Listings posted by the current user (My Listings).
  List<Listing> get myListings {
    final mine = _all
        .where((l) => l.sellerId == Session.currentUserId)
        .toList();
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

  /// Called by main.dart when someone logs in or out: loads their favorites.
  void setUser(String? userId) {
    if (userId == _userId) return;
    _userId = userId;
    _favoriteIds = {};
    // Runs while widgets are being built, so load right after the build.
    Future.microtask(_loadFavorites);
  }

  Future<void> _loadFavorites() async {
    final id = _userId;
    if (id == null) {
      notifyListeners();
      return;
    }
    try {
      final ids = await _repository.fetchFavoriteIds(id);
      if (id != _userId) return; // user changed while loading
      _favoriteIds = ids;
    } catch (_) {
      _favoriteIds = {}; // favorites are optional; the listings still show
    }
    notifyListeners();
  }

  /// Loads listings from the repository and shows loading / error states.
  /// Also used by pull-to-refresh on Home to get other students' new listings.
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
    String photo = '',
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
      photo: photo,
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

  /// Adds or removes a listing from favorites and saves the change.
  /// Returns false if saving fails; then the heart goes back to how it was.
  Future<bool> toggleFavorite(String id) async {
    final userId = _userId;
    if (userId == null) return false; // guests are asked to log in first
    final before = _favoriteIds;
    final updated = {..._favoriteIds};
    if (!updated.remove(id)) updated.add(id);
    _favoriteIds = updated; // update the UI right away
    notifyListeners();
    try {
      await _repository.saveFavoriteIds(userId, updated);
      return true;
    } catch (e) {
      _favoriteIds = before;
      notifyListeners();
      return false;
    }
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
