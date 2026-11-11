import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../providers/chat_provider.dart';
import '../providers/listings_provider.dart';
import '../widgets/chat_item_tile.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  static const String _currentUserId = 'my_user_id';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatProvider = context.watch<ChatProvider>();
    final listingsProvider = context.watch<ListingsProvider>();

    final filteredChats = chatProvider.chats.where((chat) {
      final listing = listingsProvider.byId(chat.listingId);
      final sellerName = listing?.sellerName ?? 'Ali (KFUPM Student)';
      final itemTitle = listing?.title ?? 'Calculus Book';
      final query = _searchQuery.toLowerCase();

      return chat.lastMessage.toLowerCase().contains(query) ||
          sellerName.toLowerCase().contains(query) ||
          itemTitle.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search chats...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: _buildBody(context, chatProvider, listingsProvider, filteredChats),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ChatProvider chatProvider,
    ListingsProvider listingsProvider,
    List filteredChats,
  ) {
    final theme = Theme.of(context);

    if (chatProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chatProvider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 12),
              Text(
                'Could not load messages',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => chatProvider.loadChats(userId: _currentUserId),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredChats.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty ? 'No chats yet' : 'No matching chats',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isEmpty
                    ? 'When you message a seller, or a buyer messages you, the chat will show up here.'
                    : 'Try searching with a different keyword.',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
              if (_searchQuery.isEmpty) ...[
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.home);
                  },
                  child: const Text('Browse listings'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: filteredChats.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final chat = filteredChats[index];
        final listing = listingsProvider.byId(chat.listingId);
        final peerName = listing?.sellerName ?? 'Ali (KFUPM Student)';
        final itemTitle = listing?.title ?? 'Calculus Book';
        final itemPrice = listing?.price ?? 150.0;

        return ChatItemTile(
          chat: chat,
          peerName: '$peerName • $itemTitle',
          currentUserId: _currentUserId,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.chat,
              arguments: {
                'chatId': chat.id,
                'peerName': peerName,
                'itemTitle': itemTitle,
                'itemPrice': itemPrice,
              },
            );
          },
        );
      },
    );
  }
}