import 'package:flutter/material.dart';
import 'package:shared/models/merchant_model.dart';
import 'cart_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../core/utils/time_helper.dart';

/// Màn hình Chi tiết Quán ăn — xem thực đơn và thêm vào giỏ
class MerchantDetailScreen extends StatefulWidget {
  final MerchantModel merchant;

  const MerchantDetailScreen({super.key, required this.merchant});

  @override
  State<MerchantDetailScreen> createState() => _MerchantDetailScreenState();
}

class _MerchantDetailScreenState extends State<MerchantDetailScreen> {
  final _cart = CartController.instance;

  @override
  void initState() {
    super.initState();
    _cart.setMerchant(widget.merchant);
  }

  void _themMon(FoodItem food) {
    setState(() => _cart.themMon(food));
  }

  void _botMon(FoodItem food) {
    setState(() => _cart.botMon(food.maMon));
  }

  void _hienThiGhiChu(FoodItem food) {
    final controller = TextEditingController(text: _cart.items
        .where((i) => i.maMon == food.maMon)
        .firstOrNull?.ghiChuMon ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Ghi chú cho "${food.tenMon}"',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'VD: Không hành, ít cay, ít cơm...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 46,
            child: ElevatedButton(
              onPressed: () {
                setState(() => _cart.capNhatGhiChu(food.maMon, controller.text.trim().isEmpty ? null : controller.text.trim()));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Lưu ghi chú'),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final merchant = widget.merchant;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar với gradient
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(merchant.tenQuan,
                style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Icon(Icons.restaurant, color: Colors.white54, size: 60),
                  ],
                ),
              ),
            ),
          ),

          // Thông tin quán
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
                    blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(child: Text(merchant.diaChi,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.delivery_dining, size: 16, color: AppColors.accent),
                  const SizedBox(width: 4),
                  Text(merchant.tuyenGiaoHang,
                    style: const TextStyle(color: AppColors.accent, fontSize: 13)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.star, size: 16, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text('${merchant.danhGia.toStringAsFixed(1)} / 5.0  •  Miễn phí ship khi gom đủ người',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ]),
              ]),
            ),
          ),

          // Tiêu đề thực đơn
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('🍽️ Thực đơn',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            ),
          ),

          // Danh sách món
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _buildFoodItem(merchant.thucDon[i]),
              childCount: merchant.thucDon.length,
            ),
          ),

          // Padding cuối tránh nút
          const SliverToBoxAdapter(child: SizedBox(height: 90)),
        ],
      ),

      // Nút xem giỏ hàng (hiện khi có món)
      bottomNavigationBar: _cart.isEmpty
          ? null
          : _buildCartBar(),
    );
  }

  Widget _buildFoodItem(FoodItem food) {
    final soLuong = _cart.getSoLuong(food.maMon);
    final ghiChu = _cart.items.where((i) => i.maMon == food.maMon).firstOrNull?.ghiChuMon;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: soLuong > 0 ? AppColors.cardBg : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: soLuong > 0 ? AppColors.primary.withOpacity(0.3) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        // Icon món
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.fastfood, color: AppColors.primary, size: 26),
        ),
        const SizedBox(width: 12),

        // Tên & giá
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(food.tenMon,
            style: const TextStyle(fontWeight: FontWeight.bold,
                fontSize: 14, color: AppColors.textPrimary)),
          if (food.moTaMon != null) ...[
            const SizedBox(height: 2),
            Text(food.moTaMon!,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
          if (ghiChu != null) ...[
            const SizedBox(height: 2),
            GestureDetector(
              onTap: () => _hienThiGhiChu(food),
              child: Row(children: [
                const Icon(Icons.edit_note, size: 14, color: AppColors.accent),
                const SizedBox(width: 2),
                Expanded(child: Text('📝 $ghiChu',
                  style: const TextStyle(color: AppColors.accent, fontSize: 11),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            ),
          ],
          const SizedBox(height: 4),
          Text(TimeHelper.formatVND(food.giaTien),
            style: const TextStyle(color: AppColors.primary,
                fontWeight: FontWeight.bold, fontSize: 14)),
        ])),

        // Controls
        Row(children: [
          if (soLuong > 0) ...[
            // Nút ghi chú
            GestureDetector(
              onTap: () => _hienThiGhiChu(food),
              child: Container(
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.notes, size: 18, color: AppColors.textSecondary),
              ),
            ),
            // Nút -
            _buildCountBtn(Icons.remove, () => _botMon(food)),
            Container(
              width: 28, alignment: Alignment.center,
              child: Text('$soLuong',
                style: const TextStyle(fontWeight: FontWeight.bold,
                    fontSize: 16, color: AppColors.primary)),
            ),
          ],
          // Nút +
          _buildCountBtn(Icons.add, () => _themMon(food), filled: true),
        ]),
      ]),
    );
  }

  Widget _buildCountBtn(IconData icon, VoidCallback onTap, {bool filled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
        ),
        child: Icon(icon, size: 18,
            color: filled ? Colors.white : AppColors.primary),
      ),
    );
  }

  Widget _buildCartBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${_cart.tongSoLuong}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Text('Xem giỏ hàng',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
          Text(TimeHelper.formatVND(_cart.tongTienMon),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}
