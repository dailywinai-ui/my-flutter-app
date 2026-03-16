import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:win_daily/theme/wddl_design_system.dart';

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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
              onTapCancel: () => _animationController.reverse(),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: WDDLDesignSystem.sage,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: WDDLDesignSystem.ink.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
