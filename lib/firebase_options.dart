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
    apiKey: 'AIzaSyBDtUL1LwaFY8LBRV1dxX9gFU0Xjzl7Hv8',
    appId: '1:1016605580902:web:0b6295e33014d05a5117a7',
    messagingSenderId: '1016605580902',
    projectId: 'dfgdfghdfgdfg-8d93f',
    authDomain: 'dfgdfghdfgdfg-8d93f.firebaseapp.com',
    storageBucket: 'dfgdfghdfgdfg-8d93f.firebasestorage.app',
    measurementId: 'G-9ZN4204RJJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCywLfGpLB5OAI-BdQ7Dq3gGH2w7kcIQyA',
    appId: '1:1016605580902:android:f9ee8a563d627b9a5117a7',
    messagingSenderId: '1016605580902',
    projectId: 'dfgdfghdfgdfg-8d93f',
    storageBucket: 'dfgdfghdfgdfg-8d93f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBeseMK0OeshmxjVNMcNhpgQiLJbktk_gU',
    appId: '1:1016605580902:ios:6bc482d2fc235cf35117a7',
    messagingSenderId: '1016605580902',
    projectId: 'dfgdfghdfgdfg-8d93f',
    storageBucket: 'dfgdfghdfgdfg-8d93f.firebasestorage.app',
    iosBundleId: 'com.example.clinicManagement',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBeseMK0OeshmxjVNMcNhpgQiLJbktk_gU',
    appId: '1:1016605580902:ios:6bc482d2fc235cf35117a7',
    messagingSenderId: '1016605580902',
    projectId: 'dfgdfghdfgdfg-8d93f',
    storageBucket: 'dfgdfghdfgdfg-8d93f.firebasestorage.app',
    iosBundleId: 'com.example.clinicManagement',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBDtUL1LwaFY8LBRV1dxX9gFU0Xjzl7Hv8',
    appId: '1:1016605580902:web:60929088b68c485f5117a7',
    messagingSenderId: '1016605580902',
    projectId: 'dfgdfghdfgdfg-8d93f',
    authDomain: 'dfgdfghdfgdfg-8d93f.firebaseapp.com',
    storageBucket: 'dfgdfghdfgdfg-8d93f.firebasestorage.app',
    measurementId: 'G-320Q7B9BZM',
  );
}
