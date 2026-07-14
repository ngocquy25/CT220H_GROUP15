import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:shared/models/hub_model.dart';
import 'package:shared/test/mock_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Trạng thái kết quả khi lấy vị trí GPS
enum LocationStatus {
  /// Lấy GPS thành công — hub list đã được lọc theo vị trí thật
  success,

  /// Quyền GPS bị từ chối — hiện toàn bộ hub để user tự chọn thủ công
  permissionDenied,

  /// Dịch vụ GPS bị tắt trên thiết bị
  serviceDisabled,

  /// Lỗi không xác định — fallback toàn bộ hub
  error,
}

/// Kết quả trả về từ layHubGanNhat()
class HubResult {
  final List<HubModel> hubs;
  final LocationStatus status;
  final double? userLat;
  final double? userLng;

  const HubResult({
    required this.hubs,
    required this.status,
    this.userLat,
    this.userLng,
  });
}

/// Controller: Xử lý logic Định vị & Tìm Hub gần nhất bằng GPS thật
class LocationHubController {
  static const String _hubKey = 'selected_hub_id';

  // Tọa độ người dùng — được cập nhật sau khi lấy GPS thật
  double? _userLat;
  double? _userLng;

  /// Kiểm tra xem user đã từng chọn Hub chưa
  Future<String?> layHubDaLuu() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_hubKey);
  }

  /// Lấy danh sách Hub gần nhất dùng GPS thật
  ///
  /// Luồng:
  /// 1. Kiểm tra dịch vụ vị trí có bật không
  /// 2. Kiểm tra và xin quyền truy cập vị trí
  /// 3. Lấy vị trí hiện tại bằng Geolocator
  /// 4. Lọc hub trong bán kính 500m và sắp xếp theo khoảng cách
  /// 5. Fallback: nếu không lấy được GPS hoặc không có Hub gần → trả toàn bộ Hub
  Future<HubResult> layHubGanNhat() async {
    // ── Bước 1: Kiểm tra GPS service có bật không ──
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return HubResult(
        hubs: MockData.mockHubs,
        status: LocationStatus.serviceDisabled,
      );
    }

    // ── Bước 2: Kiểm tra & xin quyền vị trí ──
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return HubResult(
          hubs: MockData.mockHubs,
          status: LocationStatus.permissionDenied,
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return HubResult(
        hubs: MockData.mockHubs,
        status: LocationStatus.permissionDenied,
      );
    }

    // ── Bước 3: Lấy vị trí GPS thật ──
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      _userLat = position.latitude;
      _userLng = position.longitude;

      // ── Bước 4: Lọc Hub trong bán kính & sắp xếp theo khoảng cách ──
      final allHubs = MockData.mockHubs;
      final nearbyHubs = allHubs.where((hub) {
        final dist = _tinhKhoangCach(_userLat!, _userLng!, hub.viDo, hub.kinhDo);
        return dist <= hub.banKinhMacDinh && hub.dangHoatDong;
      }).toList();

      nearbyHubs.sort((a, b) {
        final dA = _tinhKhoangCach(_userLat!, _userLng!, a.viDo, a.kinhDo);
        final dB = _tinhKhoangCach(_userLat!, _userLng!, b.viDo, b.kinhDo);
        return dA.compareTo(dB);
      });

      // Nếu không có Hub gần trong 500m → trả toàn bộ Hub (kèm khoảng cách thật)
      if (nearbyHubs.isEmpty) {
        final allSorted = List<HubModel>.from(allHubs.where((h) => h.dangHoatDong));
        allSorted.sort((a, b) {
          final dA = _tinhKhoangCach(_userLat!, _userLng!, a.viDo, a.kinhDo);
          final dB = _tinhKhoangCach(_userLat!, _userLng!, b.viDo, b.kinhDo);
          return dA.compareTo(dB);
        });
        return HubResult(
          hubs: allSorted,
          status: LocationStatus.success,
          userLat: _userLat,
          userLng: _userLng,
        );
      }

      // Lấy tối đa 3 Hub gần nhất trong bán kính 500m
      return HubResult(
        hubs: nearbyHubs.take(3).toList(),
        status: LocationStatus.success,
        userLat: _userLat,
        userLng: _userLng,
      );
    } catch (e) {
      // Lỗi không xác định → fallback toàn bộ Hub
      return HubResult(
        hubs: MockData.mockHubs,
        status: LocationStatus.error,
      );
    }
  }

  /// Tính khoảng cách (mét) đến một hub cụ thể từ vị trí hiện tại của user
  /// Trả về null nếu vị trí user chưa được lấy
  double? tinhKhoangCachDenHub(HubModel hub) {
    if (_userLat == null || _userLng == null) return null;
    return _tinhKhoangCach(_userLat!, _userLng!, hub.viDo, hub.kinhDo);
  }

  /// Lưu Hub đã chọn vào bộ nhớ thiết bị
  Future<void> luuHubDaChon(String maHub) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_hubKey, maHub);
  }

  /// Xóa Hub đã lưu (dùng khi cần thay đổi Hub)
  Future<void> xoaHubDaLuu() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hubKey);
  }

  /// Công thức Haversine tính khoảng cách (mét) giữa 2 tọa độ
  double _tinhKhoangCach(double lat1, double lng1, double lat2, double lng2) {
    const double R = 6371000; // Bán kính Trái Đất (mét)
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
            sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double deg) => deg * pi / 180;
}
