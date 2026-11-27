import 'dart:async';

import 'package:souq/models/chat.dart';
import 'package:souq/models/message.dart';
import 'package:souq/services/chat_repository.dart';

/// In-memory chat repository used by tests (no Firebase, no delay).
/// Its streams send a new value after every change, like Firestore does.
class FakeChatRepository implements ChatRepository {
  final Map<String, Chat> chats = {};
  final Map<String, List<Message>> messages = {};
  final _changes = StreamController<void>.broadcast();

  /// When true, every call throws (to test error states).
  bool shouldFail = false;

  void _check() {
    if (shouldFail) throw Exception('No connection');
  }

  List<Chat> _chatsFor(String userId) =>
      chats.values.where((c) => c.participantIds.contains(userId)).toList();

  @override
  Stream<List<Chat>> watchChats(String userId) async* {
    _check();
    yield _chatsFor(userId);
    await for (final _ in _changes.stream) {
      yield _chatsFor(userId);
    }
  }

  @override
  Stream<List<Message>> watchMessages(String chatId) async* {
    _check();
    yield [...?messages[chatId]];
    await for (final _ in _changes.stream) {
      yield [...?messages[chatId]];
    }
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
    final chat = chats.putIfAbsent(
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
    _changes.add(null);
    return chat;
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
      lastMessage: message.preview,
      lastMessageAt: message.sentAt,
      unreadCount: unread,
    );
    _changes.add(null);
  }

  @override
  Future<void> markRead(String chatId, String userId) async {
    _check();
    final chat = chats[chatId];
    if (chat == null) return;
    chats[chatId] = chat.copyWith(
      unreadCount: Map<String, int>.from(chat.unreadCount)..[userId] = 0,
    );
    _changes.add(null);
  }
}
