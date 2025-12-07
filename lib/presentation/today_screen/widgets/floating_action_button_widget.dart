import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FloatingActionButtonWidget extends StatefulWidget {
  final VoidCallback onPressed;

  const FloatingActionButtonWidget({super.key, required this.onPressed});

  @override
  State<FloatingActionButtonWidget> createState() =>
      _FloatingActionButtonWidgetState();
}

class _FloatingActionButtonWidgetState extends State<FloatingActionButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      // Align floating button 16px from right and 40px from bottom
      bottom: 40.0,
      right: 16.0,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: (_) {
                _animationController.forward();
                HapticFeedback.mediumImpact();
              },
              onTapUp: (_) {
                _animationController.reverse();
                widget.onPressed();
              },
              onTapCancel: () {
                _animationController.reverse();
              },
              child: Container(
                width: 56, // Standard FAB size
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B8B7F),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const CustomIconWidget(
                  iconName: 'add',
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
