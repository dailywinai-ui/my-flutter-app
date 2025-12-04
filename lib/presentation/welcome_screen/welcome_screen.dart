import 'package:flutter/material.dart';
import 'package:win_daily/theme/wddl_design_system.dart';
import 'package:win_daily/routes/app_routes.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _continue() {
    // For now, just navigate - we'll add saving later
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.today,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WDDLDesignSystem.beige,
      body: SafeArea(
        child: Padding(
          padding: WDDLDesignSystem.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: WDDLDesignSystem.sageLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: WDDLDesignSystem.sageMedium,
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_outline,
                      size: 40,
                      color: Color(0xFF7A9D8E),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to Win Daily',
                style: WDDLDesignSystem.h1Large.copyWith(fontSize: 28),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'What should we call you?',
                style: WDDLDesignSystem.bodyLarge.copyWith(
                  color: WDDLDesignSystem.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                style: WDDLDesignSystem.h2,
                decoration: WDDLDesignSystem.inputDecoration.copyWith(
                  hintText: 'Your first name',
                ),
                textCapitalization: TextCapitalization.words,
                maxLength: 30,
                onSubmitted: (_) => _continue(),
              ),
              const SizedBox(height: 12),
              Text(
                'We will use it to personalize your experience',
                style: WDDLDesignSystem.caption.copyWith(
                  color: WDDLDesignSystem.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _continue,
                style: WDDLDesignSystem.primaryButton,
                child: const Text('Continue'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _continue,
                style: WDDLDesignSystem.textButton,
                child: const Text('Skip for now'),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
