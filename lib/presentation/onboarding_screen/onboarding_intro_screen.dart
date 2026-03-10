import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import 'package:win_daily/theme/wddl_design_system.dart';
import './widgets/onboarding_success_modal.dart';

class OnboardingIntroScreen extends StatefulWidget {
  const OnboardingIntroScreen({super.key});

  @override
  State<OnboardingIntroScreen> createState() => _OnboardingIntroScreenState();
}

class _OnboardingIntroScreenState extends State<OnboardingIntroScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _checkmarkController;
  late AnimationController _plantController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _plantController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _checkmarkController.dispose();
    _plantController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    if (page == 1) _checkmarkController.forward();
    if (page == 2) _plantController.forward();
    HapticFeedback.selectionClick();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);
    try {
      await AuthService.instance.markOnboardingSeen();
      HapticFeedback.mediumImpact();
      if (mounted) _showSuccessModal();
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => OnboardingSuccessModal(
        onComplete: () {
          Navigator.of(context).pop();
          _navigateToNextScreen();
        },
      ),
    );
  }

  void _navigateToNextScreen() {
    if (AuthService.instance.isSignedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.authentication);
    }
  }

  Future<void> _enableReminders() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 19, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: WDDLDesignSystem.sage,
              onPrimary: Colors.white,
              surface: WDDLDesignSystem.cream,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('reminders_enabled', true);
        await prefs.setString(
          'daily_reminder_time',
          '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}',
        );
        HapticFeedback.mediumImpact();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Reminder set for ${pickedTime.format(context)}',
                style: WDDLDesignSystem.body.copyWith(color: Colors.white),
              ),
              backgroundColor: WDDLDesignSystem.ink,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WDDLDesignSystem.cream,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Top nav: progress dots + skip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 60),
                    _buildProgressDots(),
                    SizedBox(
                      width: 60,
                      child: _currentPage < 2
                          ? Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: _skipToEnd,
                                child: Text(
                                  'Skip',
                                  style: WDDLDesignSystem.body.copyWith(
                                    color: WDDLDesignSystem.inkMuted,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

              // Slides
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: [
                    _buildSlide1(),
                    _buildSlide2(),
                    _buildSlide3(),
                  ],
                ),
              ),

              // Bottom CTA
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: _currentPage < 2
                    ? _buildNextButton()
                    : _buildGetStartedSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final isActive = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: isActive
                ? WDDLDesignSystem.sage
                : WDDLDesignSystem.sagePale,
          ),
        );
      }),
    );
  }

  Widget _buildSlide1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.only(bottom: 36),
            child: SvgPicture.asset(
              'assets/images/onboarding/slide1_arc.svg',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  color: WDDLDesignSystem.sageBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.calendar_today_outlined,
                    size: 48, color: WDDLDesignSystem.sage),
              ),
            ),
          ),

          // Headline
          Text(
            'An archive of wins\nyou can doomscroll.',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: WDDLDesignSystem.ink,
              height: 1.25,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            'Win Daily helps you capture one meaningful win each day and move on — without the noise.',
            style: WDDLDesignSystem.bodyLarge.copyWith(
              color: WDDLDesignSystem.inkMuted,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 28),

          // Hint card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: WDDLDesignSystem.sageBg.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Calm, simple, and designed to reduce pressure.',
              style: WDDLDesignSystem.body.copyWith(
                color: WDDLDesignSystem.ink,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mock win card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 32),
            padding: const EdgeInsets.all(20),
            decoration: WDDLDesignSystem.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _checkmarkController,
                      builder: (_, __) => Transform.scale(
                        scale: _checkmarkController.value,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: WDDLDesignSystem.sageBg,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: WDDLDesignSystem.sage, size: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Today\'s Win',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: WDDLDesignSystem.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: WDDLDesignSystem.cream,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: WDDLDesignSystem.beigeDark),
                  ),
                  child: Text(
                    'Took a 10-minute walk during lunch',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: WDDLDesignSystem.inkMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Text(
            'Log what went right.',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: WDDLDesignSystem.ink,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 14),

          Text(
            'Tap the +, jot your win in seconds. Small steps build momentum.',
            style: WDDLDesignSystem.bodyLarge.copyWith(
              color: WDDLDesignSystem.inkMuted,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Tip chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: WDDLDesignSystem.sagePale.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'took a walk · finished an email · showed up',
              style: WDDLDesignSystem.hint.copyWith(color: WDDLDesignSystem.sage),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Sprout illustration
          SvgPicture.asset(
            'assets/images/onboarding/slide3_sprout.svg',
            width: 80,
            height: 80,
            errorBuilder: (_, __, ___) => const Text('🌱', style: TextStyle(fontSize: 56)),
          ),
          const SizedBox(height: 28),

          // Reflection card preview
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 28),
            padding: const EdgeInsets.all(20),
            decoration: WDDLDesignSystem.cardDecoration,
            child: Column(
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    _chip('What went well?'),
                    _chip('What did I learn?'),
                    _chip('Tomorrow I will...'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _moodDot('😔', false),
                    _moodDot('😐', false),
                    _moodDot('🙂', true),
                    _moodDot('😊', false),
                    _moodDot('🤩', false),
                  ],
                ),
              ],
            ),
          ),

          Text(
            'Reflect, don\'t perform.',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: WDDLDesignSystem.ink,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 14),

          Text(
            'Gentle prompts and a quick mood check — to understand your progress, not perform it.',
            style: WDDLDesignSystem.bodyLarge.copyWith(
              color: WDDLDesignSystem.inkMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: WDDLDesignSystem.sagePale.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: WDDLDesignSystem.hint.copyWith(color: WDDLDesignSystem.sage),
      ),
    );
  }

  Widget _moodDot(String emoji, bool selected) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? WDDLDesignSystem.sagePale : Colors.transparent,
        border: selected
            ? Border.all(color: WDDLDesignSystem.sage, width: 1.5)
            : null,
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 19))),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _nextPage,
        style: WDDLDesignSystem.primaryButton,
        child: Text(
          'Next',
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildGetStartedSection() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _completeOnboarding,
            style: WDDLDesignSystem.primaryButton,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Get started →',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 14),

        GestureDetector(
          onTap: _enableReminders,
          child: Text(
            'Enable daily reminders',
            style: WDDLDesignSystem.body.copyWith(
              color: WDDLDesignSystem.inkMuted,
              decoration: TextDecoration.underline,
              decorationColor: WDDLDesignSystem.inkMuted.withValues(alpha: 0.4),
            ),
          ),
        ),
      ],
    );
  }
}