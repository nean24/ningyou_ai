class AppConfig {
  const AppConfig({required this.appName, required this.convexUrl});

  factory AppConfig.dev() {
    return const AppConfig(appName: 'Ningyou', convexUrl: '');
  }

  final String appName;
  final String convexUrl;
}
