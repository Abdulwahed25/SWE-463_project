import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../providers/listings_provider.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';
import '../widgets/listing_card.dart';

enum _StatusTab { all, available, sold }

/// The current user's own listings, with an All / Available / Sold filter.
class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  _StatusTab _tab = _StatusTab.all; // local state (setState)

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingsProvider>();
    final mine = provider.myListings.where((l) {
      switch (_tab) {
        case _StatusTab.all:
          return true;
        case _StatusTab.available:
          return !l.isSold;
        case _StatusTab.sold:
          return l.isSold;
      }
    }).toList();

    Widget body;
    if (provider.isLoading && !provider.hasLoaded) {
      body = const Center(child: CircularProgressIndicator());
    } else if (provider.myListings.isEmpty) {
      body = EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No listings yet',
        message: 'Items you post will appear here.',
        buttonText: 'Post a listing',
        onPressed: () => Navigator.pushNamed(context, AppRoutes.postListing),
      );
    } else if (mine.isEmpty) {
      body = const EmptyState(
        icon: Icons.filter_alt_off_outlined,
        title: 'Nothing here',
        message: 'No listings match this status.',
      );
    } else {
      body = GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mine.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 260,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, i) {
          final l = mine[i];
          return ListingCard(
            title: l.title,
            price: l.price,
            location: '${l.location} · ${timeAgo(l.createdAt)}',
            isSold: l.isSold,
            onTap: () => Navigator.pushNamed(context, AppRoutes.listingDetail, arguments: l.id),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SegmentedButton<_StatusTab>(
              segments: const [
                ButtonSegment(value: _StatusTab.all, label: Text('All')),
                ButtonSegment(value: _StatusTab.available, label: Text('Available')),
                ButtonSegment(value: _StatusTab.sold, label: Text('Sold')),
              ],
              selected: {_tab},
              onSelectionChanged: (s) => setState(() => _tab = s.first),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
