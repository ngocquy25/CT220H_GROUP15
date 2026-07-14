import 'package:shared/models/user_model.dart';
import 'package:shared/models/hub_model.dart';
import 'package:shared/models/room_model.dart';
import 'package:shared/models/merchant_model.dart';
import 'package:shared/models/order_model.dart';

/// ============================================================
/// MOCK DATA - Dữ liệu giả lập để kiểm thử (không cần Firebase)
/// ============================================================
/// Sử dụng: import file này trong màn hình cần test
/// VD: final merchants = MockData.mockMerchants;

class MockData {
  // ─────────────────────────────────────────────────────────
  // 1. DANH SÁCH HUB (3 Hub tại Cần Thơ)
  // ─────────────────────────────────────────────────────────
  static final List<HubModel> mockHubs = [
    HubModel(
      maHub: 'HUB001',
      tenHub: 'Tòa nhà Viettel Cần Thơ',
      kinhDo: 105.7469,
      viDo: 10.0341,
      banKinhMacDinh: 500,
      diaChi: '166 Trần Hưng Đạo, Ninh Kiều, Cần Thơ',
      dangHoatDong: true,
    ),
    HubModel(
      maHub: 'HUB002',
      tenHub: 'Co.opMart Hưng Lợi',
      kinhDo: 105.7701,
      viDo: 10.0183,
      banKinhMacDinh: 500,
      diaChi: 'Khu dân cư Hưng Lợi, Ninh Kiều, Cần Thơ',
      dangHoatDong: true,
    ),
    HubModel(
      maHub: 'HUB003',
      tenHub: 'FPT Software Cần Thơ',
      kinhDo: 105.7800,
      viDo: 10.0290,
      banKinhMacDinh: 500,
      diaChi: 'Khu phần mềm Quang Trung, Cần Thơ',
      dangHoatDong: true,
    ),
  ];

  // ─────────────────────────────────────────────────────────
  // 2. DANH SÁCH NGƯỜI DÙNG / KHÁCH HÀNG (4 users)
  // ─────────────────────────────────────────────────────────
  static final List<UserModel> mockUsers = [
    UserModel(
      maKhachHang: 'KH001',
      tenKhachHang: 'Nguyễn Văn An',
      soDienThoai: '0901234567',
      email: 'an.nguyen@gmail.com',
      soDuVi: 500000,
      trangThaiVi: 'connected',
      maHubDaChon: 'HUB001',
      luaChonMacDinh: 'Chắc chắn ăn',
    ),
    UserModel(
      maKhachHang: 'KH002',
      tenKhachHang: 'Trần Thị Bích',
      soDienThoai: '0912345678',
      email: 'bich.tran@gmail.com',
      soDuVi: 320000,
      trangThaiVi: 'connected',
      maHubDaChon: 'HUB001',
      luaChonMacDinh: 'Đảm bảo rẻ',
    ),
    UserModel(
      maKhachHang: 'KH003',
      tenKhachHang: 'Lê Minh Châu',
      soDienThoai: '0923456789',
      email: 'chau.le@gmail.com',
      soDuVi: 800000,
      trangThaiVi: 'connected',
      maHubDaChon: 'HUB002',
      luaChonMacDinh: 'Đảm bảo rẻ',
    ),
    UserModel(
      maKhachHang: 'KH004',
      tenKhachHang: 'Phạm Quốc Dũng',
      soDienThoai: '0934567890',
      email: 'dung.pham@gmail.com',
      soDuVi: 150000,
      trangThaiVi: 'disconnected',
      maHubDaChon: null,
      luaChonMacDinh: 'Chắc chắn ăn',
    ),
  ];

