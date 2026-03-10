import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:win_daily/theme/wddl_design_system.dart';
import 'package:win_daily/routes/app_routes.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      try {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          await Supabase.instance.client
              .from('user_profiles')
              .update({
                'first_name': name,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', userId);
          await Future.delayed(const Duration(milliseconds: 300));
        }
      } catch (_) {}
    }

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.today,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WDDLDesignSystem.cream,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // Sage circle monogram
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: WDDLDesignSystem.sageBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: 36,
                        color: WDDLDesignSystem.sage,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Headline — Cormorant
                Text(
                  'Welcome to Win Daily.',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: WDDLDesignSystem.ink,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  'What should we call you?',
                  style: WDDLDesignSystem.bodyLarge.copyWith(
                    color: WDDLDesignSystem.inkMuted,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Name input
                TextField(
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: WDDLDesignSystem.ink,
                  ),
                  decoration: WDDLDesignSystem.inputDecoration.copyWith(
                    hintText: 'Your first name',
                    hintStyle: GoogleFonts.cormorantGaramond(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      color: WDDLDesignSystem.inkMuted.withValues(alpha: 0.5),
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  maxLength: 30,
                  buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                  onSubmitted: (_) => _continue(),
                ),

                const SizedBox(height: 8),

                Text(
                  'We\'ll use this to personalize your experience.',
                  style: WDDLDesignSystem.caption,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                // CTA button
                ElevatedButton(
                  onPressed: _continue,
                  style: WDDLDesignSystem.primaryButton,
                  child: Text(
                    'Continue →',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Skip link
                Center(
                  child: GestureDetector(
                    onTap: _continue,
                    child: Text(
                      'Skip for now',
                      style: WDDLDesignSystem.body.copyWith(
                        color: WDDLDesignSystem.inkMuted,
                        decoration: TextDecoration.underline,
                        decorationColor: WDDLDesignSystem.inkMuted.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}