import 'package:flutter/material.dart';
import 'package:shared/models/hub_model.dart';
import 'location_hub_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_routes.dart';

/// Màn hình Định vị & Chọn Hub
/// - Hiển thị vị trí GPS + danh sách Hub gần nhất
/// - Bắt buộc chọn Hub trước khi vào màn hình chính
class LocationHubScreen extends StatefulWidget {
  const LocationHubScreen({super.key});

  @override
  State<LocationHubScreen> createState() => _LocationHubScreenState();
}

class _LocationHubScreenState extends State<LocationHubScreen> {
  final _controller = LocationHubController();
  List<HubModel> _nearbyHubs = [];
  HubModel? _selectedHub;
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadNearbyHubs();
  }

  Future<void> _loadNearbyHubs() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    try {
      final hubs = await _controller.layHubGanNhat();
      setState(() { _nearbyHubs = hubs; _isLoading = false; });
    } catch (e) {
      setState(() { _errorMsg = e.toString(); _isLoading = false; });
    }
  }

  void _chonHub(HubModel hub) {
    setState(() => _selectedHub = hub);
  }

  Future<void> _xacNhanHub() async {
    if (_selectedHub == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Vui lòng chọn một Hub gần bạn!')),
      );
      return;
    }
    await _controller.luuHubDaChon(_selectedHub!.maHub);
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.searchFood);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chọn điểm nhận hàng', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Banner hướng dẫn
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: const Text(
              '📍 Hệ thống đang quét vị trí của bạn để tìm Hub giao hàng gần nhất trong bán kính 500m',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _errorMsg != null
                    ? _buildErrorState()
                    : _buildHubList(),
          ),

          // Nút xác nhận
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _selectedHub != null ? _xacNhanHub : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.textHint,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  _selectedHub != null ? 'Xác nhận Hub: ${_selectedHub!.tenHub}' : 'Chưa chọn Hub',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHubList() {
    if (_nearbyHubs.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.location_off, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          const Text('Không tìm thấy Hub nào\ntrong bán kính 500m của bạn',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          TextButton(onPressed: _loadNearbyHubs, child: const Text('Thử lại')),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _nearbyHubs.length,
      itemBuilder: (_, i) {
        final hub = _nearbyHubs[i];
        final isSelected = _selectedHub?.maHub == hub.maHub;
        return GestureDetector(
          onTap: () => _chonHub(hub),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.cardBg : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
              boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10, offset: const Offset(0, 3),
              )],
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.business,
                  color: isSelected ? Colors.white : AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(hub.tenHub, style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                )),
                const SizedBox(height: 4),
                Text(hub.diaChi, style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.my_location, size: 12, color: AppColors.accent),
                  const SizedBox(width: 4),
                  Text('Bán kính ${hub.banKinhMacDinh}m',
                    style: const TextStyle(fontSize: 11, color: AppColors.accent)),
                ]),
              ])),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.primary),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, size: 64, color: AppColors.error),
        const SizedBox(height: 16),
        const Text('Không thể lấy vị trí GPS.\nVui lòng kiểm tra quyền truy cập.',
          textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _loadNearbyHubs, child: const Text('Thử lại')),
      ]),
    );
  }
}