  // ─────────────────────────────────────────────────────────
  // 3. DANH SÁCH QUÁN ĂN & THỰC ĐƠN (3 quán tại Ninh Kiều)
  // ─────────────────────────────────────────────────────────
  static final List<MerchantModel> mockMerchants = [
    MerchantModel(
      maQuan: 'QA001',
      tenQuan: 'Cơm Tấm Bà Ba',
      diaChi: '45 Ngô Đức Kế, Ninh Kiều, Cần Thơ',
      tuyenGiaoHang: 'Ninh Kiều → Hưng Lợi → FPT',
      tyLeChietKhau: 0.15,
      danhGia: 4.8,
      dangHoatDong: true,
      thucDon: [
        FoodItem(maMon: 'M001', tenMon: 'Cơm tấm sườn bì chả', giaTien: 45000,
            moTa: 'Sườn nướng than hoa, bì sợi, chả hấp, dưa chua, nước mắm đặc biệt'),
        FoodItem(maMon: 'M002', tenMon: 'Cơm tấm sườn nướng', giaTien: 40000,
            moTa: 'Sườn non nướng lửa than, rau xà lách, cà chua, nước mắm'),
        FoodItem(maMon: 'M003', tenMon: 'Cơm tấm bì chả', giaTien: 38000,
            moTa: 'Bì sợi dai ngon, chả hấp mịn, dưa leo'),
        FoodItem(maMon: 'M004', tenMon: 'Nước mía tươi', giaTien: 15000,
            moTa: 'Ép tươi mỗi ly, thêm tắc, đá viên'),
      ],
    ),
    MerchantModel(
      maQuan: 'QA002',
      tenQuan: 'Bún Bò Huế Cô Hạnh',
      diaChi: '12 Mậu Thân, Ninh Kiều, Cần Thơ',
      tuyenGiaoHang: 'Ninh Kiều → Viettel → FPT',
      tyLeChietKhau: 0.12,
      danhGia: 4.6,
      dangHoatDong: true,
      thucDon: [
        FoodItem(maMon: 'M005', tenMon: 'Bún bò Huế đặc biệt', giaTien: 55000,
            moTa: 'Giò heo, bắp bò, chả, huyết, nước dùng sả ớt đậm đà'),
        FoodItem(maMon: 'M006', tenMon: 'Bún bò Huế thường', giaTien: 45000,
            moTa: 'Thịt bò, nước dùng sả ớt truyền thống'),
        FoodItem(maMon: 'M007', tenMon: 'Bún riêu cua', giaTien: 50000,
            moTa: 'Cua đồng tươi, đậu phụ chiên, cà chua chín'),
        FoodItem(maMon: 'M008', tenMon: 'Trà đá chanh', giaTien: 10000,
            moTa: 'Trà xanh pha đá, vắt chanh tươi'),
      ],
    ),
    MerchantModel(
      maQuan: 'QA003',
      tenQuan: 'Cháo Ếch Singapore Tám Liên',
      diaChi: '88 Lý Tự Trọng, Ninh Kiều, Cần Thơ',
      tuyenGiaoHang: 'Ninh Kiều → Co.opMart Hưng Lợi',
      tyLeChietKhau: 0.10,
      danhGia: 4.3,
      dangHoatDong: true,
      thucDon: [
        FoodItem(maMon: 'M009', tenMon: 'Cháo ếch Singapore', giaTien: 65000,
            moTa: 'Ếch phi lê, cháo trắng loãng, hành lá, gừng thái chỉ'),
        FoodItem(maMon: 'M010', tenMon: 'Cháo gà xé phay', giaTien: 55000,
            moTa: 'Gà ta luộc xé phay, cháo đặc, hành ngò'),
        FoodItem(maMon: 'M011', tenMon: 'Hủ tiếu Nam Vang', giaTien: 50000,
            moTa: 'Sợi hủ tiếu dai, thịt heo băm, tôm, gan heo'),
        FoodItem(maMon: 'M012', tenMon: 'Nước dừa tươi', giaTien: 20000,
            moTa: 'Dừa tươi nguyên trái, cùi dừa non'),
      ],
    ),
  ];

  // ─────────────────────────────────────────────────────────
  // 4. DANH SÁCH PHÒNG GOM ĐƠN (2 phòng)
  // ─────────────────────────────────────────────────────────
  static final List<RoomModel> mockRooms = [
    RoomModel(
      maPhong: 'PHONG001',
      maHubGoc: 'HUB001',
      maTaiXe: null,              // Chưa có tài xế (đang gom)
      tenTaiXe: null,
      thoiGianTao: '2026-07-07T08:00:00Z',
      ngayGiao: '2026-07-07',
      banKinhHienTai: 500,
      trangThaiPhong: 'Đang gom',
      soThanhVien: 3,
      tongSoMon: 5,
    ),
    RoomModel(
      maPhong: 'PHONG002',
      maHubGoc: 'HUB002',
      maTaiXe: 'TX001',
      tenTaiXe: 'Trần Hùng Cường',
      thoiGianTao: '2026-07-07T07:30:00Z',
      ngayGiao: '2026-07-07',
      banKinhHienTai: 500,
      trangThaiPhong: 'Thành công',
      soThanhVien: 5,
      tongSoMon: 8,
    ),
  ];

