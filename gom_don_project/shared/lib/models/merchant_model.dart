/// Lớp con: Món ăn trong thực đơn quán
class FoodItem {
  final String maMon;
  final String tenMon;
  final int giaTien;        // VND
  final String? moTa;       // Mô tả món ăn
  final String? hinhAnh;    // URL hình ảnh món

  FoodItem({
    required this.maMon,
    required this.tenMon,
    required this.giaTien,
    this.moTa,
    this.hinhAnh,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      maMon: json['MaMon'] ?? '',
      tenMon: json['TenMon'] ?? '',
      giaTien: json['GiaTien'] ?? 0,
      moTa: json['MoTa'],
      hinhAnh: json['HinhAnh'],
    );
  }

  Map<String, dynamic> toJson() => {
    'MaMon': maMon,
    'TenMon': tenMon,
    'GiaTien': giaTien,
    'MoTa': moTa,
    'HinhAnh': hinhAnh,
  };

  @override
  String toString() => 'FoodItem($tenMon - ${giaTien}đ)';
}

/// Model chính: Quán ăn đối tác
/// Collection Firestore: merchants
class MerchantModel {
  final String maQuan;
  final String tenQuan;
  final String diaChi;            // Địa chỉ quán (ở trung tâm Ninh Kiều)
  final String tuyenGiaoHang;     // VD: "Ninh Kiều → Cái Răng"
  final double tyLeChietKhau;     // VD: 0.15 = 15%
  final List<FoodItem> thucDon;   // Danh sách món ăn
  final String? hinhAnhQuan;      // URL logo/ảnh quán
  final bool dangHoatDong;        // Quán có đang nhận đơn không
  final double danhGia;           // 1.0 - 5.0

  MerchantModel({
    required this.maQuan,
    required this.tenQuan,
    required this.diaChi,
    required this.tuyenGiaoHang,
    required this.tyLeChietKhau,
    required this.thucDon,
    this.hinhAnhQuan,
    this.dangHoatDong = true,
    this.danhGia = 4.5,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    var list = json['ThucDon'] as List? ?? [];
    List<FoodItem> menuList = list.map((i) => FoodItem.fromJson(i)).toList();

    return MerchantModel(
      maQuan: json['MaQuan'] ?? '',
      tenQuan: json['TenQuan'] ?? '',
      diaChi: json['DiaChi'] ?? '',
      tuyenGiaoHang: json['TuyenGiaoHang'] ?? '',
      tyLeChietKhau: (json['TyLeChietKhau'] ?? 0.0).toDouble(),
      thucDon: menuList,
      hinhAnhQuan: json['HinhAnhQuan'],
      dangHoatDong: json['DangHoatDong'] ?? true,
      danhGia: (json['DanhGia'] ?? 4.5).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'MaQuan': maQuan,
    'TenQuan': tenQuan,
    'DiaChi': diaChi,
    'TuyenGiaoHang': tuyenGiaoHang,
    'TyLeChietKhau': tyLeChietKhau,
    'ThucDon': thucDon.map((e) => e.toJson()).toList(),
    'HinhAnhQuan': hinhAnhQuan,
    'DangHoatDong': dangHoatDong,
    'DanhGia': danhGia,
  };

  @override
  String toString() => 'MerchantModel(ma: $maQuan, ten: $tenQuan, soMon: ${thucDon.length})';
}
