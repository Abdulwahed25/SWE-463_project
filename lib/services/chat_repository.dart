import '../models/chat.dart';
import '../models/message.dart';

/// Where chats and messages are stored.
/// Screens and providers only use this interface, so the local version
/// can be replaced by Firestore in Phase 4 without changing the screens.
abstract class ChatRepository {
  /// All chats the user is part of, newest first.
  Future<List<Chat>> fetchChats(String userId);

  /// Messages of one chat, newest first.
  Future<List<Message>> fetchMessages(String chatId);

  /// Returns the chat between [buyerId] and [sellerId] about [listingId].
  /// Creates it (with no messages) if it does not exist yet.
  Future<Chat> openChat({
    required String listingId,
    required String buyerId,
    required String buyerName,
    required String sellerId,
    required String sellerName,
  });

  /// Saves a message, updates the chat's last message and adds one
  /// unread message for the other person.
  Future<void> sendMessage(String chatId, Message message);

  /// Sets the unread count of [userId] in this chat to zero.
  Future<void> markRead(String chatId, String userId);
}
