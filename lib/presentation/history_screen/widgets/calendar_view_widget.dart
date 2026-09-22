import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/app_export.dart';
import 'package:win_daily/theme/wddl_design_system.dart';

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
    with SingleTickerProviderStateMixin {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _selectedDayWins = [];
  bool _hasInteracted = false;

  late AnimationController _cardController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = widget.selectedDay ?? DateTime.now();
    _updateSelectedDayWins();

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _cardController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));

    _cardController.forward();
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  void _updateSelectedDayWins() {
    if (_selectedDay == null) { _selectedDayWins = []; return; }
    _selectedDayWins = widget.wins.where((win) {
      final winDate = DateTime.parse(win['date'] as String);
      return isSameDay(winDate, _selectedDay!);
    }).toList();
  }

  List<Map<String, dynamic>> _getWinsForDay(DateTime day) {
    return widget.wins.where((win) {
      final winDate = DateTime.parse(win['date'] as String);
      return isSameDay(winDate, day);
    }).toList();
  }

  int _calculateConsecutiveStreak() {
    int streak = 0;
    DateTime check = DateTime.now();
    while (true) {
      if (_getWinsForDay(check).isNotEmpty) {
        streak++;
        check = check.subtract(const Duration(days: 1));
      } else break;
    }
    return streak;
  }

  int _countThisMonth() {
    final now = DateTime.now();
    return widget.wins.where((win) {
      final d = DateTime.parse(win['date'] as String);
      return d.year == now.year && d.month == now.month;
    }).length;
  }

  String _formatSelectedDate(DateTime day) {
    const months = ['January','February','March','April','May','June',
      'July','August','September','October','November','December'];
    const weekdays = ['','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    final isToday = isSameDay(day, DateTime.now());
    if (isToday) return 'Today · ${months[day.month - 1]} ${day.day}';
    return '${weekdays[day.weekday]} · ${months[day.month - 1]} ${day.day}';
  }

  String _getMonthYearString(DateTime date) {
    const months = ['January','February','March','April','May','June',
      'July','August','September','October','November','December'];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.wins.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: WDDLDesignSystem.sageBg, shape: BoxShape.circle),
                child: Icon(Icons.calendar_month_rounded, size: 36, color: WDDLDesignSystem.sage),
              ),
              const SizedBox(height: 20),
              Text('Your calendar will fill as you log wins.',
                  style: WDDLDesignSystem.h2, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Start today.',
                  style: WDDLDesignSystem.body.copyWith(color: WDDLDesignSystem.inkMuted),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    final monthCount = _countThisMonth();
    final streak = _calculateConsecutiveStreak();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Month header + streak pill ─────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getMonthYearString(_focusedDay),
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22, fontWeight: FontWeight.w600,
                      color: WDDLDesignSystem.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$monthCount ${monthCount == 1 ? 'win' : 'wins'} this month',
                    style: WDDLDesignSystem.caption.copyWith(
                      color: WDDLDesignSystem.inkMuted, letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: WDDLDesignSystem.sageBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department_rounded,
                          size: 13, color: WDDLDesignSystem.sage),
                      const SizedBox(width: 4),
                      Text(
                        '$streak day${streak == 1 ? '' : 's'}',
                        style: WDDLDesignSystem.caption.copyWith(
                          color: WDDLDesignSystem.sage, fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Calendar ───────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: WDDLDesignSystem.beigeDark, width: 1),
              boxShadow: [
                BoxShadow(
                  color: WDDLDesignSystem.ink.withValues(alpha: 0.04),
                  blurRadius: 16, offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            child: TableCalendar<Map<String, dynamic>>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              eventLoader: _getWinsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) async {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _hasInteracted = true;
                });
                _updateSelectedDayWins();
                widget.onDaySelected(selectedDay);
                _cardController.reset();
                await _cardController.forward();
              },
              onPageChanged: (focusedDay) {
                setState(() => _focusedDay = focusedDay);
              },
              calendarBuilders: CalendarBuilders(
                // Default day — bold if has win
                defaultBuilder: (context, day, focusedDay) {
                  final hasWin = _getWinsForDay(day).isNotEmpty;
                  return Center(
                    child: Text('${day.day}',
                      style: WDDLDesignSystem.body.copyWith(
                        color: hasWin ? WDDLDesignSystem.ink : WDDLDesignSystem.inkMuted,
                        fontWeight: hasWin ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  );
                },
                // Today — sage outline ring
                todayBuilder: (context, day, focusedDay) {
                  final hasWin = _getWinsForDay(day).isNotEmpty;
                  return Center(
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: WDDLDesignSystem.sage, width: 1.5),
                      ),
                      child: Center(
                        child: Text('${day.day}',
                          style: WDDLDesignSystem.body.copyWith(
                            color: WDDLDesignSystem.sage,
                            fontWeight: hasWin ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                // Selected — filled sage, white number
                selectedBuilder: (context, day, focusedDay) {
                  return Center(
                    child: Container(
                      width: 36, height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7D9180),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('${day.day}',
                          style: WDDLDesignSystem.body.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                // Win dot — white when selected (visible on sage), sage otherwise
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return const SizedBox.shrink();
                  final isSelected = isSameDay(day, _selectedDay);
                  return Positioned(
                    bottom: 6,
                    child: Container(
                      width: 4, height: 4,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.8)
                            : WDDLDesignSystem.sage,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
                markersMaxCount: 1,
                markerSize: 4,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: WDDLDesignSystem.caption.copyWith(
                  color: WDDLDesignSystem.inkMuted, fontWeight: FontWeight.w500,
                ),
                headerPadding: const EdgeInsets.only(bottom: 8),
                leftChevronIcon: Icon(Icons.chevron_left_rounded,
                    color: WDDLDesignSystem.sage, size: 20),
                rightChevronIcon: Icon(Icons.chevron_right_rounded,
                    color: WDDLDesignSystem.sage, size: 20),
                leftChevronPadding: const EdgeInsets.all(4),
                rightChevronPadding: const EdgeInsets.all(4),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: WDDLDesignSystem.eyebrow.copyWith(
                  color: WDDLDesignSystem.inkMuted.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
                weekendStyle: WDDLDesignSystem.eyebrow.copyWith(
                  color: WDDLDesignSystem.inkMuted.withValues(alpha: 0.4),
                  fontSize: 10,
                ),
              ),
            ),
          ),

          // ── Hint — fades out after first tap ──────────────
          AnimatedOpacity(
            opacity: _hasInteracted ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 400),
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app_rounded, size: 11,
                      color: WDDLDesignSystem.inkMuted.withValues(alpha: 0.4)),
                  const SizedBox(width: 4),
                  Text('Tap any day to revisit it.',
                    style: WDDLDesignSystem.caption.copyWith(
                      color: WDDLDesignSystem.inkMuted.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Win card — immediately below calendar ──────────
          if (_selectedDay != null)
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _selectedDayWins.isNotEmpty
                    ? _buildWinCard(_selectedDayWins.first)
                    : _hasInteracted
                        ? _buildEmptyDayCard()
                        : const SizedBox.shrink(),
              ),
            ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildWinCard(Map<String, dynamic> win) {
    final title = (win['title'] as String?) ?? '';
    final reflection = (win['reflection'] as String?) ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Sage left border = visual anchor to selected calendar day
        border: Border(
          left: BorderSide(color: WDDLDesignSystem.sage, width: 3),
          top: BorderSide(color: WDDLDesignSystem.beigeDark, width: 1),
          right: BorderSide(color: WDDLDesignSystem.beigeDark, width: 1),
          bottom: BorderSide(color: WDDLDesignSystem.beigeDark, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: WDDLDesignSystem.ink.withValues(alpha: 0.04),
            blurRadius: 12, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatSelectedDate(_selectedDay!).toUpperCase(),
            style: WDDLDesignSystem.eyebrow.copyWith(color: WDDLDesignSystem.sage),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 20, fontWeight: FontWeight.w600,
              color: WDDLDesignSystem.ink, height: 1.35,
            ),
          ),
          if (reflection.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              reflection,
              style: WDDLDesignSystem.body.copyWith(
                color: WDDLDesignSystem.inkMuted, fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyDayCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: WDDLDesignSystem.beigeDark, width: 3),
          top: BorderSide(color: WDDLDesignSystem.beigeDark, width: 1),
          right: BorderSide(color: WDDLDesignSystem.beigeDark, width: 1),
          bottom: BorderSide(color: WDDLDesignSystem.beigeDark, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatSelectedDate(_selectedDay!).toUpperCase(),
            style: WDDLDesignSystem.eyebrow.copyWith(color: WDDLDesignSystem.inkMuted),
          ),
          const SizedBox(height: 8),
          Text('Nothing logged this day.',
            style: WDDLDesignSystem.body.copyWith(color: WDDLDesignSystem.inkMuted),
          ),
        ],
      ),
    );
  }
}