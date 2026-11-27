import 'package:flutter/material.dart';

import '../models/message.dart';
import 'photo_view.dart';

/// One message in the chat: my messages on the right in teal,
/// the other person's on the left in grey. A message can have a photo.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  final Message message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = message.text.isNotEmpty;
    final photoOnly = message.hasPhoto && !hasText;
    final time =
        '${message.sentAt.hour.toString().padLeft(2, '0')}:${message.sentAt.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: photoOnly
            ? const EdgeInsets.all(6)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.hasPhoto) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PhotoView(photo: message.photo, width: 220, height: 220),
              ),
              if (hasText) const SizedBox(height: 8),
            ],
            if (hasText)
              Text(
                message.text,
                style: TextStyle(
                  color: isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                  fontSize: 15,
                ),
              ),
            const SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: photoOnly ? 6 : 0),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: isMe
                      ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                      : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
