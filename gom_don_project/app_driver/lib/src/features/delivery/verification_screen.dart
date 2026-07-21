import 'package:flutter/material.dart';
import 'package:shared/models/order_model.dart';
import 'package:shared/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'verification_controller.dart';

/// Màn hình Xác thực giao hàng bằng PIN hoặc QR Code
class VerificationScreen extends StatefulWidget {
  final String? maPhong; // Có thể null để xem danh sách chuyến đã nhận

  const VerificationScreen({super.key, this.maPhong});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _controller = VerificationController();
  List<OrderModel> _orders = [];
  final Map<String, TextEditingController> _pinControllers = {};
  final Map<String, bool> _verified = {};
  final Map<String, bool> _pinLoading = {};
  bool _isLoading = true;
  String? _selectedRoom;
  List<String> _myAcceptedRooms = [];
  final _currency = NumberFormat('#,###', 'vi_VN');

  @override
  void initState() {
    super.initState();
    _selectedRoom = widget.maPhong;
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    if (_selectedRoom != null) {
      await _loadOrders(_selectedRoom!);
    } else {
      await _loadMyAcceptedRooms();
    }
  }

  Future<void> _loadMyAcceptedRooms() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .where('MaTaiXe', isEqualTo: 'DRIVER_TEST')
          .get();

