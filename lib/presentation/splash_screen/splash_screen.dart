import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import 'package:win_daily/theme/wddl_design_system.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    try {
      if (AuthService.instance.isSignedIn) {
        Navigator.pushReplacementNamed(context, AppRoutes.today);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.authentication);
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.authentication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WDDLDesignSystem.cream,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Opacity(
            opacity: _fadeAnim.value,
            child: Transform.scale(
              scale: _scaleAnim.value,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    SvgPicture.asset(
                      'assets/images/the_node_logo.svg',
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                      errorBuilder: (context, _, __) => Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: WDDLDesignSystem.sagePale,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          size: 48,
                          color: WDDLDesignSystem.sage,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // App name — Cormorant
                    Text(
                      'Win Daily',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        color: WDDLDesignSystem.ink,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Tagline — DM Sans
                    Text(
                      'Reflect. Don\'t perform.',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: WDDLDesignSystem.inkMuted,
                        letterSpacing: 0.2,
                      ),
                    ),

                    const SizedBox(height: 64),

                    // Subtle loading dot
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          WDDLDesignSystem.sage.withValues(alpha: 0.5),
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