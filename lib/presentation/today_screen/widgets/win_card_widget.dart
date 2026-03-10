import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import 'package:win_daily/theme/wddl_design_system.dart';

class WinCardWidget extends StatefulWidget {
  final Map<String, dynamic> winData;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const WinCardWidget({
    super.key,
    required this.winData,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<WinCardWidget> createState() => _WinCardWidgetState();
}

class _WinCardWidgetState extends State<WinCardWidget> {
  bool _isExpanded = false;

  String _formatTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24) return '${diff.inHours}h ago';
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final title      = (widget.winData['title']      as String?) ?? '';
    final reflection = (widget.winData['reflection'] as String?) ?? '';
    final timestamp  = widget.winData['timestamp']   as DateTime?;

    final reflectionPreview =
        reflection.isNotEmpty ? reflection.split('\n').first : '';
    final hasMore = reflection.length > reflectionPreview.length;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        widget.onLongPress?.call();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: WDDLDesignSystem.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Win title — Cormorant, no decoration, no indicator
            Text(
              title,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: WDDLDesignSystem.ink,
                height: 1.35,
              ),
            ),

            // Reflection — italic, collapsible
            if (reflection.isNotEmpty) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  setState(() => _isExpanded = !_isExpanded);
                  HapticFeedback.lightImpact();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isExpanded ? reflection : reflectionPreview,
                      style: WDDLDesignSystem.body.copyWith(
                        color: WDDLDesignSystem.inkMuted,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: _isExpanded ? null : 2,
                      overflow: _isExpanded ? null : TextOverflow.ellipsis,
                    ),
                    if (hasMore && !_isExpanded) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Read more',
                        style: WDDLDesignSystem.caption.copyWith(
                          color: WDDLDesignSystem.sage,
                        ),
                      ),
                    ],
                    if (_isExpanded && hasMore) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Show less',
                        style: WDDLDesignSystem.caption.copyWith(
                          color: WDDLDesignSystem.sage,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Timestamp — quiet, bottom left
            if (timestamp != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: WDDLDesignSystem.inkMuted.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(timestamp),
                    style: WDDLDesignSystem.caption.copyWith(
                      color: WDDLDesignSystem.inkMuted.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],

          ],
        ),
      ),
    );
  }
}}
