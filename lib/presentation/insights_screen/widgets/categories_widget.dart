import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/wddl_design_system.dart';

class CategoriesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> tagCounts;
  final Function(String) onTagTap;

  const CategoriesWidget({
    super.key,
    required this.tagCounts,
    required this.onTagTap,
  });

  @override
  Widget build(BuildContext context) {
    final maxCount =
        tagCounts.isEmpty
            ? 1
            : tagCounts
                .map((e) => e['count'] as int)
                .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: WDDLDesignSystem.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Where you\'re winning', style: WDDLDesignSystem.h2),
          SizedBox(height: 16),

          // Top tag chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                tagCounts.take(5).map((tagData) {
                  final tag = tagData['tag'] as String;
                  final count = tagData['count'] as int;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onTagTap(tag);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: WDDLDesignSystem.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: WDDLDesignSystem.secondary.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Text(
                        '$tag $count',
                        style: WDDLDesignSystem.body.copyWith(
                          fontSize: 12,
                          color: WDDLDesignSystem.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),

          SizedBox(height: 16),

          // Horizontal bar chart
          Column(
            children:
                tagCounts.take(5).map((tagData) {
                  final tag = tagData['tag'] as String;
                  final count = tagData['count'] as int;
                  final percentage = maxCount > 0 ? (count / maxCount) : 0.0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text(
                            tag,
                            style: WDDLDesignSystem.body.copyWith(
                              fontSize: 12,
                              color: WDDLDesignSystem.textSecondary,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: WDDLDesignSystem.textSecondary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: percentage,
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: WDDLDesignSystem.success,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          count.toString(),
                          style: WDDLDesignSystem.body.copyWith(
                            fontSize: 12,
                            color: WDDLDesignSystem.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
