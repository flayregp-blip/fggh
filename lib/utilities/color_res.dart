hereimport 'package:flutter/material.dart';

class ColorRes {
  // ─── Pure ───────────────────────────────────────────
  static const Color blackPure      = Color(0xFF0A0A0F);
  static const Color whitePure      = Color(0xFFFFFFFF);

  // ─── Background Layers (light theme) ────────────────
  static const Color bgDeep         = Color(0xFFF0F0F7); // ← خلفية scaffold
  static const Color themeColor     = Color(0xFFFFFFFF); // ← خلفية أساسية
  static const Color themeGradient2 = Color(0xFFF7F7FC); // ← كارت / bottom sheet
  static const Color themeGradient1 = Color(0xFFEEEEF8); // ← elevated card
  static const Color themeAccentSolid = Color(0xFFE8E8F4); // ← input fields / chips

  // ─── Borders & Dividers ─────────────────────────────
  static const Color borderSubtle   = Color(0xFFE2E2EE); // ← حدود خفيفة
  static const Color borderMedium   = Color(0xFFD0D0E2); // ← حدود واضحة

  // ─── Text ────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFF12121E); // ← أسود ناعم
  static const Color textSecondary  = Color(0xFF6B6B85); // ← ثانوي
  static const Color textMuted      = Color(0xFFAAAAAC); // ← مكتوم
  static const Color textDarkGrey   = Color(0xFF2D2D3A); // ← نص داكن
  static const Color textLightGrey  = Color(0xFF9090A8); // ← نص فاتح

  // ─── Primary Accent — Deep Violet ───────────────────
  static const Color orange         = Color(0xFF6C3FF5); // ← CTA رئيسي (بنفسجي عميق)
  static const Color orangeLight    = Color(0xFF9B75FF); // ← hover / highlight
  static const Color orangeDim      = Color(0x206C3FF5); // ← خلفية badge

  // ─── Secondary Accent — Coral Pink ──────────────────
  static const Color blueFollow     = Color(0xFFFF4E8C); // ← زرار متابعة / accent
  static const Color blueLight      = Color(0xFFFF85B3); // ← فاتح
  static const Color blueDim        = Color(0x20FF4E8C); // ← خلفية فاتحة

  // ─── Battle / Live ───────────────────────────────────
  static const Color battleProgressColor = Color(0xFF00C2FF); // ← لايف / باتل
  static const Color battleDim           = Color(0x2600C2FF);

  // ─── Success / Green ────────────────────────────────
  static const Color green          = Color(0xFF00B87C);
  static const Color green1         = Color(0xFF34D9A4);
  static const Color greenDim       = Color(0x2234D9A4);

  // ─── Error / Like / Red ─────────────────────────────
  static const Color likeRed              = Color(0xFFFF4E8C); // ← نفس الـ coral
  static const Color textStoryBgGradient2 = Color(0xFFFF2D6B);
  static const Color redDim               = Color(0x20FF4E8C);

  // ─── Light Theme Surfaces ───────────────────────────
  static const Color bgLightGrey    = Color(0xFFF5F5FA);
  static const Color bgGrey         = Color(0xFFEAEAF4);
  static const Color bgMediumGrey   = Color(0xFFF0F0F8);
  static const Color disabledGrey   = Color(0xFFBCBCCC);

  // ─── Gradients ──────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C3FF5), Color(0xFFFF4E8C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBgGradient = LinearGradient(
    colors: [Color(0xFFF0F0F7), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient battleGradient = LinearGradient(
    colors: [Color(0xFF00C2FF), Color(0xFF6C3FF5)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
