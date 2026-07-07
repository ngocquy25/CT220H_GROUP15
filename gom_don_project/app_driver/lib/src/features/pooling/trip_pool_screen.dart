import 'package:flutter/material.dart';
import 'package:shared/models/room_model.dart';
import 'trip_pool_controller.dart';

/// Màn hình Danh sách Chuyến xe - Hiển thị sau 10:05
/// Tài xế nhìn thấy tất cả phòng gom thành công cần giao
class TripPoolScreen extends StatefulWidget {
  const TripPoolScreen({super.key});

  @override
  State<TripPoolScreen> createState() => _TripPoolScreenState();
}

class _TripPoolScreenState extends State<TripPoolScreen> {
  final _controller = TripPoolController();
  List<RoomModel> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    final rooms = await _controller.layDanhSachPhongThanhCong();
    setState(() { _rooms = rooms; _isLoading = false; });
  }

  Future<void> _nhanChuyen(RoomModel room) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nhận chuyến xe?'),
        content: Text('Bạn muốn nhận giao hàng cho phòng ${room.maPhong}?\n'
            '${room.soThanhVien} khách • ${room.tongSoMon} món'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2980B9),
                foregroundColor: Colors.white),
            child: const Text('Nhận chuyến')),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _controller.nhanChuyen(room.maPhong, 'TX_MOCK');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? '✅ Đã nhận chuyến ${room.maPhong}!' : '❌ Chuyến đã được nhận bởi tài xế khác'),
          backgroundColor: success ? Colors.green : Colors.red,
        ));
        if (success) _loadRooms();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Danh sách chuyến xe', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2980B9),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadRooms),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rooms.isEmpty
              ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.no_transfer, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Chưa có chuyến xe nào.\nCập nhật lúc 10:05 sáng mỗi ngày.',
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _rooms.length,
                  itemBuilder: (_, i) => _buildRoomCard(_rooms[i]),
                ),
    );
  }

  Widget _buildRoomCard(RoomModel room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08),
            blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(room.maPhong, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Thành công', style: TextStyle(color: Colors.green, fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 8),
          Text('📍 Hub: ${room.maHubGoc}', style: TextStyle(color: Colors.grey[600])),
          Text('📅 Ngày: ${room.ngayGiao}', style: TextStyle(color: Colors.grey[600])),
          Text('👥 ${room.soThanhVien} khách • 🍽️ ${room.tongSoMon} món',
            style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _nhanChuyen(room),
              icon: const Icon(Icons.delivery_dining),
              label: const Text('Nhận chuyến', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2980B9), foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
