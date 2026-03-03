import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    _setupAnimations();
    _loadInsights();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: WDDLDesignSystem.fadeInDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: WDDLDesignSystem.fadeInCurve,
      ),
    );
  }

  Future<void> _loadInsights() async {
    setState(() => _isLoading = true);

    try {
      final dailyWins = await WinsService.instance.getDailyWins(limit: 1000);

      setState(() {
        _totalWins = dailyWins.length;
        _hasEnoughWins = _totalWins >= 3;

        if (_hasEnoughWins) {
          _calculateInsightData(dailyWins);
        }

        _isLoading = false;
      });

      _fadeController.forward();
    } catch (error) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load insights: $error'),
            backgroundColor: WDDLDesignSystem.error,
          ),
        );
      }
    }
  }

  void _calculateInsightData(List<dynamic> wins) {
    final now = DateTime.now();

    _winsByDayLast7 = List.filled(7, 0);
    final last7Days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    _winsByDay = List.filled(14, 0);
    final last14Days = List.generate(14, (i) => now.subtract(Duration(days: 13 - i)));

    _moodScoresLast30 = List.filled(30, null);
    final last30Days = List.generate(30, (i) => now.subtract(Duration(days: 29 - i)));

    for (final win in wins) {
      final winDate = DateTime.parse(win.winDate.toString());

      for (int i = 0; i < 7; i++) {
        if (_isSameDay(winDate, last7Days[i])) {
          _winsByDayLast7[i]++;
          break;
        }
      }

      for (int i = 0; i < 14; i++) {
        if (_isSameDay(winDate, last14Days[i])) {
          _winsByDay[i] = 1;
          break;
        }
      }

      for (int i = 0; i < 30; i++) {
        if (_isSameDay(winDate, last30Days[i])) {
          _moodScoresLast30[i] = (win.moodRating ?? 3).toDouble();
          break;
        }
      }
    }

    _totalReflections = _calculateTotalReflections(wins);

    final daysWithWins = _winsByDayLast7.where((count) => count > 0).length;
    _completionRate = ((daysWithWins / 7) * 100).round();

    final validMoods =
        _moodScoresLast30.where((mood) => mood != null).cast<double>();
    _averageMood = validMoods.isEmpty
        ? 3.0
        : validMoods.reduce((a, b) => a + b) / validMoods.length;

    _tagCounts = [
      {"tag": "#focus", "count": (wins.length * 0.4).round()},
      {"tag": "#health", "count": (wins.length * 0.3).round()},
      {"tag": "#learning", "count": (wins.length * 0.2).round()},
      {"tag": "#gratitude", "count": (wins.length * 0.1).round()},
    ];

    _topReflectionSentences = wins
        .where((win) =>
            win.reflection != null && (win.reflection as String).isNotEmpty)
        .take(3)
        .map((win) {
          String reflection = win.reflection as String;
          return reflection.length > 120
              ? '${reflection.substring(0, 120)}...'
              : reflection;
        })
        .toList();

    _top3Keywords = ["focus", "gratitude", "energy"];
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  int _calculateTotalReflections(List<dynamic> wins) {
    if (wins.isEmpty) return 0;

    final sortedWins = List.from(wins);
    sortedWins.sort((a, b) => DateTime.parse(b.winDate.toString())
        .compareTo(DateTime.parse(a.winDate.toString())));

    int total = 0;
    DateTime currentDate = DateTime.now();

    for (final win in sortedWins) {
      final winDate = DateTime.parse(win.winDate.toString());
      final checkDate =
          DateTime(currentDate.year, currentDate.month, currentDate.day);
      final winDateNormalized =
          DateTime(winDate.year, winDate.month, winDate.day);

      if (winDateNormalized.isAtSameMomentAs(checkDate)) {
        total++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return total;
  }

  void _onWinsThisWeekTap() {
    Navigator.pushNamed(context, '/history-screen',
        arguments: {'filter': 'This Week'});
  }

  void _onTagTap(String tag) {
    Navigator.pushNamed(context, '/history-screen',
        arguments: {'filter': tag});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WDDLDesignSystem.background,
      appBar: AppBar(
        backgroundColor: WDDLDesignSystem.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: WDDLDesignSystem.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _isLoading
              ? _buildLoadingState()
              : !_hasEnoughWins
                  ? _buildEmptyState()
                  : _buildInsightsContent(),
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
            'Analyzing your progress...',
            style: WDDLDesignSystem.body
                .copyWith(color: WDDLDesignSystem.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final String bodyText = _totalWins > 0
        ? 'You have $_totalWins win${_totalWins == 1 ? '' : 's'} so far. Keep showing up daily — insights unlock at 3.'
        : 'You need at least 3 wins to unlock your insights dashboard.';

    return Padding(
      padding: WDDLDesignSystem.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: WDDLDesignSystem.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
                child: Text('🌿', style: TextStyle(fontSize: 48))),
          ),
          const SizedBox(height: 32),
          Text(
            'Log a few wins to see insights bloom 🌿',
            style: WDDLDesignSystem.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            bodyText,
            style: WDDLDesignSystem.body
                .copyWith(color: WDDLDesignSystem.textSecondary),
            textAlign: TextAlign.center,
          ),
          // FIX: No button here — one win per day is the rule.
          // User logs from the Today screen only.
        ],
      ),
    );
  }

  Widget _buildInsightsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Insights', style: WDDLDesignSystem.h1),
          const SizedBox(height: 8),
          Text(
            'See your progress at a glance.',
            style: WDDLDesignSystem.body
                .copyWith(color: WDDLDesignSystem.textSecondary),
          ),
          const SizedBox(height: 32),
          _buildCardWithAnimation(
            delay: 0,
            child: ReflectionCountWidget(
              totalReflections: _totalReflections,
              winsByDay: _winsByDay,
            ),
          ),
          const SizedBox(height: 24),
          _buildCardWithAnimation(
            delay: 100,
            child: WinsThisWeekWidget(
              winsByDayLast7: _winsByDayLast7,
              completionRate: _completionRate,
              onTap: _onWinsThisWeekTap,
            ),
          ),
          const SizedBox(height: 24),
          _buildCardWithAnimation(
            delay: 200,
            child: MoodTrendWidget(
              moodScoresLast30: _moodScoresLast30,
              averageMood: _averageMood,
            ),
          ),
          const SizedBox(height: 24),
          _buildCardWithAnimation(
            delay: 300,
            child:
                CategoriesWidget(tagCounts: _tagCounts, onTagTap: _onTagTap),
          ),
          const SizedBox(height: 24),
          _buildCardWithAnimation(
            delay: 400,
            child: ReflectionHighlightsWidget(
              topReflectionSentences: _topReflectionSentences,
              top3Keywords: _top3Keywords,
            ),
          ),
          const SizedBox(height: 32),
          const RotatingNudgeWidget(),
        ],
      ),
    );
  }

  Widget _buildCardWithAnimation({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}
