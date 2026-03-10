import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../services/wins_service.dart';
import 'package:win_daily/theme/wddl_design_system.dart';
import '../../widgets/custom_bottom_bar.dart';
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

    _loadUserWins();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserWins() async {
    setState(() => _isLoading = true);
    try {
      final dailyWins   = await WinsService.instance.getDailyWins(limit: 100);
      final generalWins = await WinsService.instance.getWins(limit: 100);

      final List<Map<String, dynamic>> combined = [];

      for (final w in dailyWins) {
        combined.add({
          "id": w.id,
          "title": w.description,
          "reflection": w.reflection ?? '',
          "mood": w.moodRating ?? 3,
          "date": w.winDate.toIso8601String(),
          "timestamp": w.createdAt,
          "type": "daily_win",
        });
      }
      for (final w in generalWins) {
        combined.add({
          "id": w.id,
          "title": w.text,
          "reflection": w.reflection ?? '',
          "mood": w.mood ?? 3,
          "date": w.winDate.toIso8601String(),
          "timestamp": w.createdAt,
          "type": "win",
        });
      }

      combined.sort((a, b) =>
          DateTime.parse(b['date'] as String)
              .compareTo(DateTime.parse(a['date'] as String)));

      setState(() {
        _allWins = combined;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load wins: $error',
                style: WDDLDesignSystem.body.copyWith(color: Colors.white)),
            backgroundColor: WDDLDesignSystem.ink,
            action: SnackBarAction(label: 'Retry', onPressed: _loadUserWins),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WDDLDesignSystem.cream,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: WDDLDesignSystem.ink, size: 20),
                    ),
                    Expanded(
                      child: Text(
                        'History',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: WDDLDesignSystem.ink,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushNamed(context, '/settings-screen');
                      },
                      icon: const Icon(Icons.settings_outlined,
                          color: WDDLDesignSystem.ink, size: 20),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: WDDLDesignSystem.sage,
                          strokeWidth: 1.5,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: CalendarViewWidget(
                          wins: _allWins,
                          onDaySelected: (day) =>
                              setState(() => _selectedCalendarDay = day),
                          selectedDay: _selectedCalendarDay,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() => _currentBottomNavIndex = index);
          if (index == 0) Navigator.pushReplacementNamed(context, '/today-screen');
          if (index == 2) Navigator.pushReplacementNamed(context, '/insights-screen');
        },
      ),
    );
  }
}