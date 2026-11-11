import 'package:flutter/material.dart';
import '../models/chat.dart';

class ChatItemTile extends StatelessWidget {
  final Chat chat;
  final String peerName;
  final String currentUserId;
  final VoidCallback onTap;

  const ChatItemTile({
    super.key,
    required this.chat,
    required this.peerName,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unread = chat.unreadCount[currentUserId] ?? 0;
    final initials = peerName.trim().isNotEmpty
        ? peerName.trim().split(' ').take(2).map((e) => e[0].toUpperCase()).join()
        : '?';

    final timeString =
        '${chat.lastMessageAt.hour.toString().padLeft(2, '0')}:${chat.lastMessageAt.minute.toString().padLeft(2, '0')}';

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      title: Text(
        peerName,
        style: TextStyle(
          fontWeight: unread > 0 ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      subtitle: Text(
        chat.lastMessage.isEmpty ? 'No messages yet' : chat.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
          color: unread > 0
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            timeString,
            style: theme.textTheme.labelSmall?.copyWith(
              color: unread > 0
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
          ),
          if (unread > 0) ...[
            const SizedBox(height: 4),
            Badge(
              label: Text('$unread'),
              backgroundColor: theme.colorScheme.primary,
            ),
          ],
        ],
      ),
    );
  }
}
