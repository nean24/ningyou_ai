import '../../conversations/domain/message.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final MessageRole role;
  final String text;
  final DateTime createdAt;
}
