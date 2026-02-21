import 'package:flutter/material.dart';

class AppColors {
  // Sand - represents the historical and cultural richness of the region (suggested primary color for backgrounds and large surfaces)
  static const Color sand50 = Color(0xFFFBF9F3);
  static const Color sand10 = Color(0xFFFFF9F1);
  static const Color sand500 = Color(0xFFCC9A53);
  static const Color sand900 = Color(0xFF6D4330);

  // Sage- represents growth, wisdom, and the natural heritage of the region (suggested primary color for text, icons, and interactive elements)
  static const Color sage50 = Color(0xFFF0F5F1);
  static const Color sage500 = Color(0xFF5D7E5F);
  static const Color sage800 = Color(0xFF344235);
  static const Color sage900 = Color(0xFF2C382E);

  // Henna - represents the artistic and cultural traditions of the region (suggested accent color for warnings, errors, and highlights)
  static const Color henna500 = Color(0xFFD66C36);
  static const Color henna700 = Color(0xFFA33D26);

  // Main color scheme for the app
  static const Color primary = sage800; 
  static const Color secondary = sand500; 
  static const Color background = sand10; 
  static const Color surface = Colors.white;
  static const Color error = henna700;
}
