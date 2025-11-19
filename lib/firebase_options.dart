import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyBZltM26lKJfYIR-eqkn0OKjfIUVdbnGTA',
        authDomain: 'pemmobuas.firebaseapp.com',
        projectId: 'pemmobuas',
        storageBucket: 'pemmobuas.firebasestorage.app',
        messagingSenderId: '725416030540',
        appId: '1:725416030540:web:00e0e0cf283db8698f1fe9',
        measurementId: 'G-1GE63VJ3H2',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'AIzaSyBZltM26lKJfYIR-eqkn0OKjfIUVdbnGTA',
          appId: '1:725416030540:web:00e0e0cf283db8698f1fe9',
          messagingSenderId: '725416030540',
          projectId: 'pemmobuas',
          storageBucket: 'pemmobuas.firebasestorage.app',
        );
      case TargetPlatform.iOS:
        return const FirebaseOptions(
          apiKey: 'AIzaSyBZltM26lKJfYIR-eqkn0OKjfIUVdbnGTA',
          appId: '1:725416030540:web:00e0e0cf283db8698f1fe9',
          messagingSenderId: '725416030540',
          projectId: 'pemmobuas',
          storageBucket: 'pemmobuas.firebasestorage.app',
          iosBundleId: 'REPLACE_WITH_IOS_BUNDLE_ID',
        );
      case TargetPlatform.macOS:
        return const FirebaseOptions(
          apiKey: 'AIzaSyBZltM26lKJfYIR-eqkn0OKjfIUVdbnGTA',
          appId: '1:725416030540:web:00e0e0cf283db8698f1fe9',
          messagingSenderId: '725416030540',
          projectId: 'pemmobuas',
          storageBucket: 'pemmobuas.firebasestorage.app',
        );
      case TargetPlatform.windows:
        return const FirebaseOptions(
          apiKey: 'AIzaSyBZltM26lKJfYIR-eqkn0OKjfIUVdbnGTA',
          appId: '1:725416030540:web:00e0e0cf283db8698f1fe9',
          messagingSenderId: '725416030540',
          projectId: 'pemmobuas',
          storageBucket: 'pemmobuas.firebasestorage.app',
        );
      case TargetPlatform.linux:
        return const FirebaseOptions(
          apiKey: 'AIzaSyBZltM26lKJfYIR-eqkn0OKjfIUVdbnGTA',
          appId: '1:725416030540:web:00e0e0cf283db8698f1fe9',
          messagingSenderId: '725416030540',
          projectId: 'pemmobuas',
          storageBucket: 'pemmobuas.firebasestorage.app',
        );
      default:
        return const FirebaseOptions(
          apiKey: 'AIzaSyBZltM26lKJfYIR-eqkn0OKjfIUVdbnGTA',
          appId: '1:725416030540:web:00e0e0cf283db8698f1fe9',
          messagingSenderId: '725416030540',
          projectId: 'pemmobuas',
          storageBucket: 'pemmobuas.firebasestorage.app',
        );
    }
  }
}