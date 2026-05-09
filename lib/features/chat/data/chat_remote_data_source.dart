abstract interface class ChatRemoteDataSource {
  Future<List<Map<String, dynamic>>> listMessages(String conversationId);
  Future<Map<String, dynamic>> sendMessage(String conversationId, String content);
}
