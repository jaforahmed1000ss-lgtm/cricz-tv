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
        throw UnsupportedError('iOS not configured yet.');
      default:
        throw UnsupportedError('Platform not supported.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBmZMyRpQLflLe8NpR_fAL4l3MTgoJ2QXI',
    appId: '1:240014972669:android:9113146f0757bfc3001094',
    messagingSenderId: '240014972669',
    projectId: 'cricz-tv-9ba00',
    storageBucket: 'cricz-tv-9ba00.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBmZMyRpQLflLe8NpR_fAL4l3MTgoJ2QXI',
    appId: '1:240014972669:android:9113146f0757bfc3001094',
    messagingSenderId: '240014972669',
    projectId: 'cricz-tv-9ba00',
    storageBucket: 'cricz-tv-9ba00.firebasestorage.app',
  );
}
