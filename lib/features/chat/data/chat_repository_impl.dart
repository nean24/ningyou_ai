import '../../conversations/domain/message.dart';
import 'chat_local_data_source.dart';
import 'chat_remote_data_source.dart';
import 'chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl({
    required ChatRemoteDataSource remote,
    required ChatLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final ChatRemoteDataSource _remote;
  final ChatLocalDataSource _local;

  @override
  Future<List<Message>> listMessages(
    String conversationId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await _local.getMessages(conversationId);
      if (cached.isNotEmpty) {
        return cached.map(Message.fromLocal).toList();
      }
    }
    final remote = await _remote.listMessages(conversationId);
    await _local.cacheMessages(remote);
    return remote.map(Message.fromRemote).toList();
  }

  @override
  Future<SendMessageResult> sendMessage(
    String conversationId,
    String content,
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final res = await _remote.sendMessage(conversationId, content);

    final userMessage = Message(
      id: res['userMessageId'] as String,
      conversationId: conversationId,
      role: MessageRole.user,
      content: content,
      status: MessageStatus.sent,
      createdAt: now,
    );

    final assistantMessage = Message(
      id: res['assistantMessageId'] as String,
      conversationId: conversationId,
      role: MessageRole.assistant,
      content: res['assistantText'] as String,
      status: MessageStatus.sent,
      createdAt: now + 1,
      model: res['assistantModel'] as String?,
    );

    // Persist both messages to local cache
    await _local.cacheMessages([
      _toRemoteMap(userMessage),
      _toRemoteMap(assistantMessage),
    ]);

    return SendMessageResult(
      userMessage: userMessage,
      assistantMessage: assistantMessage,
    );
  }

  Map<String, dynamic> _toRemoteMap(Message m) => {
        '_id': m.id,
        'conversationId': m.conversationId,
        'role': m.role.name,
        'content': m.content,
        'status': m.status.name,
        'model': m.model,
        'createdAt': m.createdAt,
      };
}
