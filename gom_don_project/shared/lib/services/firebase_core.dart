import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Dịch vụ khởi tạo và kết nối Firebase dùng chung cho toàn dự án
/// Được gọi một lần duy nhất trong main.dart của từng phân hệ
class FirebaseCoreService {
  static bool _initialized = false;

  /// Khởi tạo Firebase - phải gọi trước khi dùng bất kỳ service nào.
  /// Truyền [options] từ DefaultFirebaseOptions.currentPlatform của từng app.
  static Future<void> initialize({FirebaseOptions? options}) async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp(options: options);
      _initialized = true;
      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      debugPrint(
        '⚠️ Firebase init failed: $e\n'
        '   → Đảm bảo đã đặt google-services.json vào android/app/\n'
        '   → App sẽ chạy ở chế độ MOCK (không kết nối Firestore)',
      );
      _initialized = false;
    }
  }

  static bool get isInitialized => _initialized;
}

