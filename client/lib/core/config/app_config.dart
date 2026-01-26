class AppConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get apiBaseUrl {
    if (isProduction) {
      return 'https://api.production.com';
    }
    return 'http://localhost:3000/api';
  }

  static const bool enableLogging = !isProduction;
  static const bool enableDebugBanner = !isProduction;
}
