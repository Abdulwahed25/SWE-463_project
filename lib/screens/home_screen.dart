import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../widgets/listing_card.dart';
import 'filter_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Souq'),
        actions: [
          IconButton(
            tooltip: 'Filter',
            icon: const Icon(Icons.tune),
            onPressed: () => showModalBottomSheet(context: context, builder: (_) => const FilterSheet()),
          ),
        ],
      ),
      // Sample cards for now. Real listings come from Firestore in Phase 3.
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, i) => ListingCard(
          title: 'Item name',
          price: 0,
          location: 'Location · Time',
          isSold: i == 2,
          onTap: () => Navigator.pushNamed(context, AppRoutes.listingDetail),
        ),
      ),
    );
  }
}
