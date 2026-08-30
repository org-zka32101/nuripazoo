import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'dart:io' show Platform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isAndroid) {
      return android;
    }
    if (Platform.isIOS) {
      return ios;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  // TODO: Firebase Console から Android設定を取得して記入
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'nuripazu-dev',
    databaseURL: 'https://nuripazu-dev.firebaseio.com',
    storageBucket: 'nuripazu-dev.appspot.com',
  );

  // TODO: Firebase Console から iOS設定を取得して記入
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'nuripazu-dev',
    databaseURL: 'https://nuripazu-dev.firebaseio.com',
    storageBucket: 'nuripazu-dev.appspot.com',
    iosBundleId: 'com.nuripazu.app',
  );
}