      final rooms = snapshot.docs.map((doc) => doc.id).toList();
      setState(() {
        _myAcceptedRooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      print('Lỗi load danh sách phòng: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadOrders(String maPhong) async {
    final orders = await _controller.layDanhSachDonCuaPhong(maPhong);

    // Giải phóng controllers cũ
    _pinControllers.forEach((key, ctrl) => ctrl.dispose());
    _pinControllers.clear();
    _verified.clear();
    _pinLoading.clear();

    for (var o in orders) {
      _pinControllers[o.maDonHang] = TextEditingController();
      _verified[o.maDonHang] = o.trangThaiDonHang == 'Đã giao';
      _pinLoading[o.maDonHang] = false;
    }
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  // ── Xác nhận PIN ─────────────────────────────────────────────────
  Future<void> _xacNhanPin(OrderModel order) async {
    final pin = _pinControllers[order.maDonHang]?.text.trim() ?? '';
    if (pin.isEmpty) {
      _showSnack('Vui lòng nhập mã PIN 4 số!', isError: true);
      return;
    }

    setState(() => _pinLoading[order.maDonHang] = true);
    final ok =
        await _controller.xacNhanhPin(order.maDonHang, pin, order.maXacThuc);
    setState(() {
      _pinLoading[order.maDonHang] = false;
      if (ok) _verified[order.maDonHang] = true;
    });

    if (!mounted) return;
    if (ok) {
      _pinControllers[order.maDonHang]?.clear();
      _showSnack('✅ Đã giao thành công cho ${order.tenKhachHang}!');
    } else {
      _showSnack('❌ Mã PIN không chính xác!', isError: true);
    }
  }

  // ── Giả lập quét QR ──────────────────────────────────────────────
  Future<void> _quetMaQR(OrderModel order) async {
    final qrCode = await showDialog<String>(
      context: context,
      builder: (context) {
        String inputVal = '';
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: const [
            Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 28),
            SizedBox(width: 10),
            Text('Quét mã QR', style: TextStyle(fontWeight: FontWeight.bold)),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Khách hàng ${order.tenKhachHang} sẽ hiện mã QR trên điện thoại.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              // Mock QR input
              TextField(
                autofocus: true,
                onChanged: (val) => inputVal = val,
                keyboardType: TextInputType.number,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: 'Nhập nội dung mã QR',
                  hintText: '${order.maXacThuc} hoặc ${order.maDonHang}',
                  prefixIcon: const Icon(Icons.qr_code),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '💡 Demo: Nhập PIN "${order.maXacThuc}" hoặc mã đơn "${order.maDonHang}" để test.',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, inputVal),
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: const Text('Xác nhận quét'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        );
      },
    );

    if (qrCode != null && qrCode.isNotEmpty) {
      setState(() => _pinLoading[order.maDonHang] = true);
      final ok = await _controller.xacNhanQR(
          order.maDonHang, qrCode, order.maXacThuc);
      setState(() {
        _pinLoading[order.maDonHang] = false;
        if (ok) _verified[order.maDonHang] = true;
      });
      if (!mounted) return;
      _showSnack(
        ok
            ? '🎉 Quét QR thành công! Đã giao cho ${order.tenKhachHang}'
            : '❌ Mã QR không hợp lệ!',
        isError: !ok,
      );
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          isError ? Colors.red.shade700 : Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Tính tỉ lệ giao hàng
    final total = _orders.length;
    final done = _verified.values.where((v) => v).length;
    final progress = total == 0 ? 0.0 : done / total;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _selectedRoom != null
              ? 'Giao hàng: $_selectedRoom'
              : 'Chuyến xe của tôi',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: _selectedRoom != null && widget.maPhong == null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedRoom = null;
                    _orders.clear();
                    _isLoading = true;
                  });
                  _initData();
                },
              )
            : null,
        bottom: _selectedRoom != null && total > 0
            ? PreferredSize(
                preferredSize: const Size.fromHeight(6),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white30,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : null,
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primary))
          : _selectedRoom != null
              ? _buildOrderListView(done, total)
              : _buildRoomSelectionView(),
    );
  }

  // ── Tab: Chọn phòng ───────────────────────────────────────────────
  Widget _buildRoomSelectionView() {
    if (_myAcceptedRooms.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_car_filled_outlined,
                  size: 90, color: Colors.grey.shade300),
              const SizedBox(height: 20),
              const Text(
                'Bạn chưa nhận chuyến nào hôm nay!',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Vào "Danh sách chuyến xe" để nhận chuyến trước.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Quay lại danh sách'),
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Bạn đang phụ trách ${_myAcceptedRooms.length} chuyến. Chọn phòng để bắt đầu xác nhận giao hàng.',
                style: const TextStyle(fontSize: 13, color: AppColors.primary),
              ),
            ),
          ]),
        ),
        ..._myAcceptedRooms.map((room) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  setState(() {
                    _selectedRoom = room;
                    _isLoading = true;
                  });
                  _loadOrders(room);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color:
                            AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.inventory_2,
                          color: AppColors.primary, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(room,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontFamily: 'monospace')),
                          const Text('Xem danh sách & Xác nhận giao',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey),
                  ]),
                ),
              ),
            )),
      ],
    );
  }

  // ── Tab: Danh sách đơn của phòng ─────────────────────────────────
  Widget _buildOrderListView(int done, int total) {
    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Không có đơn hàng nào trong phòng này.',
                style: TextStyle(color: Colors.grey, fontSize: 15)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary bar
        _buildProgressSummary(done, total),
        const SizedBox(height: 12),
        ..._orders.map((o) => _buildOrderCard(o)),
      ],
    );
  }

  Widget _buildProgressSummary(int done, int total) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: done == total
              ? [Colors.green.shade600, Colors.green.shade800]
              : [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Tổng đơn', total.toString()),
          _buildSummaryItem('Đã giao', done.toString()),
          _buildSummaryItem('Còn lại', '${total - done}'),
          _buildSummaryItem(
            'Tiến độ',
            '${(done / total * 100).toStringAsFixed(0)}%',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(children: [
      Text(value,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold)),
      Text(label,
          style:
              const TextStyle(color: Colors.white70, fontSize: 11)),
    ]);
  }

  // ── Card đơn hàng ─────────────────────────────────────────────────
  Widget _buildOrderCard(OrderModel order) {
    final isVerified = _verified[order.maDonHang] ?? false;
    final isLoading = _pinLoading[order.maDonHang] ?? false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isVerified ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified
              ? Colors.green.shade400
              : Colors.grey.shade100,
          width: isVerified ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Header: tên khách + trạng thái ──────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                CircleAvatar(
                  backgroundColor: isVerified
                      ? Colors.green.shade100
                      : AppColors.primary.withOpacity(0.1),
                  radius: 22,
                  child: Text(
                    order.tenKhachHang.isNotEmpty
                        ? order.tenKhachHang[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isVerified
                          ? Colors.green.shade700
                          : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(order.tenKhachHang,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(
                    order.soDienThoaiKhach,
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 13),
                  ),
                ]),
              ]),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(children: [
                    Icon(Icons.check, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Đã giao',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ]),
                ),
            ],
          ),
          const Divider(height: 16),

          // ── Chi tiết món ──────────────────────────────────────
          Text('Quán: ${order.tenQuan}',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: 6),
          ...order.danhSachMonAn.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 8, top: 1),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(item.tenMon,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                  ),
                  Text('x${item.soLuong}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(width: 12),
                  Text(
                    '${_currency.format(item.thanhTien)}đ',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                ]),
              )),

          // Ghi chú món
          ...order.danhSachMonAn
              .where((i) =>
                  i.ghiChuMon != null && i.ghiChuMon!.isNotEmpty)
              .map((i) => Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      const Icon(Icons.notes, size: 13,
                          color: Colors.orange),
                      const SizedBox(width: 6),
                      Text(
                        '${i.tenMon}: "${i.ghiChuMon}"',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.deepOrange),
                      ),
                    ]),
                  )),

          // ── Phần xác nhận (chỉ hiện nếu chưa giao) ──────────
          if (!isVerified) ...[
            const Divider(height: 20),
            Row(children: [
              // PIN input
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _pinControllers[order.maDonHang],
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8),
                  decoration: InputDecoration(
                    hintText: '••••',
                    hintStyle: TextStyle(
                        color: Colors.grey.shade300,
                        letterSpacing: 8,
                        fontSize: 20),
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Nút xác nhận PIN
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => _xacNhanPin(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Nhập PIN',
                            style: TextStyle(
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            // Nút quét QR
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () => _quetMaQR(order),
                icon: const Icon(Icons.qr_code_scanner,
                    color: AppColors.primary, size: 20),
                label: const Text('📲 Quét mã QR của khách',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ] else ...[
            // Khi đã giao xong
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(children: [
                Icon(Icons.verified, color: Colors.green, size: 18),
                SizedBox(width: 8),
                Text(
                  'Đã xác nhận giao hàng thành công!',
                  style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  @override
  void dispose() {
    for (var c in _pinControllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}
