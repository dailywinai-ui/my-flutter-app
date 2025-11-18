import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


/// Win Daily Calm-Tech Design Language (WDDL)
/// Comprehensive design system for Win Daily application
class WDDLDesignSystem {
  WDDLDesignSystem._();

  // WDDL Color Palette
  static const Color primary = Color(0xFF1D3557);
  static const Color secondary = Color(0xFF457B9D);
  static const Color background = Color(0xFFA8DADC);
  static const Color surface = Color(0xFFF1FAEE);
  static const Color textPrimary = Color(0xFF1D3557);
  static const Color textSecondary = Color(0xFF6E767D);
  static const Color success = Color(0xFF84C69B);
  static const Color error = Color(0xFFE76F51);

  // Input field colors
  static const Color inputBackground = Color(0xFFF8F9FA);
  static const Color inputBorder = Color(0xFFD9E4E6);

  // Vertical Rhythm Grid
  static const double headerTopPadding = 48.0;
  static const double sectionGap = 32.0;
  static const double componentGap = 16.0;
  static const double bottomSafeArea = 40.0; // Reduced from 48px to 40px

  // WDDL Specific Layout Measurements
  static const double greetingDateTopPadding =
      32.0; // Top padding after greeting/date section
  static const double dateToWinCardGap =
      16.0; // Gap between date and first win card
  static const double lastCardToFabGap =
      48.0; // Gap between last card/toast and FAB

  // Typography Specifications
  static TextStyle get h1 => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle get h1Large => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle get h2 => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle get hint => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );

  // Button Styles
  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 0,
    shadowColor: Colors.black.withValues(alpha: 0.1),
    textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
  );

  // Input Field Decoration
  static InputDecoration get inputDecoration => InputDecoration(
    filled: true,
    fillColor: inputBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: inputBorder, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: inputBorder, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: secondary, width: 2),
    ),
    contentPadding: const EdgeInsets.all(16),
    hintStyle: hint,
  );

  // Card Style
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
  );

  // Toast Style (Win logged 🌿)
  static BoxDecoration get toastDecoration => BoxDecoration(
    color: success.withValues(alpha: 0.1), // #84C69B 10% opacity
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: success.withValues(alpha: 0.2), width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 8, // Subtle blur backdrop
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Divider Style (Light divider line between date and wins)
  static Color get dividerColor =>
      primary.withValues(alpha: 0.08); // 8% opacity #1D3557

  // Animations
  static const Duration fadeInDuration = Duration(milliseconds: 600);
  static const Duration tapFeedbackDuration = Duration(milliseconds: 150);
  static const Duration successModalDuration = Duration(milliseconds: 400);
  static const Duration winCardFadeInDuration = Duration(
    milliseconds: 400,
  ); // New win card animation

  // Animation Curves
  static const Curve fadeInCurve = Curves.easeOut;
  static const Curve tapFeedbackCurve = Curves.easeInOut;
  static const Curve winCardAnimationCurve =
      Curves.easeOut; // For calm visual entry

  // Success Messages
  static const String winLoggedMessage = 'Win logged 🌿';
  static const String reflectionSavedMessage =
      'Reflection saved 🌿 — You\'re building self-awareness one day at a time.';

  // Calm-tech Microcopy Examples
  static const List<String> calmTechMessages = [
    'You\'re building momentum 🌿',
    'Small steps, big identity.',
    'One win at a time.',
    'You\'re becoming someone who shows up daily.',
    'Progress, not perfection.',
  ];

  // Tab Styles
  static BoxDecoration get activeTabDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: secondary, width: 1),
  );

  static BoxDecoration get inactiveTabDecoration => BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(12),
  );

  static Color get activeTabTextColor => textPrimary;
  static Color get inactiveTabTextColor => textSecondary.withValues(alpha: 0.7);

  // Helper Methods
  static Widget fadeInWidget({required Widget child, Duration? duration}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration ?? fadeInDuration,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }

  static Widget tapScaleWidget({
    required Widget child,
    required VoidCallback onTap,
    double scale = 0.98,
  }) {
    return GestureDetector(
      onTapDown: (_) => {},
      onTapUp: (_) => onTap(),
      onTapCancel: () => {},
      child: AnimatedScale(
        scale: 1.0,
        duration: tapFeedbackDuration,
        curve: tapFeedbackCurve,
        child: child,
      ),
    );
  }

  // New win card fade-in animation helper
  static Widget newWinCardAnimation({
    required Widget child,
    bool showAnimation = true,
  }) {
    if (!showAnimation) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1.0), // 90% opacity to 100%
      duration: winCardFadeInDuration,
      curve: winCardAnimationCurve,
      builder: (context, opacity, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 8.0, end: 0.0), // Y = +8 → 0
          duration: winCardFadeInDuration,
          curve: winCardAnimationCurve,
          builder: (context, yOffset, child) {
            return Transform.translate(
              offset: Offset(0, yOffset),
              child: Opacity(opacity: opacity, child: child),
            );
          },
          child: child,
        );
      },
      child: child,
    );
  }

  // Screen-specific padding helpers
  static EdgeInsets get screenPadding =>
      const EdgeInsets.symmetric(horizontal: 24);
  static EdgeInsets get sectionPadding =>
      const EdgeInsets.only(bottom: sectionGap);
  static EdgeInsets get componentPadding =>
      const EdgeInsets.only(bottom: componentGap);
}
