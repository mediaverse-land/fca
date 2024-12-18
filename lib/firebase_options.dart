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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAewiZmrw5esWfaS5p83qOxMS84uA6xaPY',
    appId: '1:56751096814:android:c26a5a1296539fbe3704ff',
    messagingSenderId: '56751096814',
    projectId: 'argon-depot-370512',
    storageBucket: 'argon-depot-370512.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBc1ct8mFzq1bW7g2-dyGgWP0LKAsNG6EY',
    appId: '1:56751096814:ios:3ff7c7aa68f0add23704ff',
    messagingSenderId: '56751096814',
    projectId: 'argon-depot-370512',
    storageBucket: 'argon-depot-370512.appspot.com',
    androidClientId: '56751096814-9h8hm3kf665l2v0fusq69l8gl81s2nr0.apps.googleusercontent.com',
    iosClientId: '56751096814-3tfkjmp1oubdli5ei5ueaqo5d9hnmnle.apps.googleusercontent.com',
    iosBundleId: 'com.app.mediaverse',
  );
}
