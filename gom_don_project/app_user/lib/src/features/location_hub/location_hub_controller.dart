import 'dart:math';
import 'package:shared/models/hub_model.dart';
import 'package:shared/test/mock_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller: Xử lý logic Định vị & Tìm Hub gần nhất
class LocationHubController {
  static const String _hubKey = 'selected_hub_id';

  // Tọa độ giả lập GPS của khách (dùng để test)
  // Gần HUB001 - Viettel Cần Thơ: lat=10.0341, lng=105.7469
  double _userLat = 10.0350;
  double _userLng = 105.7475;

  /// Lấy danh sách Hub gần nhất trong bán kính 500m
  /// Hiện tại dùng mock data + tọa độ giả lập
  Future<List<HubModel>> layHubGanNhat() async {
    // Giả lập độ trễ GPS
    await Future.delayed(const Duration(seconds: 1));

    // TODO: Thay bằng Geolocator.getCurrentPosition() thật
    // final position = await Geolocator.getCurrentPosition();
    // _userLat = position.latitude;
    // _userLng = position.longitude;

    final allHubs = MockData.mockHubs;

    // Lọc hub trong bán kính 500m (0.5km)
    final nearbyHubs = allHubs.where((hub) {
      final dist = _tinhKhoangCach(_userLat, _userLng, hub.viDo, hub.kinhDo);
      return dist <= hub.banKinhMacDinh && hub.dangHoatDong;
    }).toList();

    // Sắp xếp theo khoảng cách tăng dần
    nearbyHubs.sort((a, b) {
      final dA = _tinhKhoangCach(_userLat, _userLng, a.viDo, a.kinhDo);
      final dB = _tinhKhoangCach(_userLat, _userLng, b.viDo, b.kinhDo);
      return dA.compareTo(dB);
    });

    // Lấy tối đa 3 Hub gần nhất
    return nearbyHubs.take(3).toList();
  }

  /// Lưu Hub đã chọn vào bộ nhớ thiết bị
  Future<void> luuHubDaChon(String maHub) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_hubKey, maHub);
  }

  /// Đọc Hub đã lưu trước đó
  Future<String?> layHubDaLuu() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_hubKey);
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
