import 'package:flutter/material.dart';

import '../../../theme/wddl_design_system.dart';

class ProgressHaloWidget extends StatefulWidget {
  final int streakCount;

  const ProgressHaloWidget({super.key, required this.streakCount});

  @override
  State<ProgressHaloWidget> createState() => _ProgressHaloWidgetState();
}

class _ProgressHaloWidgetState extends State<ProgressHaloWidget>
    with TickerProviderStateMixin {
  late AnimationController _widthController;
  late AnimationController _pulseController;
  late Animation<double> _widthAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Width animation: smoothly animate width increase as streak count grows
    _widthController = AnimationController(
      duration: Duration(milliseconds: 600), // ease-in-out 0.6s
      vsync: this,
    );

    // Pulse animation: light pulse (opacity 0.6 → 0.9 → 0.6) every 3s
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 3000), // 3s cycle
      vsync: this,
    );

    _widthAnimation = Tween<double>(
      begin: 0.0,
      end: _calculateWidthProgress(),
    ).animate(
      CurvedAnimation(
        parent: _widthController,
        curve: Curves.easeInOut, // ease-in-out curve
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.6, end: 0.9).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _widthController.forward();
    _startPulseAnimation();
  }

  void _startPulseAnimation() {
    _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(ProgressHaloWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streakCount != widget.streakCount) {
      // Update width animation for new streak count
      _widthAnimation = Tween<double>(
        begin: _widthAnimation.value,
        end: _calculateWidthProgress(),
      ).animate(
        CurvedAnimation(parent: _widthController, curve: Curves.easeInOut),
      );
      _widthController.forward();
    }
  }

  @override
  void dispose() {
    _widthController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // Calculate progress width based on streak count (0.0 to 1.0)
  double _calculateWidthProgress() {
    if (widget.streakCount == 0) return 0.0;
    // Max out at 30 days for full width, scale proportionally
    const maxStreak = 30;
    return (widget.streakCount / maxStreak).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16, // Height: 16px as specified
      width: double.infinity, // Full container width
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([_widthAnimation, _pulseAnimation]),
        builder: (context, child) {
          return Stack(
            children: [
              // Background track (subtle)
              Container(
                width: double.infinity,
                height: 16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: WDDLDesignSystem.success.withValues(alpha: 0.05),
                ),
              ),

              // Progress halo with gradient and animation
              Container(
                width:
                    MediaQuery.of(context).size.width * _widthAnimation.value,
                height: 16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      WDDLDesignSystem.success.withValues(
                        alpha:
                            0.17 * // Reduce intensity by 15% (0.2 * 0.85 = 0.17)
                            _pulseAnimation
                                .value, // Adjusted opacity with pulse
                      ),
                      Colors.transparent,
                    ],
                    stops: [0.0, 1.0],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
