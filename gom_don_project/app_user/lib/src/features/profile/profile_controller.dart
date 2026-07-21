import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/models/user_model.dart';
import 'package:shared/services/firebase_core.dart';
import 'package:shared/test/mock_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_controller.dart';

/// Controller: Quản lý thông tin hồ sơ người dùng
class ProfileController {
  static const String _hubKey = 'selected_hub_id';
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Lấy user đang đăng nhập
  UserModel? get currentUser => LoginController.currentUser;

  /// Kết nối ví (chuyển trạng thái disconnected → connected + nạp tiền)
  Future<bool> ketNoiVi() async {
    final user = LoginController.currentUser;
    if (user == null) return false;

    final updatedUser = user.copyWith(
      trangThaiVi: 'connected',
      soDuVi: 500000,
    );

    if (!FirebaseCoreService.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 800));
      final idx = MockData.mockUsers.indexWhere((u) => u.maKhachHang == user.maKhachHang);
      if (idx >= 0) {
        MockData.mockUsers[idx] = updatedUser;
        LoginController.currentUser = updatedUser;
        return true;
      }
      return false;
    }

    try {
      await _db.collection('users').doc(user.maKhachHang).update({
        'TrangThaiVi': 'connected',
        'SoDuVi': 500000,
      });
      LoginController.currentUser = updatedUser;
      return true;
    } catch (e) {
      print('❌ Lỗi ketNoiVi Firestore: $e');
      return false;
    }
  }

  /// Ngắt kết nối ví
  Future<void> ngKetNoiVi() async {
    final user = LoginController.currentUser;
    if (user == null) return;

    final updatedUser = user.copyWith(
      trangThaiVi: 'disconnected',
      soDuVi: 0,
    );

    if (!FirebaseCoreService.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 500));
      final idx = MockData.mockUsers.indexWhere((u) => u.maKhachHang == user.maKhachHang);
      if (idx >= 0) {
        MockData.mockUsers[idx] = updatedUser;
        LoginController.currentUser = updatedUser;
      }
      return;
    }

    try {
      await _db.collection('users').doc(user.maKhachHang).update({
        'TrangThaiVi': 'disconnected',
        'SoDuVi': 0,
      });
      LoginController.currentUser = updatedUser;
    } catch (e) {
      print('❌ Lỗi ngKetNoiVi Firestore: $e');
    }
  }

  /// Lấy tên Hub đang được lưu
  Future<String?> layTenHubDaChon() async {
    final prefs = await SharedPreferences.getInstance();
    final maHub = prefs.getString(_hubKey);
    if (maHub == null) return null;

    if (!FirebaseCoreService.isInitialized) {
      return MockData.getHubById(maHub)?.tenHub;
    }

    try {
      final doc = await _db.collection('hubs').doc(maHub).get();
      if (doc.exists) {
        return doc.data()?['TenHub'];
      }
    } catch (e) {
      print('❌ Lỗi layTenHubDaChon Firestore: $e');
    }
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
