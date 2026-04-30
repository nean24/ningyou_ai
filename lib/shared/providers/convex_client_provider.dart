import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/convex_http_client.dart';

/// Provides a base [ConvexHttpClient] (without auth token).
/// Use [authedConvexClientProvider] for authenticated calls.
final convexClientProvider = Provider<ConvexHttpClient>((ref) {
  return ConvexHttpClient();
});
