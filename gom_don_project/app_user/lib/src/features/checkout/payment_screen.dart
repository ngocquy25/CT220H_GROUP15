import 'package:flutter/material.dart';
import 'payment_controller.dart';
import '../../core/app_colors.dart';
import '../../core/utils/time_helper.dart';

/// Màn hình Thanh toán & Tạm khóa tiền
/// Hiển thị tổng tiền, 2 lựa chọn cài đặt, và nút Đặt hàng
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _controller = PaymentController();
  String _luaChon = 'Chắc chắn ăn'; // Lựa chọn mặc định
  bool _isLoading = false;

  // Dữ liệu mẫu (sẽ được truyền qua arguments từ màn hình trước)
  final int _tongTienMon = 45000;
  final int _phiShipGoc = 30000;

  int get _soTienTamKhoa => _tongTienMon + _phiShipGoc;

  Future<void> _datHang() async {
    setState(() => _isLoading = true);

    final ketQua = await _controller.thucHienDatHang(
      tongTienMon: _tongTienMon,
      phiShipGoc: _phiShipGoc,
      luaChon: _luaChon,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;
    if (ketQua.success) {
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
          Icon(Icons.check_circle, color: AppColors.success, size: 56),
          SizedBox(height: 8),
          Text('Đặt hàng thành công!', textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Mã đơn: $maDon', style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary),
            ),
            child: Column(children: [
              const Text('🔐 Mã PIN xác nhận giao hàng',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Text(maPin, style: const TextStyle(
                fontSize: 36, fontWeight: FontWeight.bold,
                color: AppColors.primary, letterSpacing: 8,
              )),
              const Text('Cho tài xế xem mã này khi nhận đồ',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ]),
          ),
          const SizedBox(height: 12),
          Text(TimeHelper.formatVND(_soTienTamKhoa),
            style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold)),
          const Text('đã được tạm khóa trong ví',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ]),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
            child: const Text('Về trang chủ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          // Tóm tắt đơn hàng
          _buildSection('📋 Tóm tắt đơn hàng', [
            _buildRow('Tiền món ăn', TimeHelper.formatVND(_tongTienMon)),
            _buildRow('Phí ship (đi một mình)', TimeHelper.formatVND(_phiShipGoc)),
            const Divider(),
            _buildRow('💰 Tạm khóa ví', TimeHelper.formatVND(_soTienTamKhoa),
                isBold: true, color: AppColors.warning),
          ]),

          const SizedBox(height: 16),

          // Lựa chọn cài đặt (BẮT BUỘC)
          _buildSection('⚙️ Chọn chế độ đơn hàng (Bắt buộc)', [
            const Text('Điều gì xảy ra nếu phòng gom không đủ người?',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 12),
            _buildOptionCard(
              value: 'Chắc chắn ăn',
              icon: '🍱',
              title: 'Chắc chắn ăn',
              desc: 'Vẫn nhận đơn kể cả khi phải trả phí ship cao hơn nếu ít người gom',
            ),
            const SizedBox(height: 8),
            _buildOptionCard(
              value: 'Đảm bảo rẻ',
              icon: '💸',
              title: 'Đảm bảo rẻ',
              desc: 'Tự động hủy đơn nếu không đạt freeship/giảm giá. Hoàn tiền ngay lập tức.',
            ),
          ]),

          const SizedBox(height: 16),

          // Thông tin giao hàng
          _buildSection('🚗 Thông tin giao hàng', [
            _buildRow('Ngày giao', TimeHelper.tinhNgayGiao()),
            _buildRow('Giờ giao dự kiến', '11:00 - 12:00'),
            _buildRow('Trạng thái đơn', 'Chờ chốt lúc 10:00'),
          ]),

          const SizedBox(height: 24),

          // Nút đặt hàng
          SizedBox(
            width: double.infinity, height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _datHang,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('Đặt hàng & Tạm khóa tiền',
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
