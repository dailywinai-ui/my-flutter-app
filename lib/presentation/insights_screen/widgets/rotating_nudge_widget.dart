import 'package:flutter/material.dart';
import 'dart:async';

import '../../../theme/wddl_design_system.dart';

class RotatingNudgeWidget extends StatefulWidget {
  const RotatingNudgeWidget({super.key});

  @override
  State<RotatingNudgeWidget> createState() => _RotatingNudgeWidgetState();
}

class _RotatingNudgeWidgetState extends State<RotatingNudgeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Timer _rotationTimer;

  int _currentIndex = 0;
  final List<String> _quotes = [
    "Every small step forward counts 🌱",
    "Progress, not perfection.",
    "Consistency compounds.",
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();

    // Start rotation timer
    _rotationTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      _rotateQuote();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _rotationTimer.cancel();
    super.dispose();
  }

  void _rotateQuote() {
    if (!mounted) return;

    _fadeController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _quotes.length;
        });
        _fadeController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Text(
              _quotes[_currentIndex],
              style: WDDLDesignSystem.body.copyWith(
                fontSize: 14,
                color: WDDLDesignSystem.primary.withValues(alpha: 0.7),
                fontWeight: FontWeight.w400,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }
}
