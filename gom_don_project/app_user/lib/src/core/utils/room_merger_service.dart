import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/models/hub_model.dart';
import 'package:shared/models/room_model.dart';
import 'package:shared/models/order_model.dart';
import 'package:shared/services/firebase_core.dart';
import 'package:shared/test/mock_data.dart';

/// ============================================================
/// ROOM MERGER SERVICE — Logic Ban Kinh Dong & Gop Hub
/// ============================================================

class GopHubResult {
  /// Phong goc sau khi da duoc cap nhat (banKinh, danhSachHubGop)
  final RoomModel phongDaCapNhat;

  /// Danh sach Hub da duoc gop vao phong nay
  final List<HubModel> hubDaGop;

  /// Tong so thanh vien sau khi gop
  final int tongThanhVienSauGop;

  /// true neu co it nhat 1 Hub duoc gop
  bool get daGopDuocHub => hubDaGop.isNotEmpty;

  const GopHubResult({
    required this.phongDaCapNhat,
    required this.hubDaGop,
    required this.tongThanhVienSauGop,
  });
}

class RoomMergerService {
  // ─────────────────────────────────────────────────────────────
  // CONSTANTS — Quy tac nghiep vu
  // ─────────────────────────────────────────────────────────────

  /// Gio noi ban kinh: 9 gio 30 phut
  static const int _gioNoRong = 9;
  static const int _phutNoRong = 30;

  /// Ban kinh mo rong (met) sau 9h30
  static const int banKinhMoRong = 1000;

  /// Ban kinh mac dinh (met) truoc 9h30
  static const int banKinhMacDinh = 500;

  /// Nguong so thanh vien toi thieu: phong co < nguongGop nguoi → du dieu kien gop
  static const int nguongGop = 3;

  // ─────────────────────────────────────────────────────────────
  // 1. KIEM TRA THOI GIAN
  // ─────────────────────────────────────────────────────────────

  /// Kiem tra gio hien tai da den 9h30 chua
  static bool daDenoGioNoRong({bool giasLapNoRong = false}) {
    if (giasLapNoRong) return true;
    final now = DateTime.now();
    if (now.hour > _gioNoRong) return true;
    if (now.hour == _gioNoRong && now.minute >= _phutNoRong) return true;
    return false;
  }

  /// Kiem tra phong co can noi ban kinh khong
  static bool canNoRong(RoomModel room, {bool giasLapNoRong = false}) {
    return daDenoGioNoRong(giasLapNoRong: giasLapNoRong) &&
        !room.daMoRongBanKinh &&
        room.dangGom;
  }

  // ─────────────────────────────────────────────────────────────
  // 2. NOI BAN KINH
  // ─────────────────────────────────────────────────────────────

  /// Noi ban kinh phong tu 500m → 1000m
  static RoomModel moRongBanKinh(RoomModel room) {
    final phongMoi = room.copyWith(
      banKinhHienTai: banKinhMoRong,
    );
    final idx = MockData.mockRooms.indexWhere((r) => r.maPhong == room.maPhong);
    if (idx != -1) MockData.mockRooms[idx] = phongMoi;
    return phongMoi;
  }

  // ─────────────────────────────────────────────────────────────
  // 3. TIM HUB LAN CAN
  // ─────────────────────────────────────────────────────────────

  /// Tim cac Hub nam trong ban kinh [banKinhMet] tu Hub goc
  static List<HubModel> timHubTrongBanKinh(
    HubModel hubGoc,
    double banKinhMet,
  ) {
    return MockData.mockHubs.where((hub) {
      if (hub.maHub == hubGoc.maHub) return false;
      if (!hub.dangHoatDong) return false;
      final dist = _haversine(hubGoc.viDo, hubGoc.kinhDo, hub.viDo, hub.kinhDo);
      return dist <= banKinhMet;
    }).toList()
      ..sort((a, b) {
        final dA = _haversine(hubGoc.viDo, hubGoc.kinhDo, a.viDo, a.kinhDo);
        final dB = _haversine(hubGoc.viDo, hubGoc.kinhDo, b.viDo, b.kinhDo);
        return dA.compareTo(dB);
      });
  }

  // ─────────────────────────────────────────────────────────────
  // 4. KIEM TRA PHONG CO DU DIEU KIEN GOP
  // ─────────────────────────────────────────────────────────────

