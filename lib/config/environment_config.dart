class EnvironmentConfig {
  static const String _environment = String.fromEnvironment(
    'FLUTTER_APP_ENVIRONMENT',
    defaultValue: 'development',
  );

  static const String _devApiUrl = 'https://cardkeep-backend.onrender.com/api';
  static const String _prodApiUrl = String.fromEnvironment(
    'FLUTTER_APP_API_BASE_URL_PROD',
    defaultValue: 'https://cardkeep-backend.onrender.com/api',
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
    defaultValue: 'AIzaSyCKwndua3dP4PxOkRncd8JYVM2HIIUYDCc',
  );

  static const String firebaseAuthDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: 'loyalty-card-app-c4947.firebaseapp.com',
  );

  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'loyalty-card-app-c4947',
  );

  static const String firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'loyalty-card-app-c4947.firebasestorage.app',
  );

  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '649249270292',
  );

  static const String firebaseAppId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:649249270292:android:c2e38c5ae48d79f91f5501',
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
