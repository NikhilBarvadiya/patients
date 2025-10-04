import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryContainer = Color(0xFFDBEAFE);
  static const Color secondaryTeal = Color(0xFF0D9488);
  static const Color secondaryDark = Color(0xFF0F766E);
  static const Color secondaryLight = Color(0xFF2DD4BF);
  static const Color secondaryContainer = Color(0xFFCCFBF1);
  static const Color accentCoral = Color(0xFFF97316);
  static const Color accentDark = Color(0xFFEA580C);
  static const Color accentLight = Color(0xFFFDBA74);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundCard = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF3B82F6);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);
  static const Color dividerColor = Color(0xFFF1F5F9);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: Color(0xFF00296B),
      secondary: secondaryTeal,
      onSecondary: Colors.white,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: Color(0xFF00201D),
      tertiary: accentCoral,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFFFD9C7),
      onTertiaryContainer: Color(0xFF2D1600),
      surface: backgroundWhite,
      onSurface: textPrimary,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: textSecondary,
      background: backgroundLight,
      onBackground: textPrimary,
      error: errorRed,
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      outline: borderLight,
      outlineVariant: borderMedium,
      shadow: Color(0x1A000000),
    ),
    scaffoldBackgroundColor: backgroundLight,
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary, height: 1.2),
      displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary, height: 1.2),
      displaySmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary, height: 1.3),
      headlineLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary, height: 1.3),
      headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary, height: 1.3),
      headlineSmall: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary, height: 1.4),
      titleLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary, height: 1.4),
      titleMedium: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary, height: 1.4),
      titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary, height: 1.4),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal, color: textSecondary, height: 1.5),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal, color: textSecondary, height: 1.5),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal, color: textTertiary, height: 1.5),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary, height: 1.4),
      labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary, height: 1.4),
      labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: textTertiary, height: 1.4),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: backgroundWhite,
      foregroundColor: textPrimary,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
      iconTheme: const IconThemeData(color: primaryBlue, size: 24),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: backgroundWhite,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      color: backgroundCard,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: borderLight, width: 1),
      ),
      margin: EdgeInsets.all(0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        disabledBackgroundColor: textLight,
        disabledForegroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryBlue,
        side: const BorderSide(color: primaryBlue, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryBlue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: backgroundWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderLight, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorRed, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      labelStyle: GoogleFonts.inter(fontSize: 14, color: textTertiary, fontWeight: FontWeight.w500),
      hintStyle: GoogleFonts.inter(fontSize: 14, color: textLight),
      errorStyle: GoogleFonts.inter(fontSize: 12, color: errorRed),
      helperStyle: GoogleFonts.inter(fontSize: 12, color: textTertiary),
    ),
    iconTheme: const IconThemeData(color: textSecondary, size: 24),
    dividerTheme: const DividerThemeData(color: dividerColor, thickness: 1, space: 1),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: backgroundWhite,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      elevation: 8,
      modalElevation: 8,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: backgroundWhite,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
      contentTextStyle: GoogleFonts.inter(fontSize: 14, color: textSecondary),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceVariant,
      disabledColor: textLight.withOpacity(0.12),
      selectedColor: primaryContainer,
      secondarySelectedColor: primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary),
      secondaryLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: primaryBlue),
      brightness: Brightness.light,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: backgroundWhite,
      selectedItemColor: primaryBlue,
      unselectedItemColor: textTertiary,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
  );
}
