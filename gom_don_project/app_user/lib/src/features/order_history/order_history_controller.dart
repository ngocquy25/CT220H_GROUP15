import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/models/order_model.dart';
import 'package:shared/services/firebase_core.dart';
import 'package:shared/test/mock_data.dart';
import '../auth/login_controller.dart';

/// Controller: Lấy lịch sử đơn hàng của user đang đăng nhập
class OrderHistoryController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Lấy tất cả đơn hàng của user hiện tại
  Future<List<OrderModel>> layLichSuDonHang() async {
    final user = LoginController.currentUser;
    if (user == null) return [];

    if (!FirebaseCoreService.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockData.getOrdersByUser(user.maKhachHang);
    }

    try {
      final snapshot = await _db
          .collection('orders')
          .where('MaKhachHang', isEqualTo: user.maKhachHang)
          .get();

      final orders = snapshot.docs
          .map((doc) => OrderModel.fromJson({...doc.data(), 'MaDonHang': doc.id}))
          .toList();

      // Sắp xếp giảm dần theo thời gian đặt
      orders.sort((a, b) => b.thoiGianDat.compareTo(a.thoiGianDat));
      return orders;
    } catch (e) {
      print('❌ Lỗi layLichSuDonHang Firestore: $e');
      return [];
    }
  }

  /// Lọc đơn theo trạng thái
  List<OrderModel> locTheoTrangThai(
      List<OrderModel> orders, String trangThai) {
    if (trangThai == 'Tất cả') return orders;
    return orders.where((o) => o.trangThaiDonHang == trangThai).toList();
  }
}
