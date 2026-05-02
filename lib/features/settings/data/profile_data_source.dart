import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/network/convex_http_client.dart';
import '../../../shared/providers/convex_client_provider.dart';
import '../../auth/presentation/auth_controller.dart';

final profileDataSourceProvider = Provider<ProfileDataSource>((ref) {
  final convex = ref.watch(convexClientProvider);
  final token = ref.watch(sessionTokenProvider);
  return ProfileDataSource(
    convex: token != null ? convex.withToken(token) : convex,
  );
});

class ProfileDataSource {
  ProfileDataSource({required ConvexHttpClient convex}) : _convex = convex;

  final ConvexHttpClient _convex;

  Future<void> updateDisplayName(String displayName) async {
    await _convex.patch('/users/profile', body: {'displayName': displayName});
  }

  /// Picks, uploads, and updates the avatar. Returns the new public URL.
  Future<String?> uploadAvatar(XFile file) async {
    // 1. Get a short-lived Convex Storage upload URL
    final urlRes = await _convex.post('/users/avatar-upload-url');
    final uploadUrl = urlRes['uploadUrl'] as String;

    // 2. PUT raw bytes to Convex Storage
    final bytes = await file.readAsBytes();
    final mimeType = _mimeType(file.name);
    final putResponse = await http.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': mimeType},
      body: bytes,
    );

    if (putResponse.statusCode < 200 || putResponse.statusCode >= 300) {
      throw ConvexHttpException('Avatar upload failed', statusCode: putResponse.statusCode);
    }

    final storageId =
        (jsonDecode(putResponse.body) as Map<String, dynamic>)['storageId'] as String;

    // 3. Save storageId → server resolves to URL
    final patchRes = await _convex.patch(
      '/users/profile',
      body: {'avatarStorageId': storageId},
    );

    return patchRes['avatarUrl'] as String?;
  }

  String _mimeType(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    return switch (ext) {
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }
}
