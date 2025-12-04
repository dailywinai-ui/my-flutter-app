import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:win_daily/theme/wddl_design_system.dart';

class AuthHeaderWidget extends StatefulWidget {
  final bool isSignUp;

  const AuthHeaderWidget({super.key, this.isSignUp = false});

  @override
  State<AuthHeaderWidget> createState() => _AuthHeaderWidgetState();
}

class _AuthHeaderWidgetState extends State<AuthHeaderWidget>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _logoScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize logo animations (fade+scale in 0.6s)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    _logoScaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    // Start logo animation
    _logoController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo section with animation centered vertically within top 30% of screen
        AnimatedBuilder(
          animation: _logoController,
          builder: (context, child) {
            return Opacity(
              opacity: _logoOpacityAnimation.value,
              child: Transform.scale(
                scale: _logoScaleAnimation.value,
                child: Container(
                  width: 50.w,
                  height: 25.w,
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Image.asset(
                    "assets/images/Gemini_Generated_Image_dbsnnjdbsnnjdbsn-1759525515813.png",
                    height: 25.w,
                    width: 50.w,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to clean circular logo design if image fails
                      return Container(
                        width: 50.w,
                        height: 25.w,
                        decoration: BoxDecoration(
                          color: WDDLDesignSystem.surface.withValues(
                            alpha: 0.9,
                          ),
                          borderRadius: BorderRadius.circular(6.w),
                          border: Border.all(
                            color: WDDLDesignSystem.primary.withValues(
                              alpha: 0.2,
                            ),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.emoji_events_outlined,
                              size: 8.w,
                              color: WDDLDesignSystem.primary,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              'Win Daily',
                              style: WDDLDesignSystem.h2.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: WDDLDesignSystem.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Tagline below logo
        Text(
          'One win at a time.',
          style: WDDLDesignSystem.body.copyWith(
            color: WDDLDesignSystem.secondary, // #457B9D
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 32),

        // Header text with WDDL specifications
        Text(
          'Ready to win your day?',
          style: WDDLDesignSystem.h1.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: WDDLDesignSystem.textPrimary, // #1D3557
          ),
        ),

        const SizedBox(height: 8),

        // Subtext
        Text(
          widget.isSignUp
              ? 'Create your account to start building daily momentum.'
              : 'Sign in to continue your calm streak.',
          style: WDDLDesignSystem.body.copyWith(
            color: WDDLDesignSystem.textSecondary, // #6E767D
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
