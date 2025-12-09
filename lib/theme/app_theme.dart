import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/win.dart';
import './wddl_design_system.dart';

/// A class that contains all theme configurations for the application.
/// Implements Win Daily Calm-Tech Design Language (WDDL)
class AppTheme {
  AppTheme._();

  // WDDL Color Specifications - Updated to match design system
  static const Color primaryLight = Color(0xFF6B8B7F); // Primary #6B8B7F
  static const Color secondaryLight = Color(0xFF7A9D8E); // Secondary #7A9D8E
  static const Color accentLight = Color(
    0xFF7A9D8E,
  ); // Using secondary as accent
  static const Color successLight = Color(0xFF84C69B); // Success #84C69B
  static const Color warningLight = Color(0xFFD69E2E); // Warm amber
  static const Color errorLight = Color(0xFFE76F51); // Error #E76F51
  static const Color backgroundLight = Color(0xFFE8F0ED); // Background #E8F0ED
  static const Color surfaceLight = Color(0xFFEBE8E3); // Surface #EBE8E3
  static const Color borderLight = Color(0xFFD9E4E6); // Input border
  static const Color overlayLight = Color(0x66000000); // 40% opacity black

  // Dark theme colors - Updated to match Win Daily Dark Mode Design Requirements
  static const Color bgDarkStart = Color(
    0xFF1A1F2A,
  ); // Dark background start #1A1F2A
  static const Color bgDarkEnd = Color(
    0xFF2B3442,
  ); // Dark background end #2B3442
  static const Color primaryDark = Color(
    0xFFFFFFFF,
  ); // White text #FFFFFF at 90% opacity
  static const Color secondaryDark = Color(
    0x99FFFFFF,
  ); // White at 60% opacity for secondary text
  static const Color accentDark = Color(
    0xFF7FAFC9,
  ); // Soft desaturated aqua #7FAFC9
  static const Color successDark = Color(0xFF68D391);
  static const Color warningDark = Color(0xFFF6E05E);
  static const Color errorDark = Color(0xFFF56565);
  static const Color backgroundDark =
      bgDarkStart; // Use bgDarkStart for main background
  static const Color surfaceDark = Color(0xFF2D3748);
  static const Color borderDark = Color(0xFF4A5568);
  static const Color overlayDark = Color(0x66FFFFFF);

  // WDDL Text colors
  static const Color textHighEmphasisLight = Color(
    0xFF6B8B7F,
  ); // TextPrimary #6B8B7F
  static const Color textMediumEmphasisLight = Color(
    0xFF6E767D,
  ); // TextSecondary #6E767D
  static const Color textDisabledLight = Color(0xFF6E767D);

  static const Color textHighEmphasisDark = Color(0xFFFFFFFF);
  static const Color textMediumEmphasisDark = Color(0xFFA0AEC0);
  static const Color textDisabledDark = Color(0xFF718096);

