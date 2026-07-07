import 'package:flutter/material.dart';
import 'package:shared/models/merchant_model.dart';
import 'search_food_controller.dart';
import '../../core/app_colors.dart';
import '../../core/utils/time_helper.dart';
import '../room_group/room_detail_screen.dart';

/// Màn hình Tìm kiếm & Lọc món ăn / quán ăn
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
    final list = await _controller.layTatCaQuan();
    setState(() { _results = list; _isLoading = false; });
  }

  void _onSearchChanged() {
    final filtered = _controller.timKiem(_searchCtrl.text);
    setState(() => _results = filtered);
  }

  void _chonQuan(MerchantModel merchant) {
    Navigator.pushNamed(context, '/room-detail',
      arguments: {'merchant': merchant});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chọn quán ăn', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Tìm tên món hoặc tên quán...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Cảnh báo nếu đã qua 10h (đặt cho ngày mai)
          if (TimeHelper.daQua10h)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: AppColors.warning.withOpacity(0.15),
              child: Row(children: [
                const Icon(Icons.info_outline, color: AppColors.warning),
                const SizedBox(width: 8),
                const Expanded(child: Text(
                  '⏰ Hệ thống đang nhận đơn giao vào trưa mai',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                )),
              ]),
            ),

          // Danh sách quán
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _results.isEmpty
                    ? const Center(child: Text('Không tìm thấy quán nào',
                        style: TextStyle(color: AppColors.textSecondary)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _results.length,
                        itemBuilder: (_, i) => _buildMerchantCard(_results[i]),
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
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12, offset: const Offset(0, 4),
          )],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header quán
          Container(
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.8), AppColors.primaryDark],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.restaurant, color: Colors.white, size: 32),
              const SizedBox(height: 6),
              Text(merchant.tenQuan,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ])),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(child: Text(merchant.diaChi,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(children: [
                    const Icon(Icons.star, size: 12, color: AppColors.success),
                    const SizedBox(width: 2),
                    Text(merchant.danhGia.toStringAsFixed(1),
                      style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ]),
              const SizedBox(height: 8),
              Text('🛵 ${merchant.tuyenGiaoHang}',
                style: const TextStyle(fontSize: 12, color: AppColors.accent)),
              const SizedBox(height: 8),
              // 3 món đầu tiên
              ...merchant.thucDon.take(3).map((food) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Text('• ${food.tenMon}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                  Text(TimeHelper.formatVND(food.giaTien),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
                ]),
              )),
              if (merchant.thucDon.length > 3)
                Text('+${merchant.thucDon.length - 3} món khác...',
                  style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
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
