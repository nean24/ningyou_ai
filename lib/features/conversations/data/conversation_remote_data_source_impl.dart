import '../../../core/network/convex_http_client.dart';
import 'conversation_remote_data_source.dart';

class ConversationRemoteDataSourceImpl implements ConversationRemoteDataSource {
  const ConversationRemoteDataSourceImpl({required ConvexHttpClient client})
      : _client = client;

  final ConvexHttpClient _client;

  @override
  Future<Map<String, dynamic>> create(String characterId) async {
    return _client.post(
      '/conversations',
      body: {'characterId': characterId},
    );
  }

  @override
  Future<List<Map<String, dynamic>>> listByUser() async {
    final res = await _client.post('/conversations/list');
    return (res['conversations'] as List<dynamic>).cast<Map<String, dynamic>>();
  }
}
