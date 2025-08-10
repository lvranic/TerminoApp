// File: lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyANMsoOF3RtOj1usPTHSZhfRsMFdE4Ya3o',
    appId: '1:577056152886:android:25391c68524d5a273aa797',
    messagingSenderId: '577056152886',
    projectId: 'termino-0510',
    storageBucket: 'termino-0510.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyANMsoOF3RtOj1usPTHSZhfRsMFdE4Ya3o',
    appId: '1:577056152886:android:25391c68524d5a273aa797',
    messagingSenderId: '577056152886',
    projectId: 'termino-0510',
    storageBucket: 'termino-0510.appspot.com',
    iosBundleId: 'com.example.termino',
  );

  static const FirebaseOptions macos = ios;

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyANMsoOF3RtOj1usPTHSZhfRsMFdE4Ya3o',
    appId: '1:577056152886:android:25391c68524d5a273aa797',
    messagingSenderId: '577056152886',
    projectId: 'termino-0510',
    storageBucket: 'termino-0510.appspot.com',
  );
}