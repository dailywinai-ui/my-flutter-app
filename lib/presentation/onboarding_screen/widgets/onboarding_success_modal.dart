import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/wddl_design_system.dart';
import '../../../utils/brand_assets.dart';

class OnboardingSuccessModal extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingSuccessModal({super.key, required this.onComplete});

  @override
  State<OnboardingSuccessModal> createState() => _OnboardingSuccessModalState();
}

class _OnboardingSuccessModalState extends State<OnboardingSuccessModal>
    with TickerProviderStateMixin {
  late AnimationController _modalController;
  late AnimationController _iconController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _iconBounceAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize modal fade + scale animation
    _modalController = AnimationController(
      duration: WDDLDesignSystem.successModalDuration, // 400ms
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _modalController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _modalController, curve: Curves.easeOut));

    // Initialize icon bounce-in animation
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _iconBounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );

    // Start animations with slight delay
    _modalController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _iconController.forward();
    });
  }

  @override
  void dispose() {
    _modalController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _handleLogFirstWin() {
    HapticFeedback.mediumImpact();
    Navigator.pushReplacementNamed(context, AppRoutes.addWinModal);
  }

  void _handleComplete() {
    HapticFeedback.lightImpact();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: AnimatedBuilder(
        animation: _modalController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  // Fixed: Solid background colors instead of transparency
                  color: isDark
                      ? const Color(0xFF1A1F2A) // Solid dark modal background
                      : Colors.white, // Solid light modal background
                  borderRadius: BorderRadius.circular(24),
                  // Enhanced backdrop blur effect
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Theme-aware logo with proper animation
                    AnimatedBuilder(
                      animation: _iconBounceAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _iconBounceAnimation.value,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // Fixed: Proper glow effect with solid background
                              color: isDark
                                  ? const Color(0xFF2B3442)
                                  : WDDLDesignSystem.surface,
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? const Color(0xFF7FAFC9)
                                          .withValues(alpha: 0.3)
                                      : WDDLDesignSystem.primary
                                          .withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Image.asset(
                                  BrandAssets.successModalLogo(context),
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: WDDLDesignSystem.success,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Title with proper contrast
                    Text(
                      'You\'re all set!',
                      style: WDDLDesignSystem.h2.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : WDDLDesignSystem.primary,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Subtitle with proper contrast
                    Text(
                      'Ready to start your daily win journey',
                      style: WDDLDesignSystem.body.copyWith(
                        fontSize: 16,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.85)
                            : WDDLDesignSystem.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Continue button with proper styling
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: widget.onComplete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? WDDLDesignSystem.primary
                              : WDDLDesignSystem.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          'Continue',
                          style: WDDLDesignSystem.bodyLarge.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
