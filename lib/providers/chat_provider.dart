import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../services/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _repository;

  ChatProvider(this._repository);

  List<Chat> _chats = [];
  List<Chat> get chats => _chats;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription<List<Chat>>? _chatsSubscription;
  StreamSubscription<List<Message>>? _messagesSubscription;

  List<Message> _activeMessages = [];
  List<Message> get activeMessages => _activeMessages;

  void loadChats({String userId = 'my_user_id'}) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _chatsSubscription?.cancel();
    _chatsSubscription = _repository.getChats(userId).listen(
      (data) {
        _chats = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void enterChat(String chatId) {
    _activeMessages = [];
    _messagesSubscription?.cancel();
    _messagesSubscription = _repository.getMessages(chatId).listen((messages) {
      _activeMessages = messages;
      notifyListeners();
    });
  }

  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String senderId,
  }) async {
    if (text.trim().isEmpty) return;

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: senderId,
      text: text.trim(),
      sentAt: DateTime.now(),
    );

    try {
      await _repository.sendMessage(chatId, newMessage);
    } catch (e) {
      _errorMessage = 'Failed to send message: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _chatsSubscription?.cancel();
    _messagesSubscription?.cancel();
    super.dispose();
  }
}