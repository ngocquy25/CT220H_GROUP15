import 'package:shared/models/order_model.dart';
import 'package:shared/test/mock_data.dart';
import '../auth/login_controller.dart';

/// Controller: Lấy lịch sử đơn hàng của user đang đăng nhập
class OrderHistoryController {
  /// Lấy tất cả đơn hàng của user hiện tại
  Future<List<OrderModel>> layLichSuDonHang() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final user = LoginController.currentUser;
    if (user == null) return [];

    // TODO: Thay bằng Firestore:
    // FirebaseFirestore.instance.collection('orders')
    //   .where('MaKhachHang', isEqualTo: user.maKhachHang)
    //   .orderBy('ThoiGianDat', descending: true)
    //   .get()
    return MockData.getOrdersByUser(user.maKhachHang);
  }

  /// Lọc đơn theo trạng thái
  List<OrderModel> locTheoTrangThai(
      List<OrderModel> orders, String trangThai) {
    if (trangThai == 'Tất cả') return orders;
    return orders.where((o) => o.trangThaiDonHang == trangThai).toList();
  }
}
