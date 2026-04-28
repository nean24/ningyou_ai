import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/env.dart';

/// Exception thrown when a Convex HTTP call fails or returns a non-2xx status.
class ConvexHttpException implements Exception {
  const ConvexHttpException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ConvexHttpException($statusCode): $message';
}

/// A lightweight HTTP client for calling Convex HTTP Actions (site URL).
///
/// Automatically attaches [Authorization: Bearer <sessionToken>] when a token
/// is provided. All requests and responses are JSON.
class ConvexHttpClient {
  ConvexHttpClient({String? sessionToken}) : _sessionToken = sessionToken;

  final String? _sessionToken;

  /// Returns a copy of this client with the given session token attached.
  ConvexHttpClient withToken(String token) =>
      ConvexHttpClient(sessionToken: token);

  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      if (_sessionToken != null) 'Authorization': 'Bearer $_sessionToken',
    };
  }

  String _siteUrl(String path) {
    final base = Env.convexSiteUrl.isNotEmpty
        ? Env.convexSiteUrl
        : 'http://127.0.0.1:3211';
    return '$base$path';
  }

  /// PATCH to a Convex HTTP action endpoint.
  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.patch(
      Uri.parse(_siteUrl(path)),
      headers: _headers(),
      body: body != null ? jsonEncode(body) : null,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ConvexHttpException(
        data['error']?.toString() ?? 'Unknown error',
        statusCode: response.statusCode,
      );
    }

    return data;
  }

  /// GET from a Convex HTTP action endpoint.
  Future<Map<String, dynamic>> get(String path) async {
    final response = await http.get(
      Uri.parse(_siteUrl(path)),
      headers: _headers(),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ConvexHttpException(
        data['error']?.toString() ?? 'Unknown error',
        statusCode: response.statusCode,
      );
    }

    return data;
  }

  /// POST to a Convex HTTP action endpoint.
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.post(
      Uri.parse(_siteUrl(path)),
      headers: _headers(),
      body: body != null ? jsonEncode(body) : null,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ConvexHttpException(
        data['error']?.toString() ?? 'Unknown error',
        statusCode: response.statusCode,
      );
    }

    return data;
  }
}
