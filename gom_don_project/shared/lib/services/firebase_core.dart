import 'package:firebase_core/firebase_core.dart';

/// Dịch vụ khởi tạo và kết nối Firebase dùng chung cho toàn dự án
/// Được gọi một lần duy nhất trong main.dart của từng phân hệ
class FirebaseCoreService {
  static bool _initialized = false;

  /// Khởi tạo Firebase - phải gọi trước khi dùng bất kỳ service nào
  static Future<void> initialize() async {
    if (_initialized) return;
    await Firebase.initializeApp();
    _initialized = true;
    print('✅ Firebase initialized successfully');
  }

  static bool get isInitialized => _initialized;
}
