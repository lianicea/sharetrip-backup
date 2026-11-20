
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6935DC);
  static const Color primaryLight = Color(0xFF8151E8);
  static const Color primaryDark = Color(0xFF26144F);

  static const Color background = Color(0xFFF7F6FC);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF191629);
  static const Color textSecondary = Color(0xFF77738A);

  static const Color success = Color(0xFF16A36A);
  static const Color warning = Color(0xFFE99A27);
  static const Color danger = Color(0xFFE6294F);

  static const Color border = Color(0xFFE7E4F0);

  static const LinearGradient headerGradient =
      LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF111027),
      Color(0xFF241250),
      Color(0xFF5122B6),
    ],
  );

  static const LinearGradient buttonGradient =
      LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF7540EA),
      Color(0xFF5719C9),
    ],
  );
}