  /// Lay phong "dang gom" cua Hub lan can (neu co) va du dieu kien gop
  static RoomModel? timPhongCanGop(
    HubModel hubLanCan,
    String ngayGiao,
  ) {
    try {
      return MockData.mockRooms.firstWhere(
        (r) =>
            r.maHubGoc == hubLanCan.maHub &&
            r.ngayGiao == ngayGiao &&
            r.dangGom &&
            r.soThanhVien < nguongGop,
      );
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 5. GOP PHONG
  // ─────────────────────────────────────────────────────────────

  /// Gop phong Hub lan can vao phong Hub goc:
  static RoomModel gopVaoPhong({
    required RoomModel phongNguon,
    required RoomModel phongNhanHang,
  }) {
    final soDonChuyen = MockData.moveOrdersBetweenRooms(
      maPhongNguon: phongNguon.maPhong,
      maPhongDich: phongNhanHang.maPhong,
    );

    final donMoi = MockData.getOrdersByRoom(phongNhanHang.maPhong);
    final soMonGop = donMoi
        .fold<int>(0, (s, o) => s + o.danhSachMonAn.length);

    final idxNguon = MockData.mockRooms
        .indexWhere((r) => r.maPhong == phongNguon.maPhong);
    if (idxNguon != -1) {
      MockData.mockRooms[idxNguon] = phongNguon.copyWith(
        trangThaiPhong: 'Da gop',
      );
    }

    final hubGopMoi = [...phongNhanHang.danhSachHubGop, phongNguon.maHubGoc];
    final phongCapNhat = phongNhanHang.copyWith(
      soThanhVien: phongNhanHang.soThanhVien + soDonChuyen,
      tongSoMon: soMonGop,
      danhSachHubGop: hubGopMoi,
    );

    final idxNhan = MockData.mockRooms
        .indexWhere((r) => r.maPhong == phongNhanHang.maPhong);
    if (idxNhan != -1) MockData.mockRooms[idxNhan] = phongCapNhat;

    return phongCapNhat;
  }

  // ─────────────────────────────────────────────────────────────
  // 6. HAM CHINH — PIPELINE GOP HUB
  // ─────────────────────────────────────────────────────────────

  /// Chay toan bo pipeline gop Hub cho mot phong cu the.
  static Future<GopHubResult> chayLogicGopHub(
    RoomModel phong,
    HubModel hubGoc, {
    bool giasLapNoRong = false,
  }) async {
    if (!FirebaseCoreService.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!canNoRong(phong, giasLapNoRong: giasLapNoRong)) {
        return GopHubResult(
          phongDaCapNhat: phong,
          hubDaGop: [],
          tongThanhVienSauGop: phong.soThanhVien,
        );
      }

      RoomModel phongHienTai = moRongBanKinh(phong);
      final hubLanCan = timHubTrongBanKinh(hubGoc, banKinhMoRong.toDouble());

      if (hubLanCan.isEmpty) {
        return GopHubResult(
          phongDaCapNhat: phongHienTai,
          hubDaGop: [],
          tongThanhVienSauGop: phongHienTai.soThanhVien,
        );
      }

      final List<HubModel> hubDaGop = [];
      final ngayGiao = phong.ngayGiao;

      for (final hub in hubLanCan) {
        final phongNguon = timPhongCanGop(hub, ngayGiao);
        if (phongNguon != null) {
          phongHienTai = gopVaoPhong(
            phongNguon: phongNguon,
            phongNhanHang: phongHienTai,
          );
          hubDaGop.add(hub);
        }
      }

      return GopHubResult(
        phongDaCapNhat: phongHienTai,
        hubDaGop: hubDaGop,
        tongThanhVienSauGop: phongHienTai.soThanhVien,
      );
    }

    try {
      final db = FirebaseFirestore.instance;

      // 1. Lấy toàn bộ Hub từ Firestore để tìm Hub lân cận
      final allHubsSnapshot = await db.collection('hubs').get();
      final allHubs = allHubsSnapshot.docs
          .map((doc) => HubModel.fromJson({...doc.data(), 'MaHub': doc.id}))
          .toList();

      final nearbyHubs = allHubs.where((hub) {
        if (hub.maHub == hubGoc.maHub) return false;
        if (!hub.dangHoatDong) return false;
        final dist = _haversine(hubGoc.viDo, hubGoc.kinhDo, hub.viDo, hub.kinhDo);
        return dist <= banKinhMoRong;
      }).toList();

      if (nearbyHubs.isEmpty) {
        // Chỉ mở rộng bán kính phòng hiện tại
        final roomRef = db.collection('rooms').doc(phong.maPhong);
        final updatedRoom = phong.copyWith(
          banKinhHienTai: banKinhMoRong,
        );
        await roomRef.update({
          'BanKinhHienTai': banKinhMoRong,
        });
        return GopHubResult(
          phongDaCapNhat: updatedRoom,
          hubDaGop: [],
          tongThanhVienSauGop: updatedRoom.soThanhVien,
        );
      }

      // 2. Lấy tất cả phòng đang gom của các Hub lân cận
      final nearbyHubIds = nearbyHubs.map((h) => h.maHub).toList();
      final roomsSnapshot = await db.collection('rooms')
          .where('NgayGiao', isEqualTo: phong.ngayGiao)
          .where('TrangThaiPhong', isEqualTo: 'Đang gom')
          .get();

      final phongNguonList = roomsSnapshot.docs
          .map((doc) => RoomModel.fromJson({...doc.data(), 'MaPhong': doc.id}))
          .where((r) => nearbyHubIds.contains(r.maHubGoc) && r.soThanhVien < nguongGop)
          .toList();

      if (phongNguonList.isEmpty) {
        // Chỉ mở rộng bán kính phòng hiện tại
        final roomRef = db.collection('rooms').doc(phong.maPhong);
        final updatedRoom = phong.copyWith(
          banKinhHienTai: banKinhMoRong,
        );
        await roomRef.update({
          'BanKinhHienTai': banKinhMoRong,
        });
        return GopHubResult(
          phongDaCapNhat: updatedRoom,
          hubDaGop: [],
          tongThanhVienSauGop: updatedRoom.soThanhVien,
        );
      }

      // 3. Lấy tất cả đơn hàng của các phòng nguồn
      final phongNguonIds = phongNguonList.map((r) => r.maPhong).toList();
      final ordersSnapshot = await db.collection('orders')
          .where('MaPhong', whereIn: phongNguonIds)
          .get();

      final sourceOrders = ordersSnapshot.docs
          .map((doc) => OrderModel.fromJson({...doc.data(), 'MaDonHang': doc.id}))
          .toList();

      // 4. Lấy tất cả đơn hàng của phòng đích hiện tại để tính tổng số món ăn
      final destOrdersSnapshot = await db.collection('orders')
          .where('MaPhong', isEqualTo: phong.maPhong)
          .get();
      final destOrders = destOrdersSnapshot.docs
          .map((doc) => OrderModel.fromJson({...doc.data(), 'MaDonHang': doc.id}))
          .toList();

      // 5. Thực hiện Batch write cập nhật
      final batch = db.batch();

      // Đổi phòng cho các đơn hàng nguồn -> sang phòng đích
      for (final doc in ordersSnapshot.docs) {
        batch.update(doc.reference, {'MaPhong': phong.maPhong});
      }

      // Đánh dấu các phòng nguồn đã gộp
      for (final pr in phongNguonList) {
        batch.update(db.collection('rooms').doc(pr.maPhong), {'TrangThaiPhong': 'Da gop'});
      }

      // Tính toán thông tin phòng đích mới
      final hubDaGop = nearbyHubs.where((h) => phongNguonList.any((pr) => pr.maHubGoc == h.maHub)).toList();
      final hubGopMoiIds = [...phong.danhSachHubGop, ...hubDaGop.map((h) => h.maHub)];

      final soThanhVienMoi = phong.soThanhVien + sourceOrders.length;
      final totalItems = [...destOrders, ...sourceOrders]
          .fold<int>(0, (total, o) => total + o.danhSachMonAn.fold<int>(0, (s, i) => s + i.soLuong));

      final updatedRoom = phong.copyWith(
        banKinhHienTai: banKinhMoRong,
        soThanhVien: soThanhVienMoi,
        tongSoMon: totalItems,
        danhSachHubGop: hubGopMoiIds,
      );

      batch.update(db.collection('rooms').doc(phong.maPhong), {
        'BanKinhHienTai': banKinhMoRong,
        'SoThanhVien': soThanhVienMoi,
        'TongSoMon': totalItems,
        'DanhSachHubGop': hubGopMoiIds,
      });

      await batch.commit();

      return GopHubResult(
        phongDaCapNhat: updatedRoom,
        hubDaGop: hubDaGop,
        tongThanhVienSauGop: soThanhVienMoi,
      );
    } catch (e) {
      print('❌ Lỗi chayLogicGopHub Firestore: $e');
      return GopHubResult(
        phongDaCapNhat: phong,
        hubDaGop: [],
        tongThanhVienSauGop: phong.soThanhVien,
      );
    }
  }

  // ─────────────────────────────────────────────────────────────
  // UTILS — Haversine
  // ─────────────────────────────────────────────────────────────

  /// Tinh khoang cach (met) giua 2 toa do GPS bang cong thuc Haversine
  static double _haversine(
      double lat1, double lng1, double lat2, double lng2) {
    const double R = 6371000;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
            sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _toRad(double deg) => deg * pi / 180;

  /// Khoang cach (met) giua 2 Hub — tien ich public cho UI
  static double khoangCachGiuaHub(HubModel a, HubModel b) =>
      _haversine(a.viDo, a.kinhDo, b.viDo, b.kinhDo);
}
