import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../widgets/placeholder_page.dart';

/// Success screen shown after a listing is posted.
class PostedScreen extends StatelessWidget {
  const PostedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The id of the new listing is passed from Post Listing.
    final listingId = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      body: SafeArea(
        child: PlaceholderPage(
          icon: Icons.check_circle_outline,
          title: 'Your listing is live!',
          message: 'Students can now find your item on Home and message you about it.',
          actions: [
            if (listingId != null)
              PlaceholderAction(
                'View listing',
                () => Navigator.pushReplacementNamed(context, AppRoutes.listingDetail, arguments: listingId),
                primary: true,
              ),
            PlaceholderAction(
              'View my listings',
              () => Navigator.pushReplacementNamed(context, AppRoutes.myListings),
            ),
            PlaceholderAction(
              'Back to Home',
              () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false),
            ),
          ],
        ),
      ),
    );
  }
}
