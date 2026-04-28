class Env {
  const Env._();

  /// Convex backend URL (e.g. http://127.0.0.1:3210 for local dev).
  /// Pass via --dart-define=CONVEX_URL=...
  static const convexUrl = String.fromEnvironment(
    'CONVEX_URL',
    defaultValue: 'https://fortunate-tapir-538.convex.cloud',
  );

  static const convexSiteUrl = String.fromEnvironment(
    'CONVEX_SITE_URL',
    defaultValue: 'https://fortunate-tapir-538.convex.site',
  );

  /// Google OAuth Web Client ID.
  /// Required for Google Sign-In on Android. Get from Google Cloud Console.
  /// Pass via --dart-define=GOOGLE_CLIENT_ID=...
  static const googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '555858112764-0djiqensneanng57grmrd0i8af684olj.apps.googleusercontent.com',  // TODO: paste Web Client ID here sau khi tạo trên Firebase/GCP
  );
}
