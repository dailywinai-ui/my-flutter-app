import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:win_daily/theme/wddl_design_system.dart';

class ReflectionCountWidget extends StatefulWidget {
  final int totalReflections;
  final List<int> winsByDay;

  const ReflectionCountWidget({
    super.key,
    required this.totalReflections,
    required this.winsByDay,
  });

  @override
  State<ReflectionCountWidget> createState() => _ReflectionCountWidgetState();
}

class _ReflectionCountWidgetState extends State<ReflectionCountWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _sparklineController;
  late Animation<double> _sparklineAnimation;

  @override
  void initState() {
    super.initState();
    _sparklineController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _sparklineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparklineController, curve: Curves.easeOut),
    );

    // Start sparkline animation after a brief delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _sparklineController.forward();
      }
    });
  }

  @override
  void dispose() {
    _sparklineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            'This month',
            style: WDDLDesignSystem.h2.copyWith(
              color: WDDLDesignSystem.primary,
            ),
          ),
          SizedBox(height: 16),

          // Large number badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: WDDLDesignSystem.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.totalReflections}',
                  style: WDDLDesignSystem.h1.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'days',
                style: WDDLDesignSystem.h2.copyWith(
                  color: WDDLDesignSystem.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          Text(
            'one win at a time.',
            style: WDDLDesignSystem.body.copyWith(
              color: WDDLDesignSystem.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),

          SizedBox(height: 16),

          // 14-day sparkline
          AnimatedBuilder(
            animation: _sparklineAnimation,
            builder: (context, child) {
              return SizedBox(
                height: 40,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (widget.winsByDay.length - 1).toDouble(),
                    minY: 0,
                    maxY: 1,
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots:
                            widget.winsByDay.asMap().entries.map((entry) {
                              final x = entry.key.toDouble();
                              final y =
                                  (entry.value * _sparklineAnimation.value)
                                      .toDouble();
                              return FlSpot(x, y);
                            }).toList(),
                        isCurved: true,
                        curveSmoothness: 0.3,
                        color: WDDLDesignSystem.success.withValues(alpha: 0.7),
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: WDDLDesignSystem.success.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
