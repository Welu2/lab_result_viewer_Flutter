class AppConfig {
  static const String appName = 'Lab Result Viewer';
  static const String apiBaseUrl = 'http://192.168.43.29:3001';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/signup';
  static const String profileEndpoint = '/profile';
  static const String labResultsEndpoint = '/lab-results';
  static const String appointmentsEndpoint = '/appointments';
  static const String notificationsEndpoint = '/notifications';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // Pagination
  static const int defaultPageSize = 10;
}
