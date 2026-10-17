import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../widgets/placeholder_page.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: PlaceholderPage(
        icon: Icons.person_add_alt,
        title: 'Create account',
        message: 'New students enter their name, KFUPM email, student ID and password.',
        actions: [
          PlaceholderAction(
            'Create account',
            () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false),
            primary: true,
          ),
          PlaceholderAction('Back to Login', () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
