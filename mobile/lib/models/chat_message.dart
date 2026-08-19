enum ChatRole { user, ai }

class ChatMessage {
  final String id;
  final String text;
  final ChatRole role;
  final DateTime timestamp;
  final bool isThinking;

  ChatMessage({
    required this.id,
    required this.text,
    required this.role,
    required this.timestamp,
    this.isThinking = false,
  });

  ChatMessage copyWith({String? text, bool? isThinking}) {
    return ChatMessage(
      id: id,
      text: text ?? this.text,
      role: role,
      timestamp: timestamp,
      isThinking: isThinking ?? this.isThinking,
    );
  }
}
