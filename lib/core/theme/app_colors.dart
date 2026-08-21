import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary
  static const Color primaryDark = Color(0xFF0F172A); // Deep slate
  static const Color primary = Color(0xFF1E1B4B); // Deep indigo
  static const Color primaryLight = Color(0xFF4338CA); // Indigo Accent
  static const Color primaryContainer = Color(0xFFE0E7FF);

  // Secondary & Accents
  static const Color secondary = Color(0xFF0D9488); // Teal
  static const Color accent = Color(0xFF6366F1); // Vibrant Indigo

  // Status Colors (Never rely on color alone)
  static const Color urgent = Color(0xFFE11D48); // Rose red
  static const Color urgentBg = Color(0xFFFFF1F2);
  static const Color urgentBorder = Color(0xFFFDA4AF);

  static const Color moderate = Color(0xFFD97706); // Amber
  static const Color moderateBg = Color(0xFFFFFBEB);
  static const Color moderateBorder = Color(0xFFFCD34D);

  static const Color routine = Color(0xFF059669); // Emerald
  static const Color routineBg = Color(0xFFECFDF5);
  static const Color routineBorder = Color(0xFF6EE7B7);

  // Neutral & Surfaces (Light)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Neutral & Surfaces (Dark)
  static const Color backgroundDark = Color(0xFF0B0F19);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF334155);

  // Glassmorphism overlays
  static const Color glassWhite = Color(0xCCFFFFFF);
  static const Color glassDark = Color(0xCC1E293B);
  static const Color shadow = Color(0x1A000000);
}
