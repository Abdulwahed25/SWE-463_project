import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../utils/format.dart';
import '../utils/photo_picker.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/empty_state.dart';
import 'seller_profile_screen.dart';

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
  final _photoPicker = PhotoPicker();
  late final ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = context.read<ChatProvider>();
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

  /// Lets the student choose a photo and sends it (with any typed text).
  Future<void> _pickAndSendPhoto() async {
    final messenger = ScaffoldMessenger.of(context);
    String? photo;
    try {
      photo = await _photoPicker.pickFromGallery();
    } on PhotoTooLargeException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
      return;
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't open your photos. Check the app's photo permission.")),
      );
      return;
    }
    if (photo == null || !mounted) return; // cancelled

    final ok = await _chatProvider.sendMessage(
      chatId: widget.chatId,
      text: _textController.text,
      photo: photo,
    );
    if (!mounted) return;
    if (ok) {
      _textController.clear();
    } else {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Photo not sent. Please try again.')));
    }
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    final messenger = ScaffoldMessenger.of(context);

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

    final initials = widget.peerName.trim().isNotEmpty
        ? widget.peerName.trim().split(' ').take(2).map((e) => e[0].toUpperCase()).join()
        : '?';

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SellerProfileScreen(
                  sellerName: widget.peerName,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  child: Text(
                    initials,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.peerName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${widget.itemTitle} - ${formatPrice(widget.itemPrice)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                  IconButton(
                    key: const Key('chat_send_photo'),
                    tooltip: 'Send a photo',
                    icon: const Icon(Icons.photo_outlined),
                    color: theme.colorScheme.primary,
                    onPressed: chat.isSending ? null : _pickAndSendPhoto,
                  ),
                  Expanded(
                    child: TextField(
                      key: const Key('chat_input'),
                      controller: _textController,
                      maxLength: ChatScreen.maxLength,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Write a message...',
                        border: InputBorder.none,
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
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
      reverse: true,
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