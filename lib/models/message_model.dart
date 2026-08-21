enum MessageSender { user, ai, system }

class MessageModel {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final List<String>? options;

  const MessageModel({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.options,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'sender': sender.name,
        'timestamp': timestamp.toIso8601String(),
        'options': options,
      };

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] as String,
        text: json['text'] as String,
        sender: MessageSender.values.byName(json['sender'] as String),
        timestamp: DateTime.parse(json['timestamp'] as String),
        options: (json['options'] as List<dynamic>?)?.cast<String>(),
      );
}
