import '../models/chat.dart';
import '../models/message.dart';

abstract class ChatRepository {
  Stream<List<Chat>> getChats(String userId);
  Stream<List<Message>> getMessages(String chatId);
  Future<void> sendMessage(String chatId, Message message);
}