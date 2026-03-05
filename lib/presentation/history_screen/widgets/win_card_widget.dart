import 'package:flutter/material.dart';
import 'package:win_daily/theme/wddl_design_system.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WinCardWidget extends StatelessWidget {
  final Map<String, dynamic> win;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  const WinCardWidget({
    super.key,
    required this.win,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateTime.parse(win['date'] as String);
    final mood = win['mood'] as int? ?? 3;

    return Dismissible(
      key: Key('win_${win['id']}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _showDeleteConfirmation(context),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        decoration: BoxDecoration(
          color: WDDLDesignSystem.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomIconWidget(
          iconName: 'delete',
          color: Colors.white,
          size: 24,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _showContextMenu(context);
        },
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          win['title'] as String? ?? 'Untitled Win',
                          // TO:
style: WDDLDesignSystem.bodyLarge.copyWith(
  fontWeight: FontWeight.w500,
  color: WDDLDesignSystem.textPrimary,
  height: 1.5,
),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildMoodIndicator(mood, theme),
                ],
              ),
              if (win['reflection'] != null &&
                  (win['reflection'] as String).isNotEmpty) ...[
                SizedBox(height: 1.h),
                Text(
                  win['reflection'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodIndicator(int mood, ThemeData theme) {
    Color moodColor;
    switch (mood) {
      case 1:
        moodColor = WDDLDesignSystem.error;
        break;
      case 2:
        moodColor = WDDLDesignSystem.warning;
        break;
      case 3:
         moodColor = WDDLDesignSystem.sageMedium;
  break;
      case 4:
        moodColor = WDDLDesignSystem.success;
        break;
      case 5:
        moodColor = WDDLDesignSystem.sageMedium;
        break;
      default:
         moodColor = WDDLDesignSystem.sageMedium;
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: moodColor,
        shape: BoxShape.circle,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final winDate = DateTime(date.year, date.month, date.day);

    if (winDate == today) {
      return 'Today';
    } else if (winDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Win'),
        content: const Text(
            'Are you sure you want to delete this win? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              onDelete?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: WDDLDesignSystem.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Edit Win'),
              onTap: () {
                Navigator.pop(context);
                onEdit?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Share Win Card'),
              onTap: () {
                Navigator.pop(context);
                onShare?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: WDDLDesignSystem.error,
                size: 24,
              ),
              title: const Text('Delete Win'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context).then((confirmed) {
                  if (confirmed == true) {
                    onDelete?.call();
                  }
                });
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
