import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'demo-api-key',
    appId: '1:123456789:web:abcdef123456789',
    messagingSenderId: '123456789',
    projectId: 'loyalty-card-demo',
    authDomain: 'loyalty-card-demo.firebaseapp.com',
    storageBucket: 'loyalty-card-demo.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:123456789:android:abcdef123456789',
    messagingSenderId: '123456789',
    projectId: 'loyalty-card-demo',
    storageBucket: 'loyalty-card-demo.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:123456789:ios:abcdef123456789',
    messagingSenderId: '123456789',
    projectId: 'loyalty-card-demo',
    storageBucket: 'loyalty-card-demo.appspot.com',
    iosBundleId: 'za.co.jbrew.stoKarataUi',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:123456789:ios:abcdef123456789',
    messagingSenderId: '123456789',
    projectId: 'loyalty-card-demo',
    storageBucket: 'loyalty-card-demo.appspot.com',
    iosBundleId: 'za.co.jbrew.stoKarataUi',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:123456789:web:abcdef123456789',
    messagingSenderId: '123456789',
    projectId: 'loyalty-card-demo',
    authDomain: 'loyalty-card-demo.firebaseapp.com',
    storageBucket: 'loyalty-card-demo.appspot.com',
  );
}
