class SendMessageRequest {
  const SendMessageRequest({
    required this.conversationId,
    required this.content,
  });

  final String conversationId;
  final String content;
}
