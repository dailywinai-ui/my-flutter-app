import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:win_daily/theme/wddl_design_system.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: WDDLDesignSystem.sagePale,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_outlined,
              color: WDDLDesignSystem.sage,
              size: 36,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'One win a day',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: WDDLDesignSystem.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Log it, move on, live your life.',
            style: WDDLDesignSystem.body.copyWith(
              color: WDDLDesignSystem.inkMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: WDDLDesignSystem.sagePale,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Tap + to log your first win',
              style: WDDLDesignSystem.caption.copyWith(
                color: WDDLDesignSystem.sage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
