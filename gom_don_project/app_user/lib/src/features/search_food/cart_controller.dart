import 'package:shared/models/merchant_model.dart';
import 'package:shared/models/order_model.dart';

/// Singleton quản lý giỏ hàng trong session hiện tại
/// Mỗi lần vào quán mới → gọi clearCart() trước
class CartController {
  CartController._();
  static final CartController instance = CartController._();

  MerchantModel? _merchant; // Quán đang đặt
  final Map<String, OrderItem> _items = {}; // maMon → OrderItem

  // ── Getters ──────────────────────────────────────
  MerchantModel? get merchant => _merchant;

  List<OrderItem> get items => _items.values.toList();

  int get tongSoLuong => _items.values.fold(0, (s, i) => s + i.soLuong);

  int get tongTienMon => _items.values.fold(0, (s, i) => s + i.thanhTien);

  bool get isEmpty => _items.isEmpty;

  // ── Mutators ─────────────────────────────────────

  /// Khởi tạo giỏ cho quán mới (xóa toàn bộ nếu đổi quán)
  void setMerchant(MerchantModel merchant) {
    if (_merchant?.maQuan != merchant.maQuan) {
      _items.clear();
    }
    _merchant = merchant;
  }

  /// Thêm 1 đơn vị món vào giỏ
  void themMon(FoodItem food) {
    if (_items.containsKey(food.maMon)) {
      final curr = _items[food.maMon]!;
      _items[food.maMon] = curr.copyWith(soLuong: curr.soLuong + 1);
    } else {
      _items[food.maMon] = OrderItem(
        maMon: food.maMon,
        tenMon: food.tenMon,
        soLuong: 1,
        giaTien: food.giaTien,
      );
    }
  }

  /// Giảm 1 đơn vị món (xóa nếu về 0)
  void botMon(String maMon) {
    if (!_items.containsKey(maMon)) return;
    final curr = _items[maMon]!;
    if (curr.soLuong <= 1) {
      _items.remove(maMon);
    } else {
      _items[maMon] = curr.copyWith(soLuong: curr.soLuong - 1);
    }
  }

  /// Lấy số lượng hiện tại của một món
  int getSoLuong(String maMon) => _items[maMon]?.soLuong ?? 0;

  /// Cập nhật ghi chú cho một món
  void capNhatGhiChu(String maMon, String? ghiChu) {
    if (_items.containsKey(maMon)) {
      _items[maMon] = _items[maMon]!.copyWith(ghiChuMon: ghiChu);
    }
  }

  /// Xóa toàn bộ giỏ hàng
  void clearCart() {
    _items.clear();
    _merchant = null;
  }
}
