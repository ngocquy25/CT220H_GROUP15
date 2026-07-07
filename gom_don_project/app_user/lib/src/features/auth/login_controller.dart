import 'package:shared/models/user_model.dart';
import 'package:shared/test/mock_data.dart';

/// Controller xử lý logic đăng nhập
/// Hiện tại dùng Mock Data để test, sau tích hợp Firebase Auth thật
class LoginController {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  /// Đăng nhập bằng số điện thoại + mật khẩu
  /// Hiện tại: giả lập - khớp số điện thoại với mock data là thành công
  Future<bool> dangNhap({
    required String soDienThoai,
    required String matKhau,
  }) async {
    // Giả lập độ trễ mạng
    await Future.delayed(const Duration(milliseconds: 800));

    // TODO: Thay bằng Firebase Auth thật
    // Tìm user khớp số điện thoại trong mock data
    try {
      final user = MockData.mockUsers.firstWhere(
        (u) => u.soDienThoai == soDienThoai,
      );
      _currentUser = user;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Đăng xuất
  Future<void> dangXuat() async {
    _currentUser = null;
    // TODO: Firebase Auth signOut()
  }

  /// Kiểm tra ví đã kết nối chưa
  bool get viDaKetNoi => _currentUser?.trangThaiVi == 'connected';
}
