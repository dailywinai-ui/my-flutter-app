import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../../core/app_export.dart';

class DataManagementWidget extends StatelessWidget {
  final VoidCallback? onDataCleared;

  const DataManagementWidget({super.key, this.onDataCleared});

  Future<void> _exportData(BuildContext context) async {
    try {
      await HapticFeedback.lightImpact();

      // Mock user data for export
      final Map<String, dynamic> exportData = {
        "app_name": "Win Daily",
        "export_date": DateTime.now().toIso8601String(),
        "version": "1.0.0",
        "user_data": {
          "wins": [
            {
              "id": 1,
              "title": "Completed morning workout",
              "reflection": "Felt energized and ready for the day",
              "mood": 5,
              "date": "2025-10-01T08:30:00.000Z",
            },
            {
              "id": 2,
              "title": "Finished project proposal",
              "reflection":
                  "Proud of the detailed research and clear presentation",
              "mood": 4,
              "date": "2025-10-02T16:45:00.000Z",
            },
            {
              "id": 3,
              "title": "Called mom and had a great conversation",
              "reflection": "Family connections are so important for wellbeing",
              "mood": 5,
              "date": "2025-10-03T19:20:00.000Z",
            },
          ],
          "preferences": {
            "notifications_enabled": true,
            "notification_time": "20:00",
            "theme": "system",
          },
          "stats": {"total_wins": 3, "current_streak": 3, "average_mood": 4.7},
        },
      };

      final String jsonString = const JsonEncoder.withIndent(
        '  ',
      ).convert(exportData);
      final String filename =
          'win_daily_export_${DateTime.now().millisecondsSinceEpoch}.json';

      await _downloadFile(jsonString, filename);

      Fluttertoast.showToast(
        msg: "Data exported successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Export failed. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.errorLight,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _downloadFile(String content, String filename) async {
    if (kIsWeb) {
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor =
          html.AnchorElement(href: url)
            ..setAttribute("download", filename)
            ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);

      // Share the file on mobile
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Win Daily Data Export');
    }
  }

  Future<void> _showClearDataDialog(BuildContext context) async {
    await HapticFeedback.lightImpact();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Reset Wins History',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will permanently delete:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 2.h),
              _buildDeleteItem(context, 'All your logged wins'),
              _buildDeleteItem(context, 'Reflection notes'),
              _buildDeleteItem(context, 'Mood ratings'),
              _buildDeleteItem(context, 'Streak progress'),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.errorLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.errorLight.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'warning',
                      color: AppTheme.errorLight,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'This action cannot be undone',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.errorLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorLight,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Delete All',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _clearAllData(context);
    }
  }

  Widget _buildDeleteItem(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'circle',
            color: theme.colorScheme.secondary,
            size: 6,
          ),
          SizedBox(width: 3.w),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData(BuildContext context) async {
    try {
      await HapticFeedback.mediumImpact();

      // Simulate data clearing process
      await Future.delayed(const Duration(milliseconds: 500));

      if (onDataCleared != null) {
        onDataCleared!();
      }

      Fluttertoast.showToast(
        msg: "All data cleared successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to clear data. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.errorLight,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: const EdgeInsets.all(12),
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
          SizedBox(height: 2.h),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.dividerColor, width: 0.5),
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'download',
                    color: theme.colorScheme.tertiary,
                    size: 20,
                  ),
                ),
              ),
              title: Text(
                'Export Data',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary,
                ),
              ),
              subtitle: Text(
                'Download your wins as JSON file',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
              trailing: CustomIconWidget(
                iconName: 'chevron_right',
                color: theme.colorScheme.secondary,
                size: 20,
              ),
              onTap: () => _exportData(context),
            ),
          ),
          Container(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE76F51).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'delete_outline',
                    color: const Color(0xFFE76F51),
                    size: 20,
                  ),
                ),
              ),
              title: Text(
                'Reset Wins History',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFE76F51),
                ),
              ),
              subtitle: Text(
                'Permanently delete all your data',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
              trailing: CustomIconWidget(
                iconName: 'chevron_right',
                color: theme.colorScheme.secondary,
                size: 20,
              ),
              onTap: () => _showClearDataDialog(context),
            ),
          ),
        ],
      ),
    );
  }
}
