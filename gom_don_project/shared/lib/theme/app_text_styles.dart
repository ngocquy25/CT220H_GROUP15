import 'package:flutter/material.dart';

/// Hệ thống typography dùng chung toàn dự án GomĐơn
/// Font chính: Be Vietnam Pro — hỗ trợ đầy đủ ký tự tiếng Việt
class AppTextStyles {
  AppTextStyles._();

  static const String _beVietnamPro = 'BeVietnamPro';

  // ─────────────────────────────────────────────────────────────────
  // HEADING
  // ─────────────────────────────────────────────────────────────────

  static const TextStyle h1 = TextStyle(
    fontFamily: _beVietnamPro, fontSize: 32,
    fontWeight: FontWeight.w700, height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _beVietnamPro, fontSize: 24,
    fontWeight: FontWeight.w700, height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _beVietnamPro, fontSize: 20,
    fontWeight: FontWeight.w600, height: 1.3,
  );

  static const TextStyle slogan = TextStyle(
    fontFamily: _beVietnamPro, fontSize: 19,
    fontWeight: FontWeight.w600, height: 1.1, letterSpacing: 0.3,
  );

  // ─────────────────────────────────────────────────────────────────
  // BODY
  // ─────────────────────────────────────────────────────────────────

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _beVietnamPro, fontSize: 16,
    fontWeight: FontWeight.w400, height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _beVietnamPro, fontSize: 14,
    fontWeight: FontWeight.w400, height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _beVietnamPro, fontSize: 13,
    fontWeight: FontWeight.w400, height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _beVietnamPro, fontSize: 11,
    fontWeight: FontWeight.w400, height: 1.4,
  );

  // ─────────────────────────────────────────────────────────────────
  // LABEL / BUTTON
  // ─────────────────────────────────────────────────────────────────

  static const TextStyle button = TextStyle(
    fontFamily: _beVietnamPro, fontSize: 16,
    fontWeight: FontWeight.w700, letterSpacing: 0.3,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: _beVietnamPro, fontSize: 15,
    fontWeight: FontWeight.w700, height: 1.3,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _beVietnamPro, fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // ─────────────────────────────────────────────────────────────────
  // PRICE
  // ─────────────────────────────────────────────────────────────────

  static const TextStyle priceLarge = TextStyle(
    fontFamily: _beVietnamPro, fontSize: 18, fontWeight: FontWeight.w700,
  );

  static const TextStyle priceMedium = TextStyle(
    fontFamily: _beVietnamPro, fontSize: 15, fontWeight: FontWeight.w600,
  );

  // ─────────────────────────────────────────────────────────────────
  // MATERIAL 3 TEXT THEME
  // ─────────────────────────────────────────────────────────────────

  static TextTheme get textTheme => const TextTheme(
    displayLarge:  TextStyle(fontFamily: _beVietnamPro, fontSize: 57, fontWeight: FontWeight.w400),
    displayMedium: TextStyle(fontFamily: _beVietnamPro, fontSize: 45, fontWeight: FontWeight.w400),
    displaySmall:  TextStyle(fontFamily: _beVietnamPro, fontSize: 36, fontWeight: FontWeight.w400),
    headlineLarge:  TextStyle(fontFamily: _beVietnamPro, fontSize: 32, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(fontFamily: _beVietnamPro, fontSize: 28, fontWeight: FontWeight.w700),
    headlineSmall:  TextStyle(fontFamily: _beVietnamPro, fontSize: 24, fontWeight: FontWeight.w600),
    titleLarge:  TextStyle(fontFamily: _beVietnamPro, fontSize: 22, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontFamily: _beVietnamPro, fontSize: 16, fontWeight: FontWeight.w500),
    titleSmall:  TextStyle(fontFamily: _beVietnamPro, fontSize: 14, fontWeight: FontWeight.w500),
    bodyLarge:   TextStyle(fontFamily: _beVietnamPro, fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium:  TextStyle(fontFamily: _beVietnamPro, fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall:   TextStyle(fontFamily: _beVietnamPro, fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge:  TextStyle(fontFamily: _beVietnamPro, fontSize: 14, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(fontFamily: _beVietnamPro, fontSize: 12, fontWeight: FontWeight.w500),
    labelSmall:  TextStyle(fontFamily: _beVietnamPro, fontSize: 11, fontWeight: FontWeight.w500),
  );
}
