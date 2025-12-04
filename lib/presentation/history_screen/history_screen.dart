import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../services/wins_service.dart';
import 'package:win_daily/theme/wddl_design_system.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/calendar_view_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  int _currentBottomNavIndex = 1;
  DateTime? _selectedCalendarDay;
  List<Map<String, dynamic>> _allWins = [];
  bool _isLoading = true;
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

    _loadUserWins();
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    super.dispose();
  }

  /// Load wins for the authenticated user from Supabase
  Future<void> _loadUserWins() async {
    setState(() => _isLoading = true);

    try {
      // Fetch both daily wins and general wins for the user
      final dailyWins = await WinsService.instance.getDailyWins(limit: 100);
      final generalWins = await WinsService.instance.getWins(limit: 100);

      // Convert to display format
      final List<Map<String, dynamic>> combinedWins = [];

      // Add daily wins
      for (final dailyWin in dailyWins) {
        combinedWins.add({
          "id": dailyWin.id,
          "title": dailyWin.description,
          "reflection": dailyWin.reflection ?? '',
          "mood": dailyWin.moodRating ?? 3,
          "date": dailyWin.winDate.toIso8601String(),
          "timestamp": dailyWin.createdAt,
          "type": "daily_win",
        });
      }

      // Add general wins
      for (final win in generalWins) {
        combinedWins.add({
          "id": win.id,
          "title": win.text,
          "reflection": win.reflection ?? '',
          "mood": win.mood ?? 3,
          "date": win.winDate.toIso8601String(),
          "timestamp": win.createdAt,
          "type": "win",
        });
      }

      // Sort by date (newest first)
      combinedWins.sort(
        (a, b) => DateTime.parse(
          b['date'] as String,
        ).compareTo(DateTime.parse(a['date'] as String)),
      );

      setState(() {
        _allWins = combinedWins;
        _isLoading = false;
      });

      // Debug print to help troubleshoot
      print(
        'Loaded ${combinedWins.length} wins: ${dailyWins.length} daily wins, ${generalWins.length} general wins',
      );
    } catch (error) {
      setState(() => _isLoading = false);

      // Enhanced error logging
      print('Failed to load user wins: $error');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load your wins: $error'),
            backgroundColor: WDDLDesignSystem.error,
            action: SnackBarAction(label: 'Retry', onPressed: _loadUserWins),
          ),
        );
      }
    }
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await _loadUserWins();
  }

  void _onCalendarDaySelected(DateTime selectedDay) {
    setState(() {
      _selectedCalendarDay = selectedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WDDLDesignSystem.background,
      appBar: AppBar(
        backgroundColor: WDDLDesignSystem.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false, // Remove automatic back button
        toolbarHeight: kToolbarHeight +
            WDDLDesignSystem.sectionGap, // Add 32px top padding
        flexibleSpace: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              WDDLDesignSystem.sectionGap,
              24,
              0,
            ), // 24px horizontal, 32px top padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  icon: CustomIconWidget(
                    iconName: 'arrow_back_ios',
                    color: WDDLDesignSystem.textPrimary,
                    size: 24,
                  ),
                  tooltip: 'Back',
                ),

                // Centered title with WDDL H2 typography
                Text('History', style: WDDLDesignSystem.h2),

                // Settings button
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/settings-screen');
                  },
                  icon: CustomIconWidget(
                    iconName: 'settings',
                    color: WDDLDesignSystem.textPrimary,
                    size: 24,
                  ),
                  tooltip: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: WDDLDesignSystem.primary,
                    ),
                    SizedBox(height: WDDLDesignSystem.componentGap),
                    Text(
                      'Loading your wins...',
                      style: WDDLDesignSystem.body.copyWith(
                        color: WDDLDesignSystem.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ), // Consistent 24px horizontal, 32px vertical padding
                child: CalendarViewWidget(
                  wins: _allWins,
                  onDaySelected: _onCalendarDaySelected,
                  selectedDay: _selectedCalendarDay,
                ),
              ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });
        },
      ),
    );
  }
}
