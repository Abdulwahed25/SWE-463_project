import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../widgets/placeholder_page.dart';

class ListingDetailScreen extends StatelessWidget {
  const ListingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listing Detail')),
      body: PlaceholderPage(
        icon: Icons.image_outlined,
        title: 'Item name',
        message: 'Photos, price, details, description and seller will be shown here.',
        actions: [
          PlaceholderAction(
            'Message seller',
            () => Navigator.pushNamed(context, AppRoutes.chat),
            primary: true,
          ),
          PlaceholderAction(
            'Copy IBAN',
            () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('IBAN copied to clipboard')),
            ),
          ),
        ],
      ),
    );
  }
}
