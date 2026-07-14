import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/models/hub_model.dart';
import 'package:shared/services/firebase_core.dart';
import 'package:shared/test/mock_data.dart';

/// Controller: Quản lý Hub (CRUD) – kết nối Firestore hoặc fallback mock
class HubManagementController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Lấy danh sách Hub ─────────────────────────────────────────────
  /// Lấy tất cả Hub từ Firestore. Nếu offline/lỗi → trả về mock data.
  Future<List<HubModel>> layDanhSachHub() async {
    if (!FirebaseCoreService.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 300));
      return List.from(MockData.mockHubs);
    }
    try {
      final snapshot = await _db.collection('hubs').orderBy('TenHub').get();
      if (snapshot.docs.isEmpty) {
        // Lần đầu chưa có data → seed mock vào Firestore
        return List.from(MockData.mockHubs);
      }
      return snapshot.docs
          .map((doc) => HubModel.fromJson({...doc.data(), 'MaHub': doc.id}))
          .toList();
    } catch (e) {
      print('⚠️ Firestore layDanhSachHub lỗi, dùng mock: $e');
      return List.from(MockData.mockHubs);
    }
  }

  // ── Thêm Hub mới ──────────────────────────────────────────────────
  /// Đẩy Hub mới lên Firestore với document ID = maHub
  Future<String?> themHub({
    required String tenHub,
    required double kinhDo,
    required double viDo,
    required String diaChi,
    int banKinh = 500,
  }) async {
    final maHub =
        'HUB${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final newHub = HubModel(
      maHub: maHub,
      tenHub: tenHub,
      kinhDo: kinhDo,
      viDo: viDo,
      banKinhMacDinh: banKinh,
      diaChi: diaChi,
      dangHoatDong: true,
    );

    if (!FirebaseCoreService.isInitialized) {
      print('[MOCK] Thêm Hub: ${newHub.toJson()}');
      return maHub;
    }

    try {
      await _db.collection('hubs').doc(maHub).set(newHub.toJson());
      print('✅ Đã thêm Hub $maHub lên Firestore');
      return maHub;
    } catch (e) {
      print('❌ Lỗi themHub Firestore: $e');
      return null;
    }
  }

  // ── Cập nhật trạng thái Hub (bật/tắt) ────────────────────────────
  Future<bool> capNhatTrangThai(String maHub, bool dangHoatDong) async {
    if (!FirebaseCoreService.isInitialized) {
      print('[MOCK] Hub $maHub → DangHoatDong: $dangHoatDong');
      return true;
    }
    try {
      await _db.collection('hubs').doc(maHub).update({
        'DangHoatDong': dangHoatDong,
      });
      return true;
    } catch (e) {
      print('❌ Lỗi capNhatTrangThai: $e');
      return false;
    }
  }

  // ── Xóa Hub ───────────────────────────────────────────────────────
  Future<bool> xoaHub(String maHub) async {
    if (!FirebaseCoreService.isInitialized) {
      print('[MOCK] Xóa Hub $maHub');
      return true;
    }
    try {
      await _db.collection('hubs').doc(maHub).delete();
      return true;
    } catch (e) {
      print('❌ Lỗi xoaHub: $e');
      return false;
    }
  }
}
