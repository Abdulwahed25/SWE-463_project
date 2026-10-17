import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../widgets/placeholder_page.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PlaceholderPage(
          icon: Icons.shopping_cart_outlined,
          title: 'Souq - Login',
          message: 'Students log in with their KFUPM email and password.',
          actions: [
            PlaceholderAction('Log in', () => Navigator.pushReplacementNamed(context, AppRoutes.home), primary: true),
            PlaceholderAction('Sign up', () => Navigator.pushNamed(context, AppRoutes.signUp)),
          ],
        ),
      ),
    );
  }
}
