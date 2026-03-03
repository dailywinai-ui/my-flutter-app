import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class WinCardWidget extends StatefulWidget {
  final Map<String, dynamic> winData;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const WinCardWidget({
    super.key,
    required this.winData,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<WinCardWidget> createState() => _WinCardWidgetState();
}

class _WinCardWidgetState extends State<WinCardWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = (widget.winData['title'] as String?) ?? '';
    final reflection = (widget.winData['reflection'] as String?) ?? '';
    final mood = (widget.winData['mood'] as int?) ?? 3;
    final timestamp = widget.winData['timestamp'] as DateTime?;

    // Create a preview of the reflection (first line only)
    final reflectionPreview =
        reflection.isNotEmpty ? reflection.split('\n').first : '';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        widget.onLongPress?.call();
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 2.w),
                _buildMoodIndicator(theme, mood),
              ],
            ),
            if (reflection.isNotEmpty) ...[
              SizedBox(height: 1.h),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                  HapticFeedback.lightImpact();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isExpanded ? reflection : reflectionPreview,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: _isExpanded ? null : 1,
                      overflow: _isExpanded ? null : TextOverflow.ellipsis,
                    ),
                    if (reflection.length > reflectionPreview.length &&
                        !_isExpanded) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        'Expand to read more',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (timestamp != null) ...[
              SizedBox(height: 1.5.h),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'access_time',
                    color: theme.colorScheme.secondary,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    _formatTime(timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMoodIndicator(ThemeData theme, int mood) {
    Color moodColor;
    switch (mood) {
      case 1:
        moodColor = const Color(0xFFE53E3E); // Red
        break;
      case 2:
        moodColor = const Color(0xFFD69E2E); // Orange
        break;
      case 3:
        moodColor = const Color(0xFF4A5568); // Gray
        break;
      case 4:
        moodColor = const Color(0xFF38A169); // Green
        break;
      case 5:
        moodColor = const Color(0xFF2B6CB0); // Blue
        break;
      default:
        moodColor = WDDLDesignSystem.sageMedium;
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: moodColor,
        shape: BoxShape.circle,
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
