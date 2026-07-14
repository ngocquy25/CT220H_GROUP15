// app_admin/lib/features/mock_data_seeder.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MockDataSeeder {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> seedAllData() async {
    final batch = _db.batch();

    // ==========================================
    // 1. COLLECTION: ROOMS (Danh sách phòng gom)
    // ==========================================

    // ROOM_001: Phòng chuẩn (Thành công, chưa ai nhận) -> Cho tài xế test Nhận Chuyến
    batch.set(_db.collection('rooms').doc('ROOM_001'), {
      'MaPhong': 'ROOM_001',
      'MaHubGoc': 'HUB_NINHKIEU_01',
      'MaTaiXe': null,
      'ThoiGianTao': '2026-07-13T08:00:00Z',
      'BanKinhHienTai': 500,
      'TrangThaiPhong': 'Thành công',
    });

    // ROOM_002: Phòng đã bị tài xế khác giật mất -> Tài xế của mình ko được thấy
    batch.set(_db.collection('rooms').doc('ROOM_002'), {
      'MaPhong': 'ROOM_002',
      'MaHubGoc': 'HUB_NINHKIEU_01',
      'MaTaiXe': 'DRIVER_ANOTHER_999', // Đã có tài xế khác
      'ThoiGianTao': '2026-07-13T08:05:00Z',
      'BanKinhHienTai': 500,
      'TrangThaiPhong': 'Thành công',
    });

    // ROOM_003: Phòng được chỉ định cho tài xế của mình (Ví dụ ID của bạn là DRIVER_TEST)
    // Dùng để test màn hình Xác thực giao hàng (Nhập mã PIN/QR)
    batch.set(_db.collection('rooms').doc('ROOM_003'), {
      'MaPhong': 'ROOM_003',
      'MaHubGoc': 'HUB_NINHKIEU_01',
      'MaTaiXe': 'DRIVER_TEST', // Chính là tài xế đang test app
      'ThoiGianTao': '2026-07-13T08:10:00Z',
      'BanKinhHienTai': 500,
      'TrangThaiPhong': 'Thành công',
    });

    // ROOM_004: Phòng từ tháng trước -> Dùng để test đối soát dữ liệu cũ
    batch.set(_db.collection('rooms').doc('ROOM_004'), {
      'MaPhong': 'ROOM_004',
      'MaHubGoc': 'HUB_NINHKIEU_02',
      'MaTaiXe': 'DRIVER_TEST',
      'ThoiGianTao': '2026-06-20T08:00:00Z',
      'BanKinhHienTai': 500,
      'TrangThaiPhong': 'Thành công',
    });


    // ==========================================
    // 2. COLLECTION: ORDERS (Danh sách đơn chi tiết)
    // ==========================================

    // ĐƠN 1 (Thuộc ROOM_001 - Quán cơm tấm QUAN_001)
    batch.set(_db.collection('orders').doc('ORD_1001'), {
      'MaDonHang': 'ORD_1001',
      'MaPhong': 'ROOM_001',
      'MaKhachHang': 'KH_001',
      'TenKhachHang': 'Nguyễn Văn A',
      'SoDienThoaiKhach': '0901234567',
      'MaQuan': 'QA001',              // ✅ Khớp với MerchantLoginScreen
      'TenQuan': 'Cơm Tấm Bà Ba',      // ✅ Khớp với MerchantLoginScreen
      'MaTaiXe': null,
      'TenTaiXe': null,
      'ThoiGianDat': '2026-07-13T08:15:00Z',
      'NgayGiao': '2026-07-13',
      'LuaChonCaiDat': 'Chắc chắn ăn',
      'PhiShipGoc': 15000,
      'PhiShipThucTe': 5000,
      'TongTienMon': 45000,
      'SoTienTamKhoa': 60000,
      'MaXacThuc': '1234',
      'TrangThaiDonHang': 'Thành công',
      'DanhSachMonAn': [
        {'MaMon': 'MON_01', 'TenMon': 'Cơm sườn trứng', 'SoLuong': 2, 'GiaTien': 45000, 'GhiChuMon': 'Nhiều mỡ hành'}
      ]
    });

    // ĐƠN 2 (Cũng thuộc ROOM_001 nhưng của quán trà sữa QUAN_002)
    // TEST: Chủ quán QUAN_001 vào Dashboard KHÔNG được thấy đơn này!
    batch.set(_db.collection('orders').doc('ORD_1002'), {
      'MaDonHang': 'ORD_1002',
      'MaPhong': 'ROOM_001',
      'MaKhachHang': 'KH_002',
      'TenKhachHang': 'Trần Thị B',
      'SoDienThoaiKhach': '0987654321',
      'MaQuan': 'QA002',              // ✅ Khớp với MerchantLoginScreen
      'TenQuan': 'Bún Bò Huế Cô Hạnh', // ✅ Khớp với MerchantLoginScreen
      'MaTaiXe': null,
      'TenTaiXe': null,
      'ThoiGianDat': '2026-07-13T08:20:00Z',
      'NgayGiao': '2026-07-13',
      'LuaChonCaiDat': 'Đảm bảo rẻ',
      'PhiShipGoc': 15000,
      'PhiShipThucTe': 5000,
      'TongTienMon': 30000,
      'SoTienTamKhoa': 45000,
      'MaXacThuc': '5678',
      'TrangThaiDonHang': 'Thành công',
      'DanhSachMonAn': [
        {'MaMon': 'TS_01', 'TenMon': 'Trà sữa trân châu', 'SoLuong': 1, 'GiaTien': 30000, 'GhiChuMon': '70% đường'}
      ]
    });

    // ĐƠN 3 (Thuộc ROOM_003 - Dành cho tài xế DRIVER_TEST xác thực giao hàng)
    batch.set(_db.collection('orders').doc('ORD_1003'), {
      'MaDonHang': 'ORD_1003',
      'MaPhong': 'ROOM_003',
      'MaKhachHang': 'KH_003',
      'TenKhachHang': 'Lê Hoàng C',
      'SoDienThoaiKhach': '0911223344',
      'MaQuan': 'QA001',              // ✅ Khớp với MerchantLoginScreen
      'TenQuan': 'Cơm Tấm Bà Ba',      // ✅ Khớp với MerchantLoginScreen
      'MaTaiXe': 'DRIVER_TEST',
      'TenTaiXe': 'Tài Xế Nghiệm Thu B',
      'ThoiGianDat': '2026-07-13T08:25:00Z',
      'NgayGiao': '2026-07-13',
      'LuaChonCaiDat': 'Chắc chắn ăn',
      'PhiShipGoc': 15000,
      'PhiShipThucTe': 5000,
      'TongTienMon': 45000,
      'SoTienTamKhoa': 60000,
      'MaXacThuc': '9999',
      'TrangThaiDonHang': 'Thành công',
      'DanhSachMonAn': [
        {'MaMon': 'MON_01', 'TenMon': 'Cơm sườn trứng', 'SoLuong': 1, 'GiaTien': 45000, 'GhiChuMon': 'Ít cơm'}
      ]
    });

    // ĐƠN 4 (Thuộc ROOM_004 - Dữ liệu cũ tháng 6 để test đối soát Excel của Admin)
    batch.set(_db.collection('orders').doc('ORD_OLD_01'), {
      'MaDonHang': 'ORD_OLD_01',
      'MaPhong': 'ROOM_004',
      'MaKhachHang': 'KH_001',
      'TenKhachHang': 'Nguyễn Văn A',
      'SoDienThoaiKhach': '0901234567',
      'MaQuan': 'QA001',              // ✅ Khớp với MerchantLoginScreen
      'TenQuan': 'Cơm Tấm Bà Ba',      // ✅ Khớp với MerchantLoginScreen
      'MaTaiXe': 'DRIVER_TEST',
      'TenTaiXe': 'Tài Xế Nghiệm Thu B',
      'ThoiGianDat': '2026-06-20T08:15:00Z',
      'NgayGiao': '2026-06-20',
      'LuaChonCaiDat': 'Chắc chắn ăn',
      'PhiShipGoc': 15000,
      'PhiShipThucTe': 3000,
      'TongTienMon': 90000,
      'SoTienTamKhoa': 105000,
      'MaXacThuc': '1111',
      'TrangThaiDonHang': 'Đã giao',
      'DanhSachMonAn': [
        {'MaMon': 'MON_01', 'TenMon': 'Cơm sườn trứng', 'SoLuong': 2, 'GiaTien': 45000, 'GhiChuMon': null}
      ]
    });

    // Thực thi đẩy toàn bộ lên Firestore trong 1 request duy nhất
    await batch.commit();
    print("=======> MOCK DATA UPLOADED SUCCESSFULLY! <=======");
  }
}