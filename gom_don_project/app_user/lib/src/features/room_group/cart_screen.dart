import 'package:flutter/material.dart';
import 'package:shared/models/order_model.dart';
import '../search_food/cart_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../core/utils/time_helper.dart';

/// Màn hình Giỏ hàng — xem lại món + ghi chú trước khi đặt
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cart = CartController.instance;

  void _themMon(OrderItem item) {
    final food = _cart.merchant!.thucDon.firstWhere((f) => f.maMon == item.maMon);
    setState(() => _cart.themMon(food));
  }

  void _botMon(OrderItem item) {
    setState(() => _cart.botMon(item.maMon));
  }

  void _xoaMon(OrderItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa món?'),
        content: Text('Bỏ "${item.tenMon}" khỏi giỏ hàng?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              while (_cart.getSoLuong(item.maMon) > 0) { _cart.botMon(item.maMon); }
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _cart.items;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Giỏ hàng', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Xóa toàn bộ?'),
                  content: const Text('Bỏ tất cả món trong giỏ?'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                    TextButton(
                      onPressed: () { setState(() => _cart.clearCart()); Navigator.pop(context); Navigator.pop(context); },
                      child: const Text('Xóa tất cả', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              ),
              child: const Text('Xóa tất', style: TextStyle(color: Colors.white70)),
            ),
        ],
      ),
      body: items.isEmpty
          ? _buildEmptyCart()
          : Column(children: [
              // Thông tin quán
              if (_cart.merchant != null)
                _buildMerchantHeader(),

              // Danh sách món
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _buildCartItem(items[i]),
                ),
              ),

              // Footer tổng tiền + nút đặt
              _buildFooter(),
            ]),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.textHint),
        const SizedBox(height: 16),
        const Text('Giỏ hàng trống', style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        const Text('Hãy chọn món từ quán ăn yêu thích',
            style: TextStyle(color: AppColors.textHint)),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Chọn quán ăn'),
        ),
      ]),
    );
  }

  Widget _buildMerchantHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppColors.primary.withOpacity(0.05),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.restaurant, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_cart.merchant!.tenQuan,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Text(_cart.merchant!.diaChi,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ])),
      ]),
    );
  }

  Widget _buildCartItem(OrderItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        // Tên & ghi chú
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.tenMon,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(TimeHelper.formatVND(item.giaTien),
            style: const TextStyle(color: AppColors.primary, fontSize: 13)),
          if (item.ghiChuMon != null) ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.notes, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 3),
              Expanded(child: Text(item.ghiChuMon!,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ],
        ])),

        // Controls
        Row(children: [
          GestureDetector(
            onTap: () => _xoaMon(item),
            child: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
          ),
          const SizedBox(width: 8),
          _countBtn(Icons.remove, () => _botMon(item)),
          Container(
            width: 32, alignment: Alignment.center,
            child: Text('${item.soLuong}',
              style: const TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 16, color: AppColors.primary)),
          ),
          _countBtn(Icons.add, () => _themMon(item), filled: true),
        ]),
      ]),
    );
  }

  Widget _countBtn(IconData icon, VoidCallback onTap, {bool filled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
        ),
        child: Icon(icon, size: 16, color: filled ? Colors.white : AppColors.primary),
      ),
    );
  }

  Widget _buildFooter() {
    final tongTien = _cart.tongTienMon;
    final phiShipGoc = 30000; // Mock phí ship đi một mình

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08),
            blurRadius: 12, offset: const Offset(0, -3))],
      ),
      child: Column(children: [
        // Tóm tắt chi phí
        _buildRow('Tiền món:', TimeHelper.formatVND(tongTien)),
        _buildRow('Phí ship tối đa:', TimeHelper.formatVND(phiShipGoc), color: AppColors.textSecondary),
        const Divider(height: 16),
        _buildRow('Tạm khóa ví:', TimeHelper.formatVND(tongTien + phiShipGoc),
            isBold: true, color: AppColors.warning),
        const SizedBox(height: 12),

        // Nút đặt chung
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.roomDetail),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('🍽️ Vào Phòng Gom Đơn',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(value, style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: color ?? AppColors.textPrimary,
        )),
      ]),
    );
  }
}
