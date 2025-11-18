import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

class ReflectionMoodSelectorWidget extends StatelessWidget {
  final int? selectedMood;
  final Function(int) onMoodSelected;

  const ReflectionMoodSelectorWidget({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  String _getMoodEmoji(int mood) {
    switch (mood) {
      case 1:
        return '😔';
      case 2:
        return '😐';
      case 3:
        return '🙂';
      case 4:
        return '😊';
      case 5:
        return '🌟';
      default:
        return '';
    }
  }

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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final mood = index + 1;
            final isSelected = selectedMood == mood;

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onMoodSelected(mood);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 11.34.w : 9.72.w,
                    height: isSelected ? 11.34.w : 9.72.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isSelected
                              ? const Color(0xFF457B9D).withValues(alpha: 0.15)
                              : Colors.transparent,
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF457B9D,
                                  ).withValues(alpha: 0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : null,
                    ),
                    child: Center(
                      child: Text(
                        _getMoodEmoji(mood),
                        style: TextStyle(
                          fontSize: isSelected ? 19.44.sp : 16.2.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    _getMoodLabel(mood),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          isSelected
                              ? const Color(0xFF457B9D)
                              : theme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 11.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }),
        ),
        SizedBox(height: 3.h),
        Center(
          child: Text(
            'Not every day is a high — showing up is what counts.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6E767D),
              fontSize: 12.sp,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
