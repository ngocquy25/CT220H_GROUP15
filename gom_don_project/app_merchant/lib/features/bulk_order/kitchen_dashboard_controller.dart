import 'package:shared/test/mock_data.dart';

/// Controller: Xử lý đơn tổng bếp (Bulk Order)
class KitchenDashboardController {
  /// Tính đơn tổng: gom nhóm số lượng theo tên món
  Future<Map<String, int>> layDonTong(String maPhong) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // TODO: Query Firestore: tất cả orders của phòng này có trạng thái "Thành công"
    return MockData.getBulkOrder(maPhong);
  }

  /// Lấy danh sách ghi chú riêng của từng khách để bếp chú ý
  Future<List<Map<String, dynamic>>> layGhiChuRieng(String maPhong) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final orders = MockData.getOrdersByRoom(maPhong)
        .where((o) => o.thanhCong || o.daGiao)
        .toList();

    final List<Map<String, dynamic>> notes = [];
    for (var order in orders) {
      for (var item in order.danhSachMonAn) {
        if (item.ghiChuMon != null && item.ghiChuMon!.isNotEmpty) {
          notes.add({
            'tenMon': item.tenMon,
            'khach': order.tenKhachHang,
            'ghiChu': item.ghiChuMon!,
          });
        }
      }
    }
    return notes;
  }

  /// Chủ quán ấn "Xong" → thông báo cho tài xế đến lấy hàng
  Future<void> xacNhanChuanBiXong(String maPhong) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: Firestore: cập nhật rooms/{maPhong} field 'TrangThaiBep' = 'Xong'
    // Trigger sẽ hiển thị chuyến xe trên màn hình tài xế
    print('✅ [MOCK] Quán thông báo xong cho phòng $maPhong. Tài xế có thể đến lấy hàng!');
  }
}
