import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class WinCardWidget extends StatelessWidget {
  final Map<String, dynamic> winData;

  const WinCardWidget({
    super.key,
    required this.winData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String date = winData['date'] ?? '';
    final String title = winData['title'] ?? '';
    final String reflection = winData['reflection'] ?? '';
    final int mood = winData['mood'] ?? 3;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date
          Text(
            date,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),

          // Title
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),

          if (reflection.isNotEmpty) ...[
            SizedBox(height: 3.h),
            // Reflection
            Text(
              reflection,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.6,
              ),
            ),
          ],

          SizedBox(height: 3.h),

          // Mood visualization
          Row(
            children: [
              Text(
                'Mood: ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _getMoodColor(mood),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                mood.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(int mood) {
    switch (mood) {
      case 1:
        return const Color(0xFFE53E3E); // Red
      case 2:
        return const Color(0xFFD69E2E); // Orange
      case 3:
        return const Color(0xFF4A5568); // Gray
      case 4:
        return const Color(0xFF2B6CB0); // Blue
      case 5:
        return const Color(0xFF38A169); // Green
      default:
        return const Color(0xFF4A5568);
    }
  }
}
