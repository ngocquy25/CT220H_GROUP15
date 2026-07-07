import 'package:flutter/material.dart';
import 'package:shared/models/order_model.dart';
import 'verification_controller.dart';

/// Màn hình Xác thực giao hàng bằng PIN hoặc QR Code
class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _controller = VerificationController();
  List<OrderModel> _orders = [];
  final Map<String, TextEditingController> _pinControllers = {};
  final Map<String, bool> _verified = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orders = await _controller.layDanhSachDonCuaPhong('PHONG002');
    for (var o in orders) {
      _pinControllers[o.maDonHang] = TextEditingController();
      _verified[o.maDonHang] = false;
    }
    setState(() { _orders = orders; _isLoading = false; });
  }

  Future<void> _xacNhanhPin(OrderModel order) async {
    final pin = _pinControllers[order.maDonHang]?.text ?? '';
    final ok = await _controller.xacNhanhPin(order.maDonHang, pin, order.maXacThuc);
    setState(() => _verified[order.maDonHang] = ok);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? '✅ Xác nhận thành công! Đã giao cho ${order.tenKhachHang}' : '❌ Mã PIN sai!'),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Xác nhận giao hàng', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2980B9),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              itemBuilder: (_, i) => _buildOrderCard(_orders[i]),
            ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final isVerified = _verified[order.maDonHang] ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isVerified ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified ? Colors.green : Colors.transparent, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08),
            blurRadius: 10, offset: const Offset(0, 3))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(order.tenKhachHang,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          if (isVerified)
            const Chip(label: Text('✅ Đã giao'),
              backgroundColor: Colors.green, labelStyle: TextStyle(color: Colors.white)),
        ]),
        Text(order.soDienThoaiKhach, style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 8),
        ...order.danhSachMonAn.map((item) => Text('• ${item.tenMon} x${item.soLuong}',
          style: const TextStyle(fontSize: 13))),
        const SizedBox(height: 12),
        if (!isVerified) ...[
          TextField(
            controller: _pinControllers[order.maDonHang],
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: InputDecoration(
              labelText: '🔐 Nhập mã PIN 4 số',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              counterText: '',
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _xacNhanhPin(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2980B9), foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Xác nhận giao hàng'),
            ),
          ),
        ],
      ]),
    );
  }

  @override
  void dispose() {
    for (var c in _pinControllers.values) c.dispose();
    super.dispose();
  }
}
