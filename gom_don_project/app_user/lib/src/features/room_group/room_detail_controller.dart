import 'package:shared/models/room_model.dart';
import 'package:shared/models/order_model.dart';
import 'package:shared/test/mock_data.dart';
import '../../core/utils/time_helper.dart';

/// Controller: Tìm hoặc tạo Phòng Gom Đơn
class RoomDetailController {
  /// Tìm phòng đang gom cho Hub + ngày hôm nay (hoặc ngày mai nếu > 10h)
  /// Nếu không có → tự tạo phòng mới
  Future<RoomModel> timHoacTaoPhong(String maHub) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final ngayGiao = TimeHelper.tinhNgayGiao();

    // TODO: Thay bằng Firestore query:
    // FirebaseFirestore.instance.collection('rooms')
    //   .where('MaHubGoc', isEqualTo: maHub)
    //   .where('NgayGiao', isEqualTo: ngayGiao)
    //   .where('TrangThaiPhong', isEqualTo: 'Đang gom')
    //   .limit(1).get()

    // Tìm trong mock data
    try {
      return MockData.mockRooms.firstWhere(
        (r) => r.maHubGoc == maHub && r.ngayGiao == ngayGiao && r.dangGom,
      );
    } catch (_) {
      // Không có phòng → tạo mới (mock)
      return RoomModel(
        maPhong: 'PHONG_${maHub}_$ngayGiao',
        maHubGoc: maHub,
        thoiGianTao: DateTime.now().toIso8601String(),
        ngayGiao: ngayGiao,
        banKinhHienTai: 500,
        trangThaiPhong: 'Đang gom',
        soThanhVien: 0,
        tongSoMon: 0,
      );
    }
  }

  /// Lấy danh sách đơn hàng trong phòng
  Future<List<OrderModel>> layDanhSachDon(String maPhong) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: Firestore real-time listener: .snapshots()
    return MockData.getOrdersByRoom(maPhong);
  }
}
