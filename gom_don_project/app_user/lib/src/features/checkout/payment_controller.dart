import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/models/order_model.dart';
import 'package:shared/services/firebase_core.dart';
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

/// Controller: Xử lý thanh toán & tạm khóa tiền
class PaymentController {
  static final _random = Random();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
      phiShipThucTe: 0,
      tongTienMon: tongTienMon,
      soTienTamKhoa: soTienTamKhoa,
      maXacThuc: maPin,
      trangThaiDonHang: 'Chờ chốt',
      danhSachMonAn: danhSachMonAn,
    );

    if (!FirebaseCoreService.isInitialized) {
      await Future.delayed(const Duration(seconds: 1));
      MockData.addOrder(order);
      LoginController.currentUser = user.copyWith(soDuVi: user.soDuVi - soTienTamKhoa);
      return PlaceOrderResult(
        success: true,
        message: 'Đặt hàng thành công! (Chế độ giả lập)',
        maDonHang: maDon,
        maXacThuc: maPin,
      );
    }

    try {
      final userRef = _db.collection('users').doc(user.maKhachHang);
      final orderRef = _db.collection('orders').doc(maDon);
      final roomRef = _db.collection('rooms').doc(maPhong);

      await _db.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userRef);
        if (!userSnapshot.exists) throw Exception('Người dùng không tồn tại');
        
        final userData = userSnapshot.data()!;
        final currentBalance = (userData['SoDuVi'] ?? 0.0).toDouble();
        if (currentBalance < soTienTamKhoa) {
          throw Exception('Số dư ví không đủ!');
        }

        // 1. Trừ tiền ví trên Firestore
        transaction.update(userRef, {
          'SoDuVi': currentBalance - soTienTamKhoa,
        });

        // 2. Tạo tài liệu đơn hàng mới
        transaction.set(orderRef, order.toJson());

        // 3. Cập nhật thống kê thành viên & món ăn của phòng gom đơn
        final roomSnapshot = await transaction.get(roomRef);
        if (roomSnapshot.exists) {
          final roomData = roomSnapshot.data()!;
          final currentMembers = roomData['SoThanhVien'] ?? 0;
          final currentTotalItems = roomData['TongSoMon'] ?? 0;
          final itemsCount = danhSachMonAn.fold<int>(0, (s, i) => s + i.soLuong);

          transaction.update(roomRef, {
            'SoThanhVien': currentMembers + 1,
            'TongSoMon': currentTotalItems + itemsCount,
          });
        }
      });

      // Cập nhật lại số dư ví cục bộ của user đang đăng nhập
      LoginController.currentUser = user.copyWith(soDuVi: user.soDuVi - soTienTamKhoa);

      return PlaceOrderResult(
        success: true,
        message: 'Đặt hàng thành công!',
        maDonHang: maDon,
        maXacThuc: maPin,
      );
    } catch (e) {
      print('❌ Lỗi thucHienDatHang Firestore: $e');
      return PlaceOrderResult(
        success: false,
        message: 'Đặt hàng thất bại: $e',
      );
    }
  }
}