  // ─────────────────────────────────────────────────────────
  // 5. DANH SÁCH ĐƠN HÀNG (5 đơn - đủ mọi trạng thái)
  // ─────────────────────────────────────────────────────────
  static final List<OrderModel> mockOrders = [
    // Đơn 1: Đang chờ chốt (thuộc phòng PHONG001)
    OrderModel(
      maDonHang: 'DH001',
      maPhong: 'PHONG001',
      maKhachHang: 'KH001',
      tenKhachHang: 'Nguyễn Văn An',
      soDienThoaiKhach: '0901234567',
      maQuan: 'QA001',
      tenQuan: 'Cơm Tấm Bà Ba',
      maTaiXe: null,
      tenTaiXe: null,
      thoiGianDat: '2026-07-07T08:15:30Z',
      ngayGiao: '2026-07-07',
      luaChonCaiDat: 'Chắc chắn ăn',
      phiShipGoc: 30000,
      phiShipThucTe: 0,      // Chưa tính vì chưa chốt
      tongTienMon: 45000,
      soTienTamKhoa: 75000,  // 45000 + 30000
      maXacThuc: '2847',
      trangThaiDonHang: 'Chờ chốt',
      danhSachMonAn: [
        OrderItem(maMon: 'M001', tenMon: 'Cơm tấm sườn bì chả',
            soLuong: 1, giaTien: 45000, ghiChuMon: 'Ít cơm, thêm dưa chua'),
      ],
    ),

    // Đơn 2: Đang chờ chốt (thuộc phòng PHONG001)
    OrderModel(
      maDonHang: 'DH002',
      maPhong: 'PHONG001',
      maKhachHang: 'KH002',
      tenKhachHang: 'Trần Thị Bích',
      soDienThoaiKhach: '0912345678',
      maQuan: 'QA001',
      tenQuan: 'Cơm Tấm Bà Ba',
      maTaiXe: null,
      tenTaiXe: null,
      thoiGianDat: '2026-07-07T08:30:00Z',
      ngayGiao: '2026-07-07',
      luaChonCaiDat: 'Đảm bảo rẻ',
      phiShipGoc: 30000,
      phiShipThucTe: 0,
      tongTienMon: 83000,    // 40000 + 45000 - 2 món
      soTienTamKhoa: 113000, // 83000 + 30000
      maXacThuc: '5193',
      trangThaiDonHang: 'Chờ chốt',
      danhSachMonAn: [
        OrderItem(maMon: 'M002', tenMon: 'Cơm tấm sườn nướng',
            soLuong: 1, giaTien: 40000, ghiChuMon: null),
        OrderItem(maMon: 'M004', tenMon: 'Nước mía tươi',
            soLuong: 1, giaTien: 15000, ghiChuMon: 'Không đá'),
      ],
    ),

    // Đơn 3: Thành công - đã chốt + chia phí ship (thuộc PHONG002)
    OrderModel(
      maDonHang: 'DH003',
      maPhong: 'PHONG002',
      maKhachHang: 'KH003',
      tenKhachHang: 'Lê Minh Châu',
      soDienThoaiKhach: '0923456789',
      maQuan: 'QA002',
      tenQuan: 'Bún Bò Huế Cô Hạnh',
      maTaiXe: 'TX001',
      tenTaiXe: 'Trần Hùng Cường',
      thoiGianDat: '2026-07-07T07:45:00Z',
      ngayGiao: '2026-07-07',
      luaChonCaiDat: 'Đảm bảo rẻ',
      phiShipGoc: 35000,
      phiShipThucTe: 7000,   // 35000 / 5 người = 7000/người
      tongTienMon: 55000,
      soTienTamKhoa: 90000,
      maXacThuc: '7362',
      trangThaiDonHang: 'Thành công',
      danhSachMonAn: [
        OrderItem(maMon: 'M005', tenMon: 'Bún bò Huế đặc biệt',
            soLuong: 1, giaTien: 55000, ghiChuMon: 'Ít cay'),
      ],
    ),

    // Đơn 4: Đã giao xong
    OrderModel(
      maDonHang: 'DH004',
      maPhong: 'PHONG002',
      maKhachHang: 'KH001',
      tenKhachHang: 'Nguyễn Văn An',
      soDienThoaiKhach: '0901234567',
      maQuan: 'QA002',
      tenQuan: 'Bún Bò Huế Cô Hạnh',
      maTaiXe: 'TX001',
      tenTaiXe: 'Trần Hùng Cường',
      thoiGianDat: '2026-07-07T07:50:00Z',
      ngayGiao: '2026-07-07',
      luaChonCaiDat: 'Chắc chắn ăn',
      phiShipGoc: 35000,
      phiShipThucTe: 7000,
      tongTienMon: 100000,
      soTienTamKhoa: 135000,
      maXacThuc: '4821',
      trangThaiDonHang: 'Đã giao',
      danhSachMonAn: [
        OrderItem(maMon: 'M005', tenMon: 'Bún bò Huế đặc biệt',
            soLuong: 1, giaTien: 55000, ghiChuMon: null),
        OrderItem(maMon: 'M008', tenMon: 'Trà đá chanh',
            soLuong: 3, giaTien: 10000, ghiChuMon: 'Ít đường'),
      ],
    ),

    // Đơn 5: Đã hủy tự động (chọn "Đảm bảo rẻ" nhưng phòng không đủ người)
    OrderModel(
      maDonHang: 'DH005',
      maPhong: 'PHONG001',
      maKhachHang: 'KH004',
      tenKhachHang: 'Phạm Quốc Dũng',
      soDienThoaiKhach: '0934567890',
      maQuan: 'QA003',
      tenQuan: 'Cháo Ếch Singapore Tám Liên',
      maTaiXe: null,
      tenTaiXe: null,
      thoiGianDat: '2026-07-07T09:00:00Z',
      ngayGiao: '2026-07-07',
      luaChonCaiDat: 'Đảm bảo rẻ',
      phiShipGoc: 40000,
      phiShipThucTe: 0,
      tongTienMon: 65000,
      soTienTamKhoa: 105000,
      maXacThuc: '9014',
      trangThaiDonHang: 'Đã hủy tự động',
      danhSachMonAn: [
        OrderItem(maMon: 'M009', tenMon: 'Cháo ếch Singapore',
            soLuong: 1, giaTien: 65000, ghiChuMon: null),
      ],
    ),
  ];

