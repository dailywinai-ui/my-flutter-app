import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../services/wins_service.dart';
import 'package:win_daily/theme/wddl_design_system.dart';
import '../../utils/brand_assets.dart';
import '../../widgets/custom_bottom_bar.dart';
import 'widgets/profile_settings_widget.dart';
import './widgets/about_section_widget.dart';
import './widgets/data_management_widget.dart';
import './widgets/notification_settings_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  bool _isNotificationEnabled = false;
  TimeOfDay? _notificationTime;
  int _currentBottomNavIndex = 2;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: WDDLDesignSystem.fadeInDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: WDDLDesignSystem.fadeInCurve),
    );
    _fadeController.forward();
    _loadNotificationPrefs();
  }

  Future<void> _loadNotificationPrefs() async {
    final enabled = await NotificationService.instance.isEnabled();
    final time = await NotificationService.instance.getSavedTime();
    if (mounted) {
      setState(() {
        _isNotificationEnabled = enabled;
        _notificationTime = time ?? (enabled ? const TimeOfDay(hour: 20, minute: 0) : null);
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _onNotificationToggle(bool enabled) async {
    if (enabled) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted) return;
    }

    final time = _notificationTime ?? const TimeOfDay(hour: 20, minute: 0);
    setState(() {
      _isNotificationEnabled = enabled;
      _notificationTime = enabled ? time : null;
    });

    await NotificationService.instance.scheduleOrCancel(
      enabled: enabled,
      time: enabled ? time : null,
    );
  }

  Future<void> _onTimeChanged(TimeOfDay? time) async {
    setState(() => _notificationTime = time);
    if (time != null && _isNotificationEnabled) {
      await NotificationService.instance.scheduleOrCancel(
        enabled: true,
        time: time,
      );
    }
  }

  void _onBottomNavTap(int index) {
    setState(() => _currentBottomNavIndex = index);
    switch (index) {
      case 0: Navigator.pushReplacementNamed(context, '/today-screen'); break;
      case 1: Navigator.pushReplacementNamed(context, '/history-screen'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WDDLDesignSystem.cream,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),

                // Page title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          color: WDDLDesignSystem.ink,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Customize your calm routine.',
                        style: WDDLDesignSystem.body.copyWith(
                          color: WDDLDesignSystem.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                _sectionLabel('Profile'),
                const SizedBox(height: 10),
                const ProfileSettingsWidget(),

                const SizedBox(height: 28),

                _sectionLabel('Notifications'),
                const SizedBox(height: 10),
                NotificationSettingsWidget(
                  isNotificationEnabled: _isNotificationEnabled,
                  notificationTime: _notificationTime,
                  onNotificationToggle: _onNotificationToggle,
                  onTimeChanged: _onTimeChanged,
                  reminderText: 'Pick a time to be reminded to reflect.',
                ),

                const SizedBox(height: 28),

                _sectionLabel('Data & Privacy'),
                const SizedBox(height: 10),
                DataManagementWidget(onDataCleared: () {}),

                const SizedBox(height: 28),

                _sectionLabel('About'),
                const SizedBox(height: 10),
                const AboutSectionWidget(),

                const SizedBox(height: 28),

                _sectionLabel('Account'),
                const SizedBox(height: 10),
                _buildAccountCard(),

                const SizedBox(height: 28),

                _sectionLabel('Feedback'),
                const SizedBox(height: 10),
                _buildFeedbackCard(),

                const SizedBox(height: 36),

                // Footer — sageBg band
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  decoration: BoxDecoration(
                    color: WDDLDesignSystem.sageBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        BrandAssets.settingsFooterLogo(context),
                        height: 36,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Text(
                          'Win Daily',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: WDDLDesignSystem.ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Log it, move on and live your life.',
                        textAlign: TextAlign.center,
                        style: WDDLDesignSystem.body.copyWith(
                          color: WDDLDesignSystem.inkMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
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

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        label.toUpperCase(),
        style: WDDLDesignSystem.eyebrow,
      ),
    );
  }

  Widget _buildAccountCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: WDDLDesignSystem.cardDecoration,
      child: _buildRow(
        icon: Icons.logout_rounded,
        iconColor: WDDLDesignSystem.error,
        label: 'Log out',
        sublabel: 'Sign out of your account',
        textColor: WDDLDesignSystem.error,
        onTap: _showLogoutDialog,
      ),
    );
  }

  Widget _buildFeedbackCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: WDDLDesignSystem.cardDecoration,
      child: Column(
        children: [
          _buildRow(
            icon: Icons.star_outline_rounded,
            iconColor: const Color(0xFFF4B942),
            label: 'Rate Win Daily',
            sublabel: 'Share your experience on the App Store',
            onTap: () {},
          ),
          Divider(height: 1, color: WDDLDesignSystem.beigeDark),
          _buildRow(
            icon: Icons.mail_outline_rounded,
            iconColor: WDDLDesignSystem.sage,
            label: 'Contact support',
            sublabel: 'Get help or send feedback',
            onTap: () async {
              final uri = Uri(
                scheme: 'mailto',
                path: 'hello@windaily.ca',
                query: 'subject=Win Daily Support',
              );
              try {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (_) {}
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String sublabel,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: WDDLDesignSystem.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      color: textColor ?? WDDLDesignSystem.ink,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: WDDLDesignSystem.body.copyWith(
                      color: WDDLDesignSystem.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: WDDLDesignSystem.inkMuted.withValues(alpha: 0.5), size: 18),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: WDDLDesignSystem.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Log out?',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: WDDLDesignSystem.ink,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of your account?',
          style: WDDLDesignSystem.body.copyWith(color: WDDLDesignSystem.inkMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: WDDLDesignSystem.body.copyWith(
                    color: WDDLDesignSystem.inkMuted)),
          ),
          TextButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              nav.pop();
              try {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => Center(
                    child: CircularProgressIndicator(
                      color: WDDLDesignSystem.sage,
                      strokeWidth: 1.5,
                    ),
                  ),
                );
                await AuthService.instance.signOut();
                nav.pop();
                nav.pushNamedAndRemoveUntil(
                    '/authentication-screen', (r) => false);
              } catch (error) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed',
                          style: WDDLDesignSystem.body.copyWith(color: Colors.white)),
                      backgroundColor: WDDLDesignSystem.ink,
                    ),
                  );
                }
              }
            },
            child: Text('Log out',
                style: WDDLDesignSystem.body.copyWith(
                    color: WDDLDesignSystem.error)),
          ),
        ],
      ),
    );
  }
}