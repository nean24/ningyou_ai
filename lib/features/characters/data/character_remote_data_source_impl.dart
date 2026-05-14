import '../../../core/network/convex_http_client.dart';
import 'character_remote_data_source.dart';

class CharacterRemoteDataSourceImpl implements CharacterRemoteDataSource {
  const CharacterRemoteDataSourceImpl({required ConvexHttpClient client})
    : _client = client;

  final ConvexHttpClient _client;

  @override
  Future<String> getAvatarUploadUrl() async {
    final res = await _client.post('/characters/avatar-upload-url');
    return res['uploadUrl'] as String;
  }

  @override
  Future<List<Map<String, dynamic>>> listByCreator() async {
    final res = await _client.post('/characters/my-list');
    return (res['characters'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

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

  @override
  Future<Map<String, dynamic>> create({
    required String name,
    required String description,
    required String systemPrompt,
    String? greeting,
    List<String> traits = const [],
    String visibility = 'public',
    String? avatarStorageId,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'description': description,
      'systemPrompt': systemPrompt,
      if (greeting != null && greeting.isNotEmpty) 'greeting': greeting,
      'traits': traits,
      'visibility': visibility,
    };

    if (avatarStorageId != null) {
      body['avatarStorageId'] = avatarStorageId;
    }

    final res = await _client.post('/characters/create', body: body);
    return res['character'] as Map<String, dynamic>;
  }
}
