import 'package:flutter/material.dart';

import '../app_routes.dart';
import 'home_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';

/// Holds the bottom navigation bar: Home, Post, Messages, Profile.
/// "Post" opens the Post Listing screen on top instead of switching tabs.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0; // 0 = Home, 1 = Messages, 2 = Profile

  static const _pages = [HomeScreen(), MessagesScreen(), ProfileScreen()];

  // Bar positions: 0 Home, 1 Post, 2 Messages, 3 Profile
  int get _barIndex => _tab == 0 ? 0 : _tab + 1;

  void _onTap(int index) {
    if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.postListing);
      return;
    }
    setState(() => _tab = index == 0 ? 0 : index - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _barIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.add_box_outlined), label: 'Post'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
