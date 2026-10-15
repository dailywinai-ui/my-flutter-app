import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:win_daily/theme/wddl_design_system.dart';

class ReflectionMoodSelectorWidget extends StatelessWidget {
  final int? selectedMood;
  final Function(int) onMoodSelected;

  const ReflectionMoodSelectorWidget({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  String _getMoodLabel(int mood) {
    switch (mood) {
      case 1:
        return 'Low';
      case 2:
        return 'Okay';
      case 3:
        return 'Good';
      case 4:
        return 'Great';
      case 5:
        return 'Amazing';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) {
            final mood = index + 1;
            final isSelected = selectedMood == mood;
            final dotSize = 9.0 + mood * 2.5;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onMoodSelected(mood);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? WDDLDesignSystem.sageBg
                            : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? WDDLDesignSystem.sage
                              : WDDLDesignSystem.beigeDark,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: dotSize,
                          height: dotSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? WDDLDesignSystem.sage
                                : WDDLDesignSystem.sage
                                    .withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getMoodLabel(mood),
                      style: WDDLDesignSystem.caption.copyWith(
                        color: isSelected
                            ? WDDLDesignSystem.sage
                            : WDDLDesignSystem.inkMuted,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'Not every day is a high. Showing up is what counts.',
            style: WDDLDesignSystem.body.copyWith(
              color: WDDLDesignSystem.inkMuted,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
