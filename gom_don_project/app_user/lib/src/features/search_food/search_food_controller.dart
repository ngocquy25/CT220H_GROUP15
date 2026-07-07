import 'package:shared/models/merchant_model.dart';
import 'package:shared/test/mock_data.dart';

/// Controller: Xử lý tìm kiếm & lọc quán ăn / món ăn
class SearchFoodController {
  List<MerchantModel> _allMerchants = [];

  /// Lấy toàn bộ danh sách quán (từ Mock hoặc Firebase)
  Future<List<MerchantModel>> layTatCaQuan() async {
    // Giả lập độ trễ mạng
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: Thay bằng Firestore: FirebaseFirestore.instance.collection('merchants').get()
    _allMerchants = MockData.mockMerchants
        .where((m) => m.dangHoatDong)
        .toList();
    return _allMerchants;
  }

  /// Lọc theo tên quán HOẶC tên món ăn (không phân biệt hoa/thường)
  List<MerchantModel> timKiem(String keyword) {
    if (keyword.trim().isEmpty) return _allMerchants;
    final kw = keyword.toLowerCase().trim();
    return _allMerchants.where((merchant) {
      // Khớp tên quán
      if (merchant.tenQuan.toLowerCase().contains(kw)) return true;
      // Khớp tên món ăn
      return merchant.thucDon.any((food) => food.tenMon.toLowerCase().contains(kw));
    }).toList();
  }
}
