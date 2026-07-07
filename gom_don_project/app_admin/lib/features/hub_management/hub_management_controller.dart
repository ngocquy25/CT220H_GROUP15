import 'package:shared/models/hub_model.dart';
import 'package:shared/test/mock_data.dart';

/// Controller: Quản lý Hub (CRUD)
class HubManagementController {
  final List<HubModel> _localHubs = List.from(MockData.mockHubs);

  /// Lấy danh sách tất cả Hub
  Future<List<HubModel>> layDanhSachHub() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // TODO: Firestore: FirebaseFirestore.instance.collection('hubs').get()
    return _localHubs;
  }

  /// Thêm Hub mới lên Firestore
  Future<void> themHub({
    required String tenHub,
    required double kinhDo,
    required double viDo,
    required String diaChi,
    int banKinh = 500,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final newHub = HubModel(
      maHub: 'HUB${_localHubs.length + 1}'.padLeft(6, '0'),
      tenHub: tenHub,
      kinhDo: kinhDo,
      viDo: viDo,
      banKinhMacDinh: banKinh,
      diaChi: diaChi,
    );
    _localHubs.add(newHub);
    // TODO: Firestore:
    // await FirebaseFirestore.instance.collection('hubs').doc(newHub.maHub).set(newHub.toJson());
    print('✅ [MOCK] Thêm Hub: ${newHub.toJson()}');
  }

  /// Cập nhật trạng thái Hub (bật/tắt)
  Future<void> capNhatTrangThai(String maHub, bool dangHoatDong) async {
    // TODO: Firestore update field DangHoatDong
    print('✅ [MOCK] Hub $maHub → DangHoatDong: $dangHoatDong');
  }
}