  // ─────────────────────────────────────────────────────────
  // 6. HÀM TIỆN ÍCH TRA CỨU NHANH
  // ─────────────────────────────────────────────────────────

  /// Lấy Hub theo mã
  static HubModel? getHubById(String maHub) {
    try { return mockHubs.firstWhere((h) => h.maHub == maHub); }
    catch (_) { return null; }
  }

  /// Lấy danh sách đơn theo phòng
  static List<OrderModel> getOrdersByRoom(String maPhong) =>
      mockOrders.where((o) => o.maPhong == maPhong).toList();

  /// Lấy danh sách đơn theo khách hàng
  static List<OrderModel> getOrdersByUser(String maKhachHang) =>
      mockOrders.where((o) => o.maKhachHang == maKhachHang).toList();

  /// Lấy quán theo mã
  static MerchantModel? getMerchantById(String maQuan) {
    try { return mockMerchants.firstWhere((m) => m.maQuan == maQuan); }
    catch (_) { return null; }
  }

  /// Tính Bulk Order (danh sách tổng cho bếp) từ các đơn thành công trong phòng
  static Map<String, int> getBulkOrder(String maPhong) {
    final orders = getOrdersByRoom(maPhong)
        .where((o) => o.thanhCong || o.daGiao)
        .toList();
    final Map<String, int> bulk = {};
    for (var order in orders) {
      for (var item in order.danhSachMonAn) {
        bulk[item.tenMon] = (bulk[item.tenMon] ?? 0) + item.soLuong;
      }
    }
    return bulk;
  }
}
