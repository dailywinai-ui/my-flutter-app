import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/user_profile.dart';
import '../../services/wins_service.dart';
import 'package:win_daily/theme/wddl_design_system.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/custom_bottom_bar.dart'; // FIX: import bottom bar
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
  // FIX: track bottom nav index — Today is index 0
  int _currentBottomNavIndex = 0;
  bool _isLoading = false;
  Map<String, dynamic>? _todayWin;
  late AnimationController _confettiController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

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

    _loadTodayWin();
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await AuthService.instance.getUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
        });
      }
    } catch (e) {
      // Silently fail
    }
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load today\'s win: $error'),
            backgroundColor: WDDLDesignSystem.error,
          ),
        );
      }
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
        Navigator.pushNamed(context, '/history-screen');
        break;
      case 2:
        Navigator.pushNamed(context, '/insights-screen');
        break;
      default:
        break;
    }
  }

  // FIX: bottom nav handler — uses pushReplacementNamed to avoid stacking
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
      default:
        break;
    }
  }

  void _onLogWinPressed() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/add-win-modal').then((result) {
      if (result == true) {
        _playConfettiAnimation();
        _loadTodayWin();
      }
    });
  }

  void _playConfettiAnimation() {
    _confettiController.forward().then((_) {
      _confettiController.reset();
    });
  }

  void _onWinCardTap() {
    if (_todayWin != null) {
      Navigator.pushNamed(context, '/win-detail-screen', arguments: _todayWin);
    }
  }

  void _onWinCardLongPress() {
    if (_todayWin != null) {
      _showWinOptionsBottomSheet();
    }
  }

  void _showWinOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: WDDLDesignSystem.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: WDDLDesignSystem.screenPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: WDDLDesignSystem.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: WDDLDesignSystem.componentGap),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'edit',
                    color: WDDLDesignSystem.primary,
                    size: 24,
                  ),
                  title: Text('Edit Win', style: WDDLDesignSystem.bodyLarge),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/add-win-modal',
                        arguments: _todayWin);
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'share',
                    color: WDDLDesignSystem.primary,
                    size: 24,
                  ),
                  title: Text('Share Win Card',
                      style: WDDLDesignSystem.bodyLarge),
                  onTap: () {
                    Navigator.pop(context);
                    _shareWinCard();
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'delete_outline',
                    color: WDDLDesignSystem.error,
                    size: 24,
                  ),
                  title: Text(
                    'Delete Win',
                    style: WDDLDesignSystem.bodyLarge
                        .copyWith(color: WDDLDesignSystem.error),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation();
                  },
                ),
                SizedBox(height: WDDLDesignSystem.componentGap),
              ],
            ),
          ),
        );
      },
    );
  }

  void _shareWinCard() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Win card shared successfully!'),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Delete Win?', style: WDDLDesignSystem.h2),
          content: Text(
            'This action cannot be undone. Your win will be permanently deleted.',
            style: WDDLDesignSystem.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteWin();
              },
              style:
                  TextButton.styleFrom(foregroundColor: WDDLDesignSystem.error),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteWin() async {
    if (_todayWin == null) return;
    HapticFeedback.lightImpact();

    try {
      await WinsService.instance.deleteDailyWin(_todayWin!['id']);
      setState(() => _todayWin = null);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Win deleted successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete win: $error'),
            backgroundColor: WDDLDesignSystem.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return _userProfile?.firstName != null
          ? 'Good morning, ${_userProfile!.firstName}!'
          : 'Good morning';
    } else if (hour < 17) {
      return _userProfile?.firstName != null
          ? 'Good afternoon, ${_userProfile!.firstName}!'
          : 'Good afternoon';
    } else {
      return _userProfile?.firstName != null
          ? 'Good evening, ${_userProfile!.firstName}!'
          : 'Good evening';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WDDLDesignSystem.background,
      // FIX: Add CustomBottomBar so it appears on Today screen consistently
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
                color: WDDLDesignSystem.primary,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          SizedBox(height: WDDLDesignSystem.headerTopPadding),
                          Padding(
                            padding: WDDLDesignSystem.screenPadding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_getGreeting(),
                                    style: WDDLDesignSystem.hint),
                                const SizedBox(height: 8),
                                Text(_formatDate(DateTime.now()),
                                    style: WDDLDesignSystem.h1),
                              ],
                            ),
                          ),
                          SizedBox(
                              height:
                                  WDDLDesignSystem.greetingDateTopPadding),
                          TabNavigationWidget(
                            currentIndex: _currentTabIndex,
                            onTabChanged: _onTabChanged,
                          ),
                          Container(
                            height: 1,
                            margin: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: WDDLDesignSystem.dateToWinCardGap,
                            ),
                            color: WDDLDesignSystem.dividerColor,
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
              // FIX: Only show FAB if no win has been logged today
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
          CircularProgressIndicator(color: WDDLDesignSystem.primary),
          SizedBox(height: WDDLDesignSystem.componentGap),
          Text(
            'Loading your progress...',
            style: WDDLDesignSystem.body
                .copyWith(color: WDDLDesignSystem.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildWinState() {
    return Padding(
      padding: WDDLDesignSystem.screenPadding,
      child: Column(
        children: [
          WDDLDesignSystem.newWinCardAnimation(
            child: WinCardWidget(
              winData: _todayWin!,
              onTap: _onWinCardTap,
              onLongPress: _onWinCardLongPress,
            ),
          ),
          SizedBox(height: WDDLDesignSystem.componentGap),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: WDDLDesignSystem.toastDecoration,
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: WDDLDesignSystem.success,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    WDDLDesignSystem.winLoggedMessage,
                    style: WDDLDesignSystem.body.copyWith(
                      color: WDDLDesignSystem.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: WDDLDesignSystem.lastCardToFabGap),
          SizedBox(height: WDDLDesignSystem.bottomSafeArea),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: WDDLDesignSystem.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          EmptyStateWidget(),
          SizedBox(height: WDDLDesignSystem.lastCardToFabGap),
          SizedBox(height: WDDLDesignSystem.bottomSafeArea),
        ],
      ),
    );
  }
}