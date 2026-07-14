import 'dart:math';
import 'package:shared/models/hub_model.dart';
import 'package:shared/models/room_model.dart';
import 'package:shared/test/mock_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/time_helper.dart';
import '../../core/utils/room_merger_service.dart';

/// Controller cho HomeScreen — quản lý hub hiện tại, phòng gom đơn và logic đổi hub
class HomeController {
  static const String _hubKey = 'selected_hub_id';

  // ─────────────────────────────────────────────────────────────
  // HUB HIỆN TẠI
  // ─────────────────────────────────────────────────────────────

  /// Lấy HubModel đang được chọn từ SharedPreferences
  /// Trả về null nếu chưa chọn hub
  Future<HubModel?> layHubHienTai() async {
    final prefs = await SharedPreferences.getInstance();
    final maHub = prefs.getString(_hubKey);
    if (maHub == null) return null;
    return MockData.getHubById(maHub);
  }

  /// Lưu hub mới được chọn
  Future<void> doiHub(String maHub) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_hubKey, maHub);
  }

  // ─────────────────────────────────────────────────────────────
  // PHÒNG GOM ĐƠN
  // ─────────────────────────────────────────────────────────────

  /// Lấy danh sách phòng đang hoạt động của hub hôm nay
  /// Trả về list rỗng nếu chưa có phòng nào
  Future<List<RoomModel>> layPhongHoatDong(String maHub) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final ngayGiao = TimeHelper.tinhNgayGiao();

    // TODO: Thay bằng Firestore query khi tích hợp thật
    return MockData.mockRooms
        .where((r) =>
            r.maHubGoc == maHub &&
            r.ngayGiao == ngayGiao &&
            r.dangGom)
        .toList();
  }

  /// Lấy danh sách đơn hàng của một phòng
  /// CHỈ trả về thông tin món ăn (ẩn danh), không có tên khách hàng
  Future<List<AnonOrderItem>> layDanhSachMonAnonyme(String maPhong) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final orders = MockData.getOrdersByRoom(maPhong);

    // Tổng hợp món ăn: gộp cùng tên món, cộng số lượng — không trả tên người
    final Map<String, AnonOrderItem> grouped = {};
    for (final order in orders) {
      for (final item in order.danhSachMonAn) {
        final key = '${item.maMon}_${item.ghiChuMon ?? ""}';
        if (grouped.containsKey(key)) {
          grouped[key] = AnonOrderItem(
            tenMon: item.tenMon,
            soLuong: grouped[key]!.soLuong + item.soLuong,
            ghiChu: item.ghiChuMon,
            giaTien: item.giaTien,
          );
        } else {
          grouped[key] = AnonOrderItem(
            tenMon: item.tenMon,
            soLuong: item.soLuong,
            ghiChu: item.ghiChuMon,
            giaTien: item.giaTien,
          );
        }
      }
    }
    return grouped.values.toList();
  }

  /// Lấy tổng số loại món và tổng số lượng trong một phòng
  Future<({int soLoaiMon, int tongSoLuong})> layThongKePhong(
      String maPhong) async {
    final items = await layDanhSachMonAnonyme(maPhong);
    final tongSoLuong = items.fold(0, (s, i) => s + i.soLuong);
    return (soLoaiMon: items.length, tongSoLuong: tongSoLuong);
  }

  // ─────────────────────────────────────────────────────────────
  // GỘP HUB & BÁN KÍNH ĐỘNG
  // ─────────────────────────────────────────────────────────────

  /// Kiểm tra và chạy logic gộp Hub cho phòng hiện tại.
  ///
  /// Nếu giờ >= 9h30 và phòng < [RoomMergerService.nguongGop] người:
  ///   - Nới bán kính 500m → 1000m
  ///   - Tìm Hub lân cận và gộp đơn vắo phòng hiện tại
  ///
  /// [giasLapNoRong]: true để test mà không cần đợi đến 9h30 thật
  Future<GopHubResult?> kiemTraVaGopHub(
    RoomModel phong,
    HubModel hubGoc, {
    bool giasLapNoRong = false,
  }) async {
    // Chỉ chạy nếu phòng chưa mở rộng ban kính
    if (!RoomMergerService.canNoRong(phong, giasLapNoRong: giasLapNoRong)) {
      return null;
    }
    return RoomMergerService.chayLogicGopHub(
      phong,
      hubGoc,
      giasLapNoRong: giasLapNoRong,
    );
  }
  // ─────────────────────────────────────────────────────────────

  // ─────────────────────────────────────────────────────────────
  // LOGIC ĐỔI HUB — HUB CÙNG TUYẾN
  // ─────────────────────────────────────────────────────────────

  /// Lấy danh sách hub cùng tuyến với hub hiện tại
  ///
  /// Định nghĩa "cùng tuyến": khoảng cách giữa 2 tâm hub ≤ 1000m (đi bộ được)
  /// Không bao gồm hub hiện tại trong kết quả
  List<HubModel> layHubCungTuyen(HubModel hubHienTai) {
    const double nguongKmCungTuyen = 1000.0; // 1km — khoảng cách đi bộ được giữa 2 tâm hub

    return MockData.mockHubs
        .where((hub) {
          if (hub.maHub == hubHienTai.maHub) return false; // bỏ hub hiện tại
          if (!hub.dangHoatDong) return false; // chỉ hub đang hoạt động
          final dist = _tinhKhoangCach(
            hubHienTai.viDo,
            hubHienTai.kinhDo,
            hub.viDo,
            hub.kinhDo,
          );
          return dist <= nguongKmCungTuyen;
        })
        .toList()
      ..sort((a, b) {
        // Sắp xếp theo khoảng cách gần nhất
        final dA = _tinhKhoangCach(
            hubHienTai.viDo, hubHienTai.kinhDo, a.viDo, a.kinhDo);
        final dB = _tinhKhoangCach(
            hubHienTai.viDo, hubHienTai.kinhDo, b.viDo, b.kinhDo);
        return dA.compareTo(dB);
      });
  }

  /// Tính khoảng cách (mét) giữa 2 toạ độ GPS bằng công thức Haversine
  double _tinhKhoangCach(
      double lat1, double lng1, double lat2, double lng2) {
    const double R = 6371000; // Bán kính Trái Đất (mét)
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) *
            cos(_toRad(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double deg) => deg * pi / 180;

  /// Tính khoảng cách (mét) từ hub hiện tại đến một hub khác
  double khoangCachGiuaHai(HubModel a, HubModel b) =>
      _tinhKhoangCach(a.viDo, a.kinhDo, b.viDo, b.kinhDo);
}

// ─────────────────────────────────────────────────────────────────────
// MODEL PHỤ: Món ăn ẩn danh (không có thông tin người đặt)
// ─────────────────────────────────────────────────────────────────────

/// Dữ liệu món ăn được hiển thị trong phòng — hoàn toàn ẩn danh
class AnonOrderItem {
  final String tenMon;
  final int soLuong;
  final String? ghiChu;
  final int giaTien;

  const AnonOrderItem({
    required this.tenMon,
    required this.soLuong,
    this.ghiChu,
    required this.giaTien,
  });
}
