import 'package:shared/test/mock_data.dart';

/// Controller xử lý logic đăng ký tài khoản mới (Mock)
class RegisterController {
  /// Đăng ký tài khoản mới
  /// Trả về null nếu thành công, thông báo lỗi nếu thất bại
  Future<String?> dangKy({
    required String tenKhachHang,
    required String soDienThoai,
    required String matKhau,
    required String xacNhanMatKhau,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    // Validate
    if (tenKhachHang.trim().isEmpty) return 'Vui lòng nhập tên của bạn';
    if (soDienThoai.length < 10) return 'Số điện thoại không hợp lệ';
    if (matKhau.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    if (matKhau != xacNhanMatKhau) return 'Xác nhận mật khẩu không khớp';

    // TODO: Thay bằng Firebase Auth createUserWithEmailAndPassword(...)
    final success = MockData.dangKy(
      tenKhachHang: tenKhachHang.trim(),
      soDienThoai: soDienThoai.trim(),
      matKhau: matKhau,
    );

    if (!success) return 'Số điện thoại này đã được đăng ký';
    return null; // null = thành công
  }
}
