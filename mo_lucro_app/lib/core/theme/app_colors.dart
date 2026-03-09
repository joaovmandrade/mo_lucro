import 'package:flutter/material.dart';

/// Mo Lucro Design System - Color Palette
class AppColors {
  AppColors._();

  // Primary colors
  static const primary = Color(0xFF1E88E5);
  static const primaryLight = Color(0xFF64B5F6);
  static const primaryDark = Color(0xFF1565C0);

  // Secondary (accent)
  static const secondary = Color(0xFF26A69A);
  static const secondaryLight = Color(0xFF80CBC4);

  // Semantic colors
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFEF5350);
  static const warning = Color(0xFFFFA726);
  static const info = Color(0xFF42A5F5);

  // Finance specific
  static const profit = Color(0xFF00C853);
  static const loss = Color(0xFFFF1744);
  static const invested = Color(0xFF7C4DFF);

  // Backgrounds
  static const background = Color(0xFFF5F7FA);
  static const surface = Color(0xFFFFFFFF);
  static const inputFill = Color(0xFFF0F2F5);

  // Text
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF4A4A68);
  static const textTertiary = Color(0xFF9E9EB8);

  // Borders & Dividers
  static const border = Color(0xFFE0E0E0);
  static const divider = Color(0xFFF0F0F0);

  // Chart colors
  static const chartColors = [
    Color(0xFF1E88E5), // Blue
    Color(0xFF26A69A), // Teal
    Color(0xFFFFA726), // Orange
    Color(0xFF7C4DFF), // Purple
    Color(0xFFEF5350), // Red
    Color(0xFF66BB6A), // Green
    Color(0xFFEC407A), // Pink
    Color(0xFF5C6BC0), // Indigo
    Color(0xFF8D6E63), // Brown
  ];

  // Investment type colors
  static const investmentColors = {
    'CDB': Color(0xFF1E88E5),
    'TESOURO_DIRETO': Color(0xFF26A69A),
    'POUPANCA': Color(0xFF66BB6A),
    'ACOES': Color(0xFFEF5350),
    'FUNDOS_IMOBILIARIOS': Color(0xFF7C4DFF),
    'FUNDOS': Color(0xFF5C6BC0),
    'CRIPTO': Color(0xFFFFA726),
    'CAIXA': Color(0xFF78909C),
    'OUTROS': Color(0xFF8D6E63),
  };

  // Category colors
  static const categoryColors = {
    'alimentação': Color(0xFFFF5722),
    'transporte': Color(0xFF2196F3),
    'moradia': Color(0xFF4CAF50),
    'saúde': Color(0xFFE91E63),
    'lazer': Color(0xFF9C27B0),
    'estudos': Color(0xFFFF9800),
    'contas fixas': Color(0xFF607D8B),
    'investimentos': Color(0xFF00BCD4),
    'outros': Color(0xFF795548),
  };
}
