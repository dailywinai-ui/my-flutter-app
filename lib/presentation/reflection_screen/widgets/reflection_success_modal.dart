import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ReflectionSuccessModal extends StatefulWidget {
  final VoidCallback onContinue;

  const ReflectionSuccessModal({super.key, required this.onContinue});

  @override
  State<ReflectionSuccessModal> createState() => _ReflectionSuccessModalState();
}

class _ReflectionSuccessModalState extends State<ReflectionSuccessModal>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _fadeController.forward();

    // Auto-close after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _dismissModal();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _dismissModal() async {
    await _fadeController.reverse();
    if (mounted) {
      widget.onContinue();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(6.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success icon
                  Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7A9D8E).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('🌿', style: TextStyle(fontSize: 8.w)),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Success message
                  Text(
                    'Reflection saved',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B8B7F),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 2.h),

                  // Success description with updated message
                  Text(
                    "You're building self-awareness one day at a time.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6E767D),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
