import 'dart:async';
import 'package:shared/models/hub_model.dart';
import 'package:shared/models/room_model.dart';
import 'package:shared/models/order_model.dart';
import 'package:shared/test/mock_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/time_helper.dart';
import '../../core/utils/room_merger_service.dart';

/// Controller: Tìm hoặc tạo Phòng Gom Đơn + Quản lý bán kính động
class RoomDetailController {
  Timer? _mergerTimer;

  /// Lấy maHub đã lưu trong SharedPreferences
  Future<String> layMaHubDaLuu() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_hub_id') ?? 'HUB001';
  }

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
      final phongMoi = RoomModel(
        maPhong: 'PHONG_${maHub}_$ngayGiao',
        maHubGoc: maHub,
        thoiGianTao: DateTime.now().toIso8601String(),
        ngayGiao: ngayGiao,
        banKinhHienTai: 500,
        trangThaiPhong: 'Đang gom',
        soThanhVien: 0,
        tongSoMon: 0,
      );
      MockData.mockRooms.add(phongMoi);
      return phongMoi;
    }
  }

  /// Lấy danh sách đơn hàng trong phòng (real-time sau này)
  Future<List<OrderModel>> layDanhSachDon(String maPhong) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: Firestore real-time listener: .snapshots()
    return MockData.getOrdersByRoom(maPhong);
  }

  // ─────────────────────────────────────────────────────────────
  // TIMER BÁN KÍNH ĐỘNG — Kiểm tra mỗi 60s
  // ─────────────────────────────────────────────────────────────

  /// Bắt đầu Timer kiểm tra giờ 9h30 mỗi phút.
  /// Khi đến giờ → tự động gọi pipeline gộp Hub.
  ///
  /// [onGopHubResult]: callback trả kết quả gộp về UI để cập nhật state
  /// [giasLapNoRong]: true để test không cần đợi 9h30 thật
  void batDauTimerNoRong({
    required RoomModel phongHienTai,
    required HubModel hubGoc,
    required void Function(GopHubResult result) onGopHubResult,
    bool giasLapNoRong = false,
  }) {
    _mergerTimer?.cancel();

    // Kiểm tra ngay lập tức khi bắt đầu
    _chayKiemTra(
      phongHienTai: phongHienTai,
      hubGoc: hubGoc,
      onGopHubResult: onGopHubResult,
      giasLapNoRong: giasLapNoRong,
    );

    // Sau đó kiểm tra mỗi 60 giây
    _mergerTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _chayKiemTra(
        phongHienTai: phongHienTai,
        hubGoc: hubGoc,
        onGopHubResult: onGopHubResult,
        giasLapNoRong: giasLapNoRong,
      );
    });
  }

  Future<void> _chayKiemTra({
    required RoomModel phongHienTai,
    required HubModel hubGoc,
    required void Function(GopHubResult result) onGopHubResult,
    required bool giasLapNoRong,
  }) async {
    if (!RoomMergerService.canNoRong(
      phongHienTai,
      giasLapNoRong: giasLapNoRong,
    )) return;

    // Đến giờ → dừng timer và chạy pipeline
    _mergerTimer?.cancel();
    final result = await RoomMergerService.chayLogicGopHub(
      phongHienTai,
      hubGoc,
      giasLapNoRong: giasLapNoRong,
    );
    onGopHubResult(result);
  }

  /// Huỷ timer khi widget bị dispose
  void dispose() {
    _mergerTimer?.cancel();
  }
}

