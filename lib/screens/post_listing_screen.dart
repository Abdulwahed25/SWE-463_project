import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../widgets/placeholder_page.dart';

class PostListingScreen extends StatelessWidget {
  const PostListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post a Listing')),
      body: PlaceholderPage(
        icon: Icons.add_a_photo_outlined,
        title: 'Post a listing',
        message: 'Photos, title, price, category, condition, location and description go here.',
        actions: [
          PlaceholderAction(
            'Post listing',
            () => Navigator.pushReplacementNamed(context, AppRoutes.posted),
            primary: true,
          ),
        ],
      ),
    );
  }
}
