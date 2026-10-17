import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../widgets/placeholder_page.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
