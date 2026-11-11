import 'package:flutter/material.dart';

import '../theme.dart';

/// White rounded card with a soft shadow, used to group rows on the
/// Profile and Edit Profile screens.
///
/// The child sits on a [Material] so that tapping a [ListTile] inside the
/// card shows the ripple effect (a plain Container would hide it).
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(kSouqRadius);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: padding == null ? child : Padding(padding: padding!, child: child),
      ),
    );
  }
}
