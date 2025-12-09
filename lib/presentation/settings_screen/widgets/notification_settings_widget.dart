import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class NotificationSettingsWidget extends StatelessWidget {
  final bool isNotificationEnabled;
  final TimeOfDay? notificationTime;
  final Function(bool) onNotificationToggle;
  final Function(TimeOfDay?) onTimeChanged;
  final String? reminderText;

  const NotificationSettingsWidget({
    super.key,
    required this.isNotificationEnabled,
    required this.notificationTime,
    required this.onNotificationToggle,
    required this.onTimeChanged,
    this.reminderText,
  });

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: notificationTime ?? const TimeOfDay(hour: 20, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // Time picker modal: background gradient #EBE8E3 → #E8F0ED
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF7A9D8E), // Selected color #7A9D8E
              surface: const Color(0xFFFFFFFF), // Background start color
              onSurface: const Color(0xFF6B8B7F), // Text color
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: const Color(0xFFFFFFFF),
              dialBackgroundColor: const Color(0xFFEBE8E3),
              dialHandColor: const Color(0xFF7A9D8E),
              dialTextColor: const Color(0xFF6B8B7F),
              entryModeIconColor: const Color(0xFF7A9D8E),
              helpTextStyle: const TextStyle(
                color: Color(0xFF6B8B7F),
                fontWeight: FontWeight.w500,
              ),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: const Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textTheme: Theme.of(context).textTheme.copyWith(
              headlineMedium: const TextStyle(
                color: Color(0xFF6B8B7F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFFFFF), // Background gradient #EBE8E3
                  Color(0xFFEBE8E3), // → #E8F0ED
                ],
              ),
            ),
            child: child!,
          ),
        );
      },
      helpText: 'Pick a time to be reminded to reflect.', // Add header text
    );

    if (picked != null) {
      HapticFeedback.lightImpact();
      onTimeChanged(picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: const EdgeInsets.all(12), // Card padding 12px
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // Background #EBE8E3
        borderRadius: BorderRadius.circular(8), // Radius 8px
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ), // Shadow 0 1 4 rgba(0,0,0,0.05)
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),

          // Notification toggle
          Row(
            children: [
              CustomIconWidget(
                iconName: 'notifications',
                color:
                    isNotificationEnabled
                        ? const Color(0xFF7A9D8E) // Active color #7A9D8E
                        : const Color(0xFFE0E5E9), // Inactive color #E0E5E9
                size: 24,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Check-in Reminder',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (reminderText != null) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        reminderText!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Switch(
                value: isNotificationEnabled,
                onChanged: onNotificationToggle,
                activeColor: const Color(0xFF7A9D8E), // Active color #7A9D8E
                inactiveThumbColor: const Color(0xFFE0E5E9), // Inactive #E0E5E9
                inactiveTrackColor: const Color(
                  0xFFE0E5E9,
                ).withValues(alpha: 0.5),
              ),
            ],
          ),

          // Time picker (only show when notifications are enabled)
          if (isNotificationEnabled && notificationTime != null) ...[
            SizedBox(height: 2.h),
            InkWell(
              onTap: () => _selectTime(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'schedule',
                      color: const Color(0xFF7A9D8E), // Selected color #7A9D8E
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Remind me at ${_formatTime(notificationTime!)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    CustomIconWidget(
                      iconName: 'edit',
                      color: theme.colorScheme.secondary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Time picker prompt (when enabled but no time set)
          if (isNotificationEnabled && notificationTime == null) ...[
            SizedBox(height: 2.h),
            InkWell(
              onTap: () => _selectTime(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF7A9D8E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF7A9D8E).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'add_alarm',
                      color: const Color(0xFF7A9D8E), // Selected color #7A9D8E
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Tap to set reminder time',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(
                          0xFF7A9D8E,
                        ), // Selected color #7A9D8E
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
