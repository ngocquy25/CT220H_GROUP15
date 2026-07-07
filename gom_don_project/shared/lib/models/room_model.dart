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
  };

  bool get dangGom => trangThaiPhong == 'Đang gom';
  bool get thanhCong => trangThaiPhong == 'Thành công';
  bool get thatBai => trangThaiPhong == 'Thất bại';
  bool get daNhanTaiXe => maTaiXe != null;

  @override
  String toString() => 'RoomModel(ma: $maPhong, hub: $maHubGoc, ngayGiao: $ngayGiao, trangThai: $trangThaiPhong)';
}
