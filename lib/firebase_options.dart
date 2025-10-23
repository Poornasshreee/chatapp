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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCq1UctRwpw1HVeZC8EbmwTdAwme7KoqMQ',
    appId: '1:71301215551:web:f4c00bfe39e5e7815f0f8a',
    messagingSenderId: '71301215551',
    projectId: 'chatapp-58ec3',
    authDomain: 'chatapp-58ec3.firebaseapp.com',
    storageBucket: 'chatapp-58ec3.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCq1UctRwpw1HVeZC8EbmwTdAwme7KoqMQ',
    appId: '1:71301215551:android:332cfb04c5eb37265f0f8a',
    messagingSenderId: '71301215551',
    projectId: 'chatapp-58ec3',
    storageBucket: 'chatapp-58ec3.firebasestorage.app',
  );
}