class Message {
  final String id;
  final String senderId;
  final String text;
  final String? imageUrl;
  final DateTime sentAt;

  const Message({
    required this.id,
    required this.senderId,
    required this.text,
    this.imageUrl,
    required this.sentAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'imageUrl': imageUrl,
      'sentAt': sentAt.toIso8601String(),
    };
  }

  factory Message.fromMap(String id, Map<String, dynamic> map) {
    return Message(
      id: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'],
      sentAt: map['sentAt'] != null
          ? DateTime.tryParse(map['sentAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}