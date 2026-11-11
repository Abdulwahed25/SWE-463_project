import 'dart:async';
import '../models/chat.dart';
import '../models/message.dart';
import 'chat_repository.dart';

class LocalChatRepository implements ChatRepository {
  final _chatsController = StreamController<List<Chat>>.broadcast();
  final _messagesController = StreamController<List<Message>>.broadcast();

  final List<Chat> _mockChats = [
    Chat(
      id: 'chat_1',
      listingId: 'item_1',
      participantIds: ['my_user_id', 'ali_id'],
      lastMessage: 'Yes, it is still available!',
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 2)),
      unreadCount: {'my_user_id': 1},
    ),
  ];

  final Map<String, List<Message>> _messagesMap = {
    'chat_1': [
      Message(
        id: 'm2',
        senderId: 'my_user_id',
        text: 'Yes, it is still available!',
        sentAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      Message(
        id: 'm1',
        senderId: 'ali_id',
        text: 'Hi, is the item still available?',
        sentAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ],
  };

  @override
  Stream<List<Chat>> getChats(String userId) async* {
    yield List.unmodifiable(_mockChats);
    yield* _chatsController.stream;
  }

  @override
  Stream<List<Message>> getMessages(String chatId) async* {
    yield List.unmodifiable(_messagesMap[chatId] ?? []);
    yield* _messagesController.stream;
  }

  @override
  Future<void> sendMessage(String chatId, Message message) async {
    _messagesMap.putIfAbsent(chatId, () => []).insert(0, message);
    _messagesController.add(List.unmodifiable(_messagesMap[chatId]!));

    final index = _mockChats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      final old = _mockChats[index];
      _mockChats[index] = Chat(
        id: old.id,
        listingId: old.listingId,
        participantIds: old.participantIds,
        lastMessage: message.text,
        lastMessageAt: message.sentAt,
        unreadCount: const {},
      );
    } else {
      final listingId = chatId.startsWith('chat_')
          ? chatId.substring(5)
          : chatId;
      _mockChats.insert(
        0,
        Chat(
          id: chatId,
          listingId: listingId,
          participantIds: [message.senderId, 'seller_id'],
          lastMessage: message.text,
          lastMessageAt: message.sentAt,
          unreadCount: const {},
        ),
      );
    }
    _chatsController.add(List.unmodifiable(_mockChats));
  }
}