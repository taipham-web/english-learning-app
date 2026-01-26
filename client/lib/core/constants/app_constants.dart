class AppConstants {
  // API Constants
  // Android emulator dùng 10.0.2.2, iOS simulator dùng localhost
  // Hoặc thay bằng IP máy của bạn (vd: http://192.168.1.x:5000/api)
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // App Info
  static const String appName = 'English Learning App';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String languageKey = 'app_language';

  // Pagination
  static const int pageSize = 20;
  static const int maxPageSize = 100;
}
