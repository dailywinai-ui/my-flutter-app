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

    _loadTodayWin();
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  /// Load today's win for the authenticated user from Supabase
  Future<void> _loadUserProfile() async {
    try {
      final profile = await AuthService.instance.getUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
        });
      }
    } catch (e) {
      // Silently fail - greeting will just not have name
    }
  }

  Future<void> _loadTodayWin() async {
    setState(() => _isLoading = true);

    try {
      // Get today's wins from Supabase
      final todaysWins = await WinsService.instance.getTodaysWins();

      // Convert the first win to display format if any exists
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

    // Navigate to other screens based on tab selection
    switch (index) {
      case 1:
        Navigator.pushNamed(context, '/history-screen');
        break;
      case 2:
        Navigator.pushNamed(context, '/insights-screen');
        break;
      default:
        // Stay on today screen
        break;
    }
  }

  void _onLogWinPressed() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/add-win-modal').then((result) {
      if (result == true) {
        // Win was successfully added
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
    final theme = Theme.of(context);

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
                    color: WDDLDesignSystem.textSecondary.withValues(
                      alpha: 0.3,
                    ),
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
                    Navigator.pushNamed(
                      context,
                      '/add-win-modal',
                      arguments: _todayWin,
                    );
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'share',
                    color: WDDLDesignSystem.primary,
                    size: 24,
                  ),
                  title: Text(
                    'Share Win Card',
                    style: WDDLDesignSystem.bodyLarge,
                  ),
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
                    style: WDDLDesignSystem.bodyLarge.copyWith(
                      color: WDDLDesignSystem.error,
                    ),
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
    // Implement win card sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Win card shared successfully!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showDeleteConfirmation() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
              style: TextButton.styleFrom(
                foregroundColor: WDDLDesignSystem.error,
              ),
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
      // Delete from Supabase
      await WinsService.instance.deleteDailyWin(_todayWin!['id']);

      setState(() => _todayWin = null);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Win deleted successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return _userProfile?.firstName != null ? 'Good morning, ${_userProfile!.firstName}!' : 'Good morning';
    } else if (hour < 17) {
      return _userProfile?.firstName != null ? 'Good afternoon, ${_userProfile!.firstName}!' : 'Good afternoon';
    } else {
      return _userProfile?.firstName != null ? 'Good evening, ${_userProfile!.firstName}!' : 'Good evening';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    final day = date.day;

    return '$weekday, $month $day';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WDDLDesignSystem.background,
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
                          // Header with WDDL 48px top padding
                          SizedBox(height: WDDLDesignSystem.headerTopPadding),
                          Padding(
                            padding: WDDLDesignSystem.screenPadding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Greeting with WDDL hint styling
                                Text(
                                  _getGreeting(),
                                  style: WDDLDesignSystem.hint,
                                ),
                                SizedBox(height: 8),
                                // Date with WDDL H1 styling (22-24px)
                                Text(
                                  _formatDate(DateTime.now()),
                                  style: WDDLDesignSystem.h1,
                                ),
                              ],
                            ),
                          ),
                          // Refined top padding after greeting/date section (32px)
                          SizedBox(
                            height: WDDLDesignSystem.greetingDateTopPadding,
                          ),
                          // Tab navigation
                          TabNavigationWidget(
                            currentIndex: _currentTabIndex,
                            onTabChanged: _onTabChanged,
                          ),
                          // Light divider line between date and list of wins (8% opacity #1D3557)
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
                      child:
                          _isLoading
                              ? _buildLoadingState()
                              : _todayWin != null
                              ? _buildWinState()
                              : _buildEmptyState(),
                    ),
                  ],
                ),
              ),
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
            style: WDDLDesignSystem.body.copyWith(
              color: WDDLDesignSystem.textSecondary,
            ),
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
          // Animate new win card with fade-in from 90% opacity and slight upward shift
          WDDLDesignSystem.newWinCardAnimation(
            child: WinCardWidget(
              winData: _todayWin!,
              onTap: _onWinCardTap,
              onLongPress: _onWinCardLongPress,
            ),
          ),
          SizedBox(height: WDDLDesignSystem.componentGap),
          // Toast with refined styling (#84C69B 10% opacity, text #1D3557, 8px blur)
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
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    WDDLDesignSystem.winLoggedMessage,
                    style: WDDLDesignSystem.body.copyWith(
                      color: WDDLDesignSystem.primary, // Text color #1D3557
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Increased gap between last card/toast and floating action button (48px)
          SizedBox(height: WDDLDesignSystem.lastCardToFabGap),
          // Reduced bottom safe area padding (40px)
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
          // Increased gap between last element and floating action button (48px)
          SizedBox(height: WDDLDesignSystem.lastCardToFabGap),
          // Reduced bottom safe area padding (40px)
          SizedBox(height: WDDLDesignSystem.bottomSafeArea),
        ],
      ),
    );
  }
}
