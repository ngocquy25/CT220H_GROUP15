import 'package:flutter/material.dart';

/// Hệ thống typography trung tâm cho App User (GomĐơn)
///
/// Font chính: Be Vietnam Pro — bundle local tại assets/fonts/
/// Hỗ trợ đầy đủ ký tự tiếng Việt (ơ, ă, đ, ...) — KHÔNG phụ thuộc mạng
///
/// Font display: Bauhaus93 — CHỈ dùng cho text ASCII thuần (badge, logo),
/// KHÔNG dùng cho text tiếng Việt (gây lỗi render ký tự dấu)
class AppTextStyles {
  AppTextStyles._();

  // Tên family đã khai báo trong pubspec.yaml
  static const String _beVietnamPro = 'BeVietnamPro';

  // ─────────────────────────────────────────────────────────────────
  // DISPLAY — Badge / branding ASCII (an toàn với Bauhaus93)
  // ─────────────────────────────────────────────────────────────────

  /// Badge/label ngắn ASCII: "FREE SHIP" — dùng Bauhaus93 (chỉ khi text HOÀN TOÀN là ASCII)
  static const TextStyle badgeAscii = TextStyle(
    fontFamily: 'Bauhaus93',
    fontSize: 10,
    letterSpacing: 2.5,
    fontWeight: FontWeight.bold,
  );

  /// Badge có ký tự tiếng Việt: "GOM ĐƠN", "Đang gom"... — dùng BeVietnamPro
  static const TextStyle badgeVi = TextStyle(
    fontFamily: _beVietnamPro,
    fontSize: 10,
    letterSpacing: 2.5,
    fontWeight: FontWeight.w700,
  );

  /// Label ASCII nhỏ: "FREE SHIP"
  static const TextStyle labelAscii = TextStyle(
    fontFamily: 'Bauhaus93',
    fontSize: 9,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
  );

  // ─────────────────────────────────────────────────────────────────
  // HEADING — Tiêu đề tiếng Việt (Be Vietnam Pro local)
  // ─────────────────────────────────────────────────────────────────

  /// H1 — Tiêu đề màn hình lớn (32px, bold)
  static const TextStyle h1 = TextStyle(
    fontFamily: _beVietnamPro,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  /// H2 — Tiêu đề section (24px, bold)
  static const TextStyle h2 = TextStyle(
    fontFamily: _beVietnamPro,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  /// H3 — Tiêu đề card (20px, semibold)
  static const TextStyle h3 = TextStyle(
    fontFamily: _beVietnamPro,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// Slogan/tagline — văn bản marketing tiếng Việt (19px, semibold)
  static const TextStyle slogan = TextStyle(
    fontFamily: _beVietnamPro,
    fontSize: 19,
    fontWeight: FontWeight.w600,
    height: 1.1,
    letterSpacing: 0.3,
  );

  // ─────────────────────────────────────────────────────────────────
  // BODY — Văn bản thông thường (Be Vietnam Pro local)
  // ─────────────────────────────────────────────────────────────────

  /// Body lớn (16px, regular)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _beVietnamPro,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Body vừa (14px, regular)
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _beVietnamPro,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Body nhỏ (13px, regular)
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _beVietnamPro,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// Caption — chú thích nhỏ (11px)
  static const TextStyle caption = TextStyle(
    fontFamily: _beVietnamPro,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // ─────────────────────────────────────────────────────────────────
  // LABEL — Nhãn, button, tag (Be Vietnam Pro local)
  // ─────────────────────────────────────────────────────────────────

  /// Button text (16px, bold)
  static const TextStyle button = TextStyle(
    fontFamily: _beVietnamPro,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  /// Label lớn (15px, bold)
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _beVietnamPro,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  /// Label nhỏ (12px, medium)
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _beVietnamPro,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // ─────────────────────────────────────────────────────────────────
  // PRICE — Giá tiền (Be Vietnam Pro local)
  // ─────────────────────────────────────────────────────────────────

  /// Giá lớn (18px, bold)
  static const TextStyle priceLarge = TextStyle(
    fontFamily: _beVietnamPro,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  /// Giá vừa (15px, semibold)
  static const TextStyle priceMedium = TextStyle(
    fontFamily: _beVietnamPro,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  // ─────────────────────────────────────────────────────────────────
  // THEME — TextTheme Material 3 với Be Vietnam Pro
  // ─────────────────────────────────────────────────────────────────

  /// TextTheme toàn app — truyền vào ThemeData.textTheme
  static TextTheme get textTheme => const TextTheme(
        displayLarge: TextStyle(fontFamily: _beVietnamPro, fontSize: 57, fontWeight: FontWeight.w400),
        displayMedium: TextStyle(fontFamily: _beVietnamPro, fontSize: 45, fontWeight: FontWeight.w400),
        displaySmall: TextStyle(fontFamily: _beVietnamPro, fontSize: 36, fontWeight: FontWeight.w400),
        headlineLarge: TextStyle(fontFamily: _beVietnamPro, fontSize: 32, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(fontFamily: _beVietnamPro, fontSize: 28, fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(fontFamily: _beVietnamPro, fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontFamily: _beVietnamPro, fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontFamily: _beVietnamPro, fontSize: 16, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(fontFamily: _beVietnamPro, fontSize: 14, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontFamily: _beVietnamPro, fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontFamily: _beVietnamPro, fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontFamily: _beVietnamPro, fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontFamily: _beVietnamPro, fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(fontFamily: _beVietnamPro, fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontFamily: _beVietnamPro, fontSize: 11, fontWeight: FontWeight.w500),
      );
}
