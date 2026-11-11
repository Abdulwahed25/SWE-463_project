import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat.dart';
import '../models/message.dart';
import 'chat_repository.dart';

/// TEMPORARY data source for Phase 3.
/// Saves chats and messages on the device with shared_preferences.
/// Two accounts on the same device can chat with each other.
/// It will be replaced by Firestore in Phase 4.
class LocalChatRepository implements ChatRepository {
  static const String _chatsKey = 'souq_chats_v1';
  static const String _messagesKey = 'souq_messages_v1';

  // Small delay so the loading state can be seen, like a real network call.
  static const Duration _delay = Duration(milliseconds: 400);

  @override
  Future<List<Chat>> fetchChats(String userId) async {
    await Future.delayed(_delay);
    final prefs = await SharedPreferences.getInstance();
    final chats = _readChats(prefs)
        .where((c) => c.participantIds.contains(userId))
        // A chat with no messages yet is only shown to the person who opened it.
        .where((c) => c.lastMessage.isNotEmpty || c.participantIds.first == userId)
        .toList();
    chats.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    return chats;
  }

  @override
  Future<List<Message>> fetchMessages(String chatId) async {
    await Future.delayed(_delay);
    final prefs = await SharedPreferences.getInstance();
    return _readMessages(prefs)[chatId] ?? [];
  }

  @override
  Future<Chat> openChat({
    required String listingId,
    required String buyerId,
    required String buyerName,
    required String sellerId,
    required String sellerName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final chats = _readChats(prefs);
    final id = Chat.idFor(listingId: listingId, buyerId: buyerId);

    for (final chat in chats) {
      if (chat.id == id) return chat;
    }

    final chat = Chat(
      id: id,
      listingId: listingId,
      participantIds: [buyerId, sellerId],
      participantNames: {buyerId: buyerName, sellerId: sellerName},
      lastMessage: '',
      lastMessageAt: DateTime.now(),
    );
    chats.add(chat);
    await _saveChats(prefs, chats);
    return chat;
  }

  @override
  Future<void> sendMessage(String chatId, Message message) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Save the message (newest first).
    final messages = _readMessages(prefs);
    messages.putIfAbsent(chatId, () => []).insert(0, message);
    await _saveMessages(prefs, messages);

    // 2. Update the chat: last message, time and the other person's unread count.
    final chats = _readChats(prefs);
    final index = chats.indexWhere((c) => c.id == chatId);
    if (index == -1) throw Exception('Chat not found');
    final chat = chats[index];
    final unread = Map<String, int>.from(chat.unreadCount);
    for (final id in chat.participantIds) {
      if (id != message.senderId) unread[id] = (unread[id] ?? 0) + 1;
    }
    chats[index] = chat.copyWith(
      lastMessage: message.text,
      lastMessageAt: message.sentAt,
      unreadCount: unread,
    );
    await _saveChats(prefs, chats);
  }

  @override
  Future<void> markRead(String chatId, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final chats = _readChats(prefs);
    final index = chats.indexWhere((c) => c.id == chatId);
    if (index == -1) return;
    final unread = Map<String, int>.from(chats[index].unreadCount)..[userId] = 0;
    chats[index] = chats[index].copyWith(unreadCount: unread);
    await _saveChats(prefs, chats);
  }

  // ---------- reading and writing JSON ----------

  List<Chat> _readChats(SharedPreferences prefs) {
    final saved = prefs.getString(_chatsKey);
    if (saved == null) return [];
    final list = jsonDecode(saved) as List<dynamic>;
    return list.map((e) {
      final map = e as Map<String, dynamic>;
      return Chat.fromMap(map['id'] as String, map);
    }).toList();
  }

  Future<void> _saveChats(SharedPreferences prefs, List<Chat> chats) {
    return prefs.setString(_chatsKey, jsonEncode(chats.map((c) => c.toMap()).toList()));
  }

  Map<String, List<Message>> _readMessages(SharedPreferences prefs) {
    final saved = prefs.getString(_messagesKey);
    if (saved == null) return {};
    final map = jsonDecode(saved) as Map<String, dynamic>;
    return map.map((chatId, list) {
      final messages = (list as List<dynamic>).map((e) {
        final m = e as Map<String, dynamic>;
        return Message.fromMap(m['id'] as String, m);
      }).toList();
      return MapEntry(chatId, messages);
    });
  }

  Future<void> _saveMessages(SharedPreferences prefs, Map<String, List<Message>> messages) {
    final map = messages.map((chatId, list) => MapEntry(
          chatId,
          list.map((m) => {'id': m.id, ...m.toMap()}).toList(),
        ));
    return prefs.setString(_messagesKey, jsonEncode(map));
  }
}
