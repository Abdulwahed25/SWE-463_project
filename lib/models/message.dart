/// One chat message. It has text, a photo, or both.
class Message {
  const Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.photo = '',
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;

  /// A photo as a base64-encoded JPEG, or '' for a text-only message.
  final String photo;

  bool get hasPhoto => photo.isNotEmpty;

  /// Short text shown in the chat list for this message.
  String get preview => text.isNotEmpty ? text : 'Photo';

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'photo': photo,
      'sentAt': sentAt.toIso8601String(),
    };
  }

  factory Message.fromMap(String id, Map<String, dynamic> map) {
    return Message(
      id: id,
      senderId: map['senderId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      photo: map['photo'] as String? ?? '',
      sentAt: DateTime.tryParse(map['sentAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
