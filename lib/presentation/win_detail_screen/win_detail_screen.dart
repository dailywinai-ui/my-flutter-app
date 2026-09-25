import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/wins_service.dart';
import 'package:win_daily/theme/wddl_design_system.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/win_card_generator.dart';
import './widgets/win_card_widget.dart';

class WinDetailScreen extends StatefulWidget {
  const WinDetailScreen({super.key});

  @override
  State<WinDetailScreen> createState() => _WinDetailScreenState();
}

class _WinDetailScreenState extends State<WinDetailScreen> {
  late Map<String, dynamic> currentWin;
  late List<Map<String, dynamic>> allWins;
  int currentIndex = 0;
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? _requestedWin;
  bool _argsRead = false;

  @override
  void initState() {
    super.initState();
    _loadUserWins();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsRead) return;
    _argsRead = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args['id'] != null) {
      _requestedWin = _normalizeWin(args);
    }
  }

  /// Callers pass win maps in different shapes (DateTime vs ISO string vs
  /// display string for the date). Normalize to the shape this screen uses.
  Map<String, dynamic> _normalizeWin(Map<String, dynamic> args) {
    final dateVal = args['date'];
    final tsVal = args['timestamp'];
    DateTime fallback = DateTime.now();
    if (tsVal is DateTime) fallback = tsVal;
    if (dateVal is DateTime) fallback = dateVal;
    final parsedIso = dateVal is String ? DateTime.tryParse(dateVal) : null;
    if (parsedIso != null) fallback = parsedIso;
    final displayDate = dateVal is DateTime
        ? _fmtDate(dateVal)
        : parsedIso != null
            ? _fmtDate(parsedIso)
            : (dateVal is String ? dateVal : _fmtDate(fallback));
    return {
      'id': args['id'],
      'date': displayDate,
      'title': args['title'] ?? '',
      'reflection': args['reflection'] ?? '',
      'mood': args['mood'] ?? 3,
      'timestamp': tsVal is DateTime ? tsVal : fallback,
      'type': args['type'] ?? 'daily_win',
    };
  }

  Future<void> _loadUserWins() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final wins      = await WinsService.instance.getWins(limit: 50);
      final dailyWins = await WinsService.instance.getDailyWins(limit: 50);

      final List<Map<String, dynamic>> formatted = [];
      for (final w in wins) {
        formatted.add({
          "id": w.id, "date": _fmtDate(w.winDate),
          "title": w.text, "reflection": w.reflection ?? "",
          "mood": w.mood ?? 3, "timestamp": w.winDate, "type": "win",
        });
      }
      for (final w in dailyWins) {
        formatted.add({
          "id": w.id, "date": _fmtDate(w.winDate),
          "title": w.description, "reflection": w.reflection ?? "",
          "mood": w.moodRating ?? 3, "timestamp": w.winDate, "type": "daily_win",
        });
      }
      formatted.sort((a, b) =>
          (b["timestamp"] as DateTime).compareTo(a["timestamp"] as DateTime));

      var startIndex = 0;
      final requested = _requestedWin;
      if (requested != null) {
        final idx =
            formatted.indexWhere((w) => w['id'] == requested['id']);
        if (idx != -1) {
          startIndex = idx;
        } else {
          formatted.insert(0, requested);
          startIndex = 0;
        }
      }
      setState(() {
        allWins = formatted;
        currentWin  = allWins.isNotEmpty ? allWins[startIndex] : {};
        currentIndex = startIndex;
        isLoading   = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
        allWins   = [];
        currentWin = {};
      });
    }
  }

  String _fmtDate(DateTime d) {
    const months = ["January","February","March","April","May","June",
        "July","August","September","October","November","December"];
    return "${months[d.month - 1]} ${d.day}, ${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WDDLDesignSystem.cream,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: WDDLDesignSystem.ink, size: 20),
                  ),
                  Expanded(
                    child: Text(
                      'Win Detail',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: WDDLDesignSystem.ink,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Edit button
                  IconButton(
                    onPressed: isLoading || currentWin.isEmpty ? null : _handleEdit,
                    icon: Icon(
                      Icons.edit_outlined,
                      color: isLoading || currentWin.isEmpty
                          ? WDDLDesignSystem.inkMuted.withValues(alpha: 0.3)
                          : WDDLDesignSystem.ink,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading)      return _buildLoading();
    if (errorMessage != null) return _buildError();
    if (allWins.isEmpty || currentWin.isEmpty) return _buildEmpty();
    return _buildContent();
  }

  Widget _buildLoading() => Center(
    child: CircularProgressIndicator(
      color: WDDLDesignSystem.sage,
      strokeWidth: 1.5,
    ),
  );

  Widget _buildError() => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline_rounded,
            color: WDDLDesignSystem.error, size: 48),
        const SizedBox(height: 20),
        Text('Unable to load wins',
            style: WDDLDesignSystem.h2, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('There was an issue loading your wins.',
            style: WDDLDesignSystem.body.copyWith(color: WDDLDesignSystem.inkMuted),
            textAlign: TextAlign.center),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: WDDLDesignSystem.secondaryButton,
                child: const Text('Go back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _loadUserWins,
                style: WDDLDesignSystem.primaryButton,
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildEmpty() => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72, height: 72,
          decoration: const BoxDecoration(
            color: WDDLDesignSystem.sageBg, shape: BoxShape.circle,
          ),
          child: const Icon(Icons.auto_awesome_outlined,
              color: WDDLDesignSystem.sage, size: 36),
        ),
        const SizedBox(height: 20),
        Text('No wins yet',
            style: WDDLDesignSystem.h2, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('Start logging daily wins to see them here.',
            style: WDDLDesignSystem.body.copyWith(color: WDDLDesignSystem.inkMuted),
            textAlign: TextAlign.center),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: WDDLDesignSystem.primaryButton,
          child: const Text('Go back'),
        ),
      ],
    ),
  );

  Widget _buildContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                WinCardWidget(winData: currentWin),
                if (allWins.length > 1) ...[
                  const SizedBox(height: 16),
                  _buildNavigationRow(),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ActionButtonsWidget(
            onCreateWinCard: _handleCreateWinCard,
            onEdit: _handleEdit,
            onDelete: _handleDelete,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNavigationRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WDDLDesignSystem.beigeDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous
          GestureDetector(
            onTap: currentIndex > 0 ? _navPrev : null,
            child: Row(
              children: [
                Icon(Icons.chevron_left_rounded,
                    color: currentIndex > 0
                        ? WDDLDesignSystem.ink
                        : WDDLDesignSystem.inkMuted.withValues(alpha: 0.3),
                    size: 20),
                Text('Previous',
                    style: WDDLDesignSystem.body.copyWith(
                      color: currentIndex > 0
                          ? WDDLDesignSystem.ink
                          : WDDLDesignSystem.inkMuted.withValues(alpha: 0.3),
                    )),
              ],
            ),
          ),

          Text(
            '${currentIndex + 1} of ${allWins.length}',
            style: WDDLDesignSystem.body.copyWith(color: WDDLDesignSystem.inkMuted),
          ),

          // Next
          GestureDetector(
            onTap: currentIndex < allWins.length - 1 ? _navNext : null,
            child: Row(
              children: [
                Text('Next',
                    style: WDDLDesignSystem.body.copyWith(
                      color: currentIndex < allWins.length - 1
                          ? WDDLDesignSystem.ink
                          : WDDLDesignSystem.inkMuted.withValues(alpha: 0.3),
                    )),
                Icon(Icons.chevron_right_rounded,
                    color: currentIndex < allWins.length - 1
                        ? WDDLDesignSystem.ink
                        : WDDLDesignSystem.inkMuted.withValues(alpha: 0.3),
                    size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navPrev() {
    if (currentIndex > 0) {
      HapticFeedback.lightImpact();
      setState(() { currentIndex--; currentWin = allWins[currentIndex]; });
    }
  }

  void _navNext() {
    if (currentIndex < allWins.length - 1) {
      HapticFeedback.lightImpact();
      setState(() { currentIndex++; currentWin = allWins[currentIndex]; });
    }
  }

  void _handleCreateWinCard() async {
    await WinCardGenerator.generateAndShareWinCard(context, currentWin);
  }

  void _handleEdit() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/add-win-modal', arguments: currentWin)
        .then((result) {
      if (result != null) {
        _loadUserWins();
      }
    });
  }

  void _handleDelete() async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: WDDLDesignSystem.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete win?',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22, fontWeight: FontWeight.w600, color: WDDLDesignSystem.ink,
            )),
        content: Text('This action cannot be undone.',
            style: WDDLDesignSystem.body.copyWith(color: WDDLDesignSystem.inkMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: WDDLDesignSystem.body.copyWith(color: WDDLDesignSystem.inkMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style: WDDLDesignSystem.body.copyWith(color: WDDLDesignSystem.error)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final id   = currentWin['id'] as String;
      final type = currentWin['type'] as String;
      if (type == 'win')       await WinsService.instance.deleteWin(id);
      if (type == 'daily_win') await WinsService.instance.deleteDailyWin(id);
      await _loadUserWins();
      if (mounted && allWins.isEmpty) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $error',
                style: WDDLDesignSystem.body.copyWith(color: Colors.white)),
            backgroundColor: WDDLDesignSystem.ink,
          ),
        );
      }
    }
  }
}