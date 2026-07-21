/// Model: Người dùng / Khách hàng
/// Collection Firestore: users
class UserModel {
  final String maKhachHang;
  final String tenKhachHang;
  final String soDienThoai;
  final String email;
  final double soDuVi;           // Số dư ví (VND)
  final String trangThaiVi;      // "connected" hoặc "disconnected"
  final String? maHubDaChon;     // Hub khách đã chọn (lưu từ session)
  final String luaChonMacDinh;   // "Chắc chắn ăn" hoặc "Đảm bảo rẻ"
  final String matKhau;          // Mật khẩu (dùng cho mock auth)

  UserModel({
    required this.maKhachHang,
    required this.tenKhachHang,
    required this.soDienThoai,
    this.email = '',
    this.soDuVi = 0.0,
    this.trangThaiVi = 'disconnected',
    this.maHubDaChon,
    this.luaChonMacDinh = 'Chắc chắn ăn',
    this.matKhau = '123456',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      maKhachHang: json['MaKhachHang'] ?? '',
      tenKhachHang: json['TenKhachHang'] ?? '',
      soDienThoai: json['SoDienThoai'] ?? '',
      email: json['Email'] ?? '',
      soDuVi: (json['SoDuVi'] ?? 0.0).toDouble(),
      trangThaiVi: json['TrangThaiVi'] ?? 'disconnected',
      maHubDaChon: json['MaHubDaChon'],
      luaChonMacDinh: json['LuaChonMacDinh'] ?? 'Chắc chắn ăn',
      matKhau: json['MatKhau'] ?? '123456',
    );
  }

  Map<String, dynamic> toJson() => {
    'MaKhachHang': maKhachHang,
    'TenKhachHang': tenKhachHang,
    'SoDienThoai': soDienThoai,
    'Email': email,
    'SoDuVi': soDuVi,
    'TrangThaiVi': trangThaiVi,
    'MaHubDaChon': maHubDaChon,
    'LuaChonMacDinh': luaChonMacDinh,
    'MatKhau': matKhau,
  };

  UserModel copyWith({
    String? maKhachHang,
    String? tenKhachHang,
    String? soDienThoai,
    String? email,
    double? soDuVi,
    String? trangThaiVi,
    String? maHubDaChon,
    String? luaChonMacDinh,
    String? matKhau,
  }) {
    return UserModel(
      maKhachHang: maKhachHang ?? this.maKhachHang,
      tenKhachHang: tenKhachHang ?? this.tenKhachHang,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      email: email ?? this.email,
      soDuVi: soDuVi ?? this.soDuVi,
      trangThaiVi: trangThaiVi ?? this.trangThaiVi,
      maHubDaChon: maHubDaChon ?? this.maHubDaChon,
      luaChonMacDinh: luaChonMacDinh ?? this.luaChonMacDinh,
      matKhau: matKhau ?? this.matKhau,
    );
  }

  @override
  String toString() => 'UserModel(ma: $maKhachHang, ten: $tenKhachHang, vi: $soDuVi VND)';
}
