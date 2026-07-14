import 'package:flutter/material.dart';
import 'package:shared/models/hub_model.dart';
import 'package:shared/models/room_model.dart';
import 'package:shared/test/mock_data.dart';
import '../../core/app_colors.dart';
import '../search_food/merchant_detail_screen.dart';
import 'home_controller.dart';
import 'room_preview_sheet.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onSearchTapped;
  const HomeScreen({super.key, this.onSearchTapped});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = HomeController();

  String _searchQuery = '';
  String _activeCategory = 'Tất cả';

  // Trạng thái hub & phòng
  HubModel? _currentHub;
  List<RoomModel> _activeRooms = [];
  bool _isLoadingRooms = true;

  final List<String> _categories = [
    'Tất cả', 'Cơm', 'Bún', 'Bánh Mì', 'Nước uống'
  ];

  final List<Map<String, dynamic>> _foods = [
    {
      'id': 1,
      'name': 'Cơm Gà Xối Mỡ',
      'merchantId': 'QA001',
      'restaurant': 'Cơm Tấm Sài Gòn',
      'price': '45.000đ',
      'originalPrice': '52.000đ',
      'rating': 4.8,
      'orders': 120,
      'tag': 'Freeship',
      'emoji': '🍗',
      'category': 'Cơm',
    },
    {
      'id': 2,
      'name': 'Bún Bò Huế Đặc Biệt',
      'merchantId': 'QA002',
      'restaurant': 'Bún Bò Huế Mệ Toàn',
      'price': '55.000đ',
      'originalPrice': null,
      'rating': 4.7,
      'orders': 88,
      'tag': 'Hot',
      'emoji': '🍜',
      'category': 'Bún',
    },
    {
      'id': 3,
      'name': 'Cơm Sườn Bì Chả',
      'merchantId': 'QA001',
      'restaurant': 'Cơm Tấm Sài Gòn',
      'price': '50.000đ',
      'originalPrice': '58.000đ',
      'rating': 4.9,
      'orders': 205,
      'tag': 'Bán chạy',
      'emoji': '🍖',
      'category': 'Cơm',
    },
    {
      'id': 4,
      'name': 'Bánh Mì Đặc Biệt',
      'merchantId': 'QA005',
      'restaurant': 'Bánh Mì Hội An Xưa',
      'price': '25.000đ',
      'originalPrice': null,
      'rating': 4.6,
      'orders': 340,
      'tag': 'Freeship',
      'emoji': '🥖',
      'category': 'Bánh Mì',
    },
  ];

  // ─────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadHubAndRooms();
  }

  /// Load hub hiện tại và danh sách phòng đang hoạt động
  Future<void> _loadHubAndRooms() async {
    setState(() => _isLoadingRooms = true);
    final hub = await _controller.layHubHienTai();
    List<RoomModel> rooms = [];
    if (hub != null) {
      rooms = await _controller.layPhongHoatDong(hub.maHub);
    }
    if (mounted) {
      setState(() {
        _currentHub = hub;
        _activeRooms = rooms;
        _isLoadingRooms = false;
      });
    }
  }

  // ─────────────────────────────────────────────────────────────
  // ACTION: Đổi Hub
  // ─────────────────────────────────────────────────────────────

  void _showDoiHubSheet() {
    if (_currentHub == null) return;

    final hubsCungTuyen = _controller.layHubCungTuyen(_currentHub!);

    // Không có hub cùng tuyến → thông báo không thể đổi
    if (hubsCungTuyen.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Không thể đổi Hub — Hub hiện tại không có Hub nào khác cùng tuyến giao hàng',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // Có hub cùng tuyến → mở bottom sheet chọn
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildDoiHubSheet(hubsCungTuyen),
    );
  }

  Widget _buildDoiHubSheet(List<HubModel> hubsCungTuyen) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // Tiêu đề
          Row(
            children: [
              const Icon(Icons.swap_horiz, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Đổi Hub nhận hàng',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Các Hub cùng tuyến giao hàng với "${_currentHub!.tenHub}"',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Hub hiện tại (disabled)
          _buildHubOptionTile(
            hub: _currentHub!,
            isCurrent: true,
            distanceText: '📍 Hub hiện tại của bạn',
            onTap: null,
          ),

          const Divider(height: 20),
          const Text(
            'Hub cùng tuyến',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textHint),
          ),
          const SizedBox(height: 8),

          // Danh sách hub cùng tuyến
          ...hubsCungTuyen.map((hub) {
            final dist =
                _controller.khoangCachGiuaHai(_currentHub!, hub);
            final distText = dist >= 1000
                ? '~${(dist / 1000).toStringAsFixed(1)} km'
                : '~${dist.round()} m';
            return _buildHubOptionTile(
              hub: hub,
              isCurrent: false,
              distanceText: '📏 Cách hub hiện tại $distText',
              onTap: () async {
                Navigator.pop(context);
                await _controller.doiHub(hub.maHub);
                _loadHubAndRooms();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Đã chuyển sang: ${hub.tenHub}'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHubOptionTile({
    required HubModel hub,
    required bool isCurrent,
    required String distanceText,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCurrent
              ? AppColors.primary.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCurrent
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.primaryDark.withValues(alpha: 0.1),
            width: isCurrent ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.primary
                    : AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.business,
                size: 18,
                color: isCurrent ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hub.tenHub,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCurrent
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hub.diaChi,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    distanceText,
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          isCurrent ? AppColors.primary : AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isCurrent)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 20)
            else
              const Icon(Icons.chevron_right,
                  color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ACTION: Xem phòng
  // ─────────────────────────────────────────────────────────────

  void _xemPhongChiTiet(RoomModel room) {
    if (_currentHub == null) return;
    final hub = MockData.getHubById(room.maHubGoc) ?? _currentHub!;
    showRoomPreviewSheet(context, room: room, hub: hub);
  }

  // ─────────────────────────────────────────────────────────────
  // ACTION: Chọn quán
  // ─────────────────────────────────────────────────────────────

  void _chonQuan(String merchantId) {
    final merchant = MockData.getMerchantById(merchantId);
    if (merchant != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => MerchantDetailScreen(merchant: merchant)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy thông tin quán!')),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final filteredFoods = _foods.where((f) {
      final matchCat =
          _activeCategory == 'Tất cả' || f['category'] == _activeCategory;
      final matchSearch = f['name']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          f['restaurant']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadHubAndRooms,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBanner(),
                    _buildActiveRooms(),
                    _buildCategories(),
                    _buildFoodGrid(filteredFoods),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TOP BAR — Hub thật + nút đổi hub
  // ─────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    final hubName = _currentHub?.tenHub ?? 'Đang xác định hub...';
    final isLoadingHub = _currentHub == null && _isLoadingRooms;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, Color(0xFF1A3AFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.8)),
                        const SizedBox(width: 4),
                        Text(
                          'Hub của bạn',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: isLoadingHub
                              ? Container(
                                  height: 16,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                )
                              : Text(
                                  hubName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                        // Nút đổi hub
                        if (!isLoadingHub && _currentHub != null)
                          GestureDetector(
                            onTap: _showDoiHubSheet,
                            child: Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color:
                                    Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                      Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.swap_horiz,
                                      size: 12, color: Colors.white),
                                  SizedBox(width: 3),
                                  Text(
                                    'Đổi Hub',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Thông báo
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Không có thông báo mới!')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_none,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: AppColors.orange, shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search bar
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onSearchTapped,
                    child: AbsorbPointer(
                      child: TextField(
                        onChanged: (val) =>
                            setState(() => _searchQuery = val),
                        style: const TextStyle(
                            color: AppColors.primaryDark, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Tìm món, tìm quán...',
                          hintStyle: TextStyle(
                              color: AppColors.primaryDark
                                  .withValues(alpha: 0.5),
                              fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _searchQuery = ''),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Xóa',
                          style: TextStyle(
                              color: AppColors.primary, fontSize: 12)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // BANNER
  // ─────────────────────────────────────────────────────────────

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -24,
            right: -24,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.beige.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -32,
            right: -8,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.flash_on, color: AppColors.beige, size: 14),
                    SizedBox(width: 4),
                    Text('Ưu đãi hôm nay',
                        style: TextStyle(
                            color: AppColors.beige,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Gom Đơn – Freeship\nSảnh Văn Phòng',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Gom đủ người → Ship miễn phí tận sảnh 🎉',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('☀️ Gom đơn ngay',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Chốt lúc 10h00',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ACTIVE ROOMS — Dữ liệu thật từ mock data
  // ─────────────────────────────────────────────────────────────

  Widget _buildActiveRooms() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.local_fire_department,
                      color: AppColors.orange, size: 18),
                  SizedBox(width: 4),
                  Text('Phòng gom đang hoạt động',
                      style: TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              GestureDetector(
                onTap: _loadHubAndRooms,
                child: const Row(
                  children: [
                    Text('Làm mới',
                        style: TextStyle(
                            color: AppColors.primary, fontSize: 12)),
                    Icon(Icons.refresh,
                        color: AppColors.primary, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Trạng thái loading
          if (_isLoadingRooms)
            _buildRoomsLoadingState()
          else if (_activeRooms.isEmpty)
            _buildNoRoomsState()
          else
            ..._activeRooms.map((room) => _buildRoomCard(room)),
        ],
      ),
    );
  }

  Widget _buildRoomsLoadingState() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.beige.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('Đang tải phòng gom đơn...',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildNoRoomsState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.beige.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.orange.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          const Text(
            'Chưa có phòng gom đơn nào',
            style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            _currentHub == null
                ? 'Vui lòng chọn Hub trước'
                : 'Hãy là người đầu tiên đặt chung tại ${_currentHub!.tenHub}!',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(RoomModel room) {
    final hub = MockData.getHubById(room.maHubGoc);
    final hubName = hub?.tenHub ?? room.maHubGoc;
    final tongSoLuong = room.tongSoMon;
    final soThanhVien = room.soThanhVien;
    final isDangGopHub = room.dangGopHub;

    // Progress bar: tỷ lệ lấp đầy (mục tiêu tối thiểu 5 người)
    final double pct = (soThanhVien / 5.0).clamp(0.0, 1.0);
    final int conThieu = (5 - soThanhVien).clamp(0, 5);

    // Màu card: tím khi đang gộp, cam khi bình thường
    final cardBorderColor = isDangGopHub
        ? const Color(0xFF9333EA).withValues(alpha: 0.35)
        : AppColors.orange.withValues(alpha: 0.2);
    final cardBgColor = isDangGopHub
        ? const Color(0xFFF5F3FF)
        : AppColors.beige;

    return GestureDetector(
      onTap: () => _xemPhongChiTiet(room),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: (isDangGopHub
                      ? const Color(0xFF9333EA)
                      : AppColors.orange)
                  .withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon hub
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDangGopHub ? Icons.merge_type : Icons.business,
                color: isDangGopHub
                    ? const Color(0xFF7C3AED)
                    : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hubName,
                          style: TextStyle(
                              color: isDangGopHub
                                  ? const Color(0xFF6B21A8)
                                  : AppColors.primaryDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Badge trạng thái
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDangGopHub
                              ? const Color(0xFF9333EA).withValues(alpha: 0.15)
                              : AppColors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isDangGopHub
                                  ? const Color(0xFF9333EA)
                                      .withValues(alpha: 0.4)
                                  : AppColors.orange.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          isDangGopHub ? '📡 Đang gộp' : room.trangThaiPhong,
                          style: TextStyle(
                              color: isDangGopHub
                                  ? const Color(0xFF7C3AED)
                                  : AppColors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Banner gộp Hub (hiển khi đang gộp)
                  if (isDangGopHub) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6B21A8), Color(0xFF9333EA)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⚡',
                              style: TextStyle(fontSize: 10)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Gộp từ: ${room.danhSachHubGop.map((id) => MockData.getHubById(id)?.tenHub.split(' ').first ?? id).join(' + ')}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${room.banKinhHienTai}m',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Thông tin: số thành viên & số món — ẩn danh
                  Row(
                    children: [
                      const Icon(Icons.people,
                          color: AppColors.textSecondary, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '$soThanhVien thành viên',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.restaurant_menu,
                          color: AppColors.orange, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '$tongSoLuong món',
                        style: const TextStyle(
                            color: AppColors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: (isDangGopHub
                                  ? const Color(0xFF9333EA)
                                  : AppColors.orange)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: pct,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: isDangGopHub
                                ? const Color(0xFF9333EA)
                                : AppColors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (conThieu > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        isDangGopHub
                            ? 'Bán kính đã mở rộng — cần thêm $conThieu người nữa'
                            : 'Cần thêm $conThieu người nữa để Freeship!',
                        style: TextStyle(
                            color: isDangGopHub
                                ? const Color(0xFF7C3AED)
                                : AppColors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  // Gợi ý nhấn để xem
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline,
                            size: 10, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          'Nhấn để xem danh sách món • tên người được bảo mật',
                          style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textHint
                                  .withValues(alpha: 0.8),
                              fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(Icons.chevron_right,
                  color: AppColors.primary, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CATEGORIES
  // ─────────────────────────────────────────────────────────────

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.shopping_bag, color: AppColors.primary, size: 18),
                SizedBox(width: 8),
                Text('Món ngon hôm nay',
                    style: TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isActive = cat == _activeCategory;
                return GestureDetector(
                  onTap: () => setState(() => _activeCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: isActive
                          ? null
                          : Border.all(
                              color: AppColors.primaryDark
                                  .withValues(alpha: 0.15)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : AppColors.primaryDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // FOOD GRID
  // ─────────────────────────────────────────────────────────────

  Widget _buildFoodGrid(List<Map<String, dynamic>> filteredFoods) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: filteredFoods.length,
        itemBuilder: (context, index) {
          final food = filteredFoods[index];
          return GestureDetector(
            onTap: () => _chonQuan(food['merchantId']),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.primaryDark.withValues(alpha: 0.07)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.beige,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(food['emoji'],
                              style: const TextStyle(fontSize: 48)),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: food['tag'] == 'Freeship'
                                    ? AppColors.primary
                                    : (food['tag'] == 'Hot'
                                        ? AppColors.orange
                                        : AppColors.primaryDark),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(food['tag'],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food['name'],
                          style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          food['restaurant'],
                          style: TextStyle(
                              color: AppColors.primaryDark
                                  .withValues(alpha: 0.5),
                              fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '${food['rating']} · ${food['orders']} đã bán',
                              style: TextStyle(
                                  color: AppColors.primaryDark
                                      .withValues(alpha: 0.6),
                                  fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(food['price'],
                                    style: const TextStyle(
                                        color: AppColors.orange,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                if (food['originalPrice'] != null)
                                  Text(food['originalPrice'],
                                      style: TextStyle(
                                          color: AppColors.primaryDark
                                              .withValues(alpha: 0.35),
                                          fontSize: 11,
                                          decoration:
                                              TextDecoration.lineThrough)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('Đặt chung',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
