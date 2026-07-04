class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'content': content,
        'isUser': isUser,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        content: map['content'] as String? ?? '',
        isUser: map['isUser'] as bool? ?? false,
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int? ?? 0),
      );
}
