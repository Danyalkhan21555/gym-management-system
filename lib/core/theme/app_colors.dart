import 'package:flutter/material.dart';

class AppColors {
  // ─── Light Mode (existing) ───
  static const Color primary = Color(0xFFC6FF00);
  static const Color dark = Color(0xFF151A1A);
  static const Color background = Color(0xFFF7F7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF7A7A7A);
  static const Color error = Color(0xFFFF4D4D);

  // ─── Dark Mode ───
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkSurfaceAlt = Color(0xFF1F262E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8B949E);
  static const Color darkDivider = Color(0xFF30363D);

  // ─── Glassmorphism (light mode) ───
  static const Color glassLight = Color(0x66FFFFFF); // white 40%
  static const Color glassBorderLight = Color(0x99FFFFFF); // white 60%

  // ─── Glassmorphism (dark mode) ───
  static const Color glassDark = Color(0x0FFFFFFF); // white 6%
  static const Color glassBorderDark = Color(0x1FFFFFFF); // white 12%

  // ─── Theme-aware helpers ───
  static Color bgOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : background;
  }

  static Color surfaceOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : surface;
  }

  static Color textPrimaryOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : dark;
  }

  static Color textSecondaryOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : textSecondary;
  }
}
