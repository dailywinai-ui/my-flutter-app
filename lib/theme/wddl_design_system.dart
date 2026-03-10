import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Win Daily Calm-Tech Design Language (WDDL) — Website-Aligned Tokens
/// Colors sourced directly from windaily.ca CSS variables
class WDDLDesignSystem {
  WDDLDesignSystem._();

  // ─── EXACT WEBSITE COLOR TOKENS ───────────────────────────────────────────
  static const Color sage        = Color(0xFF7D9180); // --sage (primary brand)
  static const Color sageLight   = Color(0xFFA8BCAC); // --sage-light
  static const Color sagePale    = Color(0xFFD4DFD6); // --sage-pale
  static const Color sageBg      = Color(0xFFCFE3D8); // --sage-bg (hero bands)
  static const Color beige       = Color(0xFFF0EBE3); // --beige
  static const Color beigeDark   = Color(0xFFE0D8CC); // --beige-dark
  static const Color ink         = Color(0xFF2C2C27); // --ink (primary text)
  static const Color inkMuted    = Color(0xFF6B6B60); // --ink-muted
  static const Color cream       = Color(0xFFFAF8F4); // --cream (page bg)

  // Semantic aliases (used throughout screens)
  static const Color primary     = sage;
  static const Color secondary   = sageLight;
  static const Color background  = cream;
  static const Color surface     = Color(0xFFFFFFFF);
  static const Color textPrimary = ink;
  static const Color textSecondary = inkMuted;
  static const Color textTertiary  = Color(0xFFABAB9E);

  // Legacy aliases (keeps existing code compiling)
  static const Color sageDark    = Color(0xFF6B7F73); // slightly darker sage
  static const Color sageMedium  = sage;
  static const Color sageBorder  = sagePale; // was #B8CFC7, now mapped to sagePale
  static const Color borderLight = beigeDark;
  static const Color borderMedium = Color(0xFFD4D0C8);
  static const Color inputBackground = Color(0xFFF5F2EE);
  static const Color inputBorder = beigeDark;
  static const Color white       = Color(0xFFFFFFFF);
  static const Color beigeLight  = cream;

  // Status colors
  static const Color success = Color(0xFF84C69B);
  static const Color error   = Color(0xFFE76F51);
  static const Color warning = Color(0xFFE9B872);

  // ─── SPACING ──────────────────────────────────────────────────────────────
  static const double headerTopPadding       = 48.0;
  static const double sectionGap            = 32.0;
  static const double componentGap          = 16.0;
  static const double bottomSafeArea        = 40.0;
  static const double greetingDateTopPadding = 32.0;
  static const double dateToWinCardGap      = 16.0;
  static const double lastCardToFabGap      = 48.0;

  // ─── TYPOGRAPHY ───────────────────────────────────────────────────────────
  // Display / Headings → Cormorant Garamond (serif, editorial)
  // Body / UI          → DM Sans (clean, calm)

  static TextStyle get displayLarge => GoogleFonts.cormorantGaramond(
    fontSize: 36, fontWeight: FontWeight.w600, color: ink, height: 1.2,
    fontStyle: FontStyle.italic,
  );

  static TextStyle get h1Large => GoogleFonts.cormorantGaramond(
    fontSize: 28, fontWeight: FontWeight.w600, color: ink, height: 1.3,
  );

  static TextStyle get h1 => GoogleFonts.cormorantGaramond(
    fontSize: 24, fontWeight: FontWeight.w600, color: ink, height: 1.3,
  );

  static TextStyle get h2 => GoogleFonts.cormorantGaramond(
    fontSize: 20, fontWeight: FontWeight.w500, color: ink, height: 1.4,
  );

  static TextStyle get h2Italic => GoogleFonts.cormorantGaramond(
    fontSize: 20, fontWeight: FontWeight.w500, color: ink, height: 1.4,
    fontStyle: FontStyle.italic,
  );

  // Body text → DM Sans
  static TextStyle get body => GoogleFonts.dmSans(
    fontSize: 14, fontWeight: FontWeight.w400, color: ink, height: 1.6,
  );

  static TextStyle get bodyLarge => GoogleFonts.dmSans(
    fontSize: 16, fontWeight: FontWeight.w400, color: ink, height: 1.6,
  );

