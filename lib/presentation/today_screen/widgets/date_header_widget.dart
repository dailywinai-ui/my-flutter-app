import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:win_daily/theme/wddl_design_system.dart';

class DateHeaderWidget extends StatelessWidget {
  final DateTime date;
  final String greeting;

  const DateHeaderWidget({
    super.key,
    required this.date,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: WDDLDesignSystem.body.copyWith(
              color: WDDLDesignSystem.inkMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(date),
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: WDDLDesignSystem.ink,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}
