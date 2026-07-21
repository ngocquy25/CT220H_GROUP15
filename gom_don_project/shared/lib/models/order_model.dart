/// Lớp con: Chi tiết 1 món trong đơn hàng
class OrderItem {
  final String maMon;
  final String tenMon;
  final int soLuong;
  final int giaTien;         // Đơn giá (VND)
  final String? ghiChuMon;  // Ghi chú riêng: "Ít cơm", "Không hành"...

  OrderItem({
    required this.maMon,
    required this.tenMon,
    required this.soLuong,
    required this.giaTien,
    this.ghiChuMon,
  });

  int get thanhTien => soLuong * giaTien;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      maMon: json['MaMon'] ?? '',
      tenMon: json['TenMon'] ?? '',
      soLuong: json['SoLuong'] ?? 1,
      giaTien: json['GiaTien'] ?? 0,
      ghiChuMon: json['GhiChuMon'],
    );
  }

  Map<String, dynamic> toJson() => {
    'MaMon': maMon,
    'TenMon': tenMon,
    'SoLuong': soLuong,
    'GiaTien': giaTien,
    'GhiChuMon': ghiChuMon,
  };

  OrderItem copyWith({
    String? maMon,
    String? tenMon,
    int? soLuong,
    int? giaTien,
    String? ghiChuMon,
  }) {
    return OrderItem(
      maMon: maMon ?? this.maMon,
      tenMon: tenMon ?? this.tenMon,
      soLuong: soLuong ?? this.soLuong,
      giaTien: giaTien ?? this.giaTien,
      ghiChuMon: ghiChuMon ?? this.ghiChuMon,
    );
  }

  @override
  String toString() => 'OrderItem($tenMon x$soLuong = ${thanhTien}đ)';
}

/// Model chính: Đơn hàng cá nhân
/// Collection Firestore: orders
class OrderModel {
  final String maDonHang;
  final String maPhong;           // Phòng gom mà đơn này thuộc về

  // ── Thông tin khách hàng ──────────────────────────────
  final String maKhachHang;
  final String tenKhachHang;
  final String soDienThoaiKhach;

  // ── Thông tin quán ăn ────────────────────────────────
  final String maQuan;
  final String tenQuan;

  // ── Thông tin tài xế (trống khi đang gom) ────────────
  final String? maTaiXe;
  final String? tenTaiXe;

  // ── Thời gian ────────────────────────────────────────
  final String thoiGianDat;      // ISO: "2026-07-07T08:30:15Z"
  final String ngayGiao;          // VD: "2026-07-07"

  // ── Cấu hình & Tài chính ─────────────────────────────
  final String luaChonCaiDat;    // "Chắc chắn ăn" | "Đảm bảo rẻ"
  final int phiShipGoc;          // Phí ship khi đi 1 mình (VND)
  final int phiShipThucTe;       // Phí ship thực tế sau chia (VND)
  final int tongTienMon;         // Tổng tiền món ăn (VND)
  final int soTienTamKhoa;       // = tongTienMon + phiShipGoc (tạm đóng băng)
  final String maXacThuc;        // Mã PIN 4 số để tài xế xác nhận giao hàng

  // ── Trạng thái ──────────────────────────────────────
  final String trangThaiDonHang; // "Chờ chốt" | "Thành công" | "Đã hủy tự động" | "Đã giao"

  // ── Danh sách món đặt ───────────────────────────────
  final List<OrderItem> danhSachMonAn;

  OrderModel({
    required this.maDonHang,
    required this.maPhong,
    required this.maKhachHang,
    required this.tenKhachHang,
    required this.soDienThoaiKhach,
    required this.maQuan,
    required this.tenQuan,
    this.maTaiXe,
    this.tenTaiXe,
    required this.thoiGianDat,
    required this.ngayGiao,
    required this.luaChonCaiDat,
    required this.phiShipGoc,
    this.phiShipThucTe = 0,
    required this.tongTienMon,
    required this.soTienTamKhoa,
    required this.maXacThuc,
    this.trangThaiDonHang = 'Chờ chốt',
    required this.danhSachMonAn,
  });

  /// Tổng tiền thực tế phải trả (sau chốt đơn)
  int get tongThanhToan => tongTienMon + phiShipThucTe;

  /// Tiền được hoàn (phần ship được giảm sau gom thành công)
  int get tienDuocHoan => soTienTamKhoa - tongThanhToan;

  bool get choChot => trangThaiDonHang == 'Chờ chốt';
  bool get thanhCong => trangThaiDonHang == 'Thành công';
  bool get daGiao => trangThaiDonHang == 'Đã giao';
  bool get daHuy => trangThaiDonHang == 'Đã hủy tự động';

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var list = json['DanhSachMonAn'] as List? ?? [];
    List<OrderItem> itemsList = list.map((i) => OrderItem.fromJson(i)).toList();

