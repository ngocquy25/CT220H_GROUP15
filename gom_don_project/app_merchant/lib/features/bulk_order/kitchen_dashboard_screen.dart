import 'package:flutter/material.dart';
import 'package:shared/theme/app_colors.dart';
import 'kitchen_dashboard_controller.dart';

/// Màn hình Bảng điều khiển Bếp - Đơn tổng (Bulk Order) lúc 10:00
class KitchenDashboardScreen extends StatefulWidget {
  const KitchenDashboardScreen({super.key});

  @override
  State<KitchenDashboardScreen> createState() => _KitchenDashboardScreenState();
}

class _KitchenDashboardScreenState extends State<KitchenDashboardScreen> {
  final _controller = KitchenDashboardController();
  Map<String, int> _bulkOrder = {};
  List<Map<String, dynamic>> _notesList = [];
  bool _isReady = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBulkOrder();
  }

  Future<void> _loadBulkOrder() async {
    final bulk = await _controller.layDonTong('ROOM_001', maQuan: 'QA001');
    final notes = await _controller.layGhiChuRieng('ROOM_001', maQuan: 'QA001');
    setState(() { _bulkOrder = bulk; _notesList = notes; _isLoading = false; });
  }

  Future<void> _xacNhanXongBep() async {
    await _controller.xacNhanChuanBiXong('ROOM_001');
    setState(() => _isReady = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Đã thông báo! Tài xế sẽ đến lấy hàng sớm.'),
        backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Đơn tổng bếp 🍳', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.roleMerchant,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Banner thời gian
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.roleMerchant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(children: [
                    Text('⏰ ĐÃ ĐẾN 10:00 SÁNG', style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Chuẩn bị đơn hàng hàng loạt theo danh sách dưới đây',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
                ),
                const SizedBox(height: 16),

                // Danh sách tổng theo món
                const Text('📋 Danh sách nấu theo món:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ..._bulkOrder.entries.map((e) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
                        blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(e.key, style: const TextStyle(fontSize: 15)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.roleMerchant.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('×${e.value}', style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.roleMerchant)),
                    ),
                  ]),
                )),

                // Ghi chú riêng
                if (_notesList.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('📝 Ghi chú đặc biệt từng khách:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ..._notesList.map((note) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(note['tenMon'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('👤 ${note['khach']}: "${note['ghiChu']}"',
                        style: const TextStyle(color: Colors.orange, fontSize: 13)),
                    ]),
                  )),
                ],

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _isReady ? null : _xacNhanXongBep,
                    icon: Icon(_isReady ? Icons.check_circle : Icons.check),
                    label: Text(_isReady ? 'Đã thông báo tài xế!' : 'Xác nhận chuẩn bị xong → Gọi tài xế',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isReady ? Colors.grey : AppColors.roleMerchant,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ]),
            ),
    );
  }
}
