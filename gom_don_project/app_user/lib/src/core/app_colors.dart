import 'package:flutter/material.dart';

/// Hệ thống màu sắc chung cho App User (GomĐơn)
class AppColors {
  AppColors._(); // Không tạo instance

  // ── Màu chính ───────────────────────────────────────────
  static const Color primary = Color(0xFFFF6B35);      // Cam đậm - màu chủ đạo
  static const Color primaryLight = Color(0xFFFF9A76); // Cam nhạt
  static const Color primaryDark = Color(0xFFCC4A1A);  // Cam tối

  // ── Màu phụ ─────────────────────────────────────────────
  static const Color secondary = Color(0xFF2ECC71);    // Xanh lá - thành công
  static const Color accent = Color(0xFF3498DB);       // Xanh dương - thông tin

  // ── Màu nền ─────────────────────────────────────────────
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFF5F2);       // Nền thẻ - cam rất nhạt

  // ── Màu văn bản ─────────────────────────────────────────
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textHint = Color(0xFFB2BEC3);

  // ── Màu trạng thái ──────────────────────────────────────
  static const Color success = Color(0xFF00B894);     // Thành công
  static const Color warning = Color(0xFFFDCB6E);     // Cảnh báo
  static const Color error = Color(0xFFD63031);       // Lỗi / Hủy
  static const Color info = Color(0xFF74B9FF);        // Thông tin

  // ── Màu countdown timer ─────────────────────────────────
  static const Color countdownNormal = Color(0xFF2ECC71);  // Còn nhiều giờ
  static const Color countdownWarning = Color(0xFFF39C12); // Gần hết giờ
  static const Color countdownDanger = Color(0xFFE74C3C);  // Sắp hết giờ

  // ── Màu ví tiền ─────────────────────────────────────────
  static const Color walletConnected = Color(0xFF00B894);
  static const Color walletDisconnected = Color(0xFFDFE6E9);
}