  static TextStyle get hint => GoogleFonts.dmSans(
    fontSize: 13, fontWeight: FontWeight.w400, color: inkMuted, height: 1.5,
  );

  static TextStyle get caption => GoogleFonts.dmSans(
    fontSize: 12, fontWeight: FontWeight.w400, color: textTertiary, height: 1.4,
  );

  // Journal textarea → Cormorant italic (feels like writing)
  static TextStyle get journalText => GoogleFonts.cormorantGaramond(
    fontSize: 18, fontWeight: FontWeight.w400, color: ink, height: 1.7,
    fontStyle: FontStyle.italic,
  );

  // Eyebrow labels → DM Sans small caps style
  static TextStyle get eyebrow => GoogleFonts.dmSans(
    fontSize: 11, fontWeight: FontWeight.w600, color: inkMuted, height: 1.4,
    letterSpacing: 1.5,
  );

  // ─── BUTTON STYLES ────────────────────────────────────────────────────────
  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
    backgroundColor: sage,
    foregroundColor: white,
    minimumSize: const Size(double.infinity, 50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 0,
    textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
  );

  static ButtonStyle get secondaryButton => OutlinedButton.styleFrom(
    foregroundColor: sage,
    side: const BorderSide(color: sagePale, width: 1.5),
    minimumSize: const Size(double.infinity, 50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500),
  );

  static ButtonStyle get textButton => TextButton.styleFrom(
    foregroundColor: sage,
    textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
  );

  // ─── INPUT DECORATION ─────────────────────────────────────────────────────
  static InputDecoration get inputDecoration => InputDecoration(
    filled: true,
    fillColor: white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: beigeDark, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: beigeDark, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: sage, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: error, width: 1),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: hint,
  );

  // ─── CARD DECORATIONS ─────────────────────────────────────────────────────
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: beigeDark, width: 1),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF2C2C27).withValues(alpha: 0.04),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration get sageBgCardDecoration => BoxDecoration(
    color: sageBg,
    borderRadius: BorderRadius.circular(14),
  );

  static BoxDecoration get toastDecoration => BoxDecoration(
    color: sagePale.withValues(alpha: 0.5),
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: sagePale, width: 1),
  );

  // ─── TAB STYLES ───────────────────────────────────────────────────────────
  static BoxDecoration get activeTabDecoration => BoxDecoration(
    color: sagePale,
    borderRadius: BorderRadius.circular(8),
  );

  static BoxDecoration get inactiveTabDecoration => BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(8),
  );

  static Color get activeTabTextColor => ink;
  static Color get inactiveTabTextColor => inkMuted;
  static Color get dividerColor => beigeDark;

  // ─── ANIMATIONS ───────────────────────────────────────────────────────────
  static const Duration fadeInDuration        = Duration(milliseconds: 600);
  static const Duration tapFeedbackDuration   = Duration(milliseconds: 150);
  static const Duration successModalDuration  = Duration(milliseconds: 400);
  static const Duration winCardFadeInDuration = Duration(milliseconds: 400);

  static const Curve fadeInCurve           = Curves.easeOut;
  static const Curve tapFeedbackCurve      = Curves.easeInOut;
  static const Curve winCardAnimationCurve = Curves.easeOut;

  // ─── MICROCOPY ────────────────────────────────────────────────────────────
  static const String winLoggedMessage = 'Win logged — keep going.';
  static const String reflectionSavedMessage =
      'Reflection saved — you\'re building self-awareness one day at a time.';

  static const List<String> calmTechMessages = [
    'Reflect. Don\'t perform.',
    'Small steps, big identity.',
    'One win at a time.',
    'Log it, move on and live your life.',
    'An archive of wins you can doomscroll.',
  ];

  // ─── PADDING ──────────────────────────────────────────────────────────────
  static EdgeInsets get screenPadding   => const EdgeInsets.symmetric(horizontal: 24);
  static EdgeInsets get sectionPadding  => const EdgeInsets.only(bottom: sectionGap);
  static EdgeInsets get componentPadding => const EdgeInsets.only(bottom: componentGap);

  // ─── ANIMATION HELPERS ────────────────────────────────────────────────────
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
      onTapUp: (_) => onTap(),
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
}