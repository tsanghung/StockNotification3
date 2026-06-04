import 'package:flutter/material.dart';

/// 色彩常數，對應 generator.js 內的 CSS 變數
class AppColors {
  // 背景色
  static const Color background    = Color(0xFF0F172A); // --bg
  static const Color cardBg        = Color(0xFF1E293B); // --card-bg
  static const Color cardBorder    = Color(0xFF334155); // subtle border

  // 文字色
  static const Color textPrimary   = Color(0xFFF8FAFC); // --text
  static const Color textSecondary = Color(0xFF94A3B8); // .date color
  static const Color textMuted     = Color(0xFF64748B); // .news-time color

  // 強調色
  static const Color accent        = Color(0xFF38BDF8); // --accent (青色)
  static const Color accentPurple  = Color(0xFF818CF8); // 漸層尾端

  // 漲跌色（台股慣例：紅漲綠跌）
  static const Color priceUp       = Color(0xFFEF4444); // --up-color
  static const Color priceDown     = Color(0xFF22C55E); // --down-color
  static const Color priceFlat     = Color(0xFF94A3B8); // 持平

  // 漸層
  static const LinearGradient headerGradient = LinearGradient(
    colors: [accent, accentPurple],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
