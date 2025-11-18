import 'package:flutter/material.dart';
import 'sh_colors.dart';

class SHThemeData {
  static ThemeData get lightTheme => _buildTheme(brightness: Brightness.light);
  static ThemeData get darkTheme => _buildTheme(brightness: Brightness.dark);

  static ThemeData _buildTheme({required Brightness brightness}) {
    bool isDark = brightness == Brightness.dark;

    return ThemeData(
      brightness: brightness,
      primarySwatch: Colors.blue,
      primaryColor: SHColors.chartPrimary,
      scaffoldBackgroundColor: isDark
          ? SHColors.backgroundDark
          : SHColors.backgroundLight,
      cardColor: isDark ? SHColors.cardColor : Colors.white,

      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? SHColors.cardColor : SHColors.chartPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: isDark ? SHColors.cardColor : Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: isDark ? Colors.white60 : Colors.black54,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: isDark ? Colors.white70 : Colors.black87,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: isDark ? Colors.white60 : Colors.black54,
          fontSize: 12,
        ),
      ),

      iconTheme: IconThemeData(color: isDark ? Colors.white70 : Colors.black54),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SHColors.chartPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      colorScheme: ColorScheme.fromSeed(
        seedColor: SHColors.chartPrimary,
        brightness: brightness,
      ),
    );
  }
}
