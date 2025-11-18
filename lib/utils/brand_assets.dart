import 'package:flutter/material.dart';


/// Win Daily Brand Assets Helper
/// Provides theme-aware logo and branding asset selection
class BrandAssets {
  BrandAssets._();

  // Available logos from assets/images/
  static const String _alternativeVerticalLogoPath =
      'assets/images/ChatGPT_Image_Oct_24_2025_03_53_24_PM-1761343283423.png';
  static const String _otherHorizontalLogoPath =
      'assets/images/ChatGPT_Image_Oct_24_2025_03_42_20_PM-1761343649222.png';
  static const String _appIconPath = 'assets/images/img_app_logo.svg';

  /// Returns appropriate splash screen logo based on theme
  static String splashLogo(BuildContext context) {
    // Use vertical logo for splash screen
    return _alternativeVerticalLogoPath;
  }

  /// Returns alternative vertical logo (new logo asset)
  static String alternativeVerticalLogo() {
    return _alternativeVerticalLogoPath;
  }

  /// Returns other horizontal logo (horizontal layout logo)
  static String otherHorizontalLogo() {
    return _otherHorizontalLogoPath;
  }

  /// Returns appropriate authentication screen logo based on theme
  static String authLogo(BuildContext context) {
    // Use horizontal logo for auth screen
    return _otherHorizontalLogoPath;
  }

  /// Returns appropriate onboarding logo based on slide and theme
  static String onboardingLogo(BuildContext context,
      {required bool isIntroSlide}) {
    if (isIntroSlide) {
      // Slide 1 (brand intro): use horizontal logo
      return _otherHorizontalLogoPath;
    } else {
      // Slides 2 & 3 (habit/reflection story): use vertical logo
      return _alternativeVerticalLogoPath;
    }
  }

  /// Returns appropriate onboarding success modal logo based on theme
  static String successModalLogo(BuildContext context) {
    return _alternativeVerticalLogoPath;
  }

  /// Returns flat icon for app bar/header use based on theme
  static String appBarIcon(BuildContext context) {
    return _appIconPath;
  }

  /// Returns settings footer logo based on theme
  static String settingsFooterLogo(BuildContext context) {
    return _otherHorizontalLogoPath;
  }

  /// Returns glow intensity for success modal based on theme
  static double getSuccessModalGlowIntensity(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? 0.6 : 0.4; // 60% for dark mode, 40% for light mode
  }

  /// Returns appropriate tagline color based on theme
  static Color getTaglineColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const Color(0xFFFFFFFF).withValues(alpha: 0.6) // White at 60% opacity
        : const Color(0xFF1D3557).withValues(alpha: 0.6); // Navy at 60% opacity
  }

  /// Returns appropriate authentication subtext color based on theme
  static Color getAuthSubtextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const Color(0xFFFFFFFF).withValues(alpha: 0.8) // White at 80% opacity
        : const Color(0xFF1D3557); // Navy
  }

  /// Returns appropriate onboarding text color based on theme
  static Color getOnboardingTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const Color(0xFFFFFFFF).withValues(alpha: 0.9) // White at 90% opacity
        : const Color(0xFF1D3557); // Navy
  }
}
