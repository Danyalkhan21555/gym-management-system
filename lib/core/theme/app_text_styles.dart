import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  // Headings
  static TextStyle get headingLarge => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get headingMedium => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600, // semi-bold
        color: AppColors.textPrimary,
      );

  static TextStyle get headingSmall => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600, // semi-bold
        color: AppColors.textPrimary,
      );

  // Subheadings
  static TextStyle get subtitleLarge => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600, // semi-bold
        color: AppColors.textPrimary,
      );

  static TextStyle get subtitleMedium => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500, // medium
        color: AppColors.textPrimary,
      );

  // Body
  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400, // regular
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400, // regular
        color: AppColors.textPrimary,
      );

  // Captions
  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400, // regular
        color: AppColors.textSecondary,
      );

  // Buttons
  static TextStyle get buttonText => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600, // semi-bold
      );
}
