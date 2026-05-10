import 'package:flutter/material.dart';

class ColorRes {
  // ─── Pure ───────────────────────────────────────────
  static const Color blackPure      = Color(0xFF000000);
  static const Color whitePure      = Color(0xFFFFFFFF);

  // ─── Background Layers (dark → light) ───────────────
  static const Color bgDeep         = Color(0xFF0D0E12); // ← أعمق طبقة (scaffold)
  static const Color themeColor     = Color(0xFF15161A); // ← خلفية أساسية
  static const Color themeGradient2 = Color(0xFF1C1D22); // ← كارت / bottom sheet
  static const Color themeGradient1 = Color(0xFF242529); // ← elevated card
  static const Color themeAccentSolid = Color(0xFF2E2F35); // ← input fields / chips

  // ─── Borders & Dividers ─────────────────────────────
  static const Color borderSubtle   = Color(0xFF2A2B30); // ← حدود خفيفة
  static const Color borderMedium   = Color(0xFF3A3B42); // ← حدود واضحة

  // ─── Text ────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFFF2F2F4); // ← أبيض ناعم (مش صارخ)
  static const Color textSecondary  = Color(0xFF9A9AA8); // ← ثانوي
  static const Color textMuted      = Color(0xFF5A5A68); // ← مكتوم
  static const Color textDarkGrey   = Color(0xFF454550);
  static const Color textLightGrey  = Color(0xFF8B8B98);

  // ─── Primary Accent — Orange ────────────────────────
  static const Color orange         = Color(0xFFFF7A19); // ← CTA رئيسي
  static const Color orangeLight    = Color(0xFFFF9A4D); // ← hover / highlight
  static const Color orangeDim      = Color(0x33FF7A19); // ← خلفية badge برتقالي

  // ─── Secondary Accent — Blue ────────────────────────
  static const Color blueFollow     = Color(0xFF3E8BFF);
  static const Color blueLight      = Color(0xFF6AABFF);
  static const Color blueDim        = Color(0x263E8BFF);

  // ─── Battle / Live ───────────────────────────────────
  static const Color battleProgressColor = Color(0xFF2CC3FF);
  static const Color battleDim           = Color(0x262CC3FF);

  // ─── Success / Green ────────────────────────────────
  static const Color green          = Color(0xFF009821);
  static const Color green1         = Color(0xFF34D948);
  static const Color greenDim       = Color(0x2634D948);

  // ─── Error / Like / Red ─────────────────────────────
  static const Color likeRed             = Color(0xFFFF5751);
  static const Color textStoryBgGradient2 = Color(0xFFFF5757);
  static const Color redDim              = Color(0x26FF5751);

  // ─── Light Theme Surfaces (for cards/sheets on light) ─
  static const Color bgLightGrey    = Color(0xFFF9F9F9);
  static const Color bgGrey         = Color(0xFFEEEEEE);
  static const Color bgMediumGrey   = Color(0xFFF4F4F4);
  static const Color disabledGrey   = Color(0xFFBCBCC8);

  // ─── Gradients (helpers) ────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [orange, likeRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBgGradient = LinearGradient(
    colors: [bgDeep, themeColor],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient battleGradient = LinearGradient(
    colors: [battleProgressColor, blueFollow],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
