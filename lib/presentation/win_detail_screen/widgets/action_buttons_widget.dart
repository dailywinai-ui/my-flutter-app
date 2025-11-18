import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback onCreateWinCard;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ActionButtonsWidget({
    super.key,
    required this.onCreateWinCard,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          // Create Win Card Button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                onCreateWinCard();
              },
              icon: CustomIconWidget(
                iconName: 'share',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: Text(
                'Create Win Card',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Action buttons row
          Row(
            children: [
              // Edit button
              Expanded(
                child: SizedBox(
                  height: 5.h,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onEdit();
                    },
                    icon: CustomIconWidget(
                      iconName: 'edit',
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                    label: Text(
                      'Edit',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: theme.colorScheme.outline,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 3.w),

              // Delete button
              SizedBox(
                height: 5.h,
                child: IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showDeleteConfirmation(context);
                  },
                  icon: CustomIconWidget(
                    iconName: 'more_vert',
                    color: theme.colorScheme.secondary,
                    size: 20,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Win',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this win? This action cannot be undone.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                HapticFeedback.mediumImpact();
                onDelete();
              },
              child: Text(
                'Delete',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.errorLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
