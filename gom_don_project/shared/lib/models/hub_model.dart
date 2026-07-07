/// Model: Hub (Cụm điểm giao hàng cố định)
/// Collection Firestore: hubs
/// Mỗi Hub là một tòa nhà / công ty có điểm giao hàng cố định
class HubModel {
  final String maHub;
  final String tenHub;         // VD: "Tòa nhà Viettel Cần Thơ"
  final double kinhDo;         // Longitude (x)
  final double viDo;           // Latitude (y)
  final int banKinhMacDinh;    // Bán kính nhận diện (mặc định 500m)
  final String diaChi;         // Địa chỉ đầy đủ
  final bool dangHoatDong;     // Hub có đang hoạt động không

  HubModel({
    required this.maHub,
    required this.tenHub,
    required this.kinhDo,
    required this.viDo,
    this.banKinhMacDinh = 500,
    this.diaChi = '',
    this.dangHoatDong = true,
  });

  factory HubModel.fromJson(Map<String, dynamic> json) {
    return HubModel(
      maHub: json['MaHub'] ?? '',
      tenHub: json['TenHub'] ?? '',
      kinhDo: (json['KinhDo'] ?? 0.0).toDouble(),
      viDo: (json['ViDo'] ?? 0.0).toDouble(),
      banKinhMacDinh: json['BanKinhMacDinh'] ?? 500,
      diaChi: json['DiaChi'] ?? '',
      dangHoatDong: json['DangHoatDong'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'MaHub': maHub,
    'TenHub': tenHub,
    'KinhDo': kinhDo,
    'ViDo': viDo,
    'BanKinhMacDinh': banKinhMacDinh,
    'DiaChi': diaChi,
    'DangHoatDong': dangHoatDong,
  };

  @override
  String toString() => 'HubModel(ma: $maHub, ten: $tenHub, lat: $viDo, lng: $kinhDo)';
}
