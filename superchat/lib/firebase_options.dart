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
        return macos;
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
    apiKey: 'AIzaSyBuHDWgJyQnrodvP1cNQfodVWXHqn7jbes',
    appId: '1:251103270210:web:4ef310fd4da75cfbd8e4db',
    messagingSenderId: '251103270210',
    projectId: 'superchat-78afde',
    authDomain: 'superchat-78afde.firebaseapp.com',
    storageBucket: 'superchat-78afde.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBt34IH9WZBsHh13DTaoNQtpSm2tczSjxw',
    appId: '1:251103270210:android:8aac9d4f3c8621ccd8e4db',
    messagingSenderId: '251103270210',
    projectId: 'superchat-78afde',
    storageBucket: 'superchat-78afde.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA0-q_qEsdtSkwS3sFrrDb61We-GNQR3jo',
    appId: '1:251103270210:ios:757be6db0f197670d8e4db',
    messagingSenderId: '251103270210',
    projectId: 'superchat-78afde',
    storageBucket: 'superchat-78afde.appspot.com',
    iosBundleId: 'com.example.superchat',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA0-q_qEsdtSkwS3sFrrDb61We-GNQR3jo',
    appId: '1:251103270210:ios:a5f0037b1ba866b8d8e4db',
    messagingSenderId: '251103270210',
    projectId: 'superchat-78afde',
    storageBucket: 'superchat-78afde.appspot.com',
    iosBundleId: 'com.example.superchat.RunnerTests',
  );
}