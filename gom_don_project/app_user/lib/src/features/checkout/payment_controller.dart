import 'dart:math';
import 'package:shared/models/order_model.dart';
import 'package:shared/test/mock_data.dart';
import '../auth/login_controller.dart';
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
  String _taoMaPin() => (_random.nextInt(9000) + 1000).toString();

  /// Tạo mã đơn hàng dựa theo timestamp
  String _taoMaDon() => 'DH${DateTime.now().millisecondsSinceEpoch}';

  /// Thực hiện đặt hàng & giả lập tạm khóa tiền
  Future<PlaceOrderResult> thucHienDatHang({
    required int tongTienMon,
    required int phiShipGoc,
    required String luaChon,
    required List<OrderItem> danhSachMonAn,
    String maQuan = 'QA001',
    String tenQuan = 'Quán ăn',
    String maPhong = 'PHONG001',
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // 1. Lấy user đang đăng nhập
    final user = LoginController.currentUser;
    if (user == null) {
      return PlaceOrderResult(
        success: false,
        message: '❌ Vui lòng đăng nhập trước!',
      );
    }

    // 2. Kiểm tra ví đã kết nối chưa
    if (user.trangThaiVi == 'disconnected') {
      return PlaceOrderResult(
        success: false,
        message: '❌ Ví chưa được kết nối. Vui lòng kết nối ví trong phần Hồ sơ!',
      );
    }

    // 3. Kiểm tra số dư đủ không
    final soTienTamKhoa = tongTienMon + phiShipGoc;
    if (user.soDuVi < soTienTamKhoa) {
      return PlaceOrderResult(
        success: false,
        message: '❌ Số dư ví không đủ! Cần ${TimeHelper.formatVND(soTienTamKhoa)}, '
            'hiện có ${TimeHelper.formatVND(user.soDuVi.toInt())}',
      );
    }

    // 4. Tạo đơn hàng & lưu vào mock data
    final maPin = _taoMaPin();
    final maDon = _taoMaDon();

    final order = OrderModel(
      maDonHang: maDon,
      maPhong: maPhong,
      maKhachHang: user.maKhachHang,
      tenKhachHang: user.tenKhachHang,
      soDienThoaiKhach: user.soDienThoai,
      maQuan: maQuan,
      tenQuan: tenQuan,
      thoiGianDat: DateTime.now().toIso8601String(),
      ngayGiao: TimeHelper.tinhNgayGiao(),
      luaChonCaiDat: luaChon,
      phiShipGoc: phiShipGoc,
      phiShipThucTe: 0, // Sẽ được tính sau 10h00
      tongTienMon: tongTienMon,
      soTienTamKhoa: soTienTamKhoa,
      maXacThuc: maPin,
      trangThaiDonHang: 'Chờ chốt',
      danhSachMonAn: danhSachMonAn,
    );

    // TODO: Đẩy lên Firestore:
    // await FirebaseFirestore.instance.collection('orders').doc(maDon).set(order.toJson());
    MockData.addOrder(order);

    return PlaceOrderResult(
      success: true,
      message: 'Đặt hàng thành công!',
      maDonHang: maDon,
      maXacThuc: maPin,
    );
  }
}
