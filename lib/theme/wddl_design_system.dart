import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Win Daily Calm-Tech Design Language (WDDL) - SAGE GREEN REDESIGN
class WDDLDesignSystem {
  WDDLDesignSystem._();

  // SAGE GREEN + BEIGE COLOR PALETTE
  static const Color sageDark = Color(0xFF6B8B7F);
  static const Color sageMedium = Color(0xFF7A9D8E);
  static const Color sageLight = Color(0xFFE8F0ED);
  static const Color sageBorder = Color(0xFFB8CFC7);
  
  static const Color beige = Color(0xFFEBE8E3);
  static const Color beigeLight = Color(0xFFF5F3F0);
  
  static const Color white = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF0EDE8);
  
  static const Color textPrimary = Color(0xFF3D4A5C);
  static const Color textSecondary = Color(0xFF6B7885);
  static const Color textTertiary = Color(0xFFA8A5A0);
  
  static const Color borderLight = Color(0xFFE5E2DD);
  static const Color borderMedium = Color(0xFFD9D5CF);
  
  // Input specific
  static const Color inputBorder = borderLight;
  
  static const Color success = Color(0xFF84C69B);
  static const Color error = Color(0xFFE76F51);
  static const Color warning = Color(0xFFE9B872);
  
  // Legacy compatibility
  static const Color primary = sageMedium;
  static const Color secondary = sageDark;
  static const Color background = beige;
  static const Color surface = white;

  // SPACING
  static const double headerTopPadding = 48.0;
  static const double sectionGap = 32.0;
  static const double componentGap = 16.0;
  static const double bottomSafeArea = 40.0;
  static const double greetingDateTopPadding = 32.0;
  static const double dateToWinCardGap = 16.0;
  static const double lastCardToFabGap = 48.0;

  // TYPOGRAPHY
  static TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 32, fontWeight: FontWeight.w600, color: textPrimary, height: 1.4,
  );

  static TextStyle get h1 => GoogleFonts.inter(
    fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary, height: 1.5,
  );

  static TextStyle get h1Large => GoogleFonts.inter(
    fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary, height: 1.5,
  );

  static TextStyle get h2 => GoogleFonts.inter(
    fontSize: 18, fontWeight: FontWeight.w500, color: textPrimary, height: 1.5,
  );

  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary, height: 1.5,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary, height: 1.5,
  );

  static TextStyle get hint => GoogleFonts.inter(
    fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary, height: 1.5,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w400, color: textTertiary, height: 1.4,
  );

  // BUTTON STYLES
  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
    backgroundColor: sageMedium,
    foregroundColor: white,
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 0,
    textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
  );
  
  static ButtonStyle get secondaryButton => OutlinedButton.styleFrom(
    foregroundColor: sageDark,
    side: BorderSide(color: sageBorder, width: 2),
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
  );
  
  static ButtonStyle get textButton => TextButton.styleFrom(
    foregroundColor: sageDark,
    textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
  );

  // INPUT DECORATION
  static InputDecoration get inputDecoration => InputDecoration(
    filled: true,
    fillColor: white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: borderLight, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: borderLight, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: sageMedium, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: error, width: 2),
    ),
    contentPadding: const EdgeInsets.all(16),
    hintStyle: hint,
  );

  // CARD DECORATION
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: borderLight, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration get toastDecoration => BoxDecoration(
    color: success.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: success.withValues(alpha: 0.2), width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static Color get dividerColor => sageBorder.withValues(alpha: 0.3);

  // ANIMATIONS
  static const Duration fadeInDuration = Duration(milliseconds: 600);
  static const Duration tapFeedbackDuration = Duration(milliseconds: 150);
  static const Duration successModalDuration = Duration(milliseconds: 400);
  static const Duration winCardFadeInDuration = Duration(milliseconds: 400);

  static const Curve fadeInCurve = Curves.easeOut;
  static const Curve tapFeedbackCurve = Curves.easeInOut;
  static const Curve winCardAnimationCurve = Curves.easeOut;

  // MICROCOPY
  static const String winLoggedMessage = 'Win logged 🌿';
  static const String reflectionSavedMessage = 
      'Reflection saved 🌿 — You\'re building self-awareness one day at a time.';

  static const List<String> calmTechMessages = [
    'You\'re building momentum 🌿',
    'Small steps, big identity.',
    'One win at a time.',
    'You\'re becoming someone who shows up daily.',
    'Progress, not perfection.',
  ];

  // TAB STYLES
  static BoxDecoration get activeTabDecoration => BoxDecoration(
    color: sageLight,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: sageMedium, width: 1),
  );

  static BoxDecoration get inactiveTabDecoration => BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(12),
  );

  static Color get activeTabTextColor => textPrimary;
  static Color get inactiveTabTextColor => textSecondary.withValues(alpha: 0.7);

  // HELPERS
  static Widget fadeInWidget({required Widget child, Duration? duration}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration ?? fadeInDuration,
      builder: (context, value, child) => Opacity(opacity: value, child: child),
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

  static Widget newWinCardAnimation({
    required Widget child,
    bool showAnimation = true,
  }) {
    if (!showAnimation) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1.0),
      duration: winCardFadeInDuration,
      curve: winCardAnimationCurve,
      builder: (context, opacity, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 8.0, end: 0.0),
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

  // PADDING
  static EdgeInsets get screenPadding => const EdgeInsets.symmetric(horizontal: 24);
  static EdgeInsets get sectionPadding => const EdgeInsets.only(bottom: sectionGap);
  static EdgeInsets get componentPadding => const EdgeInsets.only(bottom: componentGap);
}
