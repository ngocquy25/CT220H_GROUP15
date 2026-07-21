// File này được cấu hình để kết nối với dự án Firebase gom-don-project
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCsN-Qaqib1-t-43OvWiaklkH5f73CWUS0',
    appId: '1:330506275706:android:bf0816ba447957d71da4c3',
    messagingSenderId: '330506275706',
    projectId: 'gom-don-project',
    storageBucket: 'gom-don-project.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCsN-Qaqib1-t-43OvWiaklkH5f73CWUS0',
    appId: '1:330506275706:android:bf0816ba447957d71da4c3',
    messagingSenderId: '330506275706',
    projectId: 'gom-don-project',
    storageBucket: 'gom-don-project.firebasestorage.app',
  );
}
