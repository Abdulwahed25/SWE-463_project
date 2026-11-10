class Chat {
  final String id;
  final String listingId;
  final List<String> participantIds; // [buyerId, sellerId]
  final String lastMessage;
  final DateTime lastMessageAt;
  final Map<String, int> unreadCount;

  const Chat({
    required this.id,
    required this.listingId,
    required this.participantIds,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'listingId': listingId,
      'participantIds': participantIds,
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
      lastMessage: map['lastMessage'] ?? '',
      lastMessageAt: map['lastMessageAt'] != null
          ? DateTime.tryParse(map['lastMessageAt']) ?? DateTime.now()
          : DateTime.now(),
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
    );
  }
}