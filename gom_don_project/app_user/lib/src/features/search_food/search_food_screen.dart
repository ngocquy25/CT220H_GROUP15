import 'package:flutter/material.dart';
import 'package:shared/models/merchant_model.dart';
import 'search_food_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/utils/time_helper.dart';
import 'merchant_detail_screen.dart';

/// Màn hình Tìm kiếm & Lọc món ăn / quán ăn
/// Đây là Tab đầu tiên trong HomeWrapper
class SearchFoodScreen extends StatefulWidget {
  const SearchFoodScreen({super.key});

  @override
  State<SearchFoodScreen> createState() => _SearchFoodScreenState();
}

class _SearchFoodScreenState extends State<SearchFoodScreen> {
  final _controller = SearchFoodController();
  final _searchCtrl = TextEditingController();
  List<MerchantModel> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
    _searchCtrl.addListener(_onSearchChanged);
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    final list = await _controller.layTatCaQuan();
    setState(() { _results = list; _isLoading = false; });
  }

  void _onSearchChanged() {
    final filtered = _controller.timKiem(_searchCtrl.text);
    setState(() => _results = filtered);
  }

  void _chonQuan(MerchantModel merchant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MerchantDetailScreen(merchant: merchant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: const Text('GomĐơn 🛵',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: '🔍 Tìm tên món hoặc tên quán...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    filled: true, fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),
            ),
          ),

          // Banner cảnh báo nếu đã qua 10h
          if (TimeHelper.daQua10h)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                ),
                child: const Row(children: [
                  Icon(Icons.info_outline, color: AppColors.warning),
                  SizedBox(width: 8),
                  Expanded(child: Text(
                    '⏰ Đã qua 10h — Hệ thống đang nhận đơn giao vào trưa mai',
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 13),
                  )),
                ]),
              ),
            ),

          // Banner khuyến mãi
          if (!TimeHelper.daQua10h)
            SliverToBoxAdapter(
              child: _buildPromoBanner(),
            ),

          // Tiêu đề danh sách
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(children: [
                const Text('🏪 Quán ăn đối tác',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${_results.length} quán',
                      style: const TextStyle(color: AppColors.primary,
                          fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ]),
            ),
          ),

          // Danh sách quán
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
              : _results.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.search_off, size: 60, color: AppColors.textHint),
                        SizedBox(height: 12),
                        Text('Không tìm thấy quán nào',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ])))
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _buildMerchantCard(_results[i]),
                          childCount: _results.length,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        // Gradient tươi trẻ: Xanh app → Tím → Hồng rực
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0046FF), // Xanh chủ đạo app
            Color(0xFF7B2FFF), // Tím sôi động
            Color(0xFFFF3CAC), // Hồng rực
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B2FFF).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── Decorative dots nền (tạo chiều sâu) ──
          Positioned(
            right: -10, top: -20,
            child: Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            right: 40, bottom: -30,
            child: Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // ── Nội dung chính ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Phần text slogan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge "App Slogan"
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '✨  GOM ĐƠN',
                          style: AppTextStyles.badgeVi.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Slogan dòng 1: "Gom đơn cho người cô"
                      Text(
                        'Gom đơn cho người cô',
                        style: AppTextStyles.slogan.copyWith(
                          color: Colors.white,
                        ),
                      ),

                      // Slogan dòng 2: '"đơn"' — highlight riêng
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700), // Vàng gold nổi bật
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '"đơn"',
                              style: AppTextStyles.slogan.copyWith(
                                fontSize: 20,
                                color: const Color(0xFF2D0080),
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '🤝',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Icon minh họa
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🛵', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(8),
                      ),
                       child: Text(
                        'FREE SHIP',
                        style: AppTextStyles.labelAscii.copyWith(
                          color: const Color(0xFF2D0080),
                        ),
                      ),
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


  Widget _buildMerchantCard(MerchantModel merchant) {
    return GestureDetector(
      onTap: () => _chonQuan(merchant),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12, offset: const Offset(0, 4),
          )],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header quán — gradient
          Container(
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withValues(alpha: 0.85), AppColors.primaryDark],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(children: [
              const Center(child: Icon(Icons.restaurant, color: Colors.white54, size: 48)),
              // Badge đánh giá
              Positioned(
                top: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(children: [
                    const Icon(Icons.star, size: 13, color: Colors.amber),
                    const SizedBox(width: 3),
                    Text(merchant.danhGia.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white,
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
              // Tên quán
              Positioned(
                bottom: 10, left: 12,
                child: Text(merchant.tenQuan,
                    style: const TextStyle(color: Colors.white,
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.location_on, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 3),
                Expanded(child: Text(merchant.diaChi,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.delivery_dining, size: 13, color: AppColors.accent),
                const SizedBox(width: 3),
                Expanded(child: Text(merchant.tuyenGiaoHang,
                    style: const TextStyle(fontSize: 12, color: AppColors.accent))),
              ]),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              // 3 món đầu tiên
              ...merchant.thucDon.take(3).map((food) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  const Text('•', style: TextStyle(color: AppColors.textHint)),
                  const SizedBox(width: 6),
                  Expanded(child: Text(food.tenMon,
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                  Text(TimeHelper.formatVND(food.giaTien),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ]),
              )),
              if (merchant.thucDon.length > 3)
                Text('+${merchant.thucDon.length - 3} món khác...',
                    style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
              const SizedBox(height: 6),
              // Nút Đặt món
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _chonQuan(merchant),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Xem thực đơn & Đặt món',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}
