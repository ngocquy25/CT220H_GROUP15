import 'package:flutter/material.dart';
import 'package:shared/models/order_model.dart';
import 'order_history_controller.dart';
import '../../core/app_colors.dart';
import '../../core/utils/time_helper.dart';

/// Màn hình Lịch sử đơn hàng — xem tất cả đơn của user
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  final _controller = OrderHistoryController();
  List<OrderModel> _allOrders = [];
  List<OrderModel> _filtered = [];
  bool _isLoading = true;
  String _selectedFilter = 'Tất cả';
  late TabController _tabCtrl;
  final Set<String> _expandedIds = {};

  static const _filters = ['Tất cả', 'Chờ chốt', 'Thành công', 'Đã hủy tự động'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _filters.length, vsync: this);
    _tabCtrl.addListener(_onTabChanged);
    _loadOrders();
  }

  void _onTabChanged() {
    if (_tabCtrl.indexIsChanging) return;
    setState(() {
      _selectedFilter = _filters[_tabCtrl.index];
      _filtered = _controller.locTheoTrangThai(_allOrders, _selectedFilter);
    });
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders = await _controller.layLichSuDonHang();
    setState(() {
      _allOrders = orders;
      _filtered = orders;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Đơn hàng của tôi',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: _filters.map((f) => Tab(text: f)).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadOrders,
              color: AppColors.primary,
              child: _filtered.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) => _buildOrderCard(_filtered[i]),
                    ),
            ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.receipt_long_outlined, size: 80, color: AppColors.textHint),
            SizedBox(height: 16),
            Text('Chưa có đơn hàng nào',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            Text('Hãy đặt món ngay hôm nay!',
                style: TextStyle(color: AppColors.textHint)),
          ]),
        ),
      ],
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final isExpanded = _expandedIds.contains(order.maDonHang);
    final statusColor = _getStatusColor(order.trangThaiDonHang);
    final statusIcon = _getStatusIcon(order.trangThaiDonHang);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(children: [
        // Header đơn hàng
        GestureDetector(
          onTap: () => setState(() {
            if (isExpanded) {
              _expandedIds.remove(order.maDonHang);
            } else {
              _expandedIds.add(order.maDonHang);
            }
          }),
          child: Container(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              // Icon quán
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.restaurant, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),

              // Thông tin đơn
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(order.tenQuan,
                    style: const TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 15, color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text('Ngày giao: ${order.ngayGiao}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 3),
                Text(TimeHelper.formatVND(order.tongTienMon),
                    style: const TextStyle(color: AppColors.primary,
                        fontWeight: FontWeight.bold, fontSize: 14)),
              ])),

              // Badge trạng thái
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(statusIcon, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(order.trangThaiDonHang,
                        style: TextStyle(color: statusColor,
                            fontSize: 11, fontWeight: FontWeight.bold)),
                  ]),
                ),
                const SizedBox(height: 6),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textHint, size: 20),
              ]),
            ]),
          ),
        ),

        // Chi tiết mở rộng
        if (isExpanded) ...[
          const Divider(height: 1, indent: 14, endIndent: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Danh sách món
              const Text('Món đã đặt:', style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 13)),
              const SizedBox(height: 6),
              ...order.danhSachMonAn.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('• ${item.tenMon} x${item.soLuong}',
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                    if (item.ghiChuMon != null)
                      Text('  📝 ${item.ghiChuMon}',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11)),
                  ])),
                  Text(TimeHelper.formatVND(item.thanhTien),
                      style: const TextStyle(color: AppColors.primary,
                          fontSize: 13, fontWeight: FontWeight.w500)),
                ]),
              )),

              const Divider(height: 16),

              // Thông tin tài chính
              _infoRow('Phí ship gốc:', TimeHelper.formatVND(order.phiShipGoc)),
              if (order.trangThaiDonHang == 'Thành công')
                _infoRow('Phí ship thực tế:', TimeHelper.formatVND(order.phiShipThucTe),
                    color: AppColors.success),
              _infoRow('Đã tạm khóa:', TimeHelper.formatVND(order.soTienTamKhoa),
                  color: AppColors.warning),

              // Lựa chọn cài đặt
              const SizedBox(height: 6),
              _infoRow('Chế độ đặt:', order.luaChonCaiDat),

              // PIN (chỉ hiện khi đang chờ chốt)
              if (order.trangThaiDonHang == 'Chờ chốt') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.lock, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Column(children: [
                      const Text('Mã PIN tài xế', style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                      Text(order.maXacThuc, style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold,
                          color: AppColors.primary, letterSpacing: 6)),
                    ]),
                  ]),
                ),
              ],
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _infoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: TextStyle(
            color: color ?? AppColors.textPrimary,
            fontSize: 13, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Thành công': return AppColors.success;
      case 'Đã hủy tự động': return AppColors.error;
      default: return AppColors.warning;
    }
  }

  String _getStatusIcon(String status) {
    switch (status) {
      case 'Thành công': return '✅';
      case 'Đã hủy tự động': return '❌';
      default: return '⏳';
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }
}
