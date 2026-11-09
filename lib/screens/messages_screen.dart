import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/placeholder_page.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Messages')),
        body: PlaceholderPage(
          icon: Icons.chat_bubble_outline,
          title: 'Messages',
          message: 'Log in to view your chats with buyers and sellers.',
          actions: [
            PlaceholderAction(
              'Log in',
              () => Navigator.pushNamed(context, AppRoutes.login),
              primary: true,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: PlaceholderPage(
        icon: Icons.chat_bubble_outline,
        title: 'Messages',
        message: 'Your chats with buyers and sellers will appear here.',
        actions: [
          PlaceholderAction('Open a chat', () => Navigator.pushNamed(context, AppRoutes.chat), primary: true),
        ],
      ),
    );
  }
}
