import '../../conversations/domain/message.dart';

class SendMessageResult {
  const SendMessageResult({
    required this.userMessage,
    required this.assistantMessage,
  });

  final Message userMessage;
  final Message assistantMessage;
}

abstract interface class ChatRepository {
  Future<List<Message>> listMessages(
    String conversationId, {
    bool forceRefresh = false,
  });
  Future<SendMessageResult> sendMessage(String conversationId, String content);
}
