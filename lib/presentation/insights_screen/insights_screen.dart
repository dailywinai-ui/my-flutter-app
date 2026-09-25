import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../services/wins_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import 'package:win_daily/theme/wddl_design_system.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<dynamic> _wins = [];

  // Computed insights
  int _totalWins = 0;
  int _monthCount = 0;
  int _consecutiveStreak = 0;
  int _longestStreak = 0;
  int _reflectionCount = 0;
  String _bestDayOfWeek = '';
  List<int> _winsByDayLast7 = List.filled(7, 0);
  List<double?> _moodLast30 = List.filled(30, null);
  double _averageMood = 0;
  double _moodTrend = 0; // positive = trending up, negative = down
  List<String> _realReflections = [];
  String _longestGapMessage = '';
  int _currentBottomNavIndex = 2;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _loadInsights();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadInsights() async {
    setState(() => _isLoading = true);
    try {
      final wins = await WinsService.instance.getDailyWins(limit: 1000);
      setState(() {
        _wins = wins;
        _totalWins = wins.length;
        if (_totalWins >= 3) _calculate(wins);
        _isLoading = false;
      });
      _fadeController.forward();
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _calculate(List<dynamic> wins) {
    final now = DateTime.now();

    // ── Month count ────────────────────────────────────────
    _monthCount = wins.where((w) {
      final d = DateTime.parse(w.winDate.toString());
      return d.year == now.year && d.month == now.month;
    }).length;

    // ── Wins by day last 7 (Mon-based) ────────────────────
    final monday = now.subtract(Duration(days: now.weekday - 1));
    _winsByDayLast7 = List.filled(7, 0);
    for (final w in wins) {
      final d = DateTime.parse(w.winDate.toString());
      for (int i = 0; i < 7; i++) {
        final day = monday.add(Duration(days: i));
        if (_same(d, day)) { _winsByDayLast7[i]++; break; }
      }
    }

    // ── Consecutive streak (from today back) ──────────────
    _consecutiveStreak = 0;
    DateTime check = now;
    if (!wins.any((w) => _same(DateTime.parse(w.winDate.toString()), check))) {
      check = check.subtract(const Duration(days: 1));
    }
    while (wins.any((w) => _same(DateTime.parse(w.winDate.toString()), check))) {
      _consecutiveStreak++;
      check = check.subtract(const Duration(days: 1));
    }

    // ── Longest streak ever ────────────────────────────────
    final sortedDates = wins
        .map((w) => DateTime.parse(w.winDate.toString()))
        .toSet()
        .toList()
      ..sort();
    int best = 0, current = 0;
    DateTime? prev;
    for (final d in sortedDates) {
      if (prev != null && d.difference(prev).inDays == 1) {
        current++;
      } else {
        current = 1;
      }
      if (current > best) best = current;
      prev = d;
    }
    _longestStreak = best;

    // ── Best day of week ───────────────────────────────────
    final dayCounts = List.filled(7, 0); // Mon=0 … Sun=6
    for (final w in wins) {
      final d = DateTime.parse(w.winDate.toString());
      dayCounts[d.weekday - 1]++;
    }
    final maxDay = dayCounts.indexOf(dayCounts.reduce((a, b) => a > b ? a : b));
    const dayNames = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    _bestDayOfWeek = dayNames[maxDay];

    // ── Mood last 30 days ──────────────────────────────────
    _moodLast30 = List.filled(30, null);
    for (final w in wins) {
      if (w.moodRating == null) continue;
      final d = DateTime.parse(w.winDate.toString());
      for (int i = 0; i < 30; i++) {
        final day = now.subtract(Duration(days: 29 - i));
        if (_same(d, day)) { _moodLast30[i] = (w.moodRating as int).toDouble(); break; }
      }
    }
    final validMoods = _moodLast30.where((m) => m != null).cast<double>().toList();
    _averageMood = validMoods.isEmpty
        ? 0
        : validMoods.reduce((a, b) => a + b) / validMoods.length;

    // Mood trend: compare first half vs second half of last 30 days
    if (validMoods.length >= 4) {
      final firstHalf = _moodLast30.sublist(0, 15).where((m) => m != null).cast<double>().toList();
      final secondHalf = _moodLast30.sublist(15).where((m) => m != null).cast<double>().toList();
      if (firstHalf.isNotEmpty && secondHalf.isNotEmpty) {
        final avgFirst = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
        final avgSecond = secondHalf.reduce((a, b) => a + b) / secondHalf.length;
        _moodTrend = avgSecond - avgFirst;
      }
    }

    // ── Reflection rate ────────────────────────────────────
    _reflectionCount = wins.where((w) =>
        w.reflection != null && (w.reflection as String).trim().isNotEmpty).length;

    // ── Real reflection sentences ──────────────────────────
    _realReflections = wins
        .where((w) => w.reflection != null && (w.reflection as String).trim().isNotEmpty)
        .take(3)
        .map((w) {
          final r = (w.reflection as String).trim();
          final first = r.split(RegExp(r'[.\n]')).first.trim();
          return first.length > 140 ? '${first.substring(0, 140)}…' : first;
        })
        .toList();

    // ── Longest gap ────────────────────────────────────────
    if (sortedDates.length >= 2) {
      int maxGap = 0;
      for (int i = 1; i < sortedDates.length; i++) {
        final gap = sortedDates[i].difference(sortedDates[i - 1]).inDays;
        if (gap > maxGap) maxGap = gap;
      }
      final longestBreak = maxGap - 1;
      if (longestBreak >= 1) {
        _longestGapMessage = '$longestBreak day${longestBreak == 1 ? '' : 's'}';
      }
    }
  }

  bool _same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _moodLabel(double avg) {
    if (avg >= 4.5) return 'excellent';
    if (avg >= 3.5) return 'good';
    if (avg >= 2.5) return 'neutral';
    return 'low';
  }

  String _moodEmoji(double avg) {
    if (avg >= 4.5) return '🤩';
    if (avg >= 3.5) return '😊';
    if (avg >= 2.5) return '🙂';
    return '😔';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WDDLDesignSystem.cream,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: WDDLDesignSystem.ink, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Insights',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: WDDLDesignSystem.ink,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: WDDLDesignSystem.sage,
                        strokeWidth: 1.5,
                      ),
                    )
                  : _totalWins < 3
                      ? _buildEmptyState()
                      : FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildContent(),
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() => _currentBottomNavIndex = index);
          if (index == 0) Navigator.pushReplacementNamed(context, '/today-screen');
          if (index == 1) Navigator.pushReplacementNamed(context, '/history-screen');
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: const BoxDecoration(
              color: WDDLDesignSystem.sageBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bar_chart_rounded,
                color: WDDLDesignSystem.sage, size: 40),
          ),
          const SizedBox(height: 28),
          Text(
            'Log a few wins to see insights bloom.',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 24, fontWeight: FontWeight.w600,
              color: WDDLDesignSystem.ink, height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            _totalWins > 0
                ? 'You have $_totalWins ${_totalWins == 1 ? 'win' : 'wins'} so far. Insights unlock at 3.'
                : 'Log at least 3 wins to unlock your insights.',
            style: WDDLDesignSystem.body.copyWith(color: WDDLDesignSystem.inkMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── At-a-glance stat row ──────────────────────────
          _staggered(0, _buildStatRow()),
          const SizedBox(height: 20),

          // ── This week bar chart ───────────────────────────
          _staggered(1, _buildWeekCard()),
          const SizedBox(height: 20),

          // ── Mood trend ────────────────────────────────────
          if (_averageMood > 0) ...[
            _staggered(2, _buildMoodCard()),
            const SizedBox(height: 20),
          ],

          // ── Pattern insights ──────────────────────────────
          _staggered(3, _buildPatternCard()),
          const SizedBox(height: 20),

          // ── Real reflections ──────────────────────────────
          if (_realReflections.isNotEmpty) ...[
            _staggered(4, _buildReflectionsCard()),
            const SizedBox(height: 20),
          ],

          // ── Progress halo ─────────────────────────────────
          if (_consecutiveStreak > 0)
            _staggered(5, _buildStreakHalo()),
        ],
      ),
    );
  }

  // ── Stat row: 3 numbers at a glance ───────────────────────
  Widget _buildStatRow() {
    return Row(
      children: [
        _buildStat('$_monthCount', 'this month'),
        _buildStatDivider(),
        _buildStat('$_consecutiveStreak', 'day streak'),
        _buildStatDivider(),
        _buildStat(
          _reflectionCount > 0
              ? '${((_reflectionCount / _totalWins) * 100).round()}%'
              : '0%',
          'reflected',
        ),
      ],
    );
  }

  Widget _buildStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 32, fontWeight: FontWeight.w600,
              color: WDDLDesignSystem.ink, height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: WDDLDesignSystem.caption.copyWith(
              color: WDDLDesignSystem.inkMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1, height: 40,
      color: WDDLDesignSystem.beigeDark,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  // ── This week ──────────────────────────────────────────────
  Widget _buildWeekCard() {
    final daysWithWins = _winsByDayLast7.where((c) => c > 0).length;
    const abbr = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow('THIS WEEK'),
          const SizedBox(height: 4),
          Text(
            '$daysWithWins of 7 days',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 20, fontWeight: FontWeight.w600,
              color: WDDLDesignSystem.ink,
            ),
          ),
          const SizedBox(height: 16),
          // Day dots — simpler than bar chart, more honest at low counts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final day = monday.add(Duration(days: i));
              final isToday = _same(day, now);
              final hasWin = _winsByDayLast7[i] > 0;
              final isFuture = day.isAfter(now);

              return Column(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300 + i * 40),
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasWin
                          ? WDDLDesignSystem.sage
                          : isFuture
                              ? Colors.transparent
                              : WDDLDesignSystem.beigeDark,
                      border: isToday
                          ? Border.all(color: WDDLDesignSystem.sage, width: 2)
                          : null,
                    ),
                    child: hasWin
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    abbr[i],
                    style: WDDLDesignSystem.caption.copyWith(
                      color: isToday
                          ? WDDLDesignSystem.sage
                          : WDDLDesignSystem.inkMuted.withValues(alpha: 0.6),
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Mood card ──────────────────────────────────────────────
  Widget _buildMoodCard() {
    final trendText = _moodTrend > 0.2
        ? 'trending up lately'
        : _moodTrend < -0.2
            ? 'trending down lately'
            : 'holding steady';

    final spots = <FlSpot>[];
    for (int i = 0; i < 30; i++) {
      if (_moodLast30[i] != null) {
        spots.add(FlSpot(i.toDouble(), _moodLast30[i]!));
      }
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow('MOOD · LAST 30 DAYS'),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _moodEmoji(_averageMood),
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(width: 8),
              Text(
                _moodLabel(_averageMood),
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 20, fontWeight: FontWeight.w600,
                  color: WDDLDesignSystem.ink,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '· $trendText',
                style: WDDLDesignSystem.caption.copyWith(
                  color: WDDLDesignSystem.inkMuted,
                ),
              ),
            ],
          ),
          if (spots.length >= 3) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 56,
              child: LineChart(
                LineChartData(
                  minY: 1, maxY: 5,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  lineTouchData: const LineTouchData(enabled: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      color: WDDLDesignSystem.sage,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: WDDLDesignSystem.sage.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Pattern card ───────────────────────────────────────────
  Widget _buildPatternCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow('YOUR PATTERNS'),
          const SizedBox(height: 12),

          // Best day
          if (_bestDayOfWeek.isNotEmpty)
            _patternRow(
              Icons.calendar_today_rounded,
              'You show up most on $_bestDayOfWeek.',
            ),

          // Longest streak
          if (_longestStreak > 1) ...[
            const SizedBox(height: 10),
            _patternRow(
              Icons.local_fire_department_rounded,
              'Your longest streak is $_longestStreak days.',
            ),
          ],

          // Longest gap
          if (_longestGapMessage.isNotEmpty) ...[
            const SizedBox(height: 10),
            _patternRow(
              Icons.pause_circle_outline_rounded,
              'Your longest break was $_longestGapMessage.',
            ),
          ],

          // Reflection rate
          if (_reflectionCount > 0) ...[
            const SizedBox(height: 10),
            _patternRow(
              Icons.edit_note_rounded,
              '$_reflectionCount of $_totalWins wins include a reflection.',
            ),
          ],
        ],
      ),
    );
  }

  Widget _patternRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: WDDLDesignSystem.sage),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: WDDLDesignSystem.body.copyWith(color: WDDLDesignSystem.ink),
          ),
        ),
      ],
    );
  }

  // ── Reflections card ───────────────────────────────────────
  Widget _buildReflectionsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow('IN YOUR OWN WORDS'),
          const SizedBox(height: 12),
          ..._realReflections.map((sentence) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: WDDLDesignSystem.sageBg.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(color: WDDLDesignSystem.sage, width: 2),
                ),
              ),
              child: Text(
                '"$sentence"',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: WDDLDesignSystem.ink,
                  height: 1.5,
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  // ── Streak halo ────────────────────────────────────────────
  Widget _buildStreakHalo() {
    final progress = (_consecutiveStreak / 30).clamp(0.0, 1.0);
    return Column(
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: WDDLDesignSystem.beigeDark,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            widthFactor: progress,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    WDDLDesignSystem.sage.withValues(alpha: 0.6),
                    WDDLDesignSystem.sage,
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$_consecutiveStreak day${_consecutiveStreak == 1 ? '' : 's'} in a row',
          style: WDDLDesignSystem.caption.copyWith(
            color: WDDLDesignSystem.inkMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Shared components ──────────────────────────────────────
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WDDLDesignSystem.beigeDark, width: 1),
        boxShadow: [
          BoxShadow(
            color: WDDLDesignSystem.ink.withValues(alpha: 0.04),
            blurRadius: 12, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _eyebrow(String text) {
    return Text(
      text,
      style: WDDLDesignSystem.eyebrow.copyWith(color: WDDLDesignSystem.sage),
    );
  }

  Widget _staggered(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + index * 80),
      curve: Curves.easeOut,
      builder: (_, value, child) => Transform.translate(
        offset: Offset(0, 12 * (1 - value)),
        child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
      ),
      child: child,
    );
  }
}