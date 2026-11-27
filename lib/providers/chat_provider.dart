import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/chat.dart';
import '../models/listing.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../services/chat_repository.dart';

/// Shared chat state: the signed-in user's chats and the open chat's messages.
/// main.dart gives it the current user from AuthProvider (see setUser), so the
/// chat list changes when someone logs in or out. Both lists are live streams
/// from the repository, so new messages appear without refreshing.
class ChatProvider extends ChangeNotifier {
  ChatProvider(this._repository);

  final ChatRepository _repository;

  User? _user;
  String? get currentUserId => _user?.id;

  // ---------- chat list (Messages tab) ----------
  StreamSubscription<List<Chat>>? _chatsSub;
  List<Chat> _chats = [];
  List<Chat> get chats => _chats;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Total unread messages, shown as a badge on the Messages tab.
  int get unreadTotal {
    final id = currentUserId;
    if (id == null) return 0;
    return _chats.fold(0, (sum, chat) => sum + (chat.unreadCount[id] ?? 0));
  }

  // ---------- open chat (Chat screen) ----------
  StreamSubscription<List<Message>>? _messagesSub;
  String? _activeChatId;
  List<Message> _activeMessages = [];
  List<Message> get activeMessages => _activeMessages;

  bool _isLoadingMessages = false;
  bool get isLoadingMessages => _isLoadingMessages;

  String? _messagesError;
  String? get messagesError => _messagesError;

  bool _isSending = false;
  bool get isSending => _isSending;

  /// Called by main.dart every time AuthProvider changes.
  /// Starts listening to the new user's chats, or clears everything after logout.
  void setUser(User? user) {
    if (user?.id == _user?.id) {
      _user = user; // same person, maybe a new name
      return;
    }
    _user = user;
    _chatsSub?.cancel();
    _chatsSub = null;
    leaveChat();
    _chats = [];
    _errorMessage = null;
    // setUser runs while widgets are being built, and a provider must not
    // notify during a build. So we start listening right after the build.
    Future.microtask(() {
      if (_disposed) return;
      if (_user == null) {
        notifyListeners();
      } else {
        loadChats();
      }
    });
  }

  /// Starts (or restarts, after an error) listening to the user's chats.
  void loadChats() {
    final id = currentUserId;
    if (id == null) return;

    _chatsSub?.cancel();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _chatsSub = _repository.watchChats(id).listen(
      (chats) {
        _chats = chats;
        _isLoading = false;
        notifyListeners();
      },
      onError: (Object e) {
        _errorMessage = 'Could not load your chats. Check your connection and try again.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// "Message seller" on a listing: finds or creates the chat and returns it.
  /// Returns null if nobody is signed in or the user is the seller.
  Future<Chat?> openChatForListing(Listing listing) async {
    final me = _user;
    if (me == null || me.id == listing.sellerId) return null;

    final chat = await _repository.openChat(
      listingId: listing.id,
      buyerId: me.id,
      buyerName: me.name,
      sellerId: listing.sellerId,
      sellerName: listing.sellerName,
    );
    if (!_chats.any((c) => c.id == chat.id)) {
      _chats = [chat, ..._chats];
      notifyListeners();
    }
    return chat;
  }

  /// Opens a chat: listens to its messages and marks them as read.
  void enterChat(String chatId) {
    _messagesSub?.cancel();
    _activeChatId = chatId;
    _activeMessages = [];
    _isLoadingMessages = true;
    _messagesError = null;
    notifyListeners();

    _messagesSub = _repository.watchMessages(chatId).listen(
      (messages) {
        _activeMessages = messages;
        _isLoadingMessages = false;
        notifyListeners();
        _markRead(chatId);
      },
      onError: (Object e) {
        _messagesError = 'Could not load messages. Check your connection and try again.';
        _isLoadingMessages = false;
        notifyListeners();
      },
    );
  }

  /// Sends a message (text, photo or both) from the signed-in user.
  /// Returns false, and sends nothing, if it is empty or saving fails.
  Future<bool> sendMessage({
    required String chatId,
    required String text,
    String photo = '',
  }) async {
    final me = currentUserId;
    final clean = text.trim();
    if (me == null || (clean.isEmpty && photo.isEmpty) || _isSending) return false;

    final message = Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      senderId: me,
      text: clean,
      photo: photo,
      sentAt: DateTime.now(),
    );

    _isSending = true;
    notifyListeners();
    try {
      await _repository.sendMessage(chatId, message);
      return true;
    } catch (e) {
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  /// Called when the Chat screen closes.
  void leaveChat() {
    _messagesSub?.cancel();
    _messagesSub = null;
    _activeChatId = null;
    _activeMessages = [];
  }

  /// Sets my unread count in this chat to zero (only when it is not zero already).
  Future<void> _markRead(String chatId) async {
    final me = currentUserId;
    if (me == null || _activeChatId != chatId) return;
    final chat = _chats.where((c) => c.id == chatId).firstOrNull;
    if (chat != null && (chat.unreadCount[me] ?? 0) == 0) return;
    try {
      await _repository.markRead(chatId, me);
    } catch (_) {
      // Not important enough to show an error; it is retried on the next message.
    }
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _chatsSub?.cancel();
    _messagesSub?.cancel();
    super.dispose();
  }

  /// Async work can finish after the provider is gone; then we stay quiet.
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }
}
