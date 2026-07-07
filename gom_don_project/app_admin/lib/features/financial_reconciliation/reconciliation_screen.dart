import 'package:flutter/material.dart';
import 'package:shared/models/order_model.dart';
import 'reconciliation_controller.dart';

/// Màn hình Đối soát Tài chính - Xuất báo cáo Excel cuối tháng
class ReconciliationScreen extends StatefulWidget {
  const ReconciliationScreen({super.key});

  @override
  State<ReconciliationScreen> createState() => _ReconciliationScreenState();
}

class _ReconciliationScreenState extends State<ReconciliationScreen> {
  final _controller = ReconciliationController();
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orders = await _controller.layLichSuDon();
    setState(() { _orders = orders; _isLoading = false; });
  }

  Future<void> _xuatExcel() async {
    setState(() => _isExporting = true);
    final path = await _controller.xuatBaoCaoExcel(_orders);
    setState(() => _isExporting = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(path != null ? '✅ Đã xuất Excel: $path' : '❌ Lỗi xuất file!'),
        backgroundColor: path != null ? Colors.purple : Colors.red,
      ));
    }
  }

  int get _tongDoanhThu => _orders.fold(0, (sum, o) => sum + o.tongTienMon);
  int get _tongPhiShip => _orders.fold(0, (sum, o) => sum + o.phiShipThucTe);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FA),
      appBar: AppBar(
        title: const Text('Đối soát tài chính', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF8E44AD),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: _isExporting
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.download),
            onPressed: _isExporting ? null : _xuatExcel,
            tooltip: 'Xuất Excel',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              // Tổng kết
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8E44AD), Color(0xFF6C3483)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _buildStat('📦 Tổng đơn', '${_orders.length}'),
                  Container(width: 1, height: 40, color: Colors.white30),
                  _buildStat('💰 Doanh thu', '${_tongDoanhThu ~/ 1000}K'),
                  Container(width: 1, height: 40, color: Colors.white30),
                  _buildStat('🚗 Phí ship', '${_tongPhiShip ~/ 1000}K'),
                ]),
              ),

              // Nút xuất Excel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isExporting ? null : _xuatExcel,
                    icon: const Icon(Icons.file_download),
                    label: const Text('Xuất báo cáo Excel', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60), foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Bảng dữ liệu
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: DataTable(
                      columnSpacing: 20,
                      headingRowColor: WidgetStateProperty.all(
                        const Color(0xFF8E44AD).withOpacity(0.1)),
                      columns: const [
                        DataColumn(label: Text('Mã đơn', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Khách', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Quán', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Tài xế', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Tiền món', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Phí ship', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: _orders.map((o) => DataRow(cells: [
                        DataCell(Text(o.maDonHang, style: const TextStyle(fontSize: 12))),
                        DataCell(Text(o.tenKhachHang)),
                        DataCell(Text(o.tenQuan)),
                        DataCell(Text(o.tenTaiXe ?? '—')),
                        DataCell(Text('${o.tongTienMon}đ')),
                        DataCell(Text('${o.phiShipThucTe}đ')),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _statusColor(o.trangThaiDonHang).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(o.trangThaiDonHang,
                            style: TextStyle(color: _statusColor(o.trangThaiDonHang),
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        )),
                      ])).toList(),
                    ),
                  ),
                ),
              ),
            ]),
    );
  }

  Widget _buildStat(String label, String value) => Column(children: [
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
    Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
  ]);

  Color _statusColor(String status) {
    switch (status) {
      case 'Đã giao': return Colors.green;
      case 'Thành công': return Colors.blue;
      case 'Chờ chốt': return Colors.orange;
      case 'Đã hủy tự động': return Colors.red;
      default: return Colors.grey;
    }
  }
}
