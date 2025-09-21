import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configuration Firebase pour le projet app-perte
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
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Configuration pour le web
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC0gQQQ9vEltA9HJEhZ3Ifb1YYanPVVEOs',
    appId: '1:759367473265:web:d61b9466fb2ae0870fa3d0',
    messagingSenderId: '759367473265',
    projectId: 'app-perte',
    authDomain: 'app-perte.firebaseapp.com',
    storageBucket: 'app-perte.firebasestorage.app',
  );

  // Configuration pour Android
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC0gQQQ9vEltA9HJEhZ3Ifb1YYanPVVEOs',
    appId: '1:759367473265:android:d61b9466fb2ae0870fa3d0',
    messagingSenderId: '759367473265',
    projectId: 'app-perte',
    storageBucket: 'app-perte.firebasestorage.app',
  );

  // Configuration pour iOS
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC0gQQQ9vEltA9HJEhZ3Ifb1YYanPVVEOs',
    appId: '1:759367473265:ios:d61b9466fb2ae0870fa3d0',
    messagingSenderId: '759367473265',
    projectId: 'app-perte',
    storageBucket: 'app-perte.firebasestorage.app',
    iosClientId: '759367473265-abcdefghijklmnop.apps.googleusercontent.com',
    iosBundleId: 'com.example.socloseApp',
  );

  // Configuration pour macOS
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC0gQQQ9vEltA9HJEhZ3Ifb1YYanPVVEOs',
    appId: '1:759367473265:ios:d61b9466fb2ae0870fa3d0',
    messagingSenderId: '759367473265',
    projectId: 'app-perte',
    storageBucket: 'app-perte.firebasestorage.app',
    iosClientId: '759367473265-abcdefghijklmnop.apps.googleusercontent.com',
    iosBundleId: 'com.example.socloseApp',
  );

  // Configuration pour Windows
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC0gQQQ9vEltA9HJEhZ3Ifb1YYanPVVEOs',
    appId: '1:759367473265:web:d61b9466fb2ae0870fa3d0',
    messagingSenderId: '759367473265',
    projectId: 'app-perte',
    storageBucket: 'app-perte.firebasestorage.app',
  );

  // Configuration pour Linux
  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyC0gQQQ9vEltA9HJEhZ3Ifb1YYanPVVEOs',
    appId: '1:759367473265:web:d61b9466fb2ae0870fa3d0',
    messagingSenderId: '759367473265',
    projectId: 'app-perte',
    storageBucket: 'app-perte.firebasestorage.app',
  );
}
