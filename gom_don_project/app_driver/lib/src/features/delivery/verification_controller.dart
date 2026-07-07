import 'package:shared/models/order_model.dart';
import 'package:shared/test/mock_data.dart';

/// Controller: Xử lý xác thực giao hàng (PIN / QR)
class VerificationController {
  /// Lấy danh sách đơn cần giao trong phòng
  Future<List<OrderModel>> layDanhSachDonCuaPhong(String maPhong) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockData.getOrdersByRoom(maPhong)
        .where((o) => o.thanhCong || o.choChot)
        .toList();
  }

  /// Kiểm tra mã PIN nhập vào có khớp với đơn hàng không
  Future<bool> xacNhanhPin(String maDonHang, String pinNhap, String pinDung) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (pinNhap.trim() == pinDung.trim()) {
      // TODO: Cập nhật Firestore: trangThaiDonHang = "Đã giao"
      print('✅ [MOCK] Đơn $maDonHang đã được xác nhận giao hàng!');
      return true;
    }
    return false;
  }
}
