/// One conversation between a buyer and a seller about one listing.
class Chat {
  final String id;
  final String listingId;
  final List<String> participantIds; // [buyerId, sellerId]
  final Map<String, String> participantNames; // userId -> display name
  final String lastMessage;
  final DateTime lastMessageAt;
  final Map<String, int> unreadCount; // userId -> unread messages

  const Chat({
    required this.id,
    required this.listingId,
    required this.participantIds,
    this.participantNames = const {},
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = const {},
  });

  /// The same chat id is always built for the same listing and buyer,
  /// so pressing "Message seller" twice opens the same conversation.
  static String idFor({required String listingId, required String buyerId}) {
    return 'chat_${listingId}_$buyerId';
  }

  /// The other person in the chat (seen from [myId]).
  String peerId(String myId) {
    return participantIds.firstWhere((id) => id != myId, orElse: () => '');
  }

  /// Name of the other person, or "KFUPM student" if it is unknown.
  String peerName(String myId) {
    final name = participantNames[peerId(myId)] ?? '';
    return name.isEmpty ? 'KFUPM student' : name;
  }

  Chat copyWith({
    String? lastMessage,
    DateTime? lastMessageAt,
    Map<String, int>? unreadCount,
  }) {
    return Chat(
      id: id,
      listingId: listingId,
      participantIds: participantIds,
      participantNames: participantNames,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'listingId': listingId,
      'participantIds': participantIds,
      'participantNames': participantNames,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }

  factory Chat.fromMap(String id, Map<String, dynamic> map) {
    return Chat(
      id: id,
      listingId: map['listingId'] ?? '',
      participantIds: List<String>.from(map['participantIds'] ?? []),
      participantNames: Map<String, String>.from(map['participantNames'] ?? {}),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageAt: map['lastMessageAt'] != null
          ? DateTime.tryParse(map['lastMessageAt']) ?? DateTime.now()
          : DateTime.now(),
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
    );
  }
}
