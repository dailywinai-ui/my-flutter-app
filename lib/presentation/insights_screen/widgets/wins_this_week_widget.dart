import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';

import 'package:win_daily/theme/wddl_design_system.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WinsThisWeekWidget extends StatelessWidget {
  final List<int> winsByDayLast7;
  final int completionRate;
  final VoidCallback onTap;

  const WinsThisWeekWidget({
    super.key,
    required this.winsByDayLast7,
    required this.completionRate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysWithWins = winsByDayLast7.where((count) => count > 0).length;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: WDDLDesignSystem.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Wins this week', style: WDDLDesignSystem.h2),
                SvgPicture.asset(
                  'assets/images/insights_weekly_pattern.svg',
                  width: 50,
                  height: 25,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 60,
              child: BarChart(
                BarChartData(
                  maxY: (winsByDayLast7.isEmpty
                          ? 1
                          : winsByDayLast7.reduce((a, b) => a > b ? a : b))
                      .toDouble() + 1,
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final now = DateTime.now();
                          final dayIndex = value.toInt();
                          if (dayIndex < 0 || dayIndex > 6) {
                            return const SizedBox.shrink();
                          }
                          final monday = now.subtract(Duration(days: now.weekday - 1));
                          final date = monday.add(Duration(days: dayIndex));
                          const abbr = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          final label = abbr[date.weekday - 1];
                          final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
                          return Text(
                            label,
                            style: WDDLDesignSystem.body.copyWith(
                              fontSize: 12,
                              color: isToday
                                  ? WDDLDesignSystem.primary
                                  : WDDLDesignSystem.textSecondary,
                              fontWeight: isToday
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: winsByDayLast7.asMap().entries.map((entry) {
                    final index = entry.key;
                    final count = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: count.toDouble(),
                          color: count > 0
                              ? WDDLDesignSystem.success
                              : WDDLDesignSystem.textSecondary
                                  .withValues(alpha: 0.3),
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: WDDLDesignSystem.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: WDDLDesignSystem.success.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '$daysWithWins/7 days • Completion rate: $completionRate%',
                style: WDDLDesignSystem.body.copyWith(
                  fontSize: 12,
                  color: WDDLDesignSystem.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'showing up beats perfection.',
              style: WDDLDesignSystem.body.copyWith(
                color: WDDLDesignSystem.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
