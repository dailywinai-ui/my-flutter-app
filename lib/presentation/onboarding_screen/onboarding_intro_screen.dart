import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import 'package:win_daily/theme/wddl_design_system.dart';
import '../../utils/brand_assets.dart';
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

  // Animation controllers for smooth animations
  late AnimationController _fadeController;
  late AnimationController _checkmarkController;
  late AnimationController _plantController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize fade animation for screen entry
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // Initialize checkmark animation (bounce-in for slide 2)
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize plant animation (for slide 3)
    _plantController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Start animations
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
    setState(() {
      _currentPage = page;
    });

    // Trigger animations based on the current page
    if (page == 1) {
      _checkmarkController.forward();
    } else if (page == 2) {
      _plantController.forward();
    }

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
    setState(() {
      _isLoading = true;
    });

    try {
      // Mark onboarding as seen using the auth service method
      await AuthService.instance.markOnboardingSeen();

      HapticFeedback.mediumImpact();

      // Show success modal
      if (mounted) {
        _showSuccessModal();
      }
    } catch (e) {
      debugPrint('Error saving onboarding state: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (BuildContext context) {
        return OnboardingSuccessModal(
          onComplete: () {
            Navigator.of(context).pop(); // Close modal
            _navigateToNextScreen();
          },
        );
      },
    );
  }

  void _navigateToNextScreen() {
    // Check if user is already signed in
    if (AuthService.instance.isSignedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.authentication);
    }
  }

  Future<void> _enableReminders() async {
    // Show native time picker for reminder setup
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 19, minute: 0), // 7 PM default
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: WDDLDesignSystem.primary,
              onPrimary: Colors.white,
              surface: WDDLDesignSystem.surface,
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
                'Daily reminder set for ${pickedTime.format(context)} 🌿',
                style: WDDLDesignSystem.body.copyWith(color: Colors.white),
              ),
              backgroundColor: WDDLDesignSystem.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error saving reminder settings: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1A1F2A) : const Color(0xFFFFFFFF),
      body: Container(
        // Theme-aware background gradient
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDark
                    ? [
                      const Color(0xFF1A1F2A), // bgDarkStart
                      const Color(0xFF2B3442), // bgDarkEnd
                    ]
                    : [
                      const Color(0xFFEBE8E3), // #A8DADC
                      const Color(0xFFFFFFFF), // #F1FAEE
                    ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Empty space for balance - fixed width
                          const SizedBox(width: 80),
                          // Progress dots - centered
                          _buildProgressDots(),
                          // Skip button (only on slides 1-2) - fixed width
                          SizedBox(
                            width: 80,
                            child:
                                _currentPage < 2
                                    ? Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: _skipToEnd,
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          minimumSize: Size.zero,
                                        ),
                                        child: Text(
                                          'Skip',
                                          style: WDDLDesignSystem.body.copyWith(
                                            color: WDDLDesignSystem.secondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    )
                                    : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.6,
                        ),
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
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                      child:
                          _currentPage < 2
                              ? _buildNextButton()
                              : _buildGetStartedSection(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                index == _currentPage
                    ? WDDLDesignSystem
                        .secondary // Active dot #457B9D
                    : WDDLDesignSystem.textSecondary.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }

  Widget _buildSlide1() {
    return Padding(
      padding: WDDLDesignSystem.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Updated logo with theme-aware selection and gentle pulse animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: 1.03),
            duration: const Duration(seconds: 4),
            curve: Curves.easeInOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                    BrandAssets.onboardingLogo(context, isIntroSlide: true),
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: WDDLDesignSystem.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.calendar_today_outlined,
                          size: 60,
                          color: WDDLDesignSystem.secondary,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // Title with theme-aware color
          Text(
            'One win a day changes everything.',
            style: WDDLDesignSystem.h1.copyWith(
              color: BrandAssets.getOnboardingTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Body with theme-aware color
          Text(
            'Win Daily helps you capture one meaningful win and move on — without the noise.',
            style: WDDLDesignSystem.bodyLarge.copyWith(
              color: BrandAssets.getOnboardingTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Bottom hint: 13px #6E767D
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: WDDLDesignSystem.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Calm, simple, and designed to reduce pressure.',
              style: WDDLDesignSystem.hint.copyWith(
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
      padding: WDDLDesignSystem.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mock of Add Win modal with theme-aware logo and bounce-in animation
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 32),
            padding: const EdgeInsets.all(20),
            decoration: WDDLDesignSystem.cardDecoration,
            child: Column(
              children: [
                // Header with animated logo
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _checkmarkController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _checkmarkController.value,
                          child: Container(
                            width: 32,
                            height: 32,
                            child: Image.asset(
                              BrandAssets.onboardingLogo(
                                context,
                                isIntroSlide: false,
                              ),
                              width: 32,
                              height: 32,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: WDDLDesignSystem.success,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Today\'s Win',
                        style: WDDLDesignSystem.h2.copyWith(
                          color: BrandAssets.getOnboardingTextColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Example win text
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: WDDLDesignSystem.inputBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: WDDLDesignSystem.inputBorder,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Took a 10-minute walk during lunch',
                    style: WDDLDesignSystem.body.copyWith(
                      color: WDDLDesignSystem.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Title with theme-aware color
          Text(
            'Log what went right.',
            style: WDDLDesignSystem.h1.copyWith(
              color: BrandAssets.getOnboardingTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Body
          Text(
            'Tap the +, jot your win in seconds. Small steps build momentum.',
            style: WDDLDesignSystem.bodyLarge,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Micro-tip chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: WDDLDesignSystem.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: WDDLDesignSystem.secondary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              'Examples: took a walk • finished an email • showed up',
              style: WDDLDesignSystem.hint.copyWith(
                color: WDDLDesignSystem.secondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Fixed: Reflection prompts + emoji row visualization with proper spacing
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 40),
            padding: const EdgeInsets.all(24),
            decoration: WDDLDesignSystem.cardDecoration.copyWith(
              // Fixed: Ensure solid background for card
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2B3442)
                      : Colors.white,
            ),
            child: Column(
              children: [
                // Fixed: Chip prompts with proper spacing
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildPromptChip('What went well?'),
                    _buildPromptChip('What did I learn?'),
                    _buildPromptChip('Tomorrow I will...'),
                  ],
                ),
                const SizedBox(height: 20),
                // 1-5 emoji row (static) with proper spacing
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMoodEmoji('😔', false),
                    _buildMoodEmoji('😐', false),
                    _buildMoodEmoji('🙂', true), // Selected
                    _buildMoodEmoji('😊', false),
                    _buildMoodEmoji('🤩', false),
                  ],
                ),
              ],
            ),
          ),

          // Title with theme-aware color
          Text(
            'Reflect, don\'t perform.',
            style: WDDLDesignSystem.h1.copyWith(
              color: BrandAssets.getOnboardingTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Body with theme-aware color
          Text(
            'Use gentle prompts and a quick mood check to understand your progress.',
            style: WDDLDesignSystem.bodyLarge.copyWith(
              color: BrandAssets.getOnboardingTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Fixed: Footer microcopy with proper background
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2B3442).withValues(alpha: 0.6)
                      : WDDLDesignSystem.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.1)
                        : WDDLDesignSystem.secondary.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Animated plant visual
                AnimatedBuilder(
                  animation: _plantController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, (1 - _plantController.value) * 10),
                      child: Opacity(
                        opacity: _plantController.value,
                        child: const Text('🌱', style: TextStyle(fontSize: 24)),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Not every day is a high — showing up counts.',
                    style: WDDLDesignSystem.hint.copyWith(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: WDDLDesignSystem.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: WDDLDesignSystem.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: WDDLDesignSystem.hint.copyWith(
          color: WDDLDesignSystem.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMoodEmoji(String emoji, bool isSelected) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isSelected
                ? WDDLDesignSystem.primary.withValues(alpha: 0.1)
                : Colors.transparent,
        border:
            isSelected
                ? Border.all(color: WDDLDesignSystem.primary, width: 2)
                : null,
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _nextPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: WDDLDesignSystem.primary, // #1D3557
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Next',
          style: WDDLDesignSystem.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildGetStartedSection() {
    return Column(
      children: [
        // Primary CTA: Get started
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _completeOnboarding,
            style: ElevatedButton.styleFrom(
              backgroundColor: WDDLDesignSystem.primary, // #1D3557
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Text(
                      'Get started',
                      style: WDDLDesignSystem.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),

        const SizedBox(height: 16),

        // Secondary tiny link: Enable reminders
        GestureDetector(
          onTap: _enableReminders,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text(
              'Enable reminders',
              style: WDDLDesignSystem.hint.copyWith(
                color: WDDLDesignSystem.secondary,
                decoration: TextDecoration.underline,
                decorationColor: WDDLDesignSystem.secondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
