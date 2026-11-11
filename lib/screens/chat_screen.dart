import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../utils/format.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/empty_state.dart';

/// One conversation. Opened from "Message seller" or from the Messages tab.
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.chatId,
    required this.peerName,
    required this.itemTitle,
    required this.itemPrice,
  });

  final String chatId;
  final String peerName;
  final String itemTitle;
  final double itemPrice;

  /// Longest message we accept.
  static const int maxLength = 500;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  late final ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = context.read<ChatProvider>();
    // Load the messages after the first frame (providers can't notify during build).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatProvider.enterChat(widget.chatId);
    });
  }

  @override
  void dispose() {
    _chatProvider.leaveChat();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    final messenger = ScaffoldMessenger.of(context);

    // Validation: empty or whitespace-only messages are not sent.
    if (text.isEmpty) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Type a message first.')));
      return;
    }

    final ok = await _chatProvider.sendMessage(chatId: widget.chatId, text: text);
    if (!mounted) return;
    if (ok) {
      _textController.clear();
    } else {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Message not sent. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chat = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.peerName, style: const TextStyle(fontSize: 16)),
            Text(
              '${widget.itemTitle} - ${formatPrice(widget.itemPrice)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessages(chat)),
          const Divider(height: 1),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: theme.colorScheme.surface,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('chat_input'),
                      controller: _textController,
                      maxLength: ChatScreen.maxLength,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Write a message...',
                        border: InputBorder.none,
                        counterText: '', // hide the 0/500 counter
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  chat.isSending
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          key: const Key('chat_send'),
                          tooltip: 'Send',
                          icon: const Icon(Icons.send_rounded),
                          color: theme.colorScheme.primary,
                          onPressed: _send,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Loading, error, empty or the list of messages.
  Widget _buildMessages(ChatProvider chat) {
    if (chat.isLoadingMessages) {
      return const Center(child: CircularProgressIndicator());
    }
    if (chat.messagesError != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Could not load messages',
        message: chat.messagesError!,
        buttonText: 'Try again',
        onPressed: () => chat.enterChat(widget.chatId),
      );
    }
    final messages = chat.activeMessages;
    if (messages.isEmpty) {
      return EmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'No messages yet',
        message: 'Say hello and ask ${widget.peerName} about the item.',
      );
    }
    return ListView.builder(
      reverse: true, // newest message at the bottom
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return ChatBubble(
          message: message,
          isMe: message.senderId == chat.currentUserId,
        );
      },
    );
  }
}
