import 'package:flutter/material.dart';
import 'package:shared/models/hub_model.dart';
import 'package:shared/models/room_model.dart';
import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../core/utils/time_helper.dart';
import 'home_controller.dart';

/// Bottom Sheet ẩn danh — hiển thị thông tin phòng gom đơn
///
/// Người dùng CHỈ thấy:
///   • Tên phòng & hub nhận hàng
///   • Đồng hồ đếm ngược
///   • Tổng số thành viên & tổng số món
///   • Danh sách <tên món> x<số lượng> (KHÔNG có tên người đặt)
/// Nút hành động: "Tham gia phòng" → push sang RoomDetailScreen
void showRoomPreviewSheet(
  BuildContext context, {
  required RoomModel room,
  required HubModel hub,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RoomPreviewSheet(room: room, hub: hub),
  );
}

class _RoomPreviewSheet extends StatefulWidget {
  final RoomModel room;
  final HubModel hub;

  const _RoomPreviewSheet({required this.room, required this.hub});

  @override
  State<_RoomPreviewSheet> createState() => _RoomPreviewSheetState();
}

class _RoomPreviewSheetState extends State<_RoomPreviewSheet> {
  final _controller = HomeController();
  List<AnonOrderItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items =
        await _controller.layDanhSachMonAnonyme(widget.room.maPhong);
    if (mounted) {
      setState(() {
        _items = items;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final countdown = TimeHelper.tinhThoiGianConLai();
    final isExpired = countdown.inSeconds == 0;
    final soThanhVien = widget.room.soThanhVien;
    final tongSoLuong = _items.fold(0, (s, i) => s + i.soLuong);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Drag handle ──
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ── Header: tên phòng + hub ──
              _buildHeader(),

              // ── Countdown + stats ──
              _buildCountdownAndStats(countdown, isExpired, soThanhVien, tongSoLuong),

              // ── Divider + nhãn ẩn danh ──
              _buildPrivacyLabel(),

              // ── Danh sách món ẩn danh ──
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary, strokeWidth: 2))
                    : _items.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            controller: scrollCtrl,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: _items.length,
                            itemBuilder: (_, i) => _buildAnonItemRow(_items[i], i),
                          ),
              ),

              // ── Nút hành động ──
              _buildActionButton(isExpired, context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.group, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phòng gom đơn',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.hub.tenHub,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 12, color: AppColors.textHint),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        widget.hub.diaChi,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textHint),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Badge trạng thái
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: const Text(
              '🟢 Đang gom',
              style: TextStyle(
                  fontSize: 10,
                  color: AppColors.success,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownAndStats(
      Duration countdown, bool isExpired, int soThanhVien, int tongSoLuong) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isExpired
            ? AppColors.error.withValues(alpha: 0.08)
            : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpired
              ? AppColors.error.withValues(alpha: 0.2)
              : AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          // Đồng hồ countdown
          Expanded(
            child: Column(
              children: [
                Text(
                  isExpired ? '⛔ Đã chốt' : '⏱ Còn lại',
                  style: TextStyle(
                    fontSize: 11,
                    color: isExpired ? AppColors.error : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isExpired ? '--:--:--' : TimeHelper.formatCountdown(countdown),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isExpired ? AppColors.error : AppColors.primary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.textHint.withValues(alpha: 0.3)),
          // Thành viên
          Expanded(
            child: Column(
              children: [
                const Text('👥 Thành viên',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  '$soThanhVien người',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.textHint.withValues(alpha: 0.3)),
          // Tổng món
          Expanded(
            child: Column(
              children: [
                const Text('🍽️ Tổng món',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  '$tongSoLuong phần',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, size: 13, color: AppColors.textHint),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'Danh sách món trong phòng — tên người đặt được bảo mật',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textHint,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          if (!_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_items.length} loại',
                style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnonItemRow(AnonOrderItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: index.isEven
            ? AppColors.background
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryDark.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          // Bullet số thứ tự ẩn danh
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Tên món
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.tenMon,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (item.ghiChu != null && item.ghiChu!.isNotEmpty)
                  Text(
                    '📝 ${item.ghiChu}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textHint),
                  ),
              ],
            ),
          ),
          // Số lượng nổi bật
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.orange.withValues(alpha: 0.25)),
            ),
            child: Text(
              'x${item.soLuong}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🍽️', style: TextStyle(fontSize: 40)),
          SizedBox(height: 12),
          Text(
            'Chưa có ai đặt chung',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary),
          ),
          SizedBox(height: 4),
          Text(
            'Hãy là người đầu tiên đặt món trong phòng này!',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool isExpired, BuildContext ctx) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: isExpired
                ? null
                : () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(ctx, AppRoutes.roomDetail);
                  },
            icon: Icon(isExpired ? Icons.block : Icons.group_add),
            label: Text(
              isExpired
                  ? '⛔ Phòng đã chốt đơn'
                  : '🚀 Tham gia phòng & Đặt chung',
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isExpired ? AppColors.textHint : AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ),
    );
  }
}
