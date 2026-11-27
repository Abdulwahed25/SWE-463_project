import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat.dart';
import '../models/message.dart';
import 'chat_repository.dart';

/// Chats saved in Cloud Firestore.
///   chats/{chatId}                     participants, last message, unread counts
///   chats/{chatId}/messages/{messageId} the messages of that chat
/// Firestore streams (snapshots) make new messages appear live on both phones.
class FirestoreChatRepository implements ChatRepository {
  FirestoreChatRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _chats =>
      _db.collection('chats');

  @override
  Stream<List<Chat>> watchChats(String userId) {
    return _chats
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final chats = snapshot.docs
              .map((doc) => Chat.fromMap(doc.id, doc.data()))
              // A chat with no messages yet is only shown to the buyer who opened it.
              .where(
                (c) =>
                    c.lastMessage.isNotEmpty ||
                    c.participantIds.first == userId,
              )
              .toList();
          chats.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
          return chats;
        });
  }

  @override
  Stream<List<Message>> watchMessages(String chatId) {
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(200)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Message.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<Chat> openChat({
    required String listingId,
    required String buyerId,
    required String buyerName,
    required String sellerId,
    required String sellerName,
  }) async {
    final id = Chat.idFor(listingId: listingId, buyerId: buyerId);
    final ref = _chats.doc(id);
    final existing = await ref.get();
    if (existing.exists) return Chat.fromMap(id, existing.data()!);

    final chat = Chat(
      id: id,
      listingId: listingId,
      participantIds: [buyerId, sellerId],
      participantNames: {buyerId: buyerName, sellerId: sellerName},
      lastMessage: '',
      lastMessageAt: DateTime.now(),
    );
    await ref.set(chat.toMap());
    return chat;
  }

  @override
  Future<void> sendMessage(String chatId, Message message) async {
    final chatRef = _chats.doc(chatId);
    final chatDoc = await chatRef.get();
    if (!chatDoc.exists) throw Exception('Chat not found');
    final chat = Chat.fromMap(chatId, chatDoc.data()!);

    // Save the message and update the chat in one batch, so both happen or neither.
    final batch = _db.batch();
    batch.set(chatRef.collection('messages').doc(message.id), message.toMap());
    batch.update(chatRef, {
      'lastMessage': message.preview,
      'lastMessageAt': message.sentAt.toIso8601String(),
      for (final id in chat.participantIds)
        if (id != message.senderId) 'unreadCount.$id': FieldValue.increment(1),
    });
    await batch.commit();
  }

  @override
  Future<void> markRead(String chatId, String userId) {
    return _chats.doc(chatId).update({'unreadCount.$userId': 0});
  }
}
