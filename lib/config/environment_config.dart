class EnvironmentConfig {
  static const String _environment = String.fromEnvironment(
    'FLUTTER_APP_ENVIRONMENT',
    defaultValue: 'development',
  );

  static const String _devApiUrl = 'http://localhost:8080/api';
  static const String _prodApiUrl = String.fromEnvironment(
    'FLUTTER_APP_API_BASE_URL_PROD',
    defaultValue: 'https://your-api-domain.com/api',
  );

  static bool get isDevelopment => _environment == 'development';
  static bool get isProduction => _environment == 'production';

  static String get apiBaseUrl {
    switch (_environment) {
      case 'production':
        return _prodApiUrl;
      case 'development':
      default:
        return _devApiUrl;
    }
  }

  static String get environment => _environment;

  // Firebase Configuration
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'your-api-key',
  );

  static const String firebaseAuthDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: 'your-project.firebaseapp.com',
  );

  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'your-project-id',
  );

  static const String firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'your-project.appspot.com',
  );

  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '123456789',
  );

  static const String firebaseAppId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:123456789:web:abcdef123456',
  );

  static const String firebaseMeasurementId = String.fromEnvironment(
    'FIREBASE_MEASUREMENT_ID',
    defaultValue: '',
  );

  /// Print current configuration (for debugging)
  static void printConfig() {
    print('🔧 Environment Configuration:');
    print('   Environment: $environment');
    print('   API Base URL: $apiBaseUrl');
    print('   Firebase Project ID: $firebaseProjectId');
    print('   Is Production: $isProduction');
  }
}
