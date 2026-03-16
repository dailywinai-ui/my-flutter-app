import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:win_daily/theme/wddl_design_system.dart';

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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: WDDLDesignSystem.beige,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WDDLDesignSystem.beigeDark, width: 1),
      ),
      child: Row(
        children: [
          _buildTab(context, 0, 'Today', Icons.wb_sunny_outlined, Icons.wb_sunny),
          _buildTab(context, 1, 'History', Icons.calendar_month_outlined, Icons.calendar_month),
          _buildTab(context, 2, 'Insights', Icons.bar_chart_outlined, Icons.bar_chart),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index, String title,
      IconData icon, IconData activeIcon) {
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? WDDLDesignSystem.sagePale : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? WDDLDesignSystem.sage : WDDLDesignSystem.inkMuted,
                size: 20,
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? WDDLDesignSystem.sage : WDDLDesignSystem.inkMuted,
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