  /// WDDL Light theme implementation
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryLight,
      onPrimary: Colors.white,
      primaryContainer: accentLight,
      onPrimaryContainer: Colors.white,
      secondary: secondaryLight,
      onSecondary: Colors.white,
      secondaryContainer: surfaceLight,
      onSecondaryContainer: primaryLight,
      tertiary: accentLight,
      onTertiary: Colors.white,
      tertiaryContainer: surfaceLight,
      onTertiaryContainer: primaryLight,
      error: errorLight,
      onError: Colors.white,
      surface: backgroundLight,
      onSurface: primaryLight,
      onSurfaceVariant: secondaryLight,
      outline: borderLight,
      outlineVariant: borderLight,
      shadow: overlayLight,
      scrim: overlayLight,
      inverseSurface: primaryLight,
      onInverseSurface: backgroundLight,
      inversePrimary: backgroundLight,
    ),
    scaffoldBackgroundColor: backgroundLight,
    cardColor: surfaceLight,
    dividerColor: borderLight,

    // AppBar theme - WDDL specifications
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundLight,
      foregroundColor: primaryLight,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: WDDLDesignSystem.h2,
      iconTheme: const IconThemeData(color: primaryLight, size: 24),
    ),

    // Card theme - WDDL specifications
    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Bottom navigation - WDDL specifications
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: backgroundLight,
      selectedItemColor: accentLight,
      unselectedItemColor: textMediumEmphasisLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8.0,
      selectedLabelStyle: WDDLDesignSystem.body.copyWith(
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: WDDLDesignSystem.body,
    ),

    // FAB theme - WDDL specifications
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryLight,
      foregroundColor: Colors.white,
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    ),

    // Button themes - WDDL specifications
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: WDDLDesignSystem.primaryButton.copyWith(
        shadowColor: WidgetStateProperty.all(
          Colors.black.withValues(alpha: 0.1),
        ),
        elevation: WidgetStateProperty.all(2.0),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLight,
        minimumSize: const Size(double.infinity, 48),
        side: const BorderSide(color: borderLight, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: WDDLDesignSystem.bodyLarge.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: WDDLDesignSystem.bodyLarge.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // Typography - WDDL specifications
    textTheme: _buildWDDLTextTheme(isLight: true),

    // Input decoration - WDDL specifications
    inputDecorationTheme: InputDecorationTheme(
      fillColor: const Color(0xFFF8F9FA), // Input background
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(
          color: Color(0xFFD9E4E6),
          width: 1,
        ), // Input border
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFFD9E4E6), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: secondaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: errorLight, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: errorLight, width: 2),
      ),
      labelStyle: WDDLDesignSystem.bodyLarge.copyWith(color: secondaryLight),
      hintStyle: WDDLDesignSystem.hint,
      contentPadding: const EdgeInsets.all(16),
    ),

    // Switch theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentLight;
        }
        return borderLight;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentLight.withValues(alpha: 0.3);
        }
        return borderLight.withValues(alpha: 0.3);
      }),
    ),

    // Checkbox theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentLight;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: const BorderSide(color: borderLight, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // Radio theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentLight;
        }
        return borderLight;
      }),
    ),

    // Progress indicator theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: accentLight,
      linearTrackColor: borderLight,
    ),

    // Slider theme
    sliderTheme: SliderThemeData(
      activeTrackColor: accentLight,
      thumbColor: accentLight,
      overlayColor: accentLight.withValues(alpha: 0.2),
      inactiveTrackColor: borderLight,
      trackHeight: 4,
    ),

    // Tab bar theme
    tabBarTheme: TabBarThemeData(
      labelColor: primaryLight,
      unselectedLabelColor: textMediumEmphasisLight,
      indicatorColor: accentLight,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: WDDLDesignSystem.bodyLarge.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: WDDLDesignSystem.bodyLarge,
    ),

    // Tooltip theme
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: primaryLight.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: WDDLDesignSystem.body.copyWith(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // SnackBar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryLight,
      contentTextStyle: WDDLDesignSystem.bodyLarge.copyWith(
        color: Colors.white,
      ),
      actionTextColor: accentLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    ),
    dialogTheme: DialogThemeData(backgroundColor: backgroundLight),
  );

  /// Dark theme - Updated for Win Daily Dark Mode specifications
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primaryDark,
      onPrimary: backgroundDark,
      primaryContainer: accentDark,
      onPrimaryContainer: backgroundDark,
      secondary: secondaryDark,
      onSecondary: backgroundDark,
      secondaryContainer: surfaceDark,
      onSecondaryContainer: primaryDark,
      tertiary: accentDark,
      onTertiary: backgroundDark,
      tertiaryContainer: surfaceDark,
      onTertiaryContainer: primaryDark,
      error: errorDark,
      onError: backgroundDark,
      surface: backgroundDark,
      onSurface: primaryDark,
      onSurfaceVariant: secondaryDark,
      outline: borderDark,
      outlineVariant: borderDark,
      shadow: overlayDark,
      scrim: overlayDark,
      inverseSurface: primaryDark,
      onInverseSurface: backgroundDark,
      inversePrimary: backgroundDark,
    ),
    scaffoldBackgroundColor: backgroundDark,
    cardColor: surfaceDark,
    dividerColor: borderDark,

    // AppBar theme - Clean and minimal
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundDark,
      foregroundColor: primaryDark,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryDark,
        letterSpacing: 0.15,
      ),
      iconTheme: const IconThemeData(color: primaryDark, size: 24),
    ),

    // Card theme - Subtle elevation
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 2.0,
      shadowColor: overlayDark.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Bottom navigation - Contextual and clean
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: backgroundDark,
      selectedItemColor: accentDark,
      unselectedItemColor: secondaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 8.0,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // FAB theme - Contextual positioning
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentDark,
      foregroundColor: backgroundDark,
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    ),

    // Button themes - Confident and accessible
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: backgroundDark,
        backgroundColor: primaryDark,
        elevation: 2.0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: const BorderSide(color: borderDark, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
      ),
    ),

    // Typography - Inter font family for consistency
    textTheme: _buildWDDLTextTheme(isLight: false),

    // Input decoration - Clean and functional
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surfaceDark,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: borderDark, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: borderDark, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: accentDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: errorDark, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: errorDark, width: 2),
      ),
      labelStyle: GoogleFonts.inter(
        color: secondaryDark,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.inter(
        color: textDisabledDark,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    // Switch theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentDark;
        }
        return borderDark;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentDark.withValues(alpha: 0.3);
        }
        return borderDark.withValues(alpha: 0.3);
      }),
    ),

    // Checkbox theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentDark;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(backgroundDark),
      side: const BorderSide(color: borderDark, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // Radio theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentDark;
        }
        return borderDark;
      }),
    ),

    // Progress indicator theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: accentDark,
      linearTrackColor: borderDark,
    ),

    // Slider theme
    sliderTheme: SliderThemeData(
      activeTrackColor: accentDark,
      thumbColor: accentDark,
      overlayColor: accentDark.withValues(alpha: 0.2),
      inactiveTrackColor: borderDark,
      trackHeight: 4,
    ),

    // Tab bar theme
    tabBarTheme: TabBarThemeData(
      labelColor: primaryDark,
      unselectedLabelColor: secondaryDark,
      indicatorColor: accentDark,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Tooltip theme
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: primaryDark.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: GoogleFonts.inter(
        color: backgroundDark,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // SnackBar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryDark,
      contentTextStyle: GoogleFonts.inter(
        color: backgroundDark,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: accentDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    ),
    dialogTheme: DialogThemeData(backgroundColor: backgroundDark),
  );

  /// Helper method to build WDDL-compliant text theme
  static TextTheme _buildWDDLTextTheme({required bool isLight}) {
    final Color textHighEmphasis =
        isLight ? textHighEmphasisLight : textHighEmphasisDark;
    final Color textMediumEmphasis =
        isLight ? textMediumEmphasisLight : textMediumEmphasisDark;
    final Color textDisabled = isLight ? textDisabledLight : textDisabledDark;

    return TextTheme(
      // Display styles
      displayLarge: WDDLDesignSystem.h1Large.copyWith(
        fontSize: 32,
        color: textHighEmphasis,
      ),
      displayMedium: WDDLDesignSystem.h1Large.copyWith(
        fontSize: 28,
        color: textHighEmphasis,
      ),
      displaySmall: WDDLDesignSystem.h1Large.copyWith(color: textHighEmphasis),

      // Headline styles
      headlineLarge: WDDLDesignSystem.h1Large.copyWith(color: textHighEmphasis),
      headlineMedium: WDDLDesignSystem.h1.copyWith(color: textHighEmphasis),
      headlineSmall: WDDLDesignSystem.h2.copyWith(
        fontSize: 20,
        color: textHighEmphasis,
      ),

      // Title styles
      titleLarge: WDDLDesignSystem.h1.copyWith(color: textHighEmphasis),
      titleMedium: WDDLDesignSystem.h2.copyWith(color: textHighEmphasis),
      titleSmall: WDDLDesignSystem.bodyLarge.copyWith(
        fontWeight: FontWeight.w500,
        color: textHighEmphasis,
      ),

      // Body styles
      bodyLarge: WDDLDesignSystem.bodyLarge.copyWith(color: textHighEmphasis),
      bodyMedium: WDDLDesignSystem.body.copyWith(color: textHighEmphasis),
      bodySmall: WDDLDesignSystem.body.copyWith(
        fontSize: 12,
        color: textMediumEmphasis,
      ),

      // Label styles
      labelLarge: WDDLDesignSystem.body.copyWith(
        fontWeight: FontWeight.w500,
        color: textHighEmphasis,
      ),
      labelMedium: WDDLDesignSystem.body.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textMediumEmphasis,
      ),
      labelSmall: WDDLDesignSystem.hint.copyWith(
        fontSize: 11,
        color: textDisabled,
      ),
    );
  }
}
