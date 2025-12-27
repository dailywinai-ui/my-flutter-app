import 'package:flutter/material.dart';

/// Win Daily Brand Assets Helper
/// Provides theme-aware logo and branding asset selection
class BrandAssets {
  BrandAssets._();

  // The Node logo (SVG)
  static const String _nodeLogoPath = 'assets/images/the_node_logo.svg';

  /// All logo methods return The Node logo
  static String splashLogo(BuildContext context) => _nodeLogoPath;
  static String authLogo(BuildContext context) => _nodeLogoPath;
  static String settingsFooterLogo(BuildContext context) => _nodeLogoPath;
  static String successModalLogo(BuildContext context) => _nodeLogoPath;
  static String onboardingLogo(BuildContext context, {required bool isIntroSlide}) => _nodeLogoPath;
  static String alternativeVerticalLogo() => _nodeLogoPath;
  static String otherHorizontalLogo() => _nodeLogoPath;
  static String appBarIcon(BuildContext context) => _nodeLogoPath;

  /// Returns text color for onboarding screens
  static Color getOnboardingTextColor(BuildContext context) {
    return const Color(0xFF6B8B7F); // Sage green for text
  }

  /// Returns tagline color
  static Color getTaglineColor(BuildContext context) {
    return const Color(0xFF6B8B7F); // Sage green
  }

  /// Returns glow intensity for success modal
  static double getSuccessModalGlowIntensity(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? 0.6 : 0.4;
  }
}
