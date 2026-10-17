import 'package:flutter/material.dart';

import '../widgets/placeholder_page.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: const PlaceholderPage(
        icon: Icons.forum_outlined,
        title: 'Chat',
        message: 'Messages between the buyer and the seller will appear here.',
      ),
    );
  }
}
