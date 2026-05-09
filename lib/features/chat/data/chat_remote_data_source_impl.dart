import '../../../core/network/convex_http_client.dart';
import 'chat_remote_data_source.dart';

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  const ChatRemoteDataSourceImpl({required ConvexHttpClient client})
      : _client = client;

  final ConvexHttpClient _client;

  @override
  Future<List<Map<String, dynamic>>> listMessages(String conversationId) async {
    final res = await _client.post(
      '/messages/list',
      body: {'conversationId': conversationId},
    );
    return (res['messages'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> sendMessage(
    String conversationId,
    String content,
  ) async {
    return _client.post(
      '/messages/send',
      body: {'conversationId': conversationId, 'content': content},
    );
  }
}
