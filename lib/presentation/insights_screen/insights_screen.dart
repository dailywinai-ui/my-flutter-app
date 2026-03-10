import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/wins_service.dart';
import 'package:win_daily/theme/wddl_design_system.dart';
import './widgets/reflection_count_widget.dart';
import './widgets/wins_this_week_widget.dart';
import './widgets/mood_trend_widget.dart';
import './widgets/categories_widget.dart';
import './widgets/reflection_highlights_widget.dart';
import './widgets/rotating_nudge_widget.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  int _totalWins = 0;
  bool _hasEnoughWins = false;

  List<int> _winsByDayLast7 = [];
  List<int> _winsByDay = [];
  List<double?> _moodScoresLast30 = [];
  List<Map<String, dynamic>> _tagCounts = [];
  List<String> _topReflectionSentences = [];
  List<String> _top3Keywords = [];
  int _totalReflections = 0;
  int _completionRate = 0;
  double _averageMood = 0.0;

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
        _totalWins = wins.length;
        _hasEnoughWins = _totalWins >= 3;
        if (_hasEnoughWins) _calculateInsightData(wins);
        _isLoading = false;
      });
      _fadeController.forward();
    } catch (error) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load insights',
                style: WDDLDesignSystem.body.copyWith(color: Colors.white)),
            backgroundColor: WDDLDesignSystem.ink,
          ),
        );
      }
    }
  }

  void _calculateInsightData(List<dynamic> wins) {
    final now = DateTime.now();

    _winsByDayLast7 = List.filled(7, 0);
    final monday    = now.subtract(Duration(days: now.weekday - 1));
    final last7Days = List.generate(7, (i) => monday.add(Duration(days: i)));

    _winsByDay = List.filled(14, 0);
    final last14Days = List.generate(14, (i) => now.subtract(Duration(days: 13 - i)));

    _moodScoresLast30 = List.filled(30, null);
    final last30Days = List.generate(30, (i) => now.subtract(Duration(days: 29 - i)));

    for (final win in wins) {
      final winDate = DateTime.parse(win.winDate.toString());
      for (int i = 0; i < 7; i++) {
        if (_isSameDay(winDate, last7Days[i])) { _winsByDayLast7[i]++; break; }
      }
      for (int i = 0; i < 14; i++) {
        if (_isSameDay(winDate, last14Days[i])) { _winsByDay[i] = 1; break; }
      }
      for (int i = 0; i < 30; i++) {
        if (_isSameDay(winDate, last30Days[i])) {
          _moodScoresLast30[i] = (win.moodRating ?? 3).toDouble();
          break;
        }
      }
    }

    _totalReflections = wins.where((w) {
      final d = DateTime.parse(w.winDate.toString());
      return d.year == now.year && d.month == now.month;
    }).length;

    final daysWithWins = _winsByDayLast7.where((c) => c > 0).length;
    _completionRate = ((daysWithWins / 7) * 100).round();

    final validMoods = _moodScoresLast30.where((m) => m != null).cast<double>();
    _averageMood = validMoods.isEmpty
        ? 3.0
        : validMoods.reduce((a, b) => a + b) / validMoods.length;

    _tagCounts = [
      {"tag": "#focus",     "count": (wins.length * 0.4).round()},
      {"tag": "#health",    "count": (wins.length * 0.3).round()},
      {"tag": "#learning",  "count": (wins.length * 0.2).round()},
      {"tag": "#gratitude", "count": (wins.length * 0.1).round()},
    ];

    _topReflectionSentences = wins
        .where((w) => w.reflection != null && (w.reflection as String).isNotEmpty)
        .take(3)
        .map((w) {
          final r = w.reflection as String;
          return r.length > 120 ? '${r.substring(0, 120)}...' : r;
        })
        .toList();

    _top3Keywords = ["focus", "gratitude", "energy"];
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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
                    const SizedBox(width: 40), // balance back button
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
                    : !_hasEnoughWins
                        ? _buildEmptyState()
                        : _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final bodyText = _totalWins > 0
        ? 'You have $_totalWins win${_totalWins == 1 ? '' : 's'} so far. Keep going — insights unlock at 3.'
        : 'Log at least 3 wins to unlock your insights.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
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
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: WDDLDesignSystem.ink,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            bodyText,
            style: WDDLDesignSystem.body.copyWith(color: WDDLDesignSystem.inkMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'See your progress at a glance.',
            style: WDDLDesignSystem.body.copyWith(color: WDDLDesignSystem.inkMuted),
          ),

          const SizedBox(height: 28),

          _animated(delay: 0,   child: ReflectionCountWidget(totalReflections: _totalReflections, winsByDay: _winsByDay)),
          const SizedBox(height: 20),
          _animated(delay: 100, child: WinsThisWeekWidget(winsByDayLast7: _winsByDayLast7, completionRate: _completionRate, onTap: () => Navigator.pushNamed(context, '/history-screen'))),
          const SizedBox(height: 20),
          _animated(delay: 200, child: MoodTrendWidget(moodScoresLast30: _moodScoresLast30, averageMood: _averageMood)),
          const SizedBox(height: 20),
          _animated(delay: 300, child: CategoriesWidget(tagCounts: _tagCounts, onTagTap: (tag) => Navigator.pushNamed(context, '/history-screen', arguments: {'filter': tag}))),
          const SizedBox(height: 20),
          _animated(delay: 400, child: ReflectionHighlightsWidget(topReflectionSentences: _topReflectionSentences, top3Keywords: _top3Keywords)),
          const SizedBox(height: 28),
          const RotatingNudgeWidget(),
        ],
      ),
    );
  }

  Widget _animated({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOut,
      builder: (_, value, child) => Transform.translate(
        offset: Offset(0, 16 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      ),
      child: child,
    );
  }
}