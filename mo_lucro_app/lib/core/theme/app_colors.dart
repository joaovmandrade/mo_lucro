import 'package:flutter/material.dart';

/// Mo Lucro Design System - Color Palette (Premium Dark Theme)
class AppColors {
  AppColors._();

  // Background & Surfaces
  static const background = Color(0xFF0F172A); // Slate 900
  static const surface = Color(0xFF1E293B); // Slate 800
  static const inputFill = Color(0xFF0F172A); // Same as bg for clean look
  static const highlightSurface = Color(0xFF334155); // Slate 700

  // Brand / Actions
  static const primary = Color(0xFF3B82F6); // Blue 500
  static const primaryLight = Color(0xFF60A5FA); // Blue 400
  static const primaryDark = Color(0xFF2563EB); // Blue 600

  // Secondary
  static const secondary = Color(0xFF94A3B8); // Slate 400 - Restored
  static const secondaryLight = Color(0xFFCBD5E1);

  // Semantic
  static const success = Color(0xFF22C55E); // Green 500 - Profits
  static const profit = success;
  static const error = Color(0xFFEF4444); // Red 500 - Losses / Expenses
  static const danger = error;
  static const loss = error;
  static const warning = Color(0xFFF59E0B); // Amber 500
  static const info = Color(0xFF0EA5E9); // Sky 500
  static const invested = Color(0xFFA855F7); // Purple 500

  // Typography
  static const textPrimary = Color(0xFFF1F5F9); // Slate 100
  static const textSecondary = Color(0xFF94A3B8); // Slate 400
  static const textTertiary = Color(0xFF64748B); // Slate 500

  // Borders & Dividers
  static const border = Color(0xFF334155); // Slate 700
  static const divider = Color(0xFF1E293B); // Slate 800

  // Charts (Minimal colors)
  static const chartColors = [
    Color(0xFF3B82F6), // Primary Blue
    Color(0xFF8B5CF6), // Violet 500
    Color(0xFF10B981), // Emerald 500
    Color(0xFFF59E0B), // Amber 500
    Color(0xFF06B6D4), // Cyan 500
    Color(0xFFEC4899), // Pink 500
  ];

  // Investment type colors (Muted for dark theme)
  static const investmentColors = {
    'CDB': Color(0xFF3B82F6),
    'TESOURO_DIRETO': Color(0xFF10B981),
    'POUPANCA': Color(0xFF22C55E),
    'ACOES': Color(0xFF8B5CF6),
    'FUNDOS_IMOBILIARIOS': Color(0xFFF59E0B),
    'FUNDOS': Color(0xFF06B6D4),
    'CRIPTO': Color(0xFFEC4899),
    'CAIXA': Color(0xFF94A3B8), // Slate 400
    'OUTROS': Color(0xFF64748B), // Slate 500
  };

  // Category Colors
  static const categoryColors = {
    'alimentação': Color(0xFFEF4444),
    'transporte': Color(0xFF3B82F6),
    'moradia': Color(0xFF10B981),
    'saúde': Color(0xFFEC4899),
    'lazer': Color(0xFF8B5CF6),
    'estudos': Color(0xFFF59E0B),
    'contas fixas': Color(0xFF06B6D4),
    'investimentos': Color(0xFF3B82F6),
    'outros': Color(0xFF94A3B8),
  };
}
