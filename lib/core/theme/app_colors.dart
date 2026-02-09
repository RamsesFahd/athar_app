import 'package:flutter/material.dart';

class AppColors {
  // Sand - تعبر عن الرمال والأصالة
  static const Color sand50 = Color(0xFFFBF9F3);
  static const Color sand500 = Color(0xFFCC9A53);
  static const Color sand900 = Color(0xFF6D4330);

  // Sage - تعبر عن الطبيعة والنماء (اللون الأساسي المقترح لأثر)
  static const Color sage50 = Color(0xFFF0F5F1);
  static const Color sage500 = Color(0xFF5D7E5F);
  static const Color sage800 = Color(0xFF344235);
  static const Color sage900 = Color(0xFF2C382E);

  // Henna - للتحذيرات أو العناصر الجاذبة للانتباه
  static const Color henna500 = Color(0xFFD66C36);
  static const Color henna700 = Color(0xFFA33D26);

  // توزيع الألوان على عناصر التطبيق
  static const Color primary = sage800; // لون الهوية الأساسي
  static const Color secondary = sand500; // لون العناصر الثانوية
  static const Color background = sand50; // خلفية التطبيق
  static const Color surface = Colors.white;
  static const Color error = henna700;
}