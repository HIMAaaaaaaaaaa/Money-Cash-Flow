// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyCQWD-ZYmQW0YA5huD71FqAYPr5DBWLRR0',
    appId: '1:951029199900:web:79aad9ff2a1e322be65bd9',
    messagingSenderId: '951029199900',
    projectId: 'money-cash-flow',
    authDomain: 'money-cash-flow.firebaseapp.com',
    storageBucket: 'money-cash-flow.firebasestorage.app',
    measurementId: 'G-Y8S71Z7TLV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyASzmduYLuXRXQtFhzRCXWQ_tY5b6__bwI',
    appId: '1:951029199900:android:aa083ce79d302948e65bd9',
    messagingSenderId: '951029199900',
    projectId: 'money-cash-flow',
    storageBucket: 'money-cash-flow.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCtZC4WWGIHFZCdxzAlYF3UmSuYfLa9uUQ',
    appId: '1:951029199900:ios:0207668d28b6aaa9e65bd9',
    messagingSenderId: '951029199900',
    projectId: 'money-cash-flow',
    storageBucket: 'money-cash-flow.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplicationMoneyCashFlow',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCtZC4WWGIHFZCdxzAlYF3UmSuYfLa9uUQ',
    appId: '1:951029199900:ios:0207668d28b6aaa9e65bd9',
    messagingSenderId: '951029199900',
    projectId: 'money-cash-flow',
    storageBucket: 'money-cash-flow.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplicationMoneyCashFlow',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCQWD-ZYmQW0YA5huD71FqAYPr5DBWLRR0',
    appId: '1:951029199900:web:8bd288b342f9b28ae65bd9',
    messagingSenderId: '951029199900',
    projectId: 'money-cash-flow',
    authDomain: 'money-cash-flow.firebaseapp.com',
    storageBucket: 'money-cash-flow.firebasestorage.app',
    measurementId: 'G-ZPJFHFC1D9',
  );
}
