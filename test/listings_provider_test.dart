import 'package:flutter_test/flutter_test.dart';
import 'package:souq/providers/listings_provider.dart';
import 'package:souq/services/session.dart';

import 'fake_listing_repository.dart';

void main() {
  late FakeListingRepository repo;
  late ListingsProvider provider;

  setUp(() {
    repo = FakeListingRepository(initial: [
      testListing('1', 'Calculus book', 60, 'Books'),
      testListing('2', 'Desk lamp', 35, 'Furniture'),
      testListing('3', 'Office chair', 150, 'Furniture', sold: true),
    ]);
    provider = ListingsProvider(repo);
  });

  test('load() fills the list and stops loading', () async {
    await provider.load();
    expect(provider.isLoading, false);
    expect(provider.error, isNull);
    expect(provider.visibleListings.length, 3);
  });

  test('load() shows an error when the repository fails', () async {
    repo.shouldFail = true;
    await provider.load();
    expect(provider.error, isNotNull);
  });

  test('search and filters change the visible listings', () async {
    await provider.load();
    provider.setSearch('lamp');
    expect(provider.visibleListings.map((l) => l.id), ['2']);

    provider.clearFilters();
    provider.setFilter(const ListingFilter(category: 'Furniture', availableOnly: true));
    expect(provider.visibleListings.map((l) => l.id), ['2']);

    provider.setFilter(const ListingFilter(maxPrice: 50));
    expect(provider.visibleListings.map((l) => l.id), ['2']);
  });

  test('addListing() saves the item and shows it in My Listings', () async {
    await provider.load();
    final added = await provider.addListing(
      title: 'Lab coat',
      price: 25,
      category: 'Clothes',
      condition: 'Used',
      location: 'Building 4',
      description: 'White lab coat, size M',
    );
    expect(added.sellerId, Session.currentUserId);
    expect(provider.visibleListings.first.id, added.id);
    expect(provider.myListings.length, 1);
    expect((await repo.fetchListings()).length, 4);
  });

  test('markAsSold() changes the status', () async {
    await provider.load();
    await provider.markAsSold('1');
    expect(provider.byId('1')!.isSold, true);
  });
}
