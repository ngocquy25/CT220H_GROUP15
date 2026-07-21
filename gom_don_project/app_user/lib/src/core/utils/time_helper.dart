/// Hàm tiện ích xử lý thời gian - Logic cốt lõi của GomĐơn
/// DEV A dùng file này để tính NgayGiao và Countdown Timer
class TimeHelper {
  TimeHelper._();

  static const int _gioChot = 10; // 10h00 sáng

  /// Kiểm tra xem hiện tại có trước giờ chốt đơn (10h00) không
  static bool get truocGioChot {
    final now = DateTime.now();
    return now.hour < _gioChot;
  }

  /// Tính NgayGiao:
  /// - Nếu < 10h00: giao hôm nay
  /// - Nếu >= 10h00: giao ngày mai
  static String tinhNgayGiao() {
    final now = DateTime.now();
    final ngayGiao = truocGioChot ? now : now.add(const Duration(days: 1));
    return '${ngayGiao.year}-${_pad(ngayGiao.month)}-${_pad(ngayGiao.day)}';
  }

  /// Tính thời điểm chốt đơn (10h00 hôm nay hoặc ngày mai)
  static DateTime tinhThoiDiemChot() {
    final now = DateTime.now();
    final ngayChot = truocGioChot ? now : now.add(const Duration(days: 1));
    return DateTime(ngayChot.year, ngayChot.month, ngayChot.day, _gioChot, 0, 0);
  }

  /// Tính Duration còn lại đến giờ chốt
  static Duration tinhThoiGianConLai() {
    final thoiDiemChot = tinhThoiDiemChot();
    final now = DateTime.now();
    final remaining = thoiDiemChot.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Format Duration thành chuỗi HH:mm:ss
  static String formatCountdown(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Format tiền VND: 45000 → "45.000đ"
  static String formatVND(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return '$bufferđ';
  }

  /// Kiểm tra còn trong khoảng cảnh báo (< 30 phút)
  static bool get gangDenGioChot {
    final remaining = tinhThoiGianConLai();
    return remaining.inMinutes < 30 && remaining.inMinutes > 0;
  }

  /// Kiểm tra đã quá giờ chốt
  static bool get daQua10h {
    final remaining = tinhThoiGianConLai();
    return remaining.inSeconds == 0;
  }

  static String _pad(int value) => value.toString().padLeft(2, '0');
}
