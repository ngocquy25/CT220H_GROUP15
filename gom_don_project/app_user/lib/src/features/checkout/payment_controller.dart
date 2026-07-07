import 'dart:math';
import 'package:shared/models/order_model.dart';
import 'package:shared/models/user_model.dart';
import 'package:shared/test/mock_data.dart';
import '../../core/utils/time_helper.dart';

/// Kết quả sau khi đặt hàng
class PlaceOrderResult {
  final bool success;
  final String message;
  final String? maDonHang;
  final String? maXacThuc; // Mã PIN 4 số

  PlaceOrderResult({
    required this.success,
    required this.message,
    this.maDonHang,
    this.maXacThuc,
  });
}

/// Controller: Xử lý thanh toán & tạm khóa tiền (Mock)
class PaymentController {
  static final _random = Random();

  /// Tạo mã PIN 4 số ngẫu nhiên
  String _taoMaPin() => _random.nextInt(9000).abs().toString().padLeft(4, '0');

  /// Tạo mã đơn hàng ngẫu nhiên
  String _taoMaDon() => 'DH${DateTime.now().millisecondsSinceEpoch}';

  /// Thực hiện đặt hàng & giả lập tạm khóa tiền
  Future<PlaceOrderResult> thucHienDatHang({
    required int tongTienMon,
    required int phiShipGoc,
    required String luaChon,
    String maKhachHang = 'KH001', // Mock: dùng user đầu tiên
    String maQuan = 'QA001',
    String maPhong = 'PHONG001',
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // 1. Kiểm tra ví đã kết nối chưa
    final user = MockData.mockUsers.firstWhere(
      (u) => u.maKhachHang == maKhachHang,
      orElse: () => MockData.mockUsers.first,
    );

    if (user.trangThaiVi == 'disconnected') {
      return PlaceOrderResult(
        success: false,
        message: '❌ Ví chưa được kết nối. Vui lòng liên kết ví MoMo/Ngân hàng trước!',
      );
    }

    // 2. Kiểm tra số dư đủ không
    final soTienTamKhoa = tongTienMon + phiShipGoc;
    if (user.soDuVi < soTienTamKhoa) {
      return PlaceOrderResult(
        success: false,
        message: '❌ Số dư ví không đủ! Cần ${soTienTamKhoa}đ, hiện có ${user.soDuVi.toInt()}đ',
      );
    }

    // 3. Tạo đơn hàng
    final maPin = _taoMaPin();
    final maDon = _taoMaDon();
    final merchant = MockData.getMerchantById(maQuan);

    final order = OrderModel(
      maDonHang: maDon,
      maPhong: maPhong,
      maKhachHang: maKhachHang,
      tenKhachHang: user.tenKhachHang,
      soDienThoaiKhach: user.soDienThoai,
      maQuan: maQuan,
      tenQuan: merchant?.tenQuan ?? 'Quán ăn',
      thoiGianDat: DateTime.now().toIso8601String(),
      ngayGiao: TimeHelper.tinhNgayGiao(),
      luaChonCaiDat: luaChon,
      phiShipGoc: phiShipGoc,
      tongTienMon: tongTienMon,
      soTienTamKhoa: soTienTamKhoa,
      maXacThuc: maPin,
      trangThaiDonHang: 'Chờ chốt',
      danhSachMonAn: [],
    );

    // TODO: Đẩy lên Firestore:
    // await FirebaseFirestore.instance.collection('orders').doc(maDon).set(order.toJson());

    print('✅ [MOCK] Đặt hàng thành công: ${order.toJson()}');

    return PlaceOrderResult(
      success: true,
      message: 'Đặt hàng thành công!',
      maDonHang: maDon,
      maXacThuc: maPin,
    );
  }
}
