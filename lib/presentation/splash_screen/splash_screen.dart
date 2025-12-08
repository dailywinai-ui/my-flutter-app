import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../utils/brand_assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Start the fade animation
    _animationController.forward();

    // Wait for animation to complete and check auth state
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    try {
      // Check if user is already authenticated
      if (AuthService.instance.isSignedIn) {
        // Wait a bit more to ensure smooth transition
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;

        Navigator.pushReplacementNamed(context, AppRoutes.today);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.authentication);
      }
    } catch (error) {
      // If there's an error checking auth state, go to auth screen
      print('Error checking auth state: $error');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.authentication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        // Updated background gradient for theme support
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1A1F2A), // bgDarkStart
                    const Color(0xFF2B3442), // bgDarkEnd
                  ]
                : [
                    const Color(0xFFEBE8E3), // Light mode background
                    const Color(0xFFFFFFFF), // Light mode surface
                  ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Updated logo with theme-aware selection and pulse animation
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1.0, end: 1.03),
                    duration: const Duration(seconds: 4),
                    curve: Curves.easeInOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 200,
                          height: 200,
                          child: Image.asset(
                            'assets/images/the_node_logo.svg',
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback with themed container
                              return Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.emoji_events,
                                  size: 80,
                                  color: isDark
                                      ? Colors.white
                                      : theme.colorScheme.primary,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // App name
                  Text(
                    'Win Daily',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: isDark ? Colors.white : Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // App tagline with theme-aware color
                  Text(
                    'One win at a time.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: BrandAssets.getTaglineColor(context),
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Loading indicator
                  SizedBox(
                    width: 6.w,
                    height: 6.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
