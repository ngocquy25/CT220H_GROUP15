import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/models/order_model.dart';

/// Controller: Xử lý xác thực giao hàng (PIN / QR) kết nối Firestore
class VerificationController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Lấy danh sách đơn cần giao trong phòng
  Future<List<OrderModel>> layDanhSachDonCuaPhong(String maPhong) async {
    try {
      final snapshot = await _db
          .collection('orders')
          .where('MaPhong', isEqualTo: maPhong)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromJson({...doc.data(), 'MaDonHang': doc.id}))
          .toList();
    } catch (e) {
      print('Error layDanhSachDonCuaPhong: $e');
      return [];
    }
  }

  /// Kiểm tra mã PIN nhập vào có khớp với đơn hàng không
  Future<bool> xacNhanhPin(String maDonHang, String pinNhap, String pinDung) async {
    try {
      if (pinNhap.trim() == pinDung.trim()) {
        // Cập nhật trạng thái đơn hàng thành "Đã giao" trên Firestore
        await _db.collection('orders').doc(maDonHang).update({
          'TrangThaiDonHang': 'Đã giao',
        });
        print('✅ Đơn $maDonHang đã được xác nhận giao hàng và lưu vào Firestore!');
        return true;
      }
      return false;
    } catch (e) {
      print('Error in xacNhanhPin: $e');
      return false;
    }
  }

  /// Xác thực nhanh bằng quét mã QR (chứa nội dung mã PIN hoặc mã đơn hàng)
  Future<bool> xacNhanQR(String maDonHang, String qrData, String pinDung) async {
    // Nếu QR data khớp với mã PIN hoặc khớp với mã đơn hàng
    if (qrData.trim() == pinDung.trim() || qrData.trim() == maDonHang.trim()) {
      return xacNhanhPin(maDonHang, pinDung, pinDung);
    }
    return false;
  }
}
