import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/models/user_model.dart';
import 'package:shared/services/firebase_core.dart';
import 'package:shared/test/mock_data.dart';

/// Controller xử lý logic đăng nhập & đăng ký
class LoginController {
  static UserModel? currentUser;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Đăng nhập bằng số điện thoại + mật khẩu
  Future<bool> dangNhap({
    required String soDienThoai,
    required String matKhau,
  }) async {
    if (!FirebaseCoreService.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 800));
      try {
        final user = MockData.mockUsers.firstWhere(
          (u) => u.soDienThoai == soDienThoai && u.matKhau == matKhau,
        );
        currentUser = user;
        return true;
      } catch (_) {
        return false;
      }
    }

    try {
      final snapshot = await _db
          .collection('users')
          .where('SoDienThoai', isEqualTo: soDienThoai)
          .where('MatKhau', isEqualTo: matKhau)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return false;
      }

      final doc = snapshot.docs.first;
      currentUser = UserModel.fromJson({...doc.data(), 'MaKhachHang': doc.id});
      return true;
    } catch (e) {
      print('❌ Lỗi dangNhap Firestore: $e');
      return false;
    }
  }

  /// Đăng xuất
  Future<void> dangXuat() async {
    currentUser = null;
  }

  /// Kiểm tra ví đã kết nối chưa
  bool get viDaKetNoi => currentUser?.trangThaiVi == 'connected';
}
