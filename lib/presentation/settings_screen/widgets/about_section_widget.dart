import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AboutSectionWidget extends StatefulWidget {
  const AboutSectionWidget({super.key});

  @override
  State<AboutSectionWidget> createState() => _AboutSectionWidgetState();
}

class _AboutSectionWidgetState extends State<AboutSectionWidget> {
  String _versionLabel = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() =>
            _versionLabel = '${info.version} (Build ${info.buildNumber})');
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
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

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'info',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
            title: Text(
              'App Version',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              _versionLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              // Show version info or changelog
            },
          ),

          Divider(color: theme.dividerColor, thickness: 0.5),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: CustomIconWidget(
                  iconName: 'privacy_tip',
                  color: Colors.blue,
                  size: 20,
                ),
              ),
            ),
            title: Text(
              'Privacy Policy',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'How we protect your data',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            trailing: CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: theme.colorScheme.secondary,
              size: 16,
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              // Navigate to privacy policy screen
              Navigator.pushNamed(context, AppRoutes.privacyPolicy);
            },
          ),
        ],
      ),
    );
  }
}
