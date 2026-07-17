import 'package:flutter/material.dart';

/// Hệ thống màu sắc chung cho App User (GomĐơn)
class AppColors {
  AppColors._(); // Không tạo instance

  // ── Màu chính ───────────────────────────────────────────
  static const Color primary = Color(0xFF0046FF);      // Xanh dương (từ #0046FF)
  static const Color primaryLight = Color(0xFF4D7CFF); // Xanh dương nhạt
  static const Color primaryDark = Color(0xFF001BB7);  // Xanh dương tối (từ #001BB7)

  // ── Màu phụ ─────────────────────────────────────────────
  static const Color secondary = Color(0xFFFF8040);    // Cam (từ #FF8040)
  static const Color accent = Color(0xFFFF8040);       // Cam
  static const Color orange = Color(0xFFFF8040);       // Màu Cam
  
  static const Color beige = Color(0xFFF5F1DC);        // Be (từ #F5F1DC)

  // ── Màu nền ─────────────────────────────────────────────
  static const Color background = Color(0xFFF9FAFB);   // Gray 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFF5F1DC);       // Dùng beige cho nền thẻ

  // ── Màu văn bản ─────────────────────────────────────────
  static const Color textPrimary = Color(0xFF001BB7);  // Dùng Dark Blue làm màu text chính
  static const Color textSecondary = Color(0xFF4A5568); // Xám đậm
  static const Color textHint = Color(0xFFA0AEC0);     // Xám nhạt

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
