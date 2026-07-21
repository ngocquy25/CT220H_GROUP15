import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/models/order_model.dart';
import 'package:shared/services/firebase_core.dart';
import 'package:shared/test/mock_data.dart';

/// Controller: Xử lý đơn tổng bếp (Bulk Order)
class KitchenDashboardController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Tính đơn tổng: gom nhóm số lượng theo tên món cho quán cụ thể trong phòng
  Future<Map<String, int>> layDonTong(String maPhong, {String maQuan = 'QA001'}) async {
    if (!FirebaseCoreService.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 600));
      return MockData.getBulkOrder(maPhong);
    }
    try {
      final snapshot = await _db
          .collection('orders')
          .where('MaPhong', isEqualTo: maPhong)
          .where('MaQuan', isEqualTo: maQuan)
          .get()
          .timeout(const Duration(seconds: 4));

      final orders = snapshot.docs
          .map((doc) => OrderModel.fromJson({...doc.data(), 'MaDonHang': doc.id}))
          .where((o) => o.thanhCong || o.daGiao)
          .toList();

      final Map<String, int> bulk = {};
      for (var order in orders) {
        for (var item in order.danhSachMonAn) {
          bulk[item.tenMon] = (bulk[item.tenMon] ?? 0) + item.soLuong;
        }
      }
      return bulk;
    } catch (e) {
      print('❌ Lỗi layDonTong Firestore: $e');
      return MockData.getBulkOrder(maPhong);
    }
  }

  /// Lấy danh sách ghi chú riêng của từng khách để bếp chú ý
  Future<List<Map<String, dynamic>>> layGhiChuRieng(String maPhong, {String maQuan = 'QA001'}) async {
    if (!FirebaseCoreService.isInitialized) {
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
    try {
      final snapshot = await _db
          .collection('orders')
          .where('MaPhong', isEqualTo: maPhong)
          .where('MaQuan', isEqualTo: maQuan)
          .get()
          .timeout(const Duration(seconds: 4));

      final orders = snapshot.docs
          .map((doc) => OrderModel.fromJson({...doc.data(), 'MaDonHang': doc.id}))
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
    } catch (e) {
      print('❌ Lỗi layGhiChuRieng Firestore: $e');
      return [];
    }
  }

  /// Chủ quán ấn "Xong" → thông báo cho tài xế đến lấy hàng
  Future<void> xacNhanChuanBiXong(String maPhong) async {
    if (!FirebaseCoreService.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 500));
      print('✅ [MOCK] Quán thông báo xong cho phòng $maPhong. Tài xế có thể đến lấy hàng!');
      return;
    }
    try {
      await _db.collection('rooms').doc(maPhong).update({
        'TrangThaiBep': 'Xong',
      });
      print('✅ Đã cập nhật TrangThaiBep = Xong cho phòng $maPhong lên Firestore');
    } catch (e) {
      print('❌ Lỗi xacNhanChuanBiXong Firestore: $e');
    }
  }
}

