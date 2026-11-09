import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../models/category.dart';
import '../models/listing.dart';
import '../providers/auth_provider.dart';
import '../providers/listings_provider.dart';
import '../utils/auth_dialog.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';
import '../widgets/listing_card.dart';
import 'filter_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  bool _savedOnly = false; // local state: show only saved listings

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearAll(ListingsProvider provider) {
    _searchController.clear();
    provider.clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingsProvider>();
    final filter = provider.filter;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Souq'),
        actions: [
          IconButton(
            tooltip: 'Filter',
            icon: Badge(isLabelVisible: filter.isActive, child: const Icon(Icons.tune)),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const FilterSheet(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: provider.setSearch,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search listings',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: provider.search.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearch('');
                        },
                      ),
              ),
            ),
          ),
          // Category chips
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: const Icon(Icons.favorite, size: 16),
                    label: const Text('Saved'),
                    selected: _savedOnly,
                    onSelected: (v) => setState(() => _savedOnly = v),
                  ),
                ),
                _categoryChip(provider, 'All', null),
                for (final c in kCategories) _categoryChip(provider, c, c),
              ],
            ),
          ),
          Expanded(child: _buildBody(provider)),
        ],
      ),
    );
  }

  Widget _categoryChip(ListingsProvider provider, String label, String? category) {
    final f = provider.filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: f.category == category,
        onSelected: (_) => provider.setFilter(
          ListingFilter(category: category, maxPrice: f.maxPrice, availableOnly: f.availableOnly),
        ),
      ),
    );
  }

  Widget _buildBody(ListingsProvider provider) {
    // Loading state (first load only)
    if (provider.isLoading && !provider.hasLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    // Error state
    if (provider.error != null) {
      return EmptyState(
        icon: Icons.wifi_off,
        title: "Couldn't load listings",
        message: provider.error!,
        buttonText: 'Try again',
        onPressed: provider.load,
      );
    }
    var listings = provider.visibleListings;
    if (_savedOnly) {
      listings = listings.where((l) => provider.isFavorite(l.id)).toList();
    }
    // Empty state for saved listings
    if (listings.isEmpty && _savedOnly) {
      return EmptyState(
        icon: Icons.favorite_border,
        title: 'No saved listings',
        message: 'Tap the heart on a listing to save it here.',
        buttonText: 'Show all listings',
        onPressed: () => setState(() => _savedOnly = false),
      );
    }
    // Empty / no results state
    if (listings.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'No results',
        message: 'Try another word or clear the filters.',
        buttonText: 'Clear filters',
        onPressed: () => _clearAll(provider),
      );
    }
    return RefreshIndicator(
      onRefresh: provider.load,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        itemCount: listings.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 260,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, i) => _card(context, listings[i]),
      ),
    );
  }

  Widget _card(BuildContext context, Listing l) {
    return ListingCard(
      title: l.title,
      price: l.price,
      location: '${l.location} · ${timeAgo(l.createdAt)}',
      isSold: l.isSold,
      isFavorite: context.read<ListingsProvider>().isFavorite(l.id),
      onFavorite: () {
        final auth = context.read<AuthProvider>();
        if (!auth.isAuthenticated) {
          showLoginPrompt(
            context,
            title: 'Login to Save',
            message: 'You need an account to save favorite items to your wishlist.',
          );
          return;
        }
        context.read<ListingsProvider>().toggleFavorite(l.id);
      },
      onTap: () => Navigator.pushNamed(context, AppRoutes.listingDetail, arguments: l.id),
    );
  }
}
