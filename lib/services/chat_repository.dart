import '../models/chat.dart';
import '../models/message.dart';

/// Where chats and messages are stored.
/// The app uses FirestoreChatRepository; tests use a fake with the same
/// methods, so screens and providers never talk to Firestore directly.
abstract class ChatRepository {
  /// Live list of the chats [userId] is part of. A new value arrives every
  /// time a chat changes (new message, unread count, new chat).
  Stream<List<Chat>> watchChats(String userId);

  /// Live list of the messages in one chat, newest first.
  Stream<List<Message>> watchMessages(String chatId);

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
