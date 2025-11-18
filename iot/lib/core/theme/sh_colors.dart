import 'package:flutter/material.dart';

abstract class SHColors {
  static const Color textColor = Color(0xFFD0D7E1);
  static const Color hintColor = Color(0xFF717578);
  static const Color backgroundColor = Color(0xff343941);
  static const Color cardColor = Color(0xff4D565F);
  static const Color trackColor = Color(0xff2C3037);
  static const Color selectedColor = Color(0xffE3D0B2);

  // Colores de fondo para temas
  static const Color backgroundDark = Color(0xFF0D1117);
  static const Color backgroundLight = Color(0xFFF8F9FA);

  // Colores para gráficas IoT
  static const Color chartPrimary = Color(0xFF00D2FF);
  static const Color chartSecondary = Color(0xFF3A86FF);
  static const Color chartAccent = Color(0xFF06FFA5);
  static const Color chartWarning = Color(0xFFFFB700);
  static const Color chartError = Color(0xFFFF006E);
  static const Color chartSuccess = Color(0xFF8ACE00);
  static const Color chartBackground = Color(0xFF1A1A1A);
  static const Color chartGrid = Color(0xFF2D3748);

  static const List<Color> cardColors = [
    Color(0xff60656D),
    Color(0xff4D565F),
    Color(0xff464D57),
  ];
  static const List<Color> dimmedLightColors = [
    Color(0xff505863),
    Color(0xff424a53),
    Color(0xff343941),
  ];

  // Colores adicionales para dashboard
  static const Color dashboardBackground = Color(0xFF0D1117);
  static const Color dashboardCard = Color(0xFF21262D);
  static const Color dashboardBorder = Color(0xFF30363D);
}
