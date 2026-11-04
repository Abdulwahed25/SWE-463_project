import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../models/listing.dart';
import '../providers/listings_provider.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_badge.dart';

/// Shows one listing. The listing id is passed as the route argument.
class ListingDetailScreen extends StatelessWidget {
  const ListingDetailScreen({super.key});

  Future<void> _confirmMarkSold(BuildContext context, Listing listing) async {
    final provider = context.read<ListingsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mark as sold?'),
        content: const Text('Buyers will see this item as sold and will not be able to message you about it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Mark as sold'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await provider.markAsSold(listing.id);
      messenger.showSnackBar(const SnackBar(content: Text('Listing marked as sold')));
    } catch (e) {
      messenger.showSnackBar(const SnackBar(content: Text("Couldn't update the listing. Try again.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)?.settings.arguments as String?;
    final provider = context.watch<ListingsProvider>();
    final listing = id == null ? null : provider.byId(id);

    if (listing == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Listing')),
        body: const EmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'Listing not found',
          message: 'This listing may have been removed.',
        ),
      );
    }

    final isMine = provider.isMine(listing);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Listing')),
      body: ListView(
        children: [
          // Photo placeholder
          Container(
            height: 220,
            color: const Color(0xFFE2EBED),
            child: const Icon(Icons.image_outlined, size: 64, color: SouqColors.teal),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusBadge(isSold: listing.isSold),
                const SizedBox(height: 10),
                Text(listing.title, style: text.titleLarge),
                const SizedBox(height: 6),
                Text(
                  formatPrice(listing.price),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: listing.isSold ? SouqColors.hint : SouqColors.teal,
                  ),
                ),
                const SizedBox(height: 16),
                _info(Icons.category_outlined, 'Category', listing.category),
                _info(Icons.star_outline, 'Condition', listing.condition),
                _info(Icons.place_outlined, 'Pickup', listing.location),
                _info(Icons.schedule, 'Posted', timeAgo(listing.createdAt)),
                const SizedBox(height: 16),
                Text('Description', style: text.titleMedium),
                const SizedBox(height: 6),
                Text(listing.description, style: text.bodyLarge),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(isMine ? 'You' : listing.sellerName),
                    subtitle: const Text('Seller'),
                  ),
                ),
                const SizedBox(height: 20),
                ..._actions(context, listing, isMine),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _actions(BuildContext context, Listing listing, bool isMine) {
    if (isMine) {
      return [
        FilledButton.icon(
          onPressed: listing.isSold ? null : () => _confirmMarkSold(context, listing),
          icon: const Icon(Icons.check),
          label: Text(listing.isSold ? 'Sold' : 'Mark as sold'),
        ),
      ];
    }
    return [
      FilledButton(
        onPressed: listing.isSold ? null : () => Navigator.pushNamed(context, AppRoutes.chat),
        child: Text(listing.isSold ? 'This item is sold' : 'Message seller'),
      ),
      const SizedBox(height: 12),
      OutlinedButton(
        onPressed: listing.isSold
            ? null
            : () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('IBAN copied to clipboard')),
                ),
        child: const Text('Copy IBAN'),
      ),
    ];
  }

  Widget _info(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: SouqColors.subText),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: SouqColors.subText)),
          Expanded(child: Text(value, style: const TextStyle(color: SouqColors.text))),
        ],
      ),
    );
  }
}
