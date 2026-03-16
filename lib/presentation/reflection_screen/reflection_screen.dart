import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/wins_service.dart';
import 'package:win_daily/theme/wddl_design_system.dart';
import './widgets/reflection_mood_selector_widget.dart';
import './widgets/reflection_success_modal.dart';

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

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<String> _allPrompts = [
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

  late final List<String> _displayedPrompts;

  @override
  void initState() {
    super.initState();

    final rand = Random();
    final shuffled = List<String>.from(_allPrompts)..shuffle(rand);
    _displayedPrompts = shuffled.take(3).toList();

    _fadeController = AnimationController(
      duration: WDDLDesignSystem.fadeInDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: WDDLDesignSystem.fadeInCurve),
    );

    _reflectionController.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args?['winId'] != null) {
        setState(() => _winId = args!['winId'] as String);
      }
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  void _selectPrompt(String prompt) {
  setState(() => _selectedPrompt = prompt);
  HapticFeedback.lightImpact();
}
  bool get _hasContent =>
      _reflectionController.text.trim().isNotEmpty || _selectedMood != null;

  Future<void> _saveReflection() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      if (_winId != null) {
        await WinsService.instance.updateDailyWin(
          winId: _winId!,
          reflection: _reflectionController.text.trim().isNotEmpty
              ? _reflectionController.text.trim()
              : null,
          moodRating: _selectedMood,
        );
      }
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => ReflectionSuccessModal(
            onContinue: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/today-screen', (r) => false);
            },
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save reflection.',
                style: WDDLDesignSystem.body.copyWith(color: Colors.white)),
            backgroundColor: WDDLDesignSystem.ink,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WDDLDesignSystem.cream,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Sage-bg hero band
            Container(
              width: double.infinity,
              color: WDDLDesignSystem.sageBg,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Eyebrow
                      Text(
                        'STEP 02',
                        style: WDDLDesignSystem.eyebrow,
                      ),
                      const SizedBox(height: 8),

                      // Headline — Cormorant
                      Text(
                        'Take a moment\nto reflect.',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: WDDLDesignSystem.ink,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Reflection helps you understand your progress — not perform it.',
                        style: WDDLDesignSystem.body.copyWith(
                          color: WDDLDesignSystem.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Scrollable body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Journal textarea
                    Text(
                      'Write your reflection',
                      style: WDDLDesignSystem.h2,
                    ),
                    const SizedBox(height: 12),

                    Container(
                      constraints: const BoxConstraints(minHeight: 140),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: WDDLDesignSystem.beigeDark),
                      ),
                      child: TextField(
                        controller: _reflectionController,
                        maxLines: null,
                        style: WDDLDesignSystem.journalText,
                        decoration: InputDecoration(
                          hintText: 'Today, I realized that…',
                          hintStyle: WDDLDesignSystem.journalText.copyWith(
                            color: WDDLDesignSystem.inkMuted.withValues(alpha: 0.4),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Reflection prompts
                    Text('Reflection prompts', style: WDDLDesignSystem.h2),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _displayedPrompts.map((prompt) {
                        final selected = _selectedPrompt == prompt;
                        return GestureDetector(
                          onTap: () => _selectPrompt(prompt),
                          child: AnimatedContainer(
                            duration: WDDLDesignSystem.tapFeedbackDuration,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? WDDLDesignSystem.sagePale
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected
                                    ? WDDLDesignSystem.sage
                                    : WDDLDesignSystem.beigeDark,
                              ),
                            ),
                            child: Text(
                              prompt,
                              style: WDDLDesignSystem.body.copyWith(
                                color: selected
                                    ? WDDLDesignSystem.sage
                                    : WDDLDesignSystem.ink,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),

                    // Mood section
                    Text('How are you feeling?', style: WDDLDesignSystem.h2),
                    const SizedBox(height: 12),

                    ReflectionMoodSelectorWidget(
                      selectedMood: _selectedMood,
                      onMoodSelected: (m) => setState(() => _selectedMood = m),
                    ),

                    const SizedBox(height: 36),

                    // Save CTA
                    AnimatedOpacity(
                      opacity: _hasContent ? 1.0 : 0.45,
                      duration: const Duration(milliseconds: 250),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _hasContent && !_isSaving
                              ? _saveReflection
                              : null,
                          style: WDDLDesignSystem.primaryButton,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Save reflection →',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Skip link
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context)
                            .pushNamedAndRemoveUntil('/today-screen', (r) => false),
                        child: Text(
                          'Skip for now',
                          style: WDDLDesignSystem.body.copyWith(
                            color: WDDLDesignSystem.inkMuted,
                            decoration: TextDecoration.underline,
                            decorationColor:
                                WDDLDesignSystem.inkMuted.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ),
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