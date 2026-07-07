import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared/models/room_model.dart';
import 'package:shared/models/order_model.dart';
import 'room_detail_controller.dart';
import '../../core/app_colors.dart';
import '../../core/utils/time_helper.dart';
import '../../core/app_routes.dart';

/// Màn hình Phòng Gom Đơn - Hiển thị thành viên + Đồng hồ đếm ngược
class RoomDetailScreen extends StatefulWidget {
  const RoomDetailScreen({super.key});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  final _controller = RoomDetailController();
  RoomModel? _room;
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
    final room = await _controller.timHoacTaoPhong('HUB001');
    final orders = await _controller.layDanhSachDon(room.maPhong);
    setState(() { _room = room; _orders = orders; _isLoading = false; });
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Countdown Timer
                _buildCountdownBanner(),

                // Trạng thái phòng
                if (_room != null)
                  _buildRoomStatus(),

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
              ],
            ),
    );
  }

  Widget _buildCountdownBanner() {
    final isExpired = _countdown.inSeconds == 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isExpired ? AppColors.error : _countdownColor.withOpacity(0.1),
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
          isExpired ? 'Chốt đơn lúc 10:00 sáng' : TimeHelper.formatCountdown(_countdown),
          style: TextStyle(
            fontSize: 28, fontWeight: FontWeight.bold,
            color: isExpired ? Colors.white : _countdownColor,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          'Giao ngày: ${TimeHelper.tinhNgayGiao()}',
          style: TextStyle(
            fontSize: 12,
            color: isExpired ? Colors.white70 : AppColors.textSecondary,
          ),
        ),
      ]),
    );
  }

  Widget _buildRoomStatus() {
    return Container(
      margin: const EdgeInsets.all(16),
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
            '  • ${item.tenMon} x${item.soLuong}',
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity, height: 52,
        child: ElevatedButton(
          onPressed: disabled ? null : () => Navigator.pushNamed(context, AppRoutes.payment),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.textHint,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            disabled ? '⛔ Đã hết giờ đặt đơn' : '🍽️ Đặt chung vào phòng này',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
