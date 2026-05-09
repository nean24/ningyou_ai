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
    this.model,
  });

  final String id;
  final String conversationId;
  final MessageRole role;
  final String content;
  final MessageStatus status;
  final int createdAt;
  final String? model;

  factory Message.fromRemote(Map<String, dynamic> m) => Message(
        id: m['_id'] as String,
        conversationId: m['conversationId'] as String,
        role: _parseRole(m['role'] as String),
        content: m['content'] as String,
        status: _parseStatus(m['status'] as String? ?? 'sent'),
        createdAt: (m['createdAt'] as num).toInt(),
        model: m['model'] as String?,
      );

  factory Message.fromLocal(Map<String, dynamic> row) => Message(
        id: row['id'] as String,
        conversationId: row['conversation_id'] as String,
        role: _parseRole(row['role'] as String),
        content: row['content'] as String,
        status: _parseStatus(row['status'] as String),
        createdAt: row['created_at'] as int,
        model: row['model'] as String?,
      );

  static MessageRole _parseRole(String s) => switch (s) {
        'assistant' => MessageRole.assistant,
        'system' => MessageRole.system,
        _ => MessageRole.user,
      };

  static MessageStatus _parseStatus(String s) => switch (s) {
        'failed' => MessageStatus.failed,
        'pending' => MessageStatus.pending,
        _ => MessageStatus.sent,
      };
}
