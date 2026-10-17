import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../widgets/placeholder_page.dart';

class PostedScreen extends StatelessWidget {
  const PostedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PlaceholderPage(
          icon: Icons.check_circle_outline,
          title: 'Your listing is live!',
          message: 'Students can now find your item and message you about it.',
          actions: [
            PlaceholderAction(
              'View my listings',
              () => Navigator.pushReplacementNamed(context, AppRoutes.myListings),
              primary: true,
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
