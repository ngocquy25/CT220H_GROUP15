import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/models/room_model.dart';

/// Controller: Xử lý danh sách chuyến và nhận chuyến từ Firestore
class TripPoolController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Lấy danh sách phòng thành công chưa có tài xế nhận (sau 10:05)
  Future<List<RoomModel>> layDanhSachPhongThanhCong() async {
    try {
      final snapshot = await _db
          .collection('rooms')
          .where('TrangThaiPhong', isEqualTo: 'Thành công')
          .where('MaTaiXe', isNull: true)
          .get();

      return snapshot.docs
          .map((doc) => RoomModel.fromJson({...doc.data(), 'MaPhong': doc.id}))
          .toList();
    } catch (e) {
      print('Error layDanhSachPhongThanhCong: $e');
      return [];
    }
  }

  /// Tài xế bấm nhận chuyến → khóa phòng cho tài xế đó và cập nhật các đơn hàng
  Future<bool> nhanChuyen(String maPhong, String maTaiXe) async {
    try {
      final roomRef = _db.collection('rooms').doc(maPhong);

      final success = await _db.runTransaction<bool>((transaction) async {
        final roomSnapshot = await transaction.get(roomRef);
        if (!roomSnapshot.exists) return false;

        final data = roomSnapshot.data();
        if (data == null) return false;

        // Kiểm tra xem đã có tài xế khác nhận chưa
        final currentDriver = data['MaTaiXe'];
        if (currentDriver != null && currentDriver.toString().trim().isNotEmpty) {
          return false;
        }

        // Cập nhật tài xế cho phòng
        transaction.update(roomRef, {
          'MaTaiXe': maTaiXe,
          'TenTaiXe': 'Tài Xế Nghiệm Thu B',
        });

        return true;
      });

      if (success) {
        // Cập nhật tài xế cho tất cả các đơn hàng thuộc phòng này
        final ordersSnapshot = await _db
            .collection('orders')
            .where('MaPhong', isEqualTo: maPhong)
            .get();

        final batch = _db.batch();
        for (var doc in ordersSnapshot.docs) {
          batch.update(doc.reference, {
            'MaTaiXe': maTaiXe,
            'TenTaiXe': 'Tài Xế Nghiệm Thu B',
          });
        }
        await batch.commit();
        return true;
      }

      return false;
    } catch (e) {
      print('Error in nhanChuyen: $e');
      return false;
    }
  }
}
