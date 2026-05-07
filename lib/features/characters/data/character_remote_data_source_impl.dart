import '../../../core/network/convex_http_client.dart';
import 'character_remote_data_source.dart';

class CharacterRemoteDataSourceImpl implements CharacterRemoteDataSource {
  const CharacterRemoteDataSourceImpl({required ConvexHttpClient client})
      : _client = client;

  final ConvexHttpClient _client;

  @override
  Future<List<Map<String, dynamic>>> listPublic() async {
    final res = await _client.get('/characters');
    return (res['characters'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>?> getById(String id) async {
    final res = await _client.post('/characters/get', body: {'id': id});
    return res['character'] as Map<String, dynamic>?;
  }
}
