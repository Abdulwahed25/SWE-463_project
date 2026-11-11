import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_routes.dart';
import '../models/chat.dart';
import '../providers/chat_provider.dart';
import '../providers/listings_provider.dart';
import '../widgets/chat_item_tile.dart';
import '../widgets/empty_state.dart';

/// Messages tab: the signed-in user's chats, with search.
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    final myId = chatProvider.currentUserId;

    // Guest: no chats to show.
    if (myId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Messages')),
        body: EmptyState(
          icon: Icons.lock_outline,
          title: 'Log in to see your messages',
          message: 'You need an account to chat with sellers and buyers.',
          buttonText: 'Log in',
          onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
        ),
      );
    }

    final query = _searchQuery.trim().toLowerCase();
    final filteredChats = chatProvider.chats.where((chat) {
      if (query.isEmpty) return true;
      final itemTitle = listingsProvider.byId(chat.listingId)?.title ?? '';
      return chat.lastMessage.toLowerCase().contains(query) ||
          chat.peerName(myId).toLowerCase().contains(query) ||
          itemTitle.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
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
            child: RefreshIndicator(
              onRefresh: chatProvider.loadChats,
              child: _buildBody(context, chatProvider, listingsProvider, filteredChats, myId),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ChatProvider chatProvider,
    ListingsProvider listingsProvider,
    List<Chat> filteredChats,
    String myId,
  ) {
    if (chatProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chatProvider.errorMessage != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Could not load messages',
        message: chatProvider.errorMessage!,
        buttonText: 'Try again',
        onPressed: chatProvider.loadChats,
      );
    }

    if (filteredChats.isEmpty) {
      return _searchQuery.isEmpty
          ? const EmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No chats yet',
              message: 'Open a listing and press "Message seller". Your chats will show up here.',
            )
          : const EmptyState(
              icon: Icons.search_off,
              title: 'No matching chats',
              message: 'Try searching with a different keyword.',
            );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(), // so pull-to-refresh works
      itemCount: filteredChats.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final chat = filteredChats[index];
        final listing = listingsProvider.byId(chat.listingId);
        final peerName = chat.peerName(myId);
        final itemTitle = listing?.title ?? 'Deleted listing';
        final itemPrice = listing?.price ?? 0;

        return ChatItemTile(
          chat: chat,
          peerName: '$peerName • $itemTitle',
          currentUserId: myId,
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
