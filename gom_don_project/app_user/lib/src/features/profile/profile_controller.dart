import 'package:shared/models/user_model.dart';
import 'package:shared/test/mock_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_controller.dart';

/// Controller: Quản lý thông tin hồ sơ người dùng
class ProfileController {
  static const String _hubKey = 'selected_hub_id';

  /// Lấy user đang đăng nhập
  UserModel? get currentUser => LoginController.currentUser;

  /// Kết nối ví (mock — chuyển trạng thái disconnected → connected)
  Future<bool> ketNoiVi() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final user = LoginController.currentUser;
    if (user == null) return false;

    // TODO: Tích hợp SDK MoMo / VNPay thật
    // Mock: tìm user trong list và cập nhật trạng thái
    final idx = MockData.mockUsers.indexWhere(
        (u) => u.maKhachHang == user.maKhachHang);
    if (idx < 0) return false;

    // Thay bằng user mới có ví connected + 500k mock balance
    MockData.mockUsers[idx] = UserModel(
      maKhachHang: user.maKhachHang,
      tenKhachHang: user.tenKhachHang,
      soDienThoai: user.soDienThoai,
      trangThaiVi: 'connected',
      soDuVi: 500000,
      matKhau: user.matKhau,
    );
    return true;
  }

  /// Ngắt kết nối ví
  Future<void> ngKetNoiVi() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final user = LoginController.currentUser;
    if (user == null) return;
    final idx = MockData.mockUsers.indexWhere(
        (u) => u.maKhachHang == user.maKhachHang);
    if (idx >= 0) {
      MockData.mockUsers[idx] = UserModel(
        maKhachHang: user.maKhachHang,
        tenKhachHang: user.tenKhachHang,
        soDienThoai: user.soDienThoai,
        trangThaiVi: 'disconnected',
        soDuVi: 0,
        matKhau: user.matKhau,
      );
    }
  }

  /// Lấy tên Hub đang được lưu
  Future<String?> layTenHubDaChon() async {
    final prefs = await SharedPreferences.getInstance();
    final maHub = prefs.getString(_hubKey);
    if (maHub == null) return null;
    return MockData.getHubById(maHub)?.tenHub;
  }

  /// Xóa Hub đã lưu (để chọn lại)
  Future<void> xoaHubDaChon() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hubKey);
  }

  /// Đăng xuất
  Future<void> dangXuat() async {
    await LoginController().dangXuat();
    await xoaHubDaChon();
  }
}
