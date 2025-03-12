import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Конфигурация по умолчанию для Firebase
///
/// Примечание: Эти значения нужно заменить на реальные после создания проекта в Firebase
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

  // Настройки для веб-платформы
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDcM-wCHWjYDPipBeRdC7IfGcmxFuO2OCQ',
    appId: '1:720432203152:web:6a1ed986e3b26365dddf15',
    messagingSenderId: '720432203152',
    projectId: 'badmcalc',
    authDomain: 'badmcalc.firebaseapp.com',
    storageBucket: 'badmcalc.appspot.com', // Исправлено на правильный домен
    measurementId: 'G-M48EKB3FT5',
  );

  // Настройки для Android
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDcM-wCHWjYDPipBeRdC7IfGcmxFuO2OCQ',
    appId: '1:720432203152:android:6a1ed986e3b26365dddf15',
    messagingSenderId: '720432203152',
    projectId: 'badmcalc',
    storageBucket: 'badmcalc.appspot.com',
  );

  // Настройки для iOS
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDcM-wCHWjYDPipBeRdC7IfGcmxFuO2OCQ',
    appId: '1:720432203152:ios:6a1ed986e3b26365dddf15',
    messagingSenderId: '720432203152',
    projectId: 'badmcalc',
    storageBucket: 'badmcalc.appspot.com',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'com.example.badmintonTournamentApp',
  );

  // Настройки для macOS
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDcM-wCHWjYDPipBeRdC7IfGcmxFuO2OCQ',
    appId: '1:720432203152:macos:6a1ed986e3b26365dddf15',
    messagingSenderId: '720432203152',
    projectId: 'badmcalc',
    storageBucket: 'badmcalc.appspot.com',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'com.example.badmintonTournamentApp',
  );
}