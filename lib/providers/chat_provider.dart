import 'package:flutter/foundation.dart';

import '../models/chat.dart';
import '../models/listing.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../services/chat_repository.dart';

/// Shared chat state: the signed-in user's chats and the open chat's messages.
/// main.dart gives it the current user from AuthProvider (see setUser),
/// so the chat list changes when someone logs in or out.
class ChatProvider extends ChangeNotifier {
  ChatProvider(this._repository);

  final ChatRepository _repository;

  User? _user;
  String? get currentUserId => _user?.id;

  // ---------- chat list (Messages tab) ----------
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
  /// Loads the new user's chats, or clears everything after logout.
  void setUser(User? user) {
    if (user?.id == _user?.id) {
      _user = user; // same person, maybe a new name
      return;
    }
    _user = user;
    _chats = [];
    _activeChatId = null;
    _activeMessages = [];
    _errorMessage = null;
    // setUser runs while widgets are being built, and a provider must not
    // notify during a build. So we load (or refresh) right after the build.
    Future.microtask(() {
      if (_disposed) return;
      if (_user == null) {
        notifyListeners();
      } else {
        loadChats();
      }
    });
  }

  /// Loads the signed-in user's chats from the repository.
  Future<void> loadChats() async {
    final id = currentUserId;
    if (id == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final chats = await _repository.fetchChats(id);
      if (currentUserId != id) return; // user changed while loading
      _chats = chats;
    } catch (e) {
      _errorMessage = 'Could not load your chats. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  /// Opens a chat: loads its messages and marks them as read.
  Future<void> enterChat(String chatId) async {
    _activeChatId = chatId;
    _activeMessages = [];
    _isLoadingMessages = true;
    _messagesError = null;
    notifyListeners();

    try {
      final messages = await _repository.fetchMessages(chatId);
      if (_activeChatId != chatId) return; // user already left this chat
      _activeMessages = messages;
      await _markRead(chatId);
    } catch (e) {
      _messagesError = 'Could not load messages.';
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  /// Sends a text or image message from the signed-in user.
  Future<bool> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
  }) async {
    final me = currentUserId;
    final clean = text.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    if (me == null || (clean.isEmpty && !hasImage) || _isSending) return false;

    final message = Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      senderId: me,
      text: clean,
      imageUrl: imageUrl,
      sentAt: DateTime.now(),
    );

    _isSending = true;
    notifyListeners();
    try {
      await _repository.sendMessage(chatId, message);
      if (_activeChatId == chatId) {
        _activeMessages = [message, ..._activeMessages];
      }
      final preview = clean.isNotEmpty ? clean : '📷 Photo';
      _updateChat(chatId, (c) => c.copyWith(lastMessage: preview, lastMessageAt: message.sentAt));
      _chats.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
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
    _activeChatId = null;
    _activeMessages = [];
  }

  Future<void> _markRead(String chatId) async {
    final me = currentUserId;
    if (me == null) return;
    await _repository.markRead(chatId, me);
    _updateChat(chatId, (c) {
      final unread = Map<String, int>.from(c.unreadCount)..[me] = 0;
      return c.copyWith(unreadCount: unread);
    });
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Async work can finish after the provider is gone; then we stay quiet.
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  void _updateChat(String chatId, Chat Function(Chat) change) {
    _chats = [
      for (final c in _chats) c.id == chatId ? change(c) : c,
    ];
  }
}