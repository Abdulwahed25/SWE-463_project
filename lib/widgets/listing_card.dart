import 'package:flutter/material.dart';

import '../theme.dart';
import 'status_badge.dart';

/// Card used in the Home and My Listings grids.
/// Shows a photo, status badge, favorite button, title, price and location.
class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.title,
    required this.price,
    required this.location,
    this.isSold = false,
    this.isFavorite = false,
    this.onTap,
    this.onFavorite,
  });

  final String title;
  final double price;
  final String location;
  final bool isSold;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isSold ? 0.7 : 1,
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo area (placeholder until real photos are added)
              Stack(
                children: [
                  Container(
                    height: 118,
                    width: double.infinity,
                    color: const Color(0xFFE2EBED),
                    child: const Icon(Icons.image_outlined, size: 44, color: SouqColors.teal),
                  ),
                  Positioned(top: 8, left: 8, child: StatusBadge(isSold: isSold)),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      onPressed: onFavorite,
                      tooltip: 'Favorite',
                      style: IconButton.styleFrom(backgroundColor: Colors.white),
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: SouqColors.teal,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SouqColors.text),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SAR ${price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isSold ? SouqColors.hint : SouqColors.teal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(location, style: const TextStyle(fontSize: 12, color: SouqColors.hint)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
