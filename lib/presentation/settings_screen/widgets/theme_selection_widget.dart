import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

// Add this enum definition to define CustomThemeMode
enum CustomThemeMode { light, dark, system }

class ThemeSelectionWidget extends StatelessWidget {
  final CustomThemeMode selectedTheme;
  final Function(CustomThemeMode) onThemeChanged;

  const ThemeSelectionWidget({
    super.key,
    required this.selectedTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FAEE),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),

          _buildThemeOption(
            context,
            title: 'Light Theme',
            subtitle: 'Clean and bright interface',
            icon: 'light_mode',
            isSelected: selectedTheme == CustomThemeMode.light,
            onTap: () => onThemeChanged(CustomThemeMode.light),
          ),

          SizedBox(height: 1.h),

          _buildThemeOption(
            context,
            title: 'Dark Theme',
            subtitle: 'Easy on the eyes',
            icon: 'dark_mode',
            isSelected: selectedTheme == CustomThemeMode.dark,
            onTap: () => onThemeChanged(CustomThemeMode.dark),
          ),

          SizedBox(height: 1.h),

          _buildThemeOption(
            context,
            title: 'System Default',
            subtitle: 'Follows your device settings',
            icon: 'settings',
            isSelected: selectedTheme == CustomThemeMode.system,
            onTap: () => onThemeChanged(CustomThemeMode.system),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF457B9D).withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border:
              isSelected
                  ? Border.all(
                    color: const Color(0xFF457B9D).withValues(alpha: 0.3),
                    width: 1,
                  )
                  : null,
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color:
                  isSelected
                      ? const Color(0xFF457B9D)
                      : const Color(0xFFE0E5E9),
              size: 24,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color:
                          isSelected
                              ? const Color(0xFF457B9D)
                              : theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              CustomIconWidget(
                iconName: 'check_circle',
                color: const Color(0xFF457B9D),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}