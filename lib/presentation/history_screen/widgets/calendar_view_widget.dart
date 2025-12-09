import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/app_export.dart';
import 'package:win_daily/theme/wddl_design_system.dart';
import './progress_halo_widget.dart';
import './rotating_quote_widget.dart';

class CalendarViewWidget extends StatefulWidget {
  final List<Map<String, dynamic>> wins;
  final Function(DateTime) onDaySelected;
  final DateTime? selectedDay;

  const CalendarViewWidget({
    super.key,
    required this.wins,
    required this.onDaySelected,
    this.selectedDay,
  });

  @override
  State<CalendarViewWidget> createState() => _CalendarViewWidgetState();
}

class _CalendarViewWidgetState extends State<CalendarViewWidget>
    with TickerProviderStateMixin {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _selectedDayWins = [];
  late AnimationController _dateSelectionController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _dayTapController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = widget.selectedDay ?? DateTime.now();
    _updateSelectedDayWins();

    // Date selection animation: fade in win card below (opacity 0→1, Y=+8→0, duration 0.3s)
    _dateSelectionController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dateSelectionController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _dateSelectionController, curve: Curves.easeOut),
    );

    // Pulse animation for active day tap
    _dayTapController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _dayTapController, curve: Curves.easeInOut),
    );

    _dateSelectionController.forward();
  }

  @override
  void dispose() {
    _dateSelectionController.dispose();
    _dayTapController.dispose();
    super.dispose();
  }

  void _updateSelectedDayWins() {
    if (_selectedDay != null) {
      _selectedDayWins = widget.wins.where((win) {
        final winDate = DateTime.parse(win['date'] as String);
        return isSameDay(winDate, _selectedDay!);
      }).toList();
    } else {
      _selectedDayWins = [];
    }
  }

  List<Map<String, dynamic>> _getWinsForDay(DateTime day) {
    return widget.wins.where((win) {
      final winDate = DateTime.parse(win['date'] as String);
      return isSameDay(winDate, day);
    }).toList();
  }

  // Calculate user streak (simplified version - shows days with wins in current month)
  int _calculateStreak() {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    int streak = 0;
    for (int i = 0; i < daysInMonth; i++) {
      final day = thisMonth.add(Duration(days: i));
      final hasWin = _getWinsForDay(day).isNotEmpty;
      if (hasWin) streak++;
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.wins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: WDDLDesignSystem.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'calendar_month',
                  size: 48,
                  color: WDDLDesignSystem.primary.withValues(alpha: 0.6),
                ),
              ),
            ),
            SizedBox(height: WDDLDesignSystem.sectionGap),
            Text(
              'Your calendar will fill as you log wins.',
              style: WDDLDesignSystem.h2,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Start building your streak today.',
              style: WDDLDesignSystem.body.copyWith(
                color: WDDLDesignSystem.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final streak = _calculateStreak();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month header with elevated styling and optional streak ribbon
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtle divider line above month header
              Container(
                height: 1,
                color: WDDLDesignSystem.dividerColor,
                margin: EdgeInsets.only(bottom: 16),
              ),

              // Month header ("October 2025") - elevated with 18px semi-bold font, color #6B8B7F
              Text(
                _getMonthYearString(_focusedDay),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600, // Semi-bold
                  color: WDDLDesignSystem.textPrimary, // Dark sage #6B8B7F
                  height: 1.5,
                ),
              ),

              // Optional streak ribbon below month title
              if (streak > 0) ...[
                SizedBox(height: 8),
                Container(
                  child: Text(
                    'Reflections this month: $streak',
                    style: GoogleFonts.inter(
                      fontSize: 14, // Font size 14px as specified
                      fontWeight: FontWeight.w600, // Weight 600 as specified
                      color: WDDLDesignSystem.textPrimary.withValues(
                        alpha: 0.85, // Dark sage #6B8B7F at 85% opacity
                      ),
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1), // 0 1px offset
                          blurRadius: 2, // 2px blur
                          color: Colors.black.withValues(
                            alpha: 0.08,
                          ), // rgba(0,0,0,0.08)
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              SizedBox(height: 16),
            ],
          ),

          // Add 8px bottom padding below calendar grid for breathing room
          SizedBox(height: 8),

          // Calendar with proper WDDL styling
          Container(
            decoration: WDDLDesignSystem.cardDecoration.copyWith(
              color: WDDLDesignSystem.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.all(16),
            child: TableCalendar<Map<String, dynamic>>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              eventLoader: _getWinsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) async {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  // Pulse animation on tap
                  HapticFeedback.lightImpact();
                  _dayTapController.forward().then(
                        (_) => _dayTapController.reverse(),
                      );

                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _updateSelectedDayWins();
                  widget.onDaySelected(selectedDay);

                  // Restart fade-in animation for new selection
                  _dateSelectionController.reset();
                  await _dateSelectionController.forward();
                }
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: WDDLDesignSystem.body,
                holidayTextStyle: WDDLDesignSystem.body,

                // Highlight active day with filled background #7A9D8E (10% opacity), border #7A9D8E
                selectedDecoration: BoxDecoration(
                  color: WDDLDesignSystem.secondary.withValues(
                    alpha: 0.1,
                  ), // Sage green #7A9D8E 10% opacity
                  border: Border.all(
                    color: WDDLDesignSystem.secondary, // Sage green #7A9D8E border
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),

                todayDecoration: BoxDecoration(
                  color: WDDLDesignSystem.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),

                markerDecoration: BoxDecoration(
                  color: WDDLDesignSystem.success,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                markerSize: 6.0,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: WDDLDesignSystem.h2,
                leftChevronIcon: CustomIconWidget(
                  iconName: 'chevron_left',
                  color: WDDLDesignSystem.primary,
                  size: 24,
                ),
                rightChevronIcon: CustomIconWidget(
                  iconName: 'chevron_right',
                  color: WDDLDesignSystem.primary,
                  size: 24,
                ),
              ),
            ),
          ),

          // Increase bottom padding under calendar to 48px for breathing room
          SizedBox(height: 48),

          // Add 24px gap between calendar grid and progress halo
          SizedBox(height: 24),

          // Progress halo animation
          ProgressHaloWidget(streakCount: streak),

          // Add 16px gap between halo and rotating quote
          SizedBox(height: 16),

          // Rotating quote component
          RotatingQuoteWidget(),

          // Add 32px margin before any following section (list of wins)
          SizedBox(height: 32),

          // Selected day wins with animation
          if (_selectedDayWins.isNotEmpty) ...[
            // Use Column instead of Expanded to allow scrolling
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.translate(
                    offset: _slideAnimation.value,
                    child: Column(
                      children: [
                        for (int index = 0;
                            index < _selectedDayWins.length;
                            index++)
                          Container(
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.all(16),
                            decoration: WDDLDesignSystem.cardDecoration,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedDayWins[index]['title'] as String? ??
                                      '',
                                  style: WDDLDesignSystem.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if ((_selectedDayWins[index]['reflection']
                                            as String? ??
                                        '')
                                    .isNotEmpty) ...[
                                  SizedBox(height: 8),
                                  Text(
                                    _selectedDayWins[index]['reflection']
                                        as String,
                                    style: WDDLDesignSystem.body.copyWith(
                                      color: WDDLDesignSystem.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ] else if (_selectedDay != null) ...[
            // Empty state card when no win logged for selected date
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.translate(
                    offset: _slideAnimation.value,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: WDDLDesignSystem.cardDecoration.copyWith(
                        color: WDDLDesignSystem.surface,
                        border: Border.all(
                          color: WDDLDesignSystem.textSecondary.withValues(
                            alpha: 0.1,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              'No win logged today 🌿',
                              style: WDDLDesignSystem.body.copyWith(
                                fontWeight: FontWeight.w500,
                                color: WDDLDesignSystem.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Your reflection journey starts here.',
                              style: WDDLDesignSystem.body.copyWith(
                                color: WDDLDesignSystem.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],

          // Add bottom padding to ensure content doesn't get cut off
          SizedBox(height: 100),
        ],
      ),
    );
  }

  String _getMonthYearString(DateTime date) {
    const months = [
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
    return '${months[date.month - 1]} ${date.year}';
  }
}
