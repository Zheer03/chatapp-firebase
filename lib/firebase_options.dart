// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyC_AwMTHU3d67d7ZOYdm9MMc9K-IhouslI',
    appId: '1:215655905976:web:d8d869760e9e6785d8d24d',
    messagingSenderId: '215655905976',
    projectId: 'chatappfirebase-4f720',
    authDomain: 'chatappfirebase-4f720.firebaseapp.com',
    storageBucket: 'chatappfirebase-4f720.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD0nKPCZ-LEtqjq7No3U5Za-6k1gAxsffs',
    appId: '1:215655905976:android:fa7abb4f69f24ed9d8d24d',
    messagingSenderId: '215655905976',
    projectId: 'chatappfirebase-4f720',
    storageBucket: 'chatappfirebase-4f720.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBorA69KBtY4VLbaHnHA7W_nPo7Cqiyr28',
    appId: '1:215655905976:ios:b90b26934eccd890d8d24d',
    messagingSenderId: '215655905976',
    projectId: 'chatappfirebase-4f720',
    storageBucket: 'chatappfirebase-4f720.appspot.com',
    iosBundleId: 'com.example.chatappFirebase',
  );
}
