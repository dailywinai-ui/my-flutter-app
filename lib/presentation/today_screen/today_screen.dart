import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/user_profile.dart';
import '../../services/wins_service.dart';
import 'package:win_daily/theme/wddl_design_system.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/empty_state_widget.dart';
import './widgets/floating_action_button_widget.dart';
import './widgets/tab_navigation_widget.dart';
import './widgets/win_card_widget.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen>
    with TickerProviderStateMixin {
  UserProfile? _userProfile;
  int _currentTabIndex = 0;
  int _currentBottomNavIndex = 0;
  bool _isLoading = false;
  Map<String, dynamic>? _todayWin;

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

    _loadUserProfile();
    _loadTodayWin();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await AuthService.instance.getUserProfile();
      if (mounted) setState(() => _userProfile = profile);
    } catch (_) {}
  }

  Future<void> _loadTodayWin() async {
    setState(() => _isLoading = true);
    try {
      final todaysWins = await WinsService.instance.getTodaysWins();
      Map<String, dynamic>? winData;
      if (todaysWins.isNotEmpty) {
        final win = todaysWins.first;
        winData = {
          "id": win.id,
          "title": win.description,
          "reflection": win.reflection ?? '',
          "mood": win.moodRating ?? 3,
          "timestamp": win.createdAt,
          "date": win.winDate,
          "type": "daily_win",
        };
      }
      setState(() {
        _todayWin = winData;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _todayWin = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    HapticFeedback.lightImpact();
    await _loadTodayWin();
  }

  void _onTabChanged(int index) {
    setState(() => _currentTabIndex = index);
    switch (index) {
      case 1:
        Navigator.pushReplacementNamed(context, '/history-screen');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/insights-screen');
        break;
    }
  }

  void _onBottomNavTap(int index) {
    if (index == _currentBottomNavIndex) return;
    setState(() => _currentBottomNavIndex = index);
    switch (index) {
      case 1:
        Navigator.pushReplacementNamed(context, '/history-screen');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/insights-screen');
        break;
    }
  }

  void _onLogWinPressed() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/add-win-modal').then((result) {
      if (result == true) _loadTodayWin();
    });
  }

  void _onWinCardTap() {
    if (_todayWin != null) {
      Navigator.pushNamed(context, '/win-detail-screen', arguments: _todayWin);
    }
  }

  void _onWinCardLongPress() {
    if (_todayWin != null) _showWinOptionsSheet();
  }

  void _showWinOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: WDDLDesignSystem.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: WDDLDesignSystem.beigeDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              _sheetTile(
                icon: Icons.edit_outlined,
                label: 'Edit win',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/add-win-modal',
                      arguments: _todayWin);
                },
              ),
              _sheetTile(
                icon: Icons.share_outlined,
                label: 'Share win card',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _sheetTile(
                icon: Icons.delete_outline_rounded,
                label: 'Delete win',
                color: WDDLDesignSystem.error,
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation();
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? WDDLDesignSystem.ink;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: c, size: 22),
      title: Text(
        label,
        style: WDDLDesignSystem.bodyLarge.copyWith(color: c),
      ),
      onTap: onTap,
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: WDDLDesignSystem.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete win?',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: WDDLDesignSystem.ink,
            )),
        content: Text(
          'This action cannot be undone.',
          style: WDDLDesignSystem.body.copyWith(color: WDDLDesignSystem.inkMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: WDDLDesignSystem.body.copyWith(color: WDDLDesignSystem.inkMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteWin();
            },
            child: Text('Delete',
                style: WDDLDesignSystem.body.copyWith(color: WDDLDesignSystem.error)),
          ),
        ],
      ),
    );
  }

  void _deleteWin() async {
    if (_todayWin == null) return;
    try {
      await WinsService.instance.deleteDailyWin(_todayWin!['id']);
      setState(() => _todayWin = null);
    } catch (_) {}
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    final name = _userProfile?.firstName;
    if (hour < 12) return name != null ? 'Good morning, $name.' : 'Good morning.';
    if (hour < 17) return name != null ? 'Good afternoon, $name.' : 'Good afternoon.';
    return name != null ? 'Good evening, $name.' : 'Good evening.';
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WDDLDesignSystem.cream,
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: _refreshData,
                color: WDDLDesignSystem.sage,
                backgroundColor: WDDLDesignSystem.cream,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 48),

                          // Greeting + date header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: WDDLDesignSystem.body.copyWith(
                                    color: WDDLDesignSystem.inkMuted,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(DateTime.now()),
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                    color: WDDLDesignSystem.ink,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Tab navigation
                          TabNavigationWidget(
                            currentIndex: _currentTabIndex,
                            onTabChanged: _onTabChanged,
                          ),

                          // Divider
                          Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            color: WDDLDesignSystem.beigeDark,
                          ),
                        ],
                      ),
                    ),

                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _isLoading
                          ? _buildLoadingState()
                          : _todayWin != null
                              ? _buildWinState()
                              : _buildEmptyState(),
                    ),
                  ],
                ),
              ),

              // FAB only when no win yet
              if (_todayWin == null)
                FloatingActionButtonWidget(onPressed: _onLogWinPressed),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: WDDLDesignSystem.sage,
            strokeWidth: 1.5,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading...',
            style: WDDLDesignSystem.body.copyWith(color: WDDLDesignSystem.inkMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildWinState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          WDDLDesignSystem.newWinCardAnimation(
            child: WinCardWidget(
              winData: _todayWin!,
              onTap: _onWinCardTap,
              onLongPress: _onWinCardLongPress,
            ),
          ),

          const SizedBox(height: 12),

          // Win logged banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: WDDLDesignSystem.sageBg.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: WDDLDesignSystem.sagePale),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    color: WDDLDesignSystem.sage, size: 18),
                const SizedBox(width: 10),
                Text(
                  WDDLDesignSystem.winLoggedMessage,
                  style: WDDLDesignSystem.body.copyWith(
                    color: WDDLDesignSystem.sage,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          EmptyStateWidget(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}