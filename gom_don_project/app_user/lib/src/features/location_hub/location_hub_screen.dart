import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared/models/hub_model.dart';
import 'location_hub_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_routes.dart';

/// Màn hình Định vị & Chọn Hub
/// - Dùng GPS thật (Geolocator) để xác định vị trí người dùng
/// - Xếp người dùng vào Hub cố định trong bán kính 500m
/// - Fallback: hiện toàn bộ Hub nếu GPS không khả dụng
class LocationHubScreen extends StatefulWidget {
  const LocationHubScreen({super.key});

  @override
  State<LocationHubScreen> createState() => _LocationHubScreenState();
}

class _LocationHubScreenState extends State<LocationHubScreen>
    with SingleTickerProviderStateMixin {
  final _controller = LocationHubController();
  List<HubModel> _nearbyHubs = [];
  HubModel? _selectedHub;
  bool _isLoading = true;
  bool _checkingCache = true;
  LocationStatus _locationStatus = LocationStatus.success;
  bool _isInRadius = true; // false nếu không có Hub trong 500m (hiện fallback)

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _checkCachedHub();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  /// Nếu đã từng chọn Hub → skip thẳng vào Home
  Future<void> _checkCachedHub() async {
    final savedHub = await _controller.layHubDaLuu();
    if (savedHub != null && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }
    setState(() => _checkingCache = false);
    _loadNearbyHubs();
  }

  Future<void> _loadNearbyHubs() async {
    setState(() {
      _isLoading = true;
      _locationStatus = LocationStatus.success;
    });

    final result = await _controller.layHubGanNhat();

    if (!mounted) return;

    // Cờ: có phải đang dùng GPS thật và có Hub gần 500m không?
    final gotRealGps = result.status == LocationStatus.success;
    // Nếu status=success nhưng hub count > 3 → không có Hub trong 500m (fallback all)
    final hasNearbyInRadius = gotRealGps && result.hubs.length <= 3;

    setState(() {
      _nearbyHubs = result.hubs;
      _locationStatus = result.status;
      _isLoading = false;
      _isInRadius = hasNearbyInRadius;
    });
  }

  void _chonHub(HubModel hub) => setState(() => _selectedHub = hub);

  Future<void> _xacNhanHub() async {
    if (_selectedHub == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Vui lòng chọn một Hub gần bạn!')),
      );
      return;
    }
    await _controller.luuHubDaChon(_selectedHub!.maHub);
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  /// Mở cài đặt hệ thống để user cấp quyền GPS
  Future<void> _moiCaiDat() async {
    await Geolocator.openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingCache) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header gradient ──
          _buildHeader(),

          // ── Thân: danh sách Hub hoặc trạng thái ──
          Expanded(
            child: _isLoading ? _buildLoadingState() : _buildContent(),
          ),

          // ── Nút xác nhận ──
          _buildConfirmButton(),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // HEADER
  // ────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // Pulse animation trên icon GPS
          ScaleTransition(
            scale: _pulseAnim,
            child: const Icon(Icons.my_location, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Chọn điểm nhận hàng',
              style: TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        _buildStatusChip(),
      ]),
    );
  }

  /// Chip hiển thị trạng thái GPS ngay dưới tiêu đề
  Widget _buildStatusChip() {
    String label;
    Color color;
    IconData icon;

    switch (_locationStatus) {
      case LocationStatus.success:
        if (_isInRadius) {
          label = '📍 GPS đã xác định — Hiện Hub gần bạn';
          color = Colors.green.shade300;
          icon = Icons.gps_fixed;
        } else {
          label = '📍 GPS hoạt động — Không có Hub trong 500m, chọn thủ công';
          color = Colors.orange.shade300;
          icon = Icons.gps_not_fixed;
        }
        break;
      case LocationStatus.permissionDenied:
        label = '⚠️ Quyền GPS bị từ chối — Chọn Hub thủ công';
        color = Colors.orange.shade300;
        icon = Icons.location_off;
        break;
      case LocationStatus.serviceDisabled:
        label = '⚠️ GPS đang tắt — Vui lòng bật GPS';
        color = Colors.red.shade300;
        icon = Icons.location_disabled;
        break;
      case LocationStatus.error:
        label = '⚠️ Lỗi định vị — Chọn Hub thủ công';
        color = Colors.orange.shade300;
        icon = Icons.wifi_tethering_error;
        break;
    }

    if (_isLoading) {
      return const Row(children: [
        SizedBox(
          width: 14, height: 14,
          child: CircularProgressIndicator(
            color: Colors.white70, strokeWidth: 2,
          ),
        ),
        SizedBox(width: 8),
        Text('🔍 Đang quét vị trí GPS...',
            style: TextStyle(color: Colors.white70, fontSize: 13)),
      ]);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Flexible(
          child: Text(label,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }

  // ────────────────────────────────────────────
  // LOADING STATE
  // ────────────────────────────────────────────

  Widget _buildLoadingState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        ScaleTransition(
          scale: _pulseAnim,
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.gps_fixed, color: AppColors.primary, size: 40),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Đang lấy vị trí GPS...',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('Vui lòng đảm bảo GPS đang bật',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 24),
        const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
      ]),
    );
  }

  // ────────────────────────────────────────────
  // CONTENT (sau khi có kết quả)
  // ────────────────────────────────────────────

  Widget _buildContent() {
    switch (_locationStatus) {
      case LocationStatus.serviceDisabled:
        return _buildServiceDisabledState();
      case LocationStatus.permissionDenied:
        return _buildPermissionDeniedState();
      case LocationStatus.error:
        return _buildErrorState();
      case LocationStatus.success:
        return _buildHubList();
    }
  }

  // ────────────────────────────────────────────
  // DANH SÁCH HUB
  // ────────────────────────────────────────────

  Widget _buildHubList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label phân biệt: Hub gần / Tất cả Hub
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(children: [
            Icon(
              _isInRadius ? Icons.near_me : Icons.list_alt,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              _isInRadius
                  ? '${_nearbyHubs.length} Hub gần bạn (trong 500m)'
                  : 'Tất cả Hub — Chọn Hub gần nhất với bạn',
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
          ]),
        ),

        // ListView Hub
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            itemCount: _nearbyHubs.length,
            itemBuilder: (_, i) => _buildHubCard(_nearbyHubs[i], i),
          ),
        ),
      ],
    );
  }

  Widget _buildHubCard(HubModel hub, int index) {
    final isSelected = _selectedHub?.maHub == hub.maHub;
    final distM = _controller.tinhKhoangCachDenHub(hub);
    final distText = distM == null
        ? 'Không xác định'
        : distM >= 1000
            ? '${(distM / 1000).toStringAsFixed(1)} km'
            : '${distM.round()} m';

    return GestureDetector(
      onTap: () => _chonHub(hub),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardBg : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10, offset: const Offset(0, 3),
          )],
        ),
        child: Row(children: [
          // Icon Hub
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.business,
                color: isSelected ? Colors.white : AppColors.textSecondary),
          ),
          const SizedBox(width: 14),

          // Thông tin Hub
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(hub.tenHub, style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            )),
            const SizedBox(height: 4),
            Text(hub.diaChi, style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.straighten, size: 13, color: AppColors.accent),
              const SizedBox(width: 4),
              Text(
                distM != null ? 'Cách bạn ~$distText' : distText,
                style: TextStyle(
                  fontSize: 12,
                  color: distM == null ? AppColors.textHint : AppColors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.radar, size: 13, color: AppColors.textHint),
              const SizedBox(width: 3),
              Text('Bán kính ${hub.banKinhMacDinh}m',
                style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
            ]),
          ])),

          // Check icon
          if (isSelected)
            const Icon(Icons.check_circle, color: AppColors.primary, size: 28),
        ]),
      ),
    );
  }

  // ────────────────────────────────────────────
  // TRẠNG THÁI LỖI
  // ────────────────────────────────────────────

  Widget _buildPermissionDeniedState() {
    return _buildFallbackWithMessage(
      icon: Icons.location_off,
      iconColor: Colors.orange,
      title: 'Quyền GPS bị từ chối',
      subtitle: 'Bạn chưa cho phép truy cập vị trí.\nVui lòng cấp quyền để hệ thống tự động tìm Hub gần nhất.',
      actionLabel: '⚙️ Mở Cài Đặt',
      onAction: _moiCaiDat,
      showHubList: true,
    );
  }

  Widget _buildServiceDisabledState() {
    return _buildFallbackWithMessage(
      icon: Icons.location_disabled,
      iconColor: Colors.red,
      title: 'GPS đang tắt',
      subtitle: 'Vui lòng bật GPS (Vị trí) trên thiết bị\nrồi thử lại để hệ thống tìm Hub gần nhất.',
      actionLabel: '📡 Bật GPS',
      onAction: () async {
        await Geolocator.openLocationSettings();
        _loadNearbyHubs();
      },
      showHubList: true,
    );
  }

  Widget _buildErrorState() {
    return _buildFallbackWithMessage(
      icon: Icons.wifi_tethering_error,
      iconColor: AppColors.error,
      title: 'Không thể lấy vị trí',
      subtitle: 'Có lỗi xảy ra khi đọc GPS.\nBạn có thể chọn Hub thủ công bên dưới.',
      actionLabel: '🔄 Thử lại',
      onAction: _loadNearbyHubs,
      showHubList: true,
    );
  }

  Widget _buildFallbackWithMessage({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
    bool showHubList = false,
  }) {
    return Column(
      children: [
        // Banner cảnh báo
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: iconColor.withValues(alpha: 0.3)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(
                  color: iconColor, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12, height: 1.5)),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.open_in_new, size: 14),
                label: Text(actionLabel, style: const TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: iconColor,
                  side: BorderSide(color: iconColor),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ])),
          ]),
        ),

        // Phân cách
        if (showHubList && _nearbyHubs.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('Chọn Hub thủ công',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textHint.withValues(alpha: 0.8))),
              ),
              const Expanded(child: Divider()),
            ]),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              itemCount: _nearbyHubs.length,
              itemBuilder: (_, i) => _buildHubCard(_nearbyHubs[i], i),
            ),
          ),
        ],
      ],
    );
  }

  // ────────────────────────────────────────────
  // NÚT XÁC NHẬN
  // ────────────────────────────────────────────

  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity, height: 54,
        child: ElevatedButton(
          onPressed: _selectedHub != null ? _xacNhanHub : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.textHint,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            _selectedHub != null
                ? '✅ Xác nhận: ${_selectedHub!.tenHub}'
                : 'Chưa chọn Hub — Vui lòng chọn',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