    return OrderModel(
      maDonHang: json['MaDonHang'] ?? '',
      maPhong: json['MaPhong'] ?? '',
      maKhachHang: json['MaKhachHang'] ?? '',
      tenKhachHang: json['TenKhachHang'] ?? '',
      soDienThoaiKhach: json['SoDienThoaiKhach'] ?? '',
      maQuan: json['MaQuan'] ?? '',
      tenQuan: json['TenQuan'] ?? '',
      maTaiXe: json['MaTaiXe'],
      tenTaiXe: json['TenTaiXe'],
      thoiGianDat: json['ThoiGianDat'] ?? '',
      ngayGiao: json['NgayGiao'] ?? '',
      luaChonCaiDat: json['LuaChonCaiDat'] ?? 'Chắc chắn ăn',
      phiShipGoc: json['PhiShipGoc'] ?? 0,
      phiShipThucTe: json['PhiShipThucTe'] ?? 0,
      tongTienMon: json['TongTienMon'] ?? 0,
      soTienTamKhoa: json['SoTienTamKhoa'] ?? 0,
      maXacThuc: json['MaXacThuc'] ?? '',
      trangThaiDonHang: json['TrangThaiDonHang'] ?? 'Chờ chốt',
      danhSachMonAn: itemsList,
    );
  }

  Map<String, dynamic> toJson() => {
    'MaDonHang': maDonHang,
    'MaPhong': maPhong,
    'MaKhachHang': maKhachHang,
    'TenKhachHang': tenKhachHang,
    'SoDienThoaiKhach': soDienThoaiKhach,
    'MaQuan': maQuan,
    'TenQuan': tenQuan,
    'MaTaiXe': maTaiXe,
    'TenTaiXe': tenTaiXe,
    'ThoiGianDat': thoiGianDat,
    'NgayGiao': ngayGiao,
    'LuaChonCaiDat': luaChonCaiDat,
    'PhiShipGoc': phiShipGoc,
    'PhiShipThucTe': phiShipThucTe,
    'TongTienMon': tongTienMon,
    'SoTienTamKhoa': soTienTamKhoa,
    'MaXacThuc': maXacThuc,
    'TrangThaiDonHang': trangThaiDonHang,
    'DanhSachMonAn': danhSachMonAn.map((e) => e.toJson()).toList(),
  };

  OrderModel copyWith({
    String? maDonHang,
    String? maPhong,
    String? maKhachHang,
    String? tenKhachHang,
    String? soDienThoaiKhach,
    String? maQuan,
    String? tenQuan,
    String? maTaiXe,
    String? tenTaiXe,
    String? thoiGianDat,
    String? ngayGiao,
    String? luaChonCaiDat,
    int? phiShipGoc,
    int? phiShipThucTe,
    int? tongTienMon,
    int? soTienTamKhoa,
    String? maXacThuc,
    String? trangThaiDonHang,
    List<OrderItem>? danhSachMonAn,
  }) {
    return OrderModel(
      maDonHang: maDonHang ?? this.maDonHang,
      maPhong: maPhong ?? this.maPhong,
      maKhachHang: maKhachHang ?? this.maKhachHang,
      tenKhachHang: tenKhachHang ?? this.tenKhachHang,
      soDienThoaiKhach: soDienThoaiKhach ?? this.soDienThoaiKhach,
      maQuan: maQuan ?? this.maQuan,
      tenQuan: tenQuan ?? this.tenQuan,
      maTaiXe: maTaiXe ?? this.maTaiXe,
      tenTaiXe: tenTaiXe ?? this.tenTaiXe,
      thoiGianDat: thoiGianDat ?? this.thoiGianDat,
      ngayGiao: ngayGiao ?? this.ngayGiao,
      luaChonCaiDat: luaChonCaiDat ?? this.luaChonCaiDat,
      phiShipGoc: phiShipGoc ?? this.phiShipGoc,
      phiShipThucTe: phiShipThucTe ?? this.phiShipThucTe,
      tongTienMon: tongTienMon ?? this.tongTienMon,
      soTienTamKhoa: soTienTamKhoa ?? this.soTienTamKhoa,
      maXacThuc: maXacThuc ?? this.maXacThuc,
      trangThaiDonHang: trangThaiDonHang ?? this.trangThaiDonHang,
      danhSachMonAn: danhSachMonAn ?? this.danhSachMonAn,
    );
  }

  @override
  String toString() => 'OrderModel(ma: $maDonHang, khach: $tenKhachHang, trangThai: $trangThaiDonHang)';
}
