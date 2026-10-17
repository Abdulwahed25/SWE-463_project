import 'package:flutter/material.dart';

import '../widgets/placeholder_page.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      body: const PlaceholderPage(
        icon: Icons.inventory_2_outlined,
        title: 'My listings',
        message: 'The items you posted, with All, Available and Sold filters, will appear here.',
      ),
    );
  }
}
