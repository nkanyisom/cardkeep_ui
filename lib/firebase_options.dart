import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:card_keep/config/environment_config.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: EnvironmentConfig.firebaseApiKey,
    appId: EnvironmentConfig.firebaseAppId,
    messagingSenderId: EnvironmentConfig.firebaseMessagingSenderId,
    projectId: EnvironmentConfig.firebaseProjectId,
    authDomain: EnvironmentConfig.firebaseAuthDomain,
    storageBucket: EnvironmentConfig.firebaseStorageBucket,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: EnvironmentConfig.firebaseApiKey,
    appId: EnvironmentConfig.firebaseAppId,
    messagingSenderId: EnvironmentConfig.firebaseMessagingSenderId,
    projectId: EnvironmentConfig.firebaseProjectId,
    storageBucket: EnvironmentConfig.firebaseStorageBucket,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: EnvironmentConfig.firebaseApiKey,
    appId: EnvironmentConfig.firebaseAppId,
    messagingSenderId: EnvironmentConfig.firebaseMessagingSenderId,
    projectId: EnvironmentConfig.firebaseProjectId,
    storageBucket: EnvironmentConfig.firebaseStorageBucket,
    iosBundleId: 'za.co.jbrew.stoKarataUi',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: EnvironmentConfig.firebaseApiKey,
    appId: EnvironmentConfig.firebaseAppId,
    messagingSenderId: EnvironmentConfig.firebaseMessagingSenderId,
    projectId: EnvironmentConfig.firebaseProjectId,
    storageBucket: EnvironmentConfig.firebaseStorageBucket,
    iosBundleId: 'za.co.jbrew.stoKarataUi',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: EnvironmentConfig.firebaseApiKey,
    appId: EnvironmentConfig.firebaseAppId,
    messagingSenderId: EnvironmentConfig.firebaseMessagingSenderId,
    projectId: EnvironmentConfig.firebaseProjectId,
    authDomain: EnvironmentConfig.firebaseAuthDomain,
    storageBucket: EnvironmentConfig.firebaseStorageBucket,
  );
}
