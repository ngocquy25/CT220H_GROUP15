import 'package:flutter/material.dart';
import 'package:shared/test/mock_data.dart';
import '../search_food/cart_controller.dart';
import '../auth/login_controller.dart';
import 'payment_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../core/utils/time_helper.dart';

/// Màn hình Thanh toán & Tạm khóa tiền
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _controller = PaymentController();
  final _cart = CartController.instance;
  String _luaChon = 'Chắc chắn ăn';
  bool _isLoading = false;

  static const int _phiShipGoc = 30000;

  int get _tongTienMon => _cart.tongTienMon;
  int get _soTienTamKhoa => _tongTienMon + _phiShipGoc;

  String get _maPhong {
    // Lấy từ mock rooms hoặc default
    final hubId = 'HUB001'; // Sẽ đọc từ SharedPrefs trong production
    return MockData.mockRooms
        .where((r) => r.maHubGoc == hubId && r.dangGom)
        .firstOrNull?.maPhong ?? 'PHONG001';
  }

  Future<void> _datHang() async {
    setState(() => _isLoading = true);

    final ketQua = await _controller.thucHienDatHang(
      tongTienMon: _tongTienMon,
      phiShipGoc: _phiShipGoc,
      luaChon: _luaChon,
      danhSachMonAn: _cart.items,
      maQuan: _cart.merchant?.maQuan ?? 'QA001',
      tenQuan: _cart.merchant?.tenQuan ?? 'Quán ăn',
      maPhong: _maPhong,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;
    if (ketQua.success) {
      _cart.clearCart(); // Xóa giỏ hàng sau khi đặt thành công
      _showSuccessDialog(ketQua.maDonHang!, ketQua.maXacThuc!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ketQua.message), backgroundColor: AppColors.error),
      );
    }
  }

  void _showSuccessDialog(String maDon, String maPin) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 64),
          SizedBox(height: 8),
          Text('Đặt hàng thành công!', textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Mã đơn: $maDon',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          // Mã PIN
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Column(children: [
              const Text('🔐 Mã PIN xác nhận giao hàng',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              Text(maPin, style: const TextStyle(
                fontSize: 40, fontWeight: FontWeight.bold,
                color: AppColors.primary, letterSpacing: 10,
              )),
              const SizedBox(height: 6),
              const Text('Đưa mã này cho tài xế khi nhận đồ',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            ]),
          ),
          const SizedBox(height: 12),
          // Số tiền tạm khóa
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.lock, color: AppColors.warning, size: 18),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(TimeHelper.formatVND(_soTienTamKhoa),
                  style: const TextStyle(color: AppColors.warning,
                      fontWeight: FontWeight.bold, fontSize: 16)),
                const Text('đã được tạm khóa trong ví',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ]),
            ]),
          ),
          const SizedBox(height: 12),
          // Thông báo về chốt đơn
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'ℹ️ Đúng 10:00 sáng, hệ thống sẽ tự động chốt đơn và giải phóng tiền ship thừa về ví bạn.',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ]),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.home, (r) => false),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Về trang chủ'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = LoginController.currentUser;
    final soDu = user?.soDuVi ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thanh toán', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Danh sách món đã đặt
          if (!_cart.isEmpty) ...[
            _buildSection('🛒 Món đã chọn', [
              ..._cart.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.tenMon, style: const TextStyle(fontWeight: FontWeight.w500)),
                    if (item.ghiChuMon != null)
                      Text('📝 ${item.ghiChuMon}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ])),
                  Text('x${item.soLuong}', style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(width: 8),
                  Text(TimeHelper.formatVND(item.thanhTien),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ]),
              )),
            ]),
            const SizedBox(height: 14),
          ],

          // Tóm tắt tài chính
          _buildSection('💰 Tóm tắt tài chính', [
            _buildRow('Tiền món ăn', TimeHelper.formatVND(_tongTienMon)),
            _buildRow('Phí ship (đi một mình)', TimeHelper.formatVND(_phiShipGoc),
                color: AppColors.textSecondary),
            const Divider(height: 16),
            _buildRow('💰 Tạm khóa ví', TimeHelper.formatVND(_soTienTamKhoa),
                isBold: true, color: AppColors.warning),
            const SizedBox(height: 4),
            _buildRow('Số dư ví hiện tại',
                TimeHelper.formatVND(soDu.toInt()),
                color: soDu >= _soTienTamKhoa ? AppColors.success : AppColors.error),
          ]),
          const SizedBox(height: 14),

          // Lựa chọn cài đặt (BẮT BUỘC)
          _buildSection('⚙️ Chọn chế độ đơn hàng (Bắt buộc)', [
            const Text('Điều gì xảy ra nếu phòng gom không đủ người?',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 12),
            _buildOptionCard(
              value: 'Chắc chắn ăn', icon: '🍱',
              title: 'Chắc chắn ăn',
              desc: 'Vẫn nhận đơn kể cả khi phải trả phí ship cao hơn nếu ít người gom',
            ),
            const SizedBox(height: 8),
            _buildOptionCard(
              value: 'Đảm bảo rẻ', icon: '💸',
              title: 'Đảm bảo rẻ',
              desc: 'Tự động hủy đơn nếu không đạt freeship. Hoàn tiền ngay lập tức.',
            ),
          ]),
          const SizedBox(height: 14),

          // Thông tin giao hàng
          _buildSection('🚗 Thông tin giao hàng', [
            _buildRow('Ngày giao', TimeHelper.tinhNgayGiao()),
            _buildRow('Giờ giao dự kiến', '11:00 - 12:00'),
            _buildRow('Chốt đơn lúc', '10:00 sáng'),
            _buildRow('Trạng thái đơn', 'Chờ chốt'),
          ]),
          const SizedBox(height: 24),

          // Nút đặt hàng
          SizedBox(
            width: double.infinity, height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _datHang,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('🔒 Đặt hàng & Tạm khóa tiền',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Khóa ${TimeHelper.formatVND(_soTienTamKhoa)} từ ví',
                        style: const TextStyle(fontSize: 11, color: Colors.white70)),
                    ]),
            ),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold,
            fontSize: 15, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(value, style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: color ?? AppColors.textPrimary,
        )),
      ]),
    );
  }

  Widget _buildOptionCard({
    required String value, required String icon,
    required String title, required String desc,
  }) {
    final isSelected = _luaChon == value;
    return GestureDetector(
      onTap: () => setState(() => _luaChon = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardBg : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textHint,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            )),
            Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          if (isSelected)
            const Icon(Icons.radio_button_checked, color: AppColors.primary)
          else
            const Icon(Icons.radio_button_unchecked, color: AppColors.textHint),
        ]),
      ),
    );
  }
}
