import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/models/merchant_model.dart';
import 'package:shared/services/firebase_core.dart';
import 'package:shared/test/mock_data.dart';

/// Controller: Xử lý tìm kiếm & lọc quán ăn / món ăn
class SearchFoodController {
  List<MerchantModel> _allMerchants = [];
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Lấy toàn bộ danh sách quán (từ Mock hoặc Firebase)
  Future<List<MerchantModel>> layTatCaQuan() async {
    if (!FirebaseCoreService.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 500));
      _allMerchants = MockData.mockMerchants
          .where((m) => m.dangHoatDong)
          .toList();
      return _allMerchants;
    }

    try {
      final snapshot = await _db.collection('merchants').get();
      _allMerchants = snapshot.docs
          .map((doc) => MerchantModel.fromJson({...doc.data(), 'MaQuan': doc.id}))
          .where((m) => m.dangHoatDong)
          .toList();
      return _allMerchants;
    } catch (e) {
      print('❌ Lỗi layTatCaQuan Firestore: $e');
      return [];
    }
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
