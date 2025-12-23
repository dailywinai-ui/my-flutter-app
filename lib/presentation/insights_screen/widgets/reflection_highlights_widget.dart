import 'package:flutter/material.dart';

import 'package:win_daily/theme/wddl_design_system.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ReflectionHighlightsWidget extends StatelessWidget {
  final List<String> topReflectionSentences;
  final List<String> top3Keywords;

  const ReflectionHighlightsWidget({
    super.key,
    required this.topReflectionSentences,
    required this.top3Keywords,
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
              Expanded(
                child: Text('Highlights from your reflections', style: WDDLDesignSystem.h2),
              ),
              SvgPicture.asset(
                'assets/images/insights_highlights.svg',
                width: 35,
                height: 35,
              ),
            ],
          ),

          // Reflection sentences
          if (topReflectionSentences.isNotEmpty) ...[
            Column(
              children:
                  topReflectionSentences.take(3).map((sentence) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: WDDLDesignSystem.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: WDDLDesignSystem.textSecondary.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      ),
                      child: Text(
                        sentence,
                        style: WDDLDesignSystem.body.copyWith(
                          color: WDDLDesignSystem.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: WDDLDesignSystem.surface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Start adding reflections to see your highlights here.',
                style: WDDLDesignSystem.body.copyWith(
                  color: WDDLDesignSystem.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          SizedBox(height: 16),

          // Keyword chips
          if (top3Keywords.isNotEmpty) ...[
            Text(
              'Key themes:',
              style: WDDLDesignSystem.body.copyWith(
                color: WDDLDesignSystem.textSecondary,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children:
                  top3Keywords.map((keyword) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: WDDLDesignSystem.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        keyword,
                        style: WDDLDesignSystem.body.copyWith(
                          fontSize: 11,
                          color: WDDLDesignSystem.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}