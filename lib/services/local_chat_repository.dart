import 'dart:async';
import '../models/chat.dart';
import '../models/message.dart';
import 'chat_repository.dart';

class LocalChatRepository implements ChatRepository {
  final List<Chat> _mockChats = [
    Chat(
      id: 'chat_1',
      listingId: 'item_1',
      participantIds: ['current_user', 'ali_id'],
      lastMessage: 'Is the book still available?',
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: {'current_user': 1},
    ),
  ];

  final Map<String, List<Message>> _messagesMap = {
    'chat_1': [
      Message(
        id: 'm1',
        senderId: 'ali_id',
        text: 'Hi, is the item still available?',
        sentAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Message(
        id: 'm2',
        senderId: 'current_user',
        text: 'Yes, still available!',
        sentAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ],
  };

  @override
  Stream<List<Chat>> getChats(String userId) {
    return Stream.value(_mockChats);
  }

  @override
  Stream<List<Message>> getMessages(String chatId) {
    return Stream.value(_messagesMap[chatId] ?? []);
  }

  @override
  Future<void> sendMessage(String chatId, Message message) async {
    _messagesMap.putIfAbsent(chatId, () => []).insert(0, message);
  }
}