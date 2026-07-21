import 'package:flutter/material.dart';
import 'package:shared/models/room_model.dart';
import 'package:shared/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'trip_pool_controller.dart';
import '../delivery/verification_screen.dart';

/// Màn hình Danh sách Chuyến xe – Hiển thị sau 10:05
/// Tài xế nhìn thấy tất cả phòng gom thành công cần giao
class TripPoolScreen extends StatefulWidget {
  const TripPoolScreen({super.key});

  @override
  State<TripPoolScreen> createState() => _TripPoolScreenState();
}

class _TripPoolScreenState extends State<TripPoolScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TripPoolController();
  List<RoomModel> _rooms = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    _loadRooms();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    if (!_isLoading) setState(() => _isRefreshing = true);
    final rooms = await _controller.layDanhSachPhongThanhCong();
    setState(() {
      _rooms = rooms;
      _isLoading = false;
      _isRefreshing = false;
    });
  }

  Future<void> _nhanChuyen(RoomModel room) async {
    // Hiển thị dialog xác nhận
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: const [
          Icon(Icons.directions_car_filled, color: AppColors.primary, size: 28),
          SizedBox(width: 10),
          Text('Nhận chuyến xe?',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfirmRow(Icons.meeting_room, 'Phòng', room.maPhong),
            const SizedBox(height: 6),
            _buildConfirmRow(Icons.location_city, 'Hub', room.maHubGoc),
            const SizedBox(height: 6),
            _buildConfirmRow(
                Icons.calendar_today, 'Ngày giao', room.ngayGiao),
            const SizedBox(height: 6),
            _buildConfirmRow(Icons.people, 'Khách hàng',
                '${room.soThanhVien} người'),
            const SizedBox(height: 6),
            _buildConfirmRow(Icons.set_meal, 'Tổng món',
                '${room.tongSoMon} món cần giao'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(children: const [
                Icon(Icons.info_outline, size: 14, color: Colors.blue),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Chuyến xe sẽ bị KHÓA ngay khi bạn xác nhận. '
                    'Tài xế khác sẽ không thấy chuyến này nữa.',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('✅ Nhận chuyến',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Gọi Firestore để khóa chuyến
    if (!mounted) return;
    _showLoadingDialog('Đang nhận chuyến...');

    final success =
        await _controller.nhanChuyen(room.maPhong, 'DRIVER_TEST');

    if (!mounted) return;
    Navigator.pop(context); // đóng loading dialog

    // Thông báo kết quả
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(success ? Icons.check_circle : Icons.error, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            success
                ? '✅ Đã nhận chuyến ${room.maPhong} thành công!'
                : '❌ Chuyến đã được nhận bởi tài xế khác!',
          ),
        ),
      ]),
      backgroundColor:
          success ? Colors.green.shade700 : Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));

    if (success) {
      _loadRooms();
      if (!mounted) return;
      // Hỏi xem giao ngay không
      final deliverNow = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('🎉 Nhận chuyến thành công!',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
              'Bạn có muốn đi giao hàng cho phòng ${room.maPhong} ngay bây giờ không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child:
                  const Text('Để sau', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.delivery_dining, size: 18),
              label: const Text('Giao ngay!'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      );

      if (deliverNow == true && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                VerificationScreen(maPhong: room.maPhong),
          ),
        );
      }
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(width: 20),
          Text(message),
        ]),
      ),
    );
  }

  Widget _buildConfirmRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 16, color: Colors.grey.shade500),
      const SizedBox(width: 8),
      Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
      Expanded(
        child: Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🚗 Chuyến xe sẵn sàng',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(
              '${_rooms.length} chuyến đang chờ',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.refresh),
            onPressed: _loadRooms,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _isLoading
          ? _buildShimmerLoading()
          : _rooms.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadRooms,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _rooms.length,
                    itemBuilder: (_, i) => _buildRoomCard(_rooms[i]),
                  ),
                ),
    );
  }

  // ── Shimmer loading ───────────────────────────────────────────────
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (_, __) => AnimatedBuilder(
        animation: _shimmerController,
        builder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 14),
          height: 180,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_transfer_rounded, size: 90,
                color: Colors.grey.shade300),
            const SizedBox(height: 20),
            const Text(
              'Không có chuyến xe nào!',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              'Các phòng gom thành công sẽ hiển thị ở đây sau 10:05 sáng.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _loadRooms,
              icon: const Icon(Icons.refresh),
              label: const Text('Tải lại'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Room card ─────────────────────────────────────────────────────
  Widget _buildRoomCard(RoomModel room) {
    final isNew = room.soThanhVien >= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          // ── Header card ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.meeting_room,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    room.maPhong,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textDark,
                        fontFamily: 'monospace'),
                  ),
                ]),
                Row(children: [
                  if (isNew)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '🔥 Đông người',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '✅ Đủ điều kiện ship',
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ]),
              ],
            ),
          ),

          // ── Body card ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thông tin Hub và ngày giao
                Row(children: [
                  _buildInfoChip(
                      Icons.location_city, 'Hub: ${room.maHubGoc}',
                      Colors.blue),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                      Icons.calendar_today,
                      room.ngayGiao.isEmpty
                          ? 'Hôm nay'
                          : _formatDate(room.ngayGiao),
                      Colors.orange),
                ]),
                const SizedBox(height: 12),

                // Số liệu
                Row(children: [
                  Expanded(
                    child: _buildMetric(
                      Icons.people_alt_rounded,
                      '${room.soThanhVien}',
                      'Khách hàng',
                      AppColors.primary,
                    ),
                  ),
                  Expanded(
                    child: _buildMetric(
                      Icons.set_meal_rounded,
                      '${room.tongSoMon}',
                      'Món ăn',
                      AppColors.orange,
                    ),
                  ),
                  Expanded(
                    child: _buildMetric(
                      Icons.route_rounded,
                      '500m',
                      'Bán kính',
                      Colors.purple,
                    ),
                  ),
                ]),
                const SizedBox(height: 14),

                // Nút nhận chuyến
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _nhanChuyen(room),
                    icon: const Icon(Icons.delivery_dining, size: 20),
                    label: const Text(
                      'Nhận Chuyến Xe Này',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildMetric(
      IconData icon, String value, String label, Color color) {
    return Column(children: [
      Icon(icon, size: 22, color: color),
      const SizedBox(height: 4),
      Text(value,
          style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold)),
      Text(label,
          style: const TextStyle(fontSize: 11, color: Colors.grey)),
    ]);
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return isoDate;
    }
  }
}
