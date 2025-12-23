import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../services/wins_service.dart';
import 'package:win_daily/theme/wddl_design_system.dart';
import './widgets/reflection_mood_selector_widget.dart';
import './widgets/reflection_success_modal.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({super.key});

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen>
    with TickerProviderStateMixin {
  final TextEditingController _reflectionController = TextEditingController();
  int? _selectedMood;
  bool _isSaving = false;
  String? _winId;
  String? _selectedPrompt;

  late AnimationController _iconAnimationController;
  late Animation<double> _iconAnimation;
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  final List<String> _allReflectionPrompts = [
    'What made this possible?',
    'How do you feel about this achievement?',
    'What did you learn from this experience?',
    'What would you do differently next time?',
    'Who helped you achieve this win?',
    'What\'s your next step forward?',
    'Why was this important to you?',
    'What surprised you most about this?',
    'How will this help you in the future?',
    'What are you most proud of?',
    'What obstacles did you overcome?',
    'How has this changed you?',
  ];

  List<String> get _displayedPrompts {
    final random = Random();
    final shuffled = List<String>.from(_allReflectionPrompts)..shuffle(random);
    return shuffled.take(3).toList();
  }

  @override
  void initState() {
    super.initState();

    // WDDL fade-in animation (opacity 0→1 in 0.6s)
    _fadeAnimationController = AnimationController(
      duration: WDDLDesignSystem.fadeInDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: WDDLDesignSystem.fadeInCurve,
      ),
    );

    // Initialize animation controller
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _iconAnimationController.repeat(reverse: true);

    // Listen to text changes for CTA button animation
    _reflectionController.addListener(() {
      setState(() {}); // Trigger rebuild for fade-in effect
    });

    // Get win ID from route arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['winId'] != null) {
        setState(() {
          _winId = args['winId'] as String;
        });
      }
      _fadeAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    _fadeAnimationController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  void _selectPrompt(String prompt) {
    setState(() {
      _selectedPrompt = prompt;
    });
    HapticFeedback.lightImpact();

    // Add prompt to text field
    final currentText = _reflectionController.text;
    final newText =
        currentText.isEmpty
            ? prompt
            : currentText.endsWith('\n') || currentText.isEmpty
            ? '$currentText$prompt'
            : '$currentText\n\n$prompt';

    _reflectionController.text = newText;
    _reflectionController.selection = TextSelection.fromPosition(
      TextPosition(offset: _reflectionController.text.length),
    );
  }

  void _onMoodSelected(int mood) {
    setState(() {
      _selectedMood = mood;
    });
  }

  Future<void> _generateAIReflection() async {
    // This would integrate with AI service to generate reflection from win
    HapticFeedback.lightImpact();

    // Placeholder for AI integration
    const aiSuggestion =
        "Today, I realized that taking small steps consistently leads to meaningful progress. This win shows me that I'm capable of growth when I stay committed to my goals.";

    _reflectionController.text = aiSuggestion;
    _reflectionController.selection = TextSelection.fromPosition(
      TextPosition(offset: _reflectionController.text.length),
    );
  }

  bool get _hasContent {
    return _reflectionController.text.trim().isNotEmpty ||
        _selectedMood != null;
  }

  Future<void> _saveReflection() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      if (_winId != null) {
        await WinsService.instance.updateDailyWin(
          winId: _winId!,
          reflection:
              _reflectionController.text.trim().isNotEmpty
                  ? _reflectionController.text.trim()
                  : null,
          moodRating: _selectedMood,
        );
      }

      // Show success modal with WDDL message
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => ReflectionSuccessModal(
                onContinue: () {
                  Navigator.of(context).pop(); // Close modal
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/today-screen', (route) => false);
                },
              ),
        );
      }
    } catch (e) {
      print('Failed to save reflection: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save reflection. Please try again.',
              style: WDDLDesignSystem.body,
            ),
            backgroundColor: WDDLDesignSystem.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WDDLDesignSystem.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Gradient header with WDDL styling
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    WDDLDesignSystem.surface,
                    WDDLDesignSystem.background,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: WDDLDesignSystem.headerTopPadding, // 48px top padding
                    bottom: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // WDDL H2 typography (18px, weight 500)
                          Text(
                            'Take a moment to reflect',
                            style: WDDLDesignSystem.h2,
                          ),
                          SizedBox(width: 8),
                          AnimatedBuilder(
                            animation: _iconAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + (_iconAnimation.value * 0.2),
                                child: const Text(
                                  '💡',
                                  style: TextStyle(fontSize: 20),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: WDDLDesignSystem.componentGap),
                      SizedBox(
                        width: 85.w, // 85% width
                        child: Text(
                          'Reflection helps you understand your progress and celebrate your achievements.',
                          style: WDDLDesignSystem.body.copyWith(
                            color: WDDLDesignSystem.textSecondary,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: WDDLDesignSystem.sectionGap,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Large text box with WDDL styling
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Write your reflection...',
                            style: WDDLDesignSystem.h2,
                          ),
                          SvgPicture.asset(
                            'assets/images/reflection_thought_network.svg',
                            width: 40,
                            height: 40,
                          ),
                        ],
                      ),

                    Container(
                      height: 140.0,
                      decoration: BoxDecoration(
                        color: WDDLDesignSystem.inputBackground,
                        border: Border.all(
                          color: WDDLDesignSystem.inputBorder,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(
                          14,
                        ), // radius 14px as specified
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _reflectionController,
                        maxLines: null,
                        expands: true,
                        style: WDDLDesignSystem.body,
                        decoration: InputDecoration(
                          hintText: 'Today, I realized that…',
                          hintStyle: WDDLDesignSystem.hint.copyWith(
                            color: WDDLDesignSystem.textSecondary.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                      ),
                    ),

                    SizedBox(height: 40.0), // 40px margin below
                    // Reflection prompts with WDDL styling
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16.0,
                      ), // 16px top padding
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reflection Prompts',
                              style: WDDLDesignSystem.h2,
                            ),
                            SvgPicture.asset(
                              'assets/images/reflection_inquiry_pattern.svg',
                              width: 35,
                              height: 35,
                            ),
                          ],
                        ),
                        ),
                    SizedBox(height: WDDLDesignSystem.componentGap),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          _displayedPrompts.map((prompt) {
                            final isSelected = _selectedPrompt == prompt;

                            return GestureDetector(
                              onTap: () => _selectPrompt(prompt),
                              child: AnimatedScale(
                                scale:
                                    isSelected
                                        ? 1.05
                                        : 1.0, // tap animation scale 1.05
                                duration:
                                    WDDLDesignSystem
                                        .tapFeedbackDuration, // 150ms
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        WDDLDesignSystem
                                            .surface, // selected chip bg #EBE8E3
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? WDDLDesignSystem
                                                  .secondary // border #7A9D8E
                                              : WDDLDesignSystem.surface,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    prompt,
                                    style: WDDLDesignSystem.body.copyWith(
                                      color:
                                          isSelected
                                              ? WDDLDesignSystem.secondary
                                              : WDDLDesignSystem.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),

                    SizedBox(
                      height: WDDLDesignSystem.sectionGap,
                    ), // 32px bottom margin
                    // AI Assist chip with WDDL styling
                    GestureDetector(
                      onTap: _generateAIReflection,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: WDDLDesignSystem.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: WDDLDesignSystem.secondary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('✨', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 8),
                            Text(
                              'Generate reflection draft from my win',
                              style: WDDLDesignSystem.body.copyWith(
                                color: WDDLDesignSystem.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Mood rating section with WDDL styling
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                      ), // 24px top padding
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'How are you feeling?',
                              style: WDDLDesignSystem.h2,
                            ),
                            SvgPicture.asset(
                              'assets/images/reflection_mood_spectrum.svg',
                              width: 80,
                              height: 20,
                            ),
                          ],
                        ),
                        ),
                    SizedBox(height: WDDLDesignSystem.componentGap),

                    ReflectionMoodSelectorWidget(
                      selectedMood: _selectedMood,
                      onMoodSelected: _onMoodSelected,
                    ),

                    SizedBox(height: WDDLDesignSystem.sectionGap * 2),

                    // WDDL Save button styling
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                      ), // 8px top margin
                      child: AnimatedOpacity(
                        opacity: _hasContent ? 1.0 : 0.5,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          width: double.infinity,
                          height: 48.0, // height 48px
                          decoration: BoxDecoration(
                            color: WDDLDesignSystem.primary.withValues(
                              alpha: 0.9,
                            ), // 90% opacity
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // radius 12px
                            border: Border.all(
                              color: Colors.white.withValues(
                                alpha: 0.1,
                              ), // subtle white border
                              width: 1,
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed:
                                _hasContent && !_isSaving
                                    ? _saveReflection
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child:
                                _isSaving
                                    ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : Text(
                                      'Save Reflection',
                                      style: WDDLDesignSystem.bodyLarge
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                    ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 40.0), // 40px bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
