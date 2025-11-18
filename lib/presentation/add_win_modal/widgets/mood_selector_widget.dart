import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

class MoodSelectorWidget extends StatelessWidget {
  final int? selectedMood;
  final Function(int) onMoodSelected;

  const MoodSelectorWidget({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  Color _getMoodColor(int mood, ThemeData theme) {
    switch (mood) {
      case 1:
        return theme.colorScheme.error;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return theme.colorScheme.outline;
    }
  }

  String _getMoodLabel(int mood) {
    switch (mood) {
      case 1:
        return 'Terrible';
      case 2:
        return 'Bad';
      case 3:
        return 'Okay';
      case 4:
        return 'Good';
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
        Text(
          'How are you feeling?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final mood = index + 1;
            final isSelected = selectedMood == mood;
            final moodColor = _getMoodColor(mood, theme);

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onMoodSelected(mood);
              },
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 12.w : 10.w,
                    height: isSelected ? 12.w : 10.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? moodColor
                          : moodColor.withValues(alpha: 0.3),
                      border: Border.all(
                        color: moodColor,
                        width: isSelected ? 3 : 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: moodColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        mood.toString(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isSelected ? Colors.white : moodColor,
                          fontWeight: FontWeight.w700,
                          fontSize: isSelected ? 16.sp : 14.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    _getMoodLabel(mood),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? moodColor
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        if (selectedMood != null) ...[
          SizedBox(height: 2.h),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 1.h,
              ),
              decoration: BoxDecoration(
                color:
                    _getMoodColor(selectedMood!, theme).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getMoodColor(selectedMood!, theme)
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'Feeling ${_getMoodLabel(selectedMood!).toLowerCase()}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getMoodColor(selectedMood!, theme),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
