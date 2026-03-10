import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import './wddl_design_system.dart';

/// Win Daily — AppTheme (website-aligned tokens)
class AppTheme {
  AppTheme._();

  // Light theme surface / background colors
  static const Color primaryLight    = WDDLDesignSystem.sage;        // #7D9180
  static const Color secondaryLight  = WDDLDesignSystem.sageLight;   // #A8BCAC
  static const Color accentLight     = WDDLDesignSystem.sagePale;    // #D4DFD6
  static const Color successLight    = WDDLDesignSystem.success;     // #84C69B
  static const Color warningLight    = WDDLDesignSystem.warning;
  static const Color errorLight      = WDDLDesignSystem.error;       // #E76F51
  static const Color backgroundLight = WDDLDesignSystem.cream;       // #FAF8F4
  static const Color surfaceLight    = Color(0xFFFFFFFF);
  static const Color borderLight     = WDDLDesignSystem.beigeDark;   // #E0D8CC
  static const Color overlayLight    = Color(0x33000000);

  // Dark theme (unchanged — kept for compatibility)
  static const Color bgDarkStart   = Color(0xFF1A1F2A);
  static const Color bgDarkEnd     = Color(0xFF2B3442);
  static const Color primaryDark   = Color(0xFFFFFFFF);
  static const Color secondaryDark = Color(0x99FFFFFF);
  static const Color accentDark    = Color(0xFF7FAFC9);
  static const Color successDark   = Color(0xFF68D391);
  static const Color warningDark   = Color(0xFFF6E05E);
  static const Color errorDark     = Color(0xFFF56565);
  static const Color backgroundDark = bgDarkStart;
  static const Color surfaceDark   = Color(0xFF2D3748);
  static const Color borderDark    = Color(0xFF4A5568);
  static const Color overlayDark   = Color(0x66FFFFFF);

  // Text colors
  static const Color textHighEmphasisLight  = WDDLDesignSystem.ink;       // #2C2C27
  static const Color textMediumEmphasisLight = WDDLDesignSystem.inkMuted; // #6B6B60
  static const Color textDisabledLight      = Color(0xFFABAB9E);

  static const Color textHighEmphasisDark  = Color(0xFFFFFFFF);
  static const Color textMediumEmphasisDark = Color(0xFFA0AEC0);
  static const Color textDisabledDark      = Color(0xFF718096);

  /// Light theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
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
      onSurface: textHighEmphasisLight,
      onSurfaceVariant: textMediumEmphasisLight,
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

    appBarTheme: AppBarTheme(
      backgroundColor: backgroundLight,
      foregroundColor: textHighEmphasisLight,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: WDDLDesignSystem.h2,
      iconTheme: const IconThemeData(color: textHighEmphasisLight, size: 24),
    ),

    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: backgroundLight,
      selectedItemColor: primaryLight,
      unselectedItemColor: textMediumEmphasisLight,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: WDDLDesignSystem.caption.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: WDDLDesignSystem.caption,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryLight,
      foregroundColor: Colors.white,
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: WDDLDesignSystem.primaryButton,
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: WDDLDesignSystem.secondaryButton,
    ),

    textButtonTheme: TextButtonThemeData(
      style: WDDLDesignSystem.textButton,
    ),

    textTheme: _buildTextTheme(isLight: true),

    inputDecorationTheme: InputDecorationTheme(
      fillColor: surfaceLight,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: borderLight, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: borderLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: primaryLight, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: errorLight, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: errorLight, width: 1.5),
      ),
      labelStyle: WDDLDesignSystem.body.copyWith(color: secondaryLight),
      hintStyle: WDDLDesignSystem.hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? primaryLight : borderLight),
      trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? primaryLight.withValues(alpha: 0.3)
              : borderLight.withValues(alpha: 0.3)),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? primaryLight : Colors.transparent),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: const BorderSide(color: borderLight, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryLight,
      linearTrackColor: borderLight,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: WDDLDesignSystem.ink,
      contentTextStyle: WDDLDesignSystem.body.copyWith(color: Colors.white),
      actionTextColor: WDDLDesignSystem.sageLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    ),

    dialogTheme: const DialogThemeData(backgroundColor: backgroundLight),
  );

  /// Dark theme (unchanged structure, kept for compatibility)
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
    textTheme: _buildTextTheme(isLight: false),
    dialogTheme: const DialogThemeData(backgroundColor: backgroundDark),
  );

  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color hi  = isLight ? textHighEmphasisLight  : textHighEmphasisDark;
    final Color mid = isLight ? textMediumEmphasisLight : textMediumEmphasisDark;
    final Color dis = isLight ? textDisabledLight       : textDisabledDark;

    return TextTheme(
      displayLarge:  WDDLDesignSystem.displayLarge.copyWith(color: hi),
      displayMedium: WDDLDesignSystem.h1Large.copyWith(fontSize: 30, color: hi),
      displaySmall:  WDDLDesignSystem.h1Large.copyWith(color: hi),
      headlineLarge: WDDLDesignSystem.h1Large.copyWith(color: hi),
      headlineMedium: WDDLDesignSystem.h1.copyWith(color: hi),
      headlineSmall: WDDLDesignSystem.h2.copyWith(fontSize: 20, color: hi),
      titleLarge:    WDDLDesignSystem.h1.copyWith(color: hi),
      titleMedium:   WDDLDesignSystem.h2.copyWith(color: hi),
      titleSmall:    WDDLDesignSystem.bodyLarge.copyWith(fontWeight: FontWeight.w500, color: hi),
      bodyLarge:     WDDLDesignSystem.bodyLarge.copyWith(color: hi),
      bodyMedium:    WDDLDesignSystem.body.copyWith(color: hi),
      bodySmall:     WDDLDesignSystem.body.copyWith(fontSize: 12, color: mid),
      labelLarge:    WDDLDesignSystem.body.copyWith(fontWeight: FontWeight.w500, color: hi),
      labelMedium:   WDDLDesignSystem.body.copyWith(fontSize: 12, fontWeight: FontWeight.w500, color: mid),
      labelSmall:    WDDLDesignSystem.hint.copyWith(fontSize: 11, color: dis),
    );
  }
}