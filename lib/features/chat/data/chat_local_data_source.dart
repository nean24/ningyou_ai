import '../../../core/database/daos/messages_dao.dart';

class ChatLocalDataSource {
  const ChatLocalDataSource(this._dao);

  final MessagesDao _dao;

  Future<List<Map<String, dynamic>>> getMessages(String conversationId) =>
      _dao.getByConversation(conversationId);

  Future<void> cacheMessages(List<Map<String, dynamic>> messages) =>
      _dao.upsertAll(messages);

  Future<void> cacheMessage(Map<String, dynamic> message) =>
      _dao.upsert(message);

  Future<void> insertPending({
    required String id,
    required String conversationId,
    required String content,
  }) =>
      _dao.insertPending(id: id, conversationId: conversationId, content: content);

  Future<void> updateStatus(String id, String status) =>
      _dao.updateStatus(id, status);
}
