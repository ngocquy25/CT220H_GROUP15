/// Model: Phòng Gom Đơn
/// Collection Firestore: rooms
/// Mỗi phòng = 1 Hub + 1 Ngày giao cụ thể
class RoomModel {
  final String maPhong;
  final String maHubGoc;           // Hub phòng này gom cho
  final String? maTaiXe;           // Nullable: chưa có tài xế khi đang gom
  final String? tenTaiXe;          // Tên tài xế (sau khi nhận chuyến)
  final String thoiGianTao;        // ISO String: "2026-07-07T08:00:00Z"
  final String ngayGiao;           // VD: "2026-07-08"
  final int banKinhHienTai;        // 500m → mở rộng 1000m lúc 9h30
  final String trangThaiPhong;     // "Đang gom" | "Thành công" | "Thất bại"
  final int soThanhVien;           // Số người đã vào phòng
  final int tongSoMon;             // Tổng số lượng món trong phòng
  final List<String> danhSachHubGop; // Danh sách các Hub đã gộp vào phòng này

  RoomModel({
    required this.maPhong,
    required this.maHubGoc,
    this.maTaiXe,
    this.tenTaiXe,
    required this.thoiGianTao,
    required this.ngayGiao,
    this.banKinhHienTai = 500,
    this.trangThaiPhong = 'Đang gom',
    this.soThanhVien = 0,
    this.tongSoMon = 0,
    this.danhSachHubGop = const [],
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      maPhong: json['MaPhong'] ?? '',
      maHubGoc: json['MaHubGoc'] ?? '',
      maTaiXe: json['MaTaiXe'],
      tenTaiXe: json['TenTaiXe'],
      thoiGianTao: json['ThoiGianTao'] ?? '',
      ngayGiao: json['NgayGiao'] ?? '',
      banKinhHienTai: json['BanKinhHienTai'] ?? 500,
      trangThaiPhong: json['TrangThaiPhong'] ?? 'Đang gom',
      soThanhVien: json['SoThanhVien'] ?? 0,
      tongSoMon: json['TongSoMon'] ?? 0,
      danhSachHubGop: List<String>.from(json['DanhSachHubGop'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'MaPhong': maPhong,
    'MaHubGoc': maHubGoc,
    'MaTaiXe': maTaiXe,
    'TenTaiXe': tenTaiXe,
    'ThoiGianTao': thoiGianTao,
    'NgayGiao': ngayGiao,
    'BanKinhHienTai': banKinhHienTai,
    'TrangThaiPhong': trangThaiPhong,
    'SoThanhVien': soThanhVien,
    'TongSoMon': tongSoMon,
    'DanhSachHubGop': danhSachHubGop,
  };

  RoomModel copyWith({
    String? maPhong,
    String? maHubGoc,
    String? maTaiXe,
    String? tenTaiXe,
    String? thoiGianTao,
    String? ngayGiao,
    int? banKinhHienTai,
    String? trangThaiPhong,
    int? soThanhVien,
    int? tongSoMon,
    List<String>? danhSachHubGop,
  }) {
    return RoomModel(
      maPhong: maPhong ?? this.maPhong,
      maHubGoc: maHubGoc ?? this.maHubGoc,
      maTaiXe: maTaiXe ?? this.maTaiXe,
      tenTaiXe: tenTaiXe ?? this.tenTaiXe,
      thoiGianTao: thoiGianTao ?? this.thoiGianTao,
      ngayGiao: ngayGiao ?? this.ngayGiao,
      banKinhHienTai: banKinhHienTai ?? this.banKinhHienTai,
      trangThaiPhong: trangThaiPhong ?? this.trangThaiPhong,
      soThanhVien: soThanhVien ?? this.soThanhVien,
      tongSoMon: tongSoMon ?? this.tongSoMon,
      danhSachHubGop: danhSachHubGop ?? this.danhSachHubGop,
    );
  }

  bool get dangGom => trangThaiPhong == 'Đang gom';
  bool get thanhCong => trangThaiPhong == 'Thành công';
  bool get thatBai => trangThaiPhong == 'Thất bại';
  bool get daNhanTaiXe => maTaiXe != null;
  bool get daMoRongBanKinh => banKinhHienTai > 500;
  bool get dangGopHub => danhSachHubGop.isNotEmpty;

  @override
  String toString() => 'RoomModel(ma: $maPhong, hub: $maHubGoc, ngayGiao: $ngayGiao, trangThai: $trangThaiPhong)';
}
