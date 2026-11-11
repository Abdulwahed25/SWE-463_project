import 'package:souq/models/chat.dart';
import 'package:souq/models/message.dart';
import 'package:souq/services/chat_repository.dart';

/// In-memory chat repository used by tests (no device storage, no delay).
class FakeChatRepository implements ChatRepository {
  final Map<String, Chat> chats = {};
  final Map<String, List<Message>> messages = {};

  /// When true, every call throws (to test error states).
  bool shouldFail = false;

  void _check() {
    if (shouldFail) throw Exception('No connection');
  }

  @override
  Future<List<Chat>> fetchChats(String userId) async {
    _check();
    return chats.values.where((c) => c.participantIds.contains(userId)).toList();
  }

  @override
  Future<List<Message>> fetchMessages(String chatId) async {
    _check();
    return [...?messages[chatId]];
  }

  @override
  Future<Chat> openChat({
    required String listingId,
    required String buyerId,
    required String buyerName,
    required String sellerId,
    required String sellerName,
  }) async {
    _check();
    final id = Chat.idFor(listingId: listingId, buyerId: buyerId);
    return chats.putIfAbsent(
      id,
      () => Chat(
        id: id,
        listingId: listingId,
        participantIds: [buyerId, sellerId],
        participantNames: {buyerId: buyerName, sellerId: sellerName},
        lastMessage: '',
        lastMessageAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> sendMessage(String chatId, Message message) async {
    _check();
    messages.putIfAbsent(chatId, () => []).insert(0, message);
    final chat = chats[chatId]!;
    final unread = Map<String, int>.from(chat.unreadCount);
    for (final id in chat.participantIds) {
      if (id != message.senderId) unread[id] = (unread[id] ?? 0) + 1;
    }
    chats[chatId] = chat.copyWith(
      lastMessage: message.text,
      lastMessageAt: message.sentAt,
      unreadCount: unread,
    );
  }

  @override
  Future<void> markRead(String chatId, String userId) async {
    _check();
    final chat = chats[chatId];
    if (chat == null) return;
    chats[chatId] = chat.copyWith(
      unreadCount: Map<String, int>.from(chat.unreadCount)..[userId] = 0,
    );
  }
}
