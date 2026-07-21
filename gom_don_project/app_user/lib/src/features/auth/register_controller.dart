import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/models/user_model.dart';
import 'package:shared/services/firebase_core.dart';
import 'package:shared/test/mock_data.dart';

/// Controller xử lý logic đăng ký tài khoản mới
class RegisterController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Đăng ký tài khoản mới
  /// Trả về null nếu thành công, thông báo lỗi nếu thất bại
  Future<String?> dangKy({
    required String tenKhachHang,
    required String soDienThoai,
    required String matKhau,
    required String xacNhanMatKhau,
  }) async {
    // Validate
    if (tenKhachHang.trim().isEmpty) return 'Vui lòng nhập tên của bạn';
    if (soDienThoai.length < 10) return 'Số điện thoại không hợp lệ';
    if (matKhau.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    if (matKhau != xacNhanMatKhau) return 'Xác nhận mật khẩu không khớp';

    if (!FirebaseCoreService.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 700));
      final success = MockData.dangKy(
        tenKhachHang: tenKhachHang.trim(),
        soDienThoai: soDienThoai.trim(),
        matKhau: matKhau,
      );
      if (!success) return 'Số điện thoại này đã được đăng ký';
      return null;
    }

    try {
      // Kiểm tra xem số điện thoại đã tồn tại chưa
      final snapshot = await _db
          .collection('users')
          .where('SoDienThoai', isEqualTo: soDienThoai.trim())
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return 'Số điện thoại này đã được đăng ký';
      }

      // Tạo ID ngẫu nhiên và lưu user mới
      final maKhachHang = 'KH${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final newUser = UserModel(
        maKhachHang: maKhachHang,
        tenKhachHang: tenKhachHang.trim(),
        soDienThoai: soDienThoai.trim(),
        matKhau: matKhau,
        trangThaiVi: 'disconnected',
        soDuVi: 0,
      );

      await _db.collection('users').doc(maKhachHang).set(newUser.toJson());
      return null; // null = thành công
    } catch (e) {
      print('❌ Lỗi dangKy Firestore: $e');
      return 'Đăng ký thất bại: $e';
    }
  }
}
