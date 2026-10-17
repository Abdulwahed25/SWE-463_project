import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../widgets/placeholder_page.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: PlaceholderPage(
        icon: Icons.person_outline,
        title: 'Profile',
        message: 'Name, email, phone, student ID and IBAN will be shown here.',
        actions: [
          PlaceholderAction('Edit profile', () => Navigator.pushNamed(context, AppRoutes.editProfile), primary: true),
          PlaceholderAction('My listings', () => Navigator.pushNamed(context, AppRoutes.myListings)),
          PlaceholderAction(
            'Log out',
            () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false),
          ),
        ],
      ),
    );
  }
}
