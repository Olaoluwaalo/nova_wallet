import 'package:flutter/material.dart';

/// NovaPay palette (fictional brand: deep blue + gold).
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF0B3B8C);
  static const Color primaryDark = Color(0xFF08285F);
  static const Color primaryTint = Color(0xFFEEF3FF);
  static const Color gold = Color(0xFFF5B83D);
  static const Color goldTint = Color(0xFFFFF6DC);
  static const Color goldDark = Color(0xFF7A4F00);
  static const Color goldText = Color(0xFF5C3B00);

  // Surfaces
  static const Color background = Color(0xFFF4F6FB);
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF101828);
  static const Color textSecondary = Color(0xFF475467);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryMuted = Color(0xCCFFFFFF);

  // Lines
  static const Color border = Color(0xFFD0D5DD);
  static const Color divider = Color(0xFFE4E7EC);

  // Disabled
  static const Color disabled = Color(0xFFD0D5DD);
  static const Color onDisabled = Color(0xFF475467);

  // Success
  static const Color success = Color(0xFF067647);
  static const Color successTint = Color(0xFFECFDF3);
  static const Color successBorder = Color(0xFFABEFC6);
  static const Color onlineDot = Color(0xFF47CD89);

  // Warning (pending / offline)
  static const Color warning = Color(0xFF93370D);
  static const Color warningTint = Color(0xFFFFFAEB);
  static const Color warningBorder = Color(0xFFFEDF89);
  static const Color warningIconBg = Color(0xFFFEF0C7);
  static const Color warningAccent = Color(0xFFB54708);

  // Error (failed)
  static const Color error = Color(0xFFB42318);
  static const Color errorTint = Color(0xFFFEF3F2);
  static const Color errorBorder = Color(0xFFFDA29B);

  // Decorative
  static const Color ornamentGold = Color(0x2EF5B83D);
  static const Color onPrimaryTrack = Color(0x38FFFFFF);

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  // Legacy aliases (pre–nova_ui merge)
  static const Color bgDefault = background;
  static const Color accent = gold;
  static const Color primaryLight = primaryTint;
  static const Color pending = Color(0xFF7C3AED);
}
