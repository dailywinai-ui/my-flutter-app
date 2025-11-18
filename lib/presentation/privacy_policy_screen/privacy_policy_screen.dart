import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'Privacy Policy', showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),
              _buildSectionHeader(theme, '1. Overview'),
              _buildSectionContent(
                theme,
                'Win Daily is built on calm, simplicity, and trust. We believe your wins belong to you — not to advertisers or third parties. This Privacy Policy explains what information we collect, why we collect it, and how we protect it.',
              ),
              SizedBox(height: 3.h),
              _buildSectionHeader(theme, '2. Information We Collect'),
              _buildSectionContent(
                theme,
                'We collect only what\'s necessary to help you track your wins and improve your experience.',
              ),
              SizedBox(height: 2.h),
              _buildSubsectionHeader(theme, 'a. Information you provide:'),
              _buildBulletPoint(
                theme,
                'Your name or email (if you sign up or create an account)',
              ),
              _buildBulletPoint(
                theme,
                'Your logged "wins," reflections, or goals',
              ),
              _buildBulletPoint(
                theme,
                'Optional profile settings (theme, notifications, etc.)',
              ),
              SizedBox(height: 2.h),
              _buildSubsectionHeader(
                theme,
                'b. Information we collect automatically (to improve performance):',
              ),
              _buildBulletPoint(theme, 'Device type and OS version'),
              _buildBulletPoint(
                theme,
                'App usage data (e.g., streaks, feature usage)',
              ),
              _buildBulletPoint(
                theme,
                'Crash and error logs (via analytics tools like Firebase or similar)',
              ),
              SizedBox(height: 2.h),
              _buildSectionContent(
                theme,
                'We do not collect sensitive personal data such as health information, contacts, or precise location.',
              ),
              SizedBox(height: 3.h),
              _buildSectionHeader(theme, '3. How We Use Your Information'),
              _buildSectionContent(theme, 'We use your data to:'),
              _buildBulletPoint(
                theme,
                'Keep your account and streaks synced securely',
              ),
              _buildBulletPoint(theme, 'Improve app performance and usability'),
              _buildBulletPoint(
                theme,
                'Provide personalized features (e.g., reflections, stats)',
              ),
              _buildBulletPoint(
                theme,
                'Send gentle reminders if you\'ve opted in',
              ),
              SizedBox(height: 2.h),
              _buildSectionContent(
                theme,
                'We do not sell or share your personal data with advertisers or external marketers.',
              ),
              SizedBox(height: 3.h),
              _buildSectionHeader(theme, '4. Data Storage and Security'),
              _buildBulletPoint(
                theme,
                'Your data is encrypted during transmission and at rest.',
              ),
              _buildBulletPoint(
                theme,
                'We use trusted third-party cloud providers with strong security standards.',
              ),
              _buildBulletPoint(
                theme,
                'You can request your data or delete your account anytime.',
              ),
              SizedBox(height: 3.h),
              _buildSectionHeader(theme, '5. Your Rights'),
              _buildSectionContent(theme, 'You have the right to:'),
              _buildBulletPoint(theme, 'Access, edit, or delete your data'),
              _buildBulletPoint(theme, 'Withdraw consent for notifications'),
              _buildBulletPoint(
                theme,
                'Request account deletion via support@windaily.app',
              ),
              SizedBox(height: 2.h),
              _buildSectionContent(
                theme,
                'We\'ll respond to all requests within 30 days.',
              ),
              SizedBox(height: 3.h),
              _buildSectionHeader(theme, '6. Third-Party Services'),
              _buildSectionContent(
                theme,
                'Win Daily may use trusted tools (e.g., Firebase Analytics, Google Play Services) to understand how the app performs — never to track you across apps. Each provider adheres to their own privacy and GDPR/CCPA standards.',
              ),
              SizedBox(height: 3.h),
              _buildSectionHeader(theme, '7. Children\'s Privacy'),
              _buildSectionContent(
                theme,
                'Win Daily is designed for users 16 and older. We do not knowingly collect data from children.',
              ),
              SizedBox(height: 3.h),
              _buildSectionHeader(theme, '8. Policy Updates'),
              _buildSectionContent(
                theme,
                'We may update this policy as we evolve. Any major changes will be reflected here, and you\'ll be notified within the app.',
              ),
              SizedBox(height: 6.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
          fontSize: 18.sp,
        ),
      ),
    );
  }

  Widget _buildSubsectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
          fontSize: 16.sp,
        ),
      ),
    );
  }

  Widget _buildSectionContent(ThemeData theme, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Text(
        content,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.secondary,
          height: 1.6,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(ThemeData theme, String content) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 0.8.h, right: 3.w),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
                height: 1.6,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
