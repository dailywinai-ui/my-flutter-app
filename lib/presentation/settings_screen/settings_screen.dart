import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/wins_service.dart';
import '../../theme/wddl_design_system.dart';
import '../../utils/brand_assets.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/about_section_widget.dart';
import './widgets/data_management_widget.dart';
import './widgets/notification_settings_widget.dart';
import './widgets/theme_selection_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  bool _isNotificationEnabled = false; // Default OFF as requested
  TimeOfDay? _notificationTime;
  CustomThemeMode _selectedTheme = CustomThemeMode.system;
  int _currentBottomNavIndex = 2; // Settings tab
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // WDDL fade-in animation (opacity 0→1 in 0.6s)
    _fadeAnimationController = AnimationController(
      duration: WDDLDesignSystem.fadeInDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: WDDLDesignSystem.fadeInCurve,
      ),
    );

    _loadSettings();
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    // Load settings from local storage
    // For now, using default values
    setState(() {
      _isNotificationEnabled = false; // Default OFF
      _notificationTime = null;
      _selectedTheme = CustomThemeMode.system;
    });
  }

  Future<void> _saveSettings() async {
    // Save settings to local storage
    // Implementation would use SharedPreferences or similar
  }

  Future<void> _onNotificationToggle(bool enabled) async {
    setState(() {
      _isNotificationEnabled = enabled;
      if (!enabled) {
        _notificationTime = null;
        // Cancel any existing notifications
        _cancelNotifications();
      } else if (_notificationTime == null) {
        _notificationTime = const TimeOfDay(hour: 20, minute: 0);
      }
    });
    _saveSettings();

    // Provide haptic feedback
    HapticFeedback.lightImpact();
  }

  Future<void> _onTimeChanged(TimeOfDay? time) async {
    setState(() {
      _notificationTime = time;
    });
    _saveSettings();

    // Schedule new notification if enabled and time is set
    if (_isNotificationEnabled && time != null) {
      _scheduleNotification(time);
    }
  }

  void _onThemeChanged(CustomThemeMode theme) {
    setState(() {
      _selectedTheme = theme;
    });
    _saveSettings();

    // Apply theme change immediately
    // This would typically involve updating the app's theme through a provider
  }

  void _onDataCleared() {
    // Handle data clearing completion
    // Could navigate to onboarding or show success message
  }

  Future<void> _scheduleNotification(TimeOfDay time) async {
    // Check if user already logged a win today
    try {
      final todaysWins = await WinsService.instance.getTodaysWins();
      if (todaysWins.isNotEmpty) {
        // User already logged a win, don't schedule notification
        return;
      }

      // Schedule notification for specified time
      // Implementation would use flutter_local_notifications or similar
      print('Scheduling notification for ${time.hour}:${time.minute}');
    } catch (error) {
      print('Error checking today\'s wins: $error');
    }
  }

  void _cancelNotifications() {
    // Cancel all scheduled notifications
    // Implementation would use flutter_local_notifications or similar
    print('Cancelling all notifications');
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });

    // Navigate based on index
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/today-screen');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/history-screen');
        break;
      case 2:
        // Already on settings screen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WDDLDesignSystem.background,
      appBar: const CustomAppBar(title: 'Settings', showBackButton: false),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // WDDL header top padding (48px)
                SizedBox(height: WDDLDesignSystem.headerTopPadding),

                // Header section with WDDL typography
                Padding(
                  padding: WDDLDesignSystem.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // WDDL H1 typography (22-24px, weight 600)
                      Text('Settings', style: WDDLDesignSystem.h1Large),
                      SizedBox(height: 8),
                      Text(
                        'Customize your calm routine.',
                        style: WDDLDesignSystem.body.copyWith(
                          color: WDDLDesignSystem.secondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // WDDL section gap (32px)
                SizedBox(height: WDDLDesignSystem.sectionGap),

                // Notification section with WDDL styling
                Padding(
                  padding: WDDLDesignSystem.screenPadding,
                  child: Text(
                    'Notifications',
                    style: WDDLDesignSystem.body.copyWith(
                      fontSize: 14, // Font size 14px
                      fontWeight: FontWeight.w500, // Weight 500
                      color: WDDLDesignSystem.secondary, // Color #457B9D
                    ),
                  ),
                ),
                SizedBox(height: WDDLDesignSystem.componentGap), // 16px spacing
                NotificationSettingsWidget(
                  isNotificationEnabled: _isNotificationEnabled,
                  notificationTime: _notificationTime,
                  onNotificationToggle: _onNotificationToggle,
                  onTimeChanged: _onTimeChanged,
                  reminderText: 'Pick a time to be reminded to reflect.',
                ),

                // WDDL section gap between sections
                SizedBox(height: WDDLDesignSystem.sectionGap),

                // Theme section with WDDL styling
                Padding(
                  padding: WDDLDesignSystem.screenPadding,
                  child: Text(
                    'Appearance',
                    style: WDDLDesignSystem.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: WDDLDesignSystem.secondary,
                    ),
                  ),
                ),
                SizedBox(height: WDDLDesignSystem.componentGap),
                ThemeSelectionWidget(
                  selectedTheme: _selectedTheme,
                  onThemeChanged: _onThemeChanged,
                ),

                // WDDL section gap between sections
                SizedBox(height: WDDLDesignSystem.sectionGap),

                // Data section
                Padding(
                  padding: WDDLDesignSystem.screenPadding,
                  child: Text(
                    'Data & Privacy',
                    style: WDDLDesignSystem.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: WDDLDesignSystem.secondary,
                    ),
                  ),
                ),
                SizedBox(height: WDDLDesignSystem.componentGap),
                DataManagementWidget(onDataCleared: _onDataCleared),

                // WDDL section gap between sections
                SizedBox(height: WDDLDesignSystem.sectionGap),

                // About section
                Padding(
                  padding: WDDLDesignSystem.screenPadding,
                  child: Text(
                    'About',
                    style: WDDLDesignSystem.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: WDDLDesignSystem.secondary,
                    ),
                  ),
                ),
                SizedBox(height: WDDLDesignSystem.componentGap),
                const AboutSectionWidget(),

                // WDDL section gap between sections
                SizedBox(height: WDDLDesignSystem.sectionGap),

                // Account section
                Padding(
                  padding: WDDLDesignSystem.screenPadding,
                  child: Text(
                    'Account',
                    style: WDDLDesignSystem.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: WDDLDesignSystem.secondary,
                    ),
                  ),
                ),
                SizedBox(height: WDDLDesignSystem.componentGap),
                _buildAccountSection(),

                // WDDL section gap between sections
                SizedBox(height: WDDLDesignSystem.sectionGap),

                // Feedback section
                Padding(
                  padding: WDDLDesignSystem.screenPadding,
                  child: Text(
                    'Feedback',
                    style: WDDLDesignSystem.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: WDDLDesignSystem.secondary,
                    ),
                  ),
                ),
                SizedBox(height: WDDLDesignSystem.componentGap),
                _buildFeedbackSection(),

                // WDDL section gap (32px) before footer
                SizedBox(height: WDDLDesignSystem.sectionGap),

                // Footer with theme-aware Win Daily branding
                Container(
                  width: double.infinity,
                  margin: WDDLDesignSystem.screenPadding,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF96C8CF), // Background #96C8CF
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // Theme-aware horizontal lockup (no glow)
                      Container(
                        height: 40,
                        child: Image.asset(
                          BrandAssets.settingsFooterLogo(context),
                          height: 40,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stackTrace) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIconWidget(
                                  iconName: 'emoji_events',
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Win Daily',
                                  style: WDDLDesignSystem.h2.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      SizedBox(height: WDDLDesignSystem.componentGap),

                      // Tagline with theme-aware color
                      Text(
                        'Redefining what it means to win your day. Log it, move on and live your life',
                        textAlign: TextAlign.center,
                        style: WDDLDesignSystem.body.copyWith(
                          fontSize: 12, // Inter Regular 12px
                          color: BrandAssets.getTaglineColor(context),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Extra space for bottom navigation
                SizedBox(height: WDDLDesignSystem.bottomSafeArea * 2),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildAccountSection() {
    return Container(
      margin: WDDLDesignSystem.screenPadding,
      padding: const EdgeInsets.all(16), // Card padding
      decoration: WDDLDesignSystem.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: WDDLDesignSystem.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'logout',
                  color: WDDLDesignSystem.error,
                  size: 20,
                ),
              ),
            ),
            title: Text(
              'Log Out',
              style: WDDLDesignSystem.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
                color: WDDLDesignSystem.error,
              ),
            ),
            subtitle: Text(
              'Sign out of your account',
              style: WDDLDesignSystem.body.copyWith(
                color: WDDLDesignSystem.textSecondary,
              ),
            ),
            trailing: CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: WDDLDesignSystem.error,
              size: 16,
            ),
            onTap: () => _showLogoutDialog(),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Out', style: WDDLDesignSystem.h2),
          content: Text(
            'Are you sure you want to log out of your account?',
            style: WDDLDesignSystem.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: WDDLDesignSystem.secondary),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  Navigator.of(context).pop(); // Close dialog first

                  // Show loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logging out...'),
                      duration: Duration(seconds: 1),
                    ),
                  );

                  // Sign out using AuthService (AuthWrapper will handle navigation automatically)
                  await AuthService.instance.signOut();

                  // Provide haptic feedback
                  HapticFeedback.lightImpact();

                  // Remove manual navigation - let AuthWrapper handle it
                  // The auth state change will automatically redirect to authentication screen
                } catch (error) {
                  // Handle logout error
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Logout failed: ${error.toString()}'),
                        backgroundColor: WDDLDesignSystem.error,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Log Out',
                style: TextStyle(color: WDDLDesignSystem.error),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeedbackSection() {
    return Container(
      margin: WDDLDesignSystem.screenPadding,
      padding: const EdgeInsets.all(16), // Card padding
      decoration: WDDLDesignSystem.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CustomIconWidget(
              iconName: 'star_rate',
              color: Colors.amber,
              size: 24,
            ),
            title: Text(
              'Rate Win Daily',
              style: WDDLDesignSystem.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Share your experience on the App Store',
              style: WDDLDesignSystem.body.copyWith(
                color: WDDLDesignSystem.textSecondary,
              ),
            ),
            trailing: CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: WDDLDesignSystem.secondary,
              size: 16,
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              // Open app store for rating
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening App Store...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
