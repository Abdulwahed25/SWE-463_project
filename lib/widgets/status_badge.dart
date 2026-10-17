import 'package:flutter/material.dart';

import '../theme.dart';

/// Small label that shows if a listing is "Available" or "Sold".
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.isSold});

  final bool isSold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSold ? SouqColors.sold : SouqColors.green,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isSold ? 'Sold' : 'Available',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
