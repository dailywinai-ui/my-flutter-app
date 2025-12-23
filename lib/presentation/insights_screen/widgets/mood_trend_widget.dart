import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:win_daily/theme/wddl_design_system.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MoodTrendWidget extends StatelessWidget {
  final List<double?> moodScoresLast30;
  final double averageMood;

  const MoodTrendWidget({
    super.key,
    required this.moodScoresLast30,
    required this.averageMood,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: WDDLDesignSystem.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mood trend (30 days)', style: WDDLDesignSystem.h2),SvgPicture.asset(
                  'assets/images/insights_mood_wave.svg',
                  width: 60,
                  height: 30,
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getMoodColor(averageMood).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Avg ${averageMood.toStringAsFixed(1)}',
                  style: WDDLDesignSystem.body.copyWith(
                    fontSize: 12,
                    color: _getMoodColor(averageMood),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Line chart
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 29,
                minY: 1,
                maxY: 5,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: WDDLDesignSystem.textSecondary.withValues(
                        alpha: 0.1,
                      ),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 7,
                      getTitlesWidget: (value, meta) {
                        final week = (value / 7).floor() + 1;
                        return Text(
                          'W$week',
                          style: WDDLDesignSystem.body.copyWith(
                            fontSize: 10,
                            color: WDDLDesignSystem.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 20,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: WDDLDesignSystem.body.copyWith(
                            fontSize: 10,
                            color: WDDLDesignSystem.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateMoodSpots(),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: WDDLDesignSystem.secondary,
                    barWidth: 2,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 2,
                          color: _getMoodColor(spot.y),
                          strokeColor: Colors.white,
                          strokeWidth: 1,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 12),

          Text(
            'not every day is a high — showing up counts.',
            style: WDDLDesignSystem.body.copyWith(
              color: WDDLDesignSystem.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateMoodSpots() {
    final spots = <FlSpot>[];
    for (int i = 0; i < moodScoresLast30.length; i++) {
      final mood = moodScoresLast30[i];
      if (mood != null) {
        spots.add(FlSpot(i.toDouble(), mood));
      }
    }
    return spots;
  }

  Color _getMoodColor(double mood) {
    if (mood >= 4.5) return WDDLDesignSystem.success;
    if (mood >= 3.5) return WDDLDesignSystem.secondary;
    if (mood >= 2.5) return WDDLDesignSystem.primary;
    return WDDLDesignSystem.error;
  }
}
