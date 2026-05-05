enum MessageRole { user, assistant, system }

enum MessageStatus { pending, sent, failed }

class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String conversationId;
  final MessageRole role;
  final String content;
  final MessageStatus status;
  final DateTime createdAt;
}
