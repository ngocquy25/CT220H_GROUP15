import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared/models/order_model.dart';
import 'package:shared/theme/app_colors.dart';
import 'reconciliation_controller.dart';

/// Màn hình Đối soát Tài chính – Xuất báo cáo Excel cuối tháng
class ReconciliationScreen extends StatefulWidget {
  const ReconciliationScreen({super.key});

  @override
  State<ReconciliationScreen> createState() => _ReconciliationScreenState();
}

class _ReconciliationScreenState extends State<ReconciliationScreen>
    with SingleTickerProviderStateMixin {
  final _controller = ReconciliationController();
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  bool _isExporting = false;
  DateTime? _tuNgay;
  DateTime? _denNgay;
  late TabController _tabController;
  final _currency = NumberFormat('#,###', 'vi_VN');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders =
        await _controller.layLichSuDon(tuNgay: _tuNgay, denNgay: _denNgay);
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  Future<void> _pickDate(bool isTuNgay) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.roleAdmin),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isTuNgay) {
          _tuNgay = picked;
        } else {
          _denNgay = picked;
        }
      });
      _loadOrders();
    }
  }

  Future<void> _xuatExcel() async {
    setState(() => _isExporting = true);
    final path = await _controller.xuatBaoCaoExcel(_orders);
    setState(() => _isExporting = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          path != null ? Icons.check_circle : Icons.error,
          color: Colors.white,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            path != null
                ? '✅ Xuất Excel thành công!\n📁 $path'
                : '❌ Lỗi xuất file Excel!',
          ),
        ),
      ]),
      backgroundColor: path != null ? Colors.green.shade700 : Colors.red,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Tổng kết ─────────────────────────────────────────────────────
  int get _tongDoanhThu =>
      _orders.fold(0, (sum, o) => sum + o.tongTienMon);
  int get _tongPhiShip =>
      _orders.fold(0, (sum, o) => sum + o.phiShipThucTe);
  int get _soLuongThanhCong =>
      _orders.where((o) => o.thanhCong || o.daGiao).length;

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('📊 Đối soát Tài chính',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.roleAdmin,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.file_download),
            onPressed: (_isExporting || _orders.isEmpty) ? null : _xuatExcel,
            tooltip: 'Xuất Excel',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.list_alt), text: 'Danh sách đơn'),
            Tab(icon: Icon(Icons.pie_chart), text: 'Tổng kết'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.roleAdmin))
          : Column(children: [
              // ── Filter bar ─────────────────────────────────────
              _buildFilterBar(),

              // ── Stats header ───────────────────────────────────
              _buildStatsHeader(),

              // ── Tabs content ───────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrdersList(),
                    _buildSummaryTab(),
                  ],
                ),
              ),
            ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (_isExporting || _orders.isEmpty) ? null : _xuatExcel,
        backgroundColor: AppColors.roleMerchant,
        foregroundColor: Colors.white,
        icon: _isExporting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.file_download),
        label: Text(_isExporting ? 'Đang xuất...' : 'Xuất Excel'),
      ),
    );
  }

  Widget _buildFilterBar() {
    final fmt = DateFormat('dd/MM/yyyy');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(children: [
        const Icon(Icons.filter_alt, size: 18, color: AppColors.roleAdmin),
        const SizedBox(width: 8),
        const Text('Lọc:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today, size: 14),
            label: Text(
              _tuNgay != null ? 'Từ: ${fmt.format(_tuNgay!)}' : 'Từ ngày',
              style: const TextStyle(fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.roleAdmin,
              side: const BorderSide(color: AppColors.roleAdmin),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
            onPressed: () => _pickDate(true),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.calendar_month, size: 14),
            label: Text(
              _denNgay != null ? 'Đến: ${fmt.format(_denNgay!)}' : 'Đến ngày',
              style: const TextStyle(fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.roleAdmin,
              side: const BorderSide(color: AppColors.roleAdmin),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
            onPressed: () => _pickDate(false),
          ),
        ),
        if (_tuNgay != null || _denNgay != null) ...[
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.clear, size: 18, color: Colors.red),
            onPressed: () {
              setState(() {
                _tuNgay = null;
                _denNgay = null;
              });
              _loadOrders();
            },
            tooltip: 'Xóa filter',
            splashRadius: 18,
          ),
        ],
      ]),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.roleAdmin, AppColors.roleAdminDark],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.roleAdmin.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
              '📦', 'Tổng đơn', _orders.length.toString()),
          _buildDivider(),
          _buildStatItem(
              '✅', 'Thành công', _soLuongThanhCong.toString()),
          _buildDivider(),
          _buildStatItem(
              '💰', 'Doanh thu', '${_currency.format(_tongDoanhThu)}đ'),
          _buildDivider(),
          _buildStatItem(
              '🚗', 'Phí ship', '${_currency.format(_tongPhiShip)}đ'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value) {
    return Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 16)),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      Text(
        label,
        style: const TextStyle(color: Colors.white60, fontSize: 10),
      ),
    ]);
  }

  Widget _buildDivider() =>
      Container(width: 1, height: 40, color: Colors.white30);

  // ── Tab 1: Danh sách đơn hàng ─────────────────────────────────────
  Widget _buildOrdersList() {
    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Không có đơn hàng nào',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
      itemCount: _orders.length,
      itemBuilder: (_, i) => _buildOrderCard(_orders[i]),
    );
  }

  Widget _buildOrderCard(OrderModel o) {
    final statusColor = _statusColor(o.trangThaiDonHang);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Mã đơn + trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  o.maDonHang,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      fontFamily: 'monospace'),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    o.trangThaiDonHang,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Row 2: Khách – Quán – Tài xế
            Row(children: [
              const Icon(Icons.person, size: 13, color: Colors.grey),
              const SizedBox(width: 4),
              Text(o.tenKhachHang,
                  style: const TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              const Icon(Icons.restaurant, size: 13, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                  child: Text(o.tenQuan,
                      style: const TextStyle(fontSize: 12,
                          color: Colors.grey),
                      overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.local_shipping, size: 13, color: Colors.grey),
              const SizedBox(width: 4),
              Text(o.tenTaiXe ?? 'Chưa có tài xế',
                  style: TextStyle(
                      fontSize: 12,
                      color:
                          o.tenTaiXe != null ? Colors.grey : Colors.orange)),
              const Spacer(),
              Text(
                o.ngayGiao,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ]),
            const Divider(height: 12),
            // Row 3: Tài chính
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMiniStat('Món', '${_currency.format(o.tongTienMon)}đ'),
                _buildMiniStat('Ship', '${_currency.format(o.phiShipThucTe)}đ'),
                _buildMiniStat(
                    'Tổng TT',
                    '${_currency.format(o.tongThanhToan)}đ',
                    highlight: true),
                _buildMiniStat(
                    'Hoàn',
                    '${_currency.format(o.tienDuocHoan)}đ',
                    isGreen: o.tienDuocHoan > 0),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value,
      {bool highlight = false, bool isGreen = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: highlight
                ? AppColors.roleAdmin
                : isGreen
                    ? Colors.green
                    : AppColors.textDark,
          ),
        ),
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  // ── Tab 2: Tổng kết theo quán ─────────────────────────────────────
  Widget _buildSummaryTab() {
    // Nhóm theo quán
    final Map<String, List<OrderModel>> byQuan = {};
    for (var o in _orders) {
      byQuan[o.tenQuan] = [...(byQuan[o.tenQuan] ?? []), o];
    }

    if (byQuan.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Không có dữ liệu để tổng kết',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      children: [
        const Text(
          '📊 Doanh thu theo quán:',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.textDark),
        ),
        const SizedBox(height: 10),
        ...byQuan.entries.map((entry) {
          final tenQuan = entry.key;
          final donList = entry.value;
          final tongDT = donList.fold(0, (s, o) => s + o.tongTienMon);
          final soThanhCong =
              donList.where((o) => o.thanhCong || o.daGiao).length;
          final ck = (tongDT * 0.15).round();

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.restaurant,
                      color: AppColors.roleAdmin, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tenQuan,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  Text(
                    '${donList.length} đơn',
                    style: const TextStyle(
                        color: AppColors.roleAdmin,
                        fontWeight: FontWeight.bold),
                  ),
                ]),
                const Divider(height: 12),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuanStat(
                          'Tổng DT', '${_currency.format(tongDT)}đ'),
                      _buildQuanStat('Thành công', '$soThanhCong'),
                      _buildQuanStat(
                          'CK 15%', '${_currency.format(ck)}đ',
                          isHighlight: true),
                    ]),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(children: [
                    const Icon(Icons.info_outline,
                        size: 14, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text(
                      'Chuyển khoản: ${_currency.format(ck)}đ × 0.15 = '
                      '${_currency.format(ck)}đ',
                      style: const TextStyle(fontSize: 11, color: Colors.brown),
                    ),
                  ]),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuanStat(String label, String value,
      {bool isHighlight = false}) {
    return Column(children: [
      Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: isHighlight ? Colors.green.shade700 : AppColors.textDark,
        ),
      ),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
    ]);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Đã giao':
        return Colors.green;
      case 'Thành công':
        return Colors.blue;
      case 'Chờ chốt':
        return Colors.orange;
      case 'Đã hủy tự động':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
