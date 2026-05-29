import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds (light theme) ──────────────────────────────
  static const Color bg0 = Color(0xFFECEEF2);
  static const Color bg1 = Color(0xFFFFFFFF);
  static const Color bg2 = Color(0xFFFFFFFF);
  static const Color bg3 = Color(0xFFF3F4F6);
  static const Color bg4 = Color(0xFFE5E7EB);

  static const Color surfaceGlass = Color(0xFAFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfacePressed = Color(0xFFF3F4F6);

  // ── Brand ──────────────────────────────────────────────────
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDim = Color(0xFF1D4ED8);
  static const Color profit = Color(0xFF10B981);
  static const Color profitDark = Color(0xFF047857);
  static const Color loss = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color accent = profit;
  static const Color purple = Color(0xFF7C3AED);

  static const Color accentBlue = primary;
  static const Color accentGreen = profit;
  static const Color accentRed = loss;
  static const Color accentOrange = warning;
  static const Color accentPurple = purple;
  static const Color accentTeal = Color(0xFF06B6D4);

  // ── Text ──────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Text on blue header
  static const Color textOnBlue = Color(0xFFFFFFFF);
  static const Color textOnBlueDim = Color(0xFFDBEAFE);
  static const Color textOnBlueReturn = Color(0xFF6EE7B7);
  static const Color textOnBlueProfit = Color(0xFF10B981);

  // ── Borders ───────────────────────────────────────────────
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color badgeBg = Color(0x0F000000);

  // ── Gradients ─────────────────────────────────────────────
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF4338CA)],
    begin: Alignment(-0.6, -1.0),
    end: Alignment(1.0, 0.6),
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFAFBFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Used in BalanceCard (shown on blue header — white text)
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF4338CA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const List<Color> chartColors = [
    Color(0xFF2563EB),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF7C3AED),
    Color(0xFF06B6D4),
  ];
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double huge = 48;
}

class AppRadius {
  AppRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double pill = 100;
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.18),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg0,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.profit,
        surface: AppColors.bg2,
        onSurface: AppColors.textPrimary,
        error: AppColors.loss,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        displayMedium: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 27,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        displaySmall: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        headlineLarge: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        headlineMedium: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        titleLarge: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        titleMedium: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        titleSmall: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        bodyLarge: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 14,
          height: 1.35,
          letterSpacing: 0,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 13,
          height: 1.35,
          letterSpacing: 0,
        ),
        bodySmall: GoogleFonts.inter(
          color: AppColors.textMuted,
          fontSize: 11,
          height: 1.3,
          letterSpacing: 0,
        ),
        labelLarge: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        labelMedium: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        labelSmall: GoogleFonts.inter(
          color: AppColors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bg2,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bg3,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.loss),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.loss, width: 1.3),
        ),
        labelStyle:
            GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle:
              GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle:
              GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bg4,
        selectedColor: AppColors.primary.withOpacity(0.10),
        labelStyle:
            GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12),
        side: const BorderSide(color: AppColors.border),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1F2937),
        contentTextStyle:
            GoogleFonts.inter(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.bg2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.bg3,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
