// Firebase settings for the souq-kfupm project (Web and Android).
//
// These values identify the Firebase project; they are not secrets. Access to
// the data is protected by Firebase Authentication and the Firestore security
// rules in firestore.rules.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    if (defaultTargetPlatform == TargetPlatform.android) return android;
    throw UnsupportedError('Souq is set up for Web and Android only.');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAR3c_1WnG7TFZzbe1nRFgrrcMN6sGDYIY',
    appId: '1:243844011954:web:1a5eb47f8a012d492db6ab',
    messagingSenderId: '243844011954',
    projectId: 'souq-kfupm',
    authDomain: 'souq-kfupm.firebaseapp.com',
    storageBucket: 'souq-kfupm.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAR3c_1WnG7TFZzbe1nRFgrrcMN6sGDYIY',
    appId: '1:243844011954:android:071dc8c90285be3d2db6ab',
    messagingSenderId: '243844011954',
    projectId: 'souq-kfupm',
    storageBucket: 'souq-kfupm.firebasestorage.app',
  );
}
