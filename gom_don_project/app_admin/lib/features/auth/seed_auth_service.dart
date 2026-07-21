import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Dịch vụ tạo tài khoản hệ thống lên Firebase Authentication
/// Chạy 1 lần từ AdminHomeScreen qua nút "Tạo tài khoản hệ thống"
///
/// Danh sách 7 tài khoản:
///   Admin  : admin@gomdon.vn        / 123456
///   Driver : driver1/2/3@gomdon.vn  / 123456
///   Merchant: merchant1/2/3@gomdon.vn / 123456
class SeedAuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db   = FirebaseFirestore.instance;

  /// Danh sách tài khoản cần tạo
  static const _accounts = [
    // (email, password, role, displayName)
    ('admin@gomdon.vn',     '123456', 'admin',    'Quản trị viên'),
    ('driver1@gomdon.vn',   '123456', 'driver',   'Tài xế 1'),
    ('driver2@gomdon.vn',   '123456', 'driver',   'Tài xế 2'),
    ('driver3@gomdon.vn',   '123456', 'driver',   'Tài xế 3'),
    ('merchant1@gomdon.vn', '123456', 'merchant', 'Cơm Tấm Bà Ba'),
    ('merchant2@gomdon.vn', '123456', 'merchant', 'Bún Bò Huế'),
    ('merchant3@gomdon.vn', '123456', 'merchant', 'Bánh Mì Thanh'),
  ];

  /// Tạo toàn bộ tài khoản.
  /// Trả về danh sách kết quả (email, success, message)
  static Future<List<(String, bool, String)>> seedAllAccounts() async {
    final results = <(String, bool, String)>[];

    for (final acc in _accounts) {
      final email       = acc.$1;
      final password    = acc.$2;
      final role        = acc.$3;
      final displayName = acc.$4;

      try {
        // Tạo tài khoản Firebase Auth
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final uid = credential.user!.uid;

        // Cập nhật displayName
        await credential.user!.updateDisplayName(displayName);

        // Lưu thông tin vào Firestore collection 'system_users'
        await _db.collection('system_users').doc(uid).set({
          'uid':         uid,
          'email':       email,
          'displayName': displayName,
          'role':        role,
          'createdAt':   FieldValue.serverTimestamp(),
          'isActive':    true,
        });

        results.add((email, true, 'Tạo thành công'));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          results.add((email, true, 'Đã tồn tại (bỏ qua)'));
        } else {
          results.add((email, false, 'Lỗi: ${e.message}'));
        }
      } catch (e) {
        results.add((email, false, 'Lỗi: $e'));
      }
    }

    // Đăng xuất tài khoản vừa tạo cuối (tránh bị auto-login)
    await _auth.signOut();

    return results;
  }
}
