import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TabNavigationWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;

  const TabNavigationWidget({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildTabItem(
            context: context,
            index: 0,
            title: 'Today',
            icon: 'today',
            activeIcon: 'today',
          ),
          _buildTabItem(
            context: context,
            index: 1,
            title: 'History',
            icon: 'history',
            activeIcon: 'history',
          ),
          _buildTabItem(
            context: context,
            index: 2,
            title: 'Insights',
            icon: 'insights',
            activeIcon: 'insights',
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required BuildContext context,
    required int index,
    required String title,
    required String icon,
    required String activeIcon,
  }) {
    final theme = Theme.of(context);
    final isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTabChanged(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFF1FAEE) // Lightened active tab background
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? Border(
                    bottom: BorderSide(
                      color: const Color(
                        0xFF457B9D,
                      ), // Active tab underline color
                      width: 2.0,
                    ),
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: isSelected ? activeIcon : icon,
                color: isSelected
                    ? const Color(0xFF1D3557) // Active text color
                    : const Color(0xFF6E767D)
                        .withAlpha(179), // Inactive tabs 70% opacity
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13, // Font size
                  color: isSelected
                      ? const Color(0xFF1D3557) // Active text color
                      : const Color(0xFF6E767D)
                          .withAlpha(179), // Inactive tabs 70% opacity
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
