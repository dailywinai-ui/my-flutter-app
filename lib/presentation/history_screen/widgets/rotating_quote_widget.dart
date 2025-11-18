import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/wddl_design_system.dart';

class RotatingQuoteWidget extends StatefulWidget {
  const RotatingQuoteWidget({super.key});

  @override
  State<RotatingQuoteWidget> createState() => _RotatingQuoteWidgetState();
}

class _RotatingQuoteWidgetState extends State<RotatingQuoteWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _currentQuoteIndex = 0;
  late List<String> _shuffledQuotes;

  // Quotes array as specified
  static const List<String> _quotes = [
    "Every small step forward counts 🌱",
    "Progress, not perfection.",
    "Consistency is the quiet superpower.",
    "You showed up today — that's a win.",
  ];

  @override
  void initState() {
    super.initState();

    // Randomize quote order per session
    _shuffledQuotes = List.from(_quotes);
    _shuffledQuotes.shuffle(Random());

    // Fade transition animation: fade-out + fade-in (opacity 0→1 in 0.8s) every 6s
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800), // 0.8s transition
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start with first quote visible
    _fadeController.forward();

    // Start rotation timer (every 6s)
    _startRotationTimer();
  }

  void _startRotationTimer() {
    Future.delayed(Duration(seconds: 6), () {
      if (mounted) {
        _rotateToNextQuote();
      }
    });
  }

  void _rotateToNextQuote() async {
    // Fade out current quote
    await _fadeController.reverse();

    if (mounted) {
      // Update to next quote
      setState(() {
        _currentQuoteIndex = (_currentQuoteIndex + 1) % _shuffledQuotes.length;
      });

      // Fade in new quote
      await _fadeController.forward();

      // Schedule next rotation
      _startRotationTimer();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 16,
      ), // 16px top and bottom padding
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              // Add faint translucent card background behind rotating quote
              decoration: BoxDecoration(
                color: Color(
                  0xFFF1FAEE,
                ).withValues(alpha: 0.6), // #F1FAEE at 60% opacity
                borderRadius: BorderRadius.circular(8), // 8px radius
              ),
              padding: EdgeInsets.symmetric(
                vertical: 8, // 8px vertical padding
                horizontal: 16, // 16px horizontal padding
              ),
              child: Text(
                _shuffledQuotes[_currentQuoteIndex],
                style: GoogleFonts.inter(
                  fontSize: 13, // Font size 13px as specified
                  fontWeight: FontWeight.w400, // Weight 400 as specified
                  color: WDDLDesignSystem.textPrimary.withValues(
                    alpha: 0.7, // #1D3557 at 70% opacity
                  ),
                  letterSpacing: 0.2, // Letter spacing 0.2px as specified
                  height: 1.5,
                ),
                textAlign: TextAlign.center, // Centered as specified
              ),
            ),
          );
        },
      ),
    );
  }
}
