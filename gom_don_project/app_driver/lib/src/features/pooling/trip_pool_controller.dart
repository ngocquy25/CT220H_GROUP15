import 'package:shared/models/room_model.dart';
import 'package:shared/test/mock_data.dart';

/// Controller: Xử lý danh sách chuyến và nhận chuyến
class TripPoolController {
  /// Lấy danh sách phòng thành công (sau 10:05)
  Future<List<RoomModel>> layDanhSachPhongThanhCong() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: Firestore query: where TrangThaiPhong == 'Thành công' AND MaTaiXe == null
    return MockData.mockRooms.where((r) => r.thanhCong && !r.daNhanTaiXe).toList();
  }

  /// Tài xế bấm nhận chuyến → khóa phòng cho tài xế đó
  Future<bool> nhanChuyen(String maPhong, String maTaiXe) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // TODO: Firestore transaction để đảm bảo chỉ 1 tài xế nhận được:
    // FirebaseFirestore.instance.runTransaction((tx) async {
    //   final doc = await tx.get(roomRef);
    //   if (doc['MaTaiXe'] != null) throw Exception('Đã có tài xế');
    //   tx.update(roomRef, {'MaTaiXe': maTaiXe});
    // });
    print('✅ [MOCK] Tài xế $maTaiXe nhận chuyến $maPhong');
    return true; // Giả lập thành công
  }
}
