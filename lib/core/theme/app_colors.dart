import 'package:flutter/material.dart';

class AppColors {
  // Primary color from user requirement
  static const Color primary = Color(0xFF16610E);

  // Related colors derived from primary
  static const Color primaryLight = Color(0xFF3A8C3A);
  static const Color primaryDark = Color(0xFF0F450F);

  // Accent colors
  static const Color accent = Color(0xFFE53935); // For delete/warning actions

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Colors.white;

  // Background colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  // Border colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderFocused = primary;
}