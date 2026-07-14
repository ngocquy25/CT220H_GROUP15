import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared/models/hub_model.dart';
import 'package:shared/models/room_model.dart';
import 'package:shared/models/order_model.dart';
import 'package:shared/test/mock_data.dart';
import '../search_food/cart_controller.dart';
import 'room_detail_controller.dart';
import '../../core/app_colors.dart';
import '../../core/utils/time_helper.dart';
import '../../core/app_routes.dart';
import '../../core/utils/room_merger_service.dart';

/// Màn hình Phòng Gom Đơn — Hiển thị thành viên + Đồng hồ đếm ngược
class RoomDetailScreen extends StatefulWidget {
  const RoomDetailScreen({super.key});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  final _controller = RoomDetailController();
  final _cart = CartController.instance;
  RoomModel? _room;
  HubModel? _hub;
  List<OrderModel> _orders = [];
  Timer? _timer;
  Duration _countdown = Duration.zero;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initRoom();
    _startCountdown();
  }

  Future<void> _initRoom() async {
    final maHub = await _controller.layMaHubDaLuu();
    final hub = MockData.getHubById(maHub);
    final room = await _controller.timHoacTaoPhong(maHub);
    final orders = await _controller.layDanhSachDon(room.maPhong);
    if (!mounted) return;
    setState(() {
      _room = room;
      _hub = hub;
      _orders = orders;
      _isLoading = false;
    });

    // Bắt đầu timer kiểm tra bán kính động (mỗi 60 giây)
    if (hub != null) {
      _controller.batDauTimerNoRong(
        phongHienTai: room,
        hubGoc: hub,
        onGopHubResult: (result) {
          if (!mounted) return;
          setState(() {
            _room = result.phongDaCapNhat;
          });
          // Tải lại đơn hàng sau khi gộp
          _controller.layDanhSachDon(result.phongDaCapNhat.maPhong).then((orders) {
            if (mounted) setState(() => _orders = orders);
          });
        },
      );
    }
  }

  void _startCountdown() {
    _countdown = TimeHelper.tinhThoiGianConLai();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = TimeHelper.tinhThoiGianConLai();
      setState(() => _countdown = remaining);
      if (remaining.inSeconds == 0) _timer?.cancel();
    });
  }

  Color get _countdownColor {
    if (_countdown.inMinutes < 10) return AppColors.countdownDanger;
    if (_countdown.inMinutes < 30) return AppColors.countdownWarning;
    return AppColors.countdownNormal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_room?.maPhong ?? 'Phòng Gom Đơn',
          style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // [DEV] Nút giả lập 9h30 để test không cần đợi giờ thật
          if (_room != null && _hub != null && !(_room!.daMoRongBanKinh))
            TextButton.icon(
              onPressed: () => _giasLapNoRong(),
              icon: const Icon(Icons.science, color: Colors.white, size: 16),
              label: const Text('[DEV]\n9h30',
                  style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(children: [
              // Countdown Timer
              _buildCountdownBanner(),

              // Banner gộp Hub (hiển thị khi đang gộp)
              if (_room != null && _room!.dangGopHub)
                _buildMergeStatusBanner(),

              // Thông tin Hub nhận hàng
              if (_hub != null) _buildHubInfo(),

              // Trạng thái phòng
              if (_room != null) _buildRoomStatus(),

              // Giỏ hàng hiện tại của user (nếu có)
              if (!_cart.isEmpty) _buildMyCartPreview(),

              // Danh sách thành viên
              Expanded(
                child: _orders.isEmpty
                    ? const Center(child: Text('Chưa có ai đặt chung. Hãy là người đầu tiên! 🍽️',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        itemBuilder: (_, i) => _buildMemberCard(_orders[i]),
                      ),
              ),

              // Nút Đặt chung
              _buildPlaceOrderButton(),
            ]),
    );
  }

  Widget _buildCountdownBanner() {
    final isExpired = _countdown.inSeconds == 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isExpired ? AppColors.error : _countdownColor.withOpacity(0.08),
        border: Border(bottom: BorderSide(color: _countdownColor.withOpacity(0.3))),
      ),
      child: Column(children: [
        Text(
          isExpired ? '⛔ Đã hết giờ đặt' : '⏱ Thời gian còn lại để đặt:',
          style: TextStyle(
            color: isExpired ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isExpired ? 'Đã chốt đơn lúc 10:00 sáng' : TimeHelper.formatCountdown(_countdown),
          style: TextStyle(
            fontSize: 30, fontWeight: FontWeight.bold,
            color: isExpired ? Colors.white : _countdownColor,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text('Giao ngày: ${TimeHelper.tinhNgayGiao()}',
          style: TextStyle(fontSize: 12,
              color: isExpired ? Colors.white70 : AppColors.textSecondary)),
      ]),
    );
  }

  Widget _buildHubInfo() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Row(children: [
        const Icon(Icons.business, color: AppColors.accent, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('📍 Nhận hàng tại: ${_hub!.tenHub}',
            style: const TextStyle(fontWeight: FontWeight.bold,
                color: AppColors.textPrimary, fontSize: 13)),
          Text(_hub!.diaChi,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ])),
      ]),
    );
  }

  Widget _buildRoomStatus() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _buildStatItem('👥 Thành viên', '${_room!.soThanhVien}'),
        Container(width: 1, height: 30, color: AppColors.textHint),
        _buildStatItem('🍽️ Tổng món', '${_room!.tongSoMon}'),
        Container(width: 1, height: 30, color: AppColors.textHint),
        _buildStatItem('📦 Trạng thái', _room!.trangThaiPhong),
      ]),
    );
  }

  Widget _buildStatItem(String label, String value) => Column(children: [
    Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
        color: AppColors.primary)),
    Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
  ]);

  Widget _buildMyCartPreview() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.shopping_cart, color: AppColors.success, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(
          'Giỏ của bạn: ${_cart.merchant?.tenQuan ?? ''} — ${_cart.tongSoLuong} món',
          style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 13),
        )),
        Text(TimeHelper.formatVND(_cart.tongTienMon),
          style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildMemberCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(order.tenKhachHang[0],
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(order.tenKhachHang,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Text(order.tenQuan,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ...order.danhSachMonAn.map((item) => Text(
            '  • ${item.tenMon} x${item.soLuong}${item.ghiChuMon != null ? " (${item.ghiChuMon})" : ""}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          )),
        ])),
        Text(TimeHelper.formatVND(order.tongTienMon),
          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildPlaceOrderButton() {
    final disabled = _countdown.inSeconds == 0;
    final isCartEmpty = _cart.isEmpty;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity, height: 52,
        child: ElevatedButton(
          onPressed: disabled
              ? null
              : (isCartEmpty
                  ? () => Navigator.pop(context) // Trở về để chọn món
                  : () => Navigator.pushNamed(context, AppRoutes.payment)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.textHint,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            disabled 
                ? '⛔ Đã hết giờ đặt đơn' 
                : (isCartEmpty ? '🛒 Chọn món ngay' : '💳 Thanh toán & Tạm khóa tiền'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // BANNER GỘP HUB — Hiển thị khi phòng đang trong trạng thái gộp
  // ─────────────────────────────────────────────────────────────────

  Widget _buildMergeStatusBanner() {
    final hubGopNames = _room!.danhSachHubGop
        .map((id) => MockData.getHubById(id)?.tenHub ?? id)
        .join(', ');
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B21A8), Color(0xFF9333EA)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9333EA).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('⚡', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đã mở rộng bán kính 1km',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                if (hubGopNames.isNotEmpty)
                  Text(
                    'Đang gộp đơn từ: $hubGopNames',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                    ),
                  )
                else
                  Text(
                    'Không tìm thấy Hub lân cận cần gộp',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_room!.banKinhHienTai}m',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // [DEV] Giả lập 9h30 — chỉ dùng khi test
  // ─────────────────────────────────────────────────────────────────

  Future<void> _giasLapNoRong() async {
    if (_room == null || _hub == null) return;
    final result = await RoomMergerService.chayLogicGopHub(
      _room!,
      _hub!,
      giasLapNoRong: true,
    );
    if (!mounted) return;
    setState(() {
      _room = result.phongDaCapNhat;
    });
    final orders = await _controller.layDanhSachDon(result.phongDaCapNhat.maPhong);
    if (mounted) setState(() => _orders = orders);

    // Hiển thị snackbar thông báo kết quả
    if (mounted) {
      final msg = result.daGopDuocHub
          ? '⚡ Đã gộp ${result.hubDaGop.length} Hub! Tổng ${result.tongThanhVienSauGop} thành viên'
          : '📡 Đã nới bán kính 1km — không có Hub nào cần gộp';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: result.daGopDuocHub
            ? const Color(0xFF7C3AED)
            : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}
