import 'dart:math';
import 'package:shared/models/hub_model.dart';
import 'package:shared/models/room_model.dart';
import 'package:shared/test/mock_data.dart';

/// ============================================================
/// ROOM MERGER SERVICE — Logic Ban Kinh Dong & Gop Hub
/// ============================================================
///
/// Pipeline thuc thi:
///   1. Kiem tra gio: neu >= 9h30 → noi banKinhHienTai 500m → 1000m
///   2. Tim cac Hub lan can trong ban kinh 1000m cua Hub hien tai
///   3. Kiem tra Hub lan can co phong gom voi < [nguongGop] nguoi khong
///   4. Neu co → gop don cua phong Hub do vao phong Hub nay
///
/// TODO (Firebase): Thay mock data bang Firestore transaction de dam bao
/// tinh nhat quan khi nhieu thiet bi cung thuc hien gop.

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
  /// [giasLapNoRong]: che do debug — bo qua kiem tra gio that
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
  /// Cap nhat in-place vao mock data va tra ve phong moi
  ///
  /// TODO (Firebase): Dung Firestore transaction:
  /// await FirebaseFirestore.instance.runTransaction((tx) async {
  ///   tx.update(roomRef, {'BanKinhHienTai': 1000, 'DaMoRongBanKinh': true});
  /// });
  static RoomModel moRongBanKinh(RoomModel room) {
    final phongMoi = room.copyWith(
      banKinhHienTai: banKinhMoRong,
      daMoRongBanKinh: true,
    );
    // Cap nhat mock data in-place
    final idx = MockData.mockRooms.indexWhere((r) => r.maPhong == room.maPhong);
    if (idx != -1) MockData.mockRooms[idx] = phongMoi;
    return phongMoi;
  }

  // ─────────────────────────────────────────────────────────────
  // 3. TIM HUB LAN CAN
  // ─────────────────────────────────────────────────────────────

  /// Tim cac Hub nam trong ban kinh [banKinhMet] tu Hub goc
  /// Khong bao gom Hub goc, chi tra Hub dang hoat dong
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
  /// Dieu kien gop: phong dang gom + so thanh vien < nguongGop
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
  ///   - Chuyen tat ca don hang tu [phongNguon] sang [phongNhanHang]
  ///   - Danh dau [phongNguon] la "Da gop"
  ///   - Cap nhat thong ke [phongNhanHang]
  ///
  /// TODO (Firebase): Dung batch write de dam bao atomicity.
  static RoomModel gopVaoPhong({
    required RoomModel phongNguon,
    required RoomModel phongNhanHang,
  }) {
    // 1. Chuyen don hang qua method cua MockData (bao ve encapsulation)
    final soDonChuyen = MockData.moveOrdersBetweenRooms(
      maPhongNguon: phongNguon.maPhong,
      maPhongDich: phongNhanHang.maPhong,
    );

    // Lay cac don da chuyen de tinh tong mon
    final donMoi = MockData.getOrdersByRoom(phongNhanHang.maPhong);
    final soMonGop = donMoi
        .where((o) {
          // Tinh lai: chi dem nhung don moi duoc chuyen sang
          return true;
        })
        .fold<int>(0, (s, o) => s + o.danhSachMonAn.length);

    // 2. Danh dau phong nguon la "Da gop"
    final idxNguon = MockData.mockRooms
        .indexWhere((r) => r.maPhong == phongNguon.maPhong);
    if (idxNguon != -1) {
      MockData.mockRooms[idxNguon] = phongNguon.copyWith(
        trangThaiPhong: 'Da gop',
      );
    }

    // 3. Cap nhat phong dich: them Hub vao danhSachHubGop, cong thanh vien
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
  /// [giasLapNoRong]: che do debug, bo qua kiem tra gio that
  ///
  /// TODO (Firebase): Thay MockData.mockRooms bang Firestore query:
  /// final snapshot = await FirebaseFirestore.instance
  ///   .collection('rooms')
  ///   .where('MaHubGoc', isEqualTo: hubLanCan.maHub)
  ///   .where('NgayGiao', isEqualTo: ngayGiao)
  ///   .where('TrangThaiPhong', isEqualTo: 'Dang gom')
  ///   .get();
  static Future<GopHubResult> chayLogicGopHub(
    RoomModel phong,
    HubModel hubGoc, {
    bool giasLapNoRong = false,
  }) async {
    // Gia lap do tre I/O (thay bang Firestore query that)
    await Future.delayed(const Duration(milliseconds: 400));

    // Buoc 1: Kiem tra co den gio noi ban kinh chua
    if (!canNoRong(phong, giasLapNoRong: giasLapNoRong)) {
      return GopHubResult(
        phongDaCapNhat: phong,
        hubDaGop: [],
        tongThanhVienSauGop: phong.soThanhVien,
      );
    }

    // Buoc 2: Noi ban kinh 500m → 1000m
    RoomModel phongHienTai = moRongBanKinh(phong);

    // Buoc 3: Tim Hub lan can trong 1000m
    final hubLanCan = timHubTrongBanKinh(hubGoc, banKinhMoRong.toDouble());

    if (hubLanCan.isEmpty) {
      return GopHubResult(
        phongDaCapNhat: phongHienTai,
        hubDaGop: [],
        tongThanhVienSauGop: phongHienTai.soThanhVien,
      );
    }

    // Buoc 4+5: Kiem tra va gop tung Hub lan can
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
